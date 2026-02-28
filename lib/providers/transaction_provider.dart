import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:async';
import '../models/transaction.dart' hide Category;
import '../models/transaction.dart' as models show Category;
import '../services/firestore_transaction_service.dart';

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

  /// Computed balances per account (Cash / Mobile Money / Bank)
  Map<AccountType, double> get accountBalances {
    final Map<AccountType, double> balances = {
      AccountType.cash: 0.0,
      AccountType.mobileMoney: 0.0,
      AccountType.bank: 0.0,
    };

    for (final t in _transactions) {
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

  void addTransaction(Transaction transaction) {
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
      if (transaction.type == TransactionType.expense) {
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
