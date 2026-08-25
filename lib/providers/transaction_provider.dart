import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:async';
import '../models/transaction.dart' hide Category;
import '../models/transaction.dart' as models show Category;
import '../services/firestore_transaction_service.dart';

/// Prefix for per-item SharedPreferences keys the SMS background isolate
/// writes detected transactions to. Each detected SMS gets its OWN key
/// (`detected_sms_tx_<id>`), so several SMS arriving at once can never
/// overwrite each other — unlike editing one shared list from multiple
/// background isolates, which loses all but the last write.
const String kDetectedSmsTxPrefix = 'detected_sms_tx_';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  StreamSubscription<List<Transaction>>? _firestoreSubscription;
  bool _hasMergedLocalIntoFirestore = false;
  final FirestoreTransactionService _firestore = FirestoreTransactionService();

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  TransactionProvider() {
    _configureForCurrentUser();
    FirebaseAuth.instance.authStateChanges().listen((_) {
      _configureForCurrentUser();
    });
  }

  double get totalIncome {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpenses;

  /// Money set aside into savings (goal contributions). It leaves the
  /// spendable balance, but it is NOT consumption — so all analysis (savings
  /// rate, top categories, spending trend) treats it separately from spending.
  double get totalSetAside {
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.category == models.Category.savings)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Real consumption = expenses excluding money set aside for savings goals.
  double get totalConsumption => totalExpenses - totalSetAside;

  /// Computed balances per account (Cash / Mobile Money / Bank)
  Map<AccountType, double> get accountBalances {
    final Map<AccountType, double> balances = {
      AccountType.cash: 0.0,
      AccountType.mobileMoney: 0.0,
      AccountType.bank: 0.0,
    };

    for (final t in _transactions) {
      // Transfers move money between the user's own accounts. We record one
      // entry per transfer, which can't express "left A, arrived at B", so
      // treating it as a withdrawal would wrongly shrink the total balance.
      // It is therefore neutral: the total stays correct.
      if (t.type == TransactionType.transfer) continue;

      final sign = t.type == TransactionType.income ? 1.0 : -1.0;
      balances[t.account] = (balances[t.account] ?? 0.0) + sign * t.amount;
    }

    return balances;
  }

  /// Spending totals grouped by reason (necessity, enjoyment, etc.)
  Map<SpendingReason, double> get spendingByReason {
    final Map<SpendingReason, double> totals = {};
    for (final t in _transactions) {
      if (t.type == TransactionType.expense && t.reason != null) {
        totals[t.reason!] = (totals[t.reason!] ?? 0.0) + t.amount;
      }
    }
    return totals;
  }

  String _storageKey() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'transactions_guest';
    return 'transactions_${user.uid}';
  }

  Future<List<Transaction>> _loadTransactionsFromPrefs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getString(key);

      if (transactionsJson == null) return [];

      final List<dynamic> decoded = json.decode(transactionsJson);
      final transactions =
          decoded.map((json) => Transaction.fromJson(json)).toList();
      transactions.sort((a, b) => b.date.compareTo(a.date));
      return transactions;
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveTransactionsToPrefs(String key, List<Transaction> txs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = json.encode(
        txs.map((t) => t.toJson()).toList(),
      );
      await prefs.setString(key, transactionsJson);
    } catch (e) {
      // Ignore caching failures
    }
  }

  // Load transactions from local storage (per user)
  Future<void> _loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final key = _storageKey();
      _transactions = await _loadTransactionsFromPrefs(key);
    } catch (e) {
      // Error loading transactions - will use empty list
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save transactions to local storage (per user)
  Future<void> _saveTransactions() async {
    final key = _storageKey();
    await _saveTransactionsToPrefs(key, _transactions);
  }

  Future<void> _configureForCurrentUser() async {
    // Stop any previous Firestore stream when switching users / logging out
    await _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
    _hasMergedLocalIntoFirestore = false;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Guest mode: local only
      await _loadTransactions();
      return;
    }

    // Show cached local transactions immediately (fast startup)
    final userKey = 'transactions_${user.uid}';
    final local = await _loadTransactionsFromPrefs(userKey);
    _transactions = local;
    _isLoading = true;
    notifyListeners();

    // Start Firestore sync (source of truth when logged in)
    _firestoreSubscription = _firestore
        .watchTransactions(user.uid)
        .listen((remoteTransactions) async {
      // One-time merge: upload any local-only items to Firestore
      if (!_hasMergedLocalIntoFirestore) {
        _hasMergedLocalIntoFirestore = true;
        try {
          final remoteIds = remoteTransactions.map((t) => t.id).toSet();
          for (final tx in local) {
            if (!remoteIds.contains(tx.id)) {
              await _firestore.upsertTransaction(user.uid, tx);
            }
          }
        } catch (e) {
          // Ignore migration errors; user still has local cache
        }
      }

      _transactions = remoteTransactions;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      _isLoading = false;
      notifyListeners();

      // Keep local cache up-to-date for offline/fast startup
      await _saveTransactionsToPrefs(userKey, _transactions);
    }, onError: (error) async {
      // If Firestore fails (e.g., permission denied on logout), silently handle it
      // This is expected when user logs out - don't show errors
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Drain any transactions the SMS background isolate detected while the
  /// app was off-screen (or while another app was in front) into the live
  /// list. Each detected SMS is stored under its own `detected_sms_tx_<id>`
  /// key, so this reads every such key, adds the ones we don't already have,
  /// then deletes the key. Called every couple of seconds while the app is
  /// on screen and on resume, so detections show up without a reopen — and
  /// because the keys are per-item, several SMS at once all come through.
  bool _isDraining = false;

  Future<void> refreshFromCache() async {
    // Serialize: two concurrent drains could each read a slot before the
    // other removes it and both insert it → a duplicate. This guard prevents
    // that (the 3s timer, app-resume, and the SMS callback can all call in).
    if (_isDraining) return;
    _isDraining = true;
    try {
      await _refreshFromCacheInner();
    } finally {
      _isDraining = false;
    }
  }

  Future<void> _refreshFromCacheInner() async {
    final prefs = await SharedPreferences.getInstance();
    // CRITICAL: the SMS background isolate writes new transactions to disk,
    // but this (main) isolate holds an in-memory snapshot of preferences and
    // won't see those writes until it re-reads from disk. Without this
    // reload, detections only appear after the app is restarted. This is the
    // fix for "I have to close and reopen the app to see the transaction".
    await prefs.reload();
    final keys = prefs
        .getKeys()
        .where((k) => k.startsWith(kDetectedSmsTxPrefix))
        .toList();

    final existingIds = _transactions.map((t) => t.id).toSet();
    final user = FirebaseAuth.instance.currentUser;
    bool changed = false;

    for (final k in keys) {
      final raw = prefs.getString(k);
      await prefs.remove(k);
      if (raw == null) continue;
      try {
        final tx = Transaction.fromJson(json.decode(raw));
        if (existingIds.contains(tx.id)) continue;
        _transactions.insert(0, tx);
        existingIds.add(tx.id);
        changed = true;
        // Sync to the cloud so it reaches other devices (idempotent by id).
        if (user != null) {
          _firestore.upsertTransaction(user.uid, tx);
        }
      } catch (_) {
        // Skip anything unreadable rather than blocking the rest.
      }
    }

    // Clean up any duplicates left by earlier builds (which used a
    // time-based id, so the same SMS could be stored under two ids).
    final removedDupes = _dedupeAutoDetected();

    if (changed || removedDupes) {
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      await _saveTransactions();
      notifyListeners();
    }
  }

  /// Collapse auto-detected transactions that are really the same MoMo
  /// message recorded twice. Keeps the first occurrence and deletes the rest
  /// (including from Firestore). Only touches auto-detected entries, never
  /// manual ones. Returns true if anything was removed.
  bool _dedupeAutoDetected() {
    final seen = <String>{};
    final kept = <Transaction>[];
    final removed = <Transaction>[];

    for (final t in _transactions) {
      if (t.isAutoDetected) {
        // Signature: same amount, direction, counterparty and same minute =
        // the same real transaction seen twice.
        final sig = '${t.type.name}|${t.amount}|${t.description.toLowerCase()}|'
            '${t.date.year}-${t.date.month}-${t.date.day}-${t.date.hour}-${t.date.minute}';
        if (seen.contains(sig)) {
          removed.add(t);
          continue;
        }
        seen.add(sig);
      }
      kept.add(t);
    }

    if (removed.isEmpty) return false;

    _transactions = kept;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      for (final t in removed) {
        _firestore.deleteTransaction(user.uid, t.id);
      }
    }
    return true;
  }

  void addTransaction(Transaction transaction) {
    // Guard against inserting the same id twice (e.g. an auto-detected
    // transaction that's already present) — update in place instead.
    final existingIndex = _transactions.indexWhere((t) => t.id == transaction.id);
    if (existingIndex != -1) {
      _transactions[existingIndex] = transaction;
      _saveTransactions();
      notifyListeners();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _firestore.upsertTransaction(user.uid, transaction);
      }
      return;
    }

    _transactions.insert(0, transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    _saveTransactions();
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestore.upsertTransaction(user.uid, transaction);
    }
  }

  void updateTransaction(Transaction transaction) {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      _saveTransactions();
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _firestore.upsertTransaction(user.uid, transaction);
      }
    }
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    _saveTransactions();
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestore.deleteTransaction(user.uid, id);
    }
  }

  /// Delete every transaction at once. Clears the in-memory list first (so the
  /// UI updates immediately), then deletes each from the cloud using a
  /// SNAPSHOT of the ids — never looping over the live list while modifying
  /// it, which was causing the "Concurrent modification during iteration"
  /// crash and leaving items behind.
  Future<void> clearAllTransactions() async {
    final ids = _transactions.map((t) => t.id).toList(growable: false);

    _transactions = [];
    await _saveTransactions();
    notifyListeners();

    // Also drop any pending SMS-detected slots so they don't immediately
    // repopulate the list on the next refresh tick.
    try {
      final prefs = await SharedPreferences.getInstance();
      final slotKeys = prefs
          .getKeys()
          .where((k) => k.startsWith(kDetectedSmsTxPrefix))
          .toList();
      for (final k in slotKeys) {
        await prefs.remove(k);
      }
    } catch (_) {}

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      for (final id in ids) {
        _firestore.deleteTransaction(user.uid, id);
      }
    }
  }

  List<Transaction> getRecentTransactions(int count) {
    return _transactions.take(count).toList();
  }

  List<Transaction> getTransactionsByCategory(dynamic category) {
    return _transactions.where((t) {
      return t.category.name == category.name;
    }).toList();
  }

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<Transaction> searchTransactions(String query) {
    if (query.isEmpty) return _transactions;
    
    final lowerQuery = query.toLowerCase();
    return _transactions.where((t) {
      return t.description.toLowerCase().contains(lowerQuery) ||
          t.category.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get spending by category (returns map of category to total amount)
  Map<models.Category, double> getCategorySpending() {
    final Map<models.Category, double> spending = {};
    
    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.expense &&
          transaction.category != models.Category.savings) {
        spending[transaction.category] =
            (spending[transaction.category] ?? 0.0) + transaction.amount;
      }
    }

    return spending;
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
