import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:async';
import '../models/goal.dart';
import '../models/transaction.dart';
import '../services/firestore_goal_service.dart';

class GoalProvider with ChangeNotifier {
  List<Goal> _goals = [];
  bool _isLoading = false;
  StreamSubscription<List<Goal>>? _firestoreSubscription;
  bool _hasMergedLocalIntoFirestore = false;
  final FirestoreGoalService _firestore = FirestoreGoalService();

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  /// Goals still being saved for (purchased ones no longer reserve money).
  List<Goal> get activeGoals =>
      _goals.where((g) => g.status == GoalStatus.active).toList();

  List<Goal> get purchasedGoals =>
      _goals.where((g) => g.status == GoalStatus.purchased).toList();

  /// Goals that have reached their target but haven't been bought yet.
  List<Goal> get readyToPurchase =>
      activeGoals.where((g) => g.isCompleted).toList();

  /// Total money currently reserved across ACTIVE goals (the "reserved pot").
  /// Money you still own but have committed to goals, so it's kept out of
  /// your available total — never counted as income or spending.
  double get totalReserved =>
      activeGoals.fold<double>(0, (sum, g) => sum + g.currentAmount);

  /// Reserved money broken down by the account it was reserved from, so each
  /// account can show Balance / Reserved / Available.
  Map<AccountType, double> get reservedByAccount {
    final totals = <AccountType, double>{
      AccountType.cash: 0,
      AccountType.mobileMoney: 0,
      AccountType.bank: 0,
    };
    for (final goal in activeGoals) {
      goal.reservedByAccount.forEach((account, amount) {
        totals[account] = (totals[account] ?? 0) + amount;
      });
    }
    return totals;
  }

  double reservedFor(AccountType account) => reservedByAccount[account] ?? 0;

  /// Reserve money from a specific account for a goal.
  void addContribution(
    String goalId, {
    required double amount,
    required AccountType account,
    String note = '',
  }) {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index == -1 || amount <= 0) return;

    final contribution = GoalContribution(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      date: DateTime.now(),
      account: account,
      note: note,
    );

    _persist(index, [..._goals[index].contributions, contribution]);
  }

  /// Return part of a goal's reserved money to the available balance.
  /// Releases are taken from the accounts holding the most first, so each
  /// account's reserved figure stays accurate.
  void releaseAmount(
    String goalId, {
    required double amount,
    String note = '',
  }) {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index == -1 || amount <= 0) return;

    final goal = _goals[index];
    var remaining = amount > goal.currentAmount ? goal.currentAmount : amount;
    if (remaining <= 0) return;

    final byAccount = goal.reservedByAccount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final releases = <GoalContribution>[];
    final stamp = DateTime.now().millisecondsSinceEpoch;
    var i = 0;
    for (final entry in byAccount) {
      if (remaining <= 0) break;
      final take = remaining < entry.value ? remaining : entry.value;
      releases.add(GoalContribution(
        id: 'r_${stamp}_${i++}',
        amount: take,
        date: DateTime.now(),
        account: entry.key,
        note: note,
        isRelease: true,
      ));
      remaining -= take;
    }

    _persist(index, [...goal.contributions, ...releases]);
  }

  /// Return everything reserved for this goal to the available balance.
  void releaseAll(String goalId, {String note = ''}) {
    final goal = _goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => throw StateError('Goal not found'),
    );
    releaseAmount(goalId, amount: goal.currentAmount, note: note);
  }

  /// Mark a goal as bought. The goal record is KEPT (history/achievement);
  /// it simply stops reserving money, because the reserved amount has now
  /// become a real expense recorded by the caller.
  void markPurchased(
    String goalId, {
    required double actualAmount,
    String? transactionId,
  }) {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index == -1) return;

    final goal = _goals[index];
    final updated = goal.copyWith(
      status: GoalStatus.purchased,
      purchasedAmount: actualAmount,
      purchasedDate: DateTime.now(),
      purchaseTransactionId: transactionId,
    );

    _goals[index] = updated;
    _saveGoals();
    notifyListeners();
    _syncGoal(updated, 'purchase');
  }

  void _persist(int index, List<GoalContribution> contributions) {
    final updated = _goals[index].copyWith(contributions: contributions);
    _goals[index] = updated;
    _saveGoals();
    notifyListeners();
    _syncGoal(updated, 'contribution');
  }

  void _syncGoal(Goal goal, String label) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestore.upsertGoal(user.uid, goal).catchError((e) {
        if (kDebugMode) {
          debugPrint('Firestore goal $label save failed: $e');
        }
      });
    }
  }

  GoalProvider() {
    _configureForCurrentUser();
    FirebaseAuth.instance.authStateChanges().listen((_) {
      _configureForCurrentUser();
    });
  }

  String _storageKey() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'goals_guest';
    return 'goals_${user.uid}';
  }

  Future<List<Goal>> _loadGoalsFromPrefs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getString(key);
      if (goalsJson == null) return [];

      final List<dynamic> decoded = json.decode(goalsJson);
      final goals = decoded.map((json) => Goal.fromJson(json)).toList();
      goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return goals;
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveGoalsToPrefs(String key, List<Goal> goals) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = json.encode(
        goals.map((g) => g.toJson()).toList(),
      );
      await prefs.setString(key, goalsJson);
    } catch (e) {
      // Ignore caching failures
    }
  }

  // Load goals from local storage (per user)
  Future<void> _loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final key = _storageKey();
      _goals = await _loadGoalsFromPrefs(key);
    } catch (e) {
      // Error loading goals - will use empty list
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save goals to local storage (per user)
  Future<void> _saveGoals() async {
    final key = _storageKey();
    await _saveGoalsToPrefs(key, _goals);
  }

  Future<void> _configureForCurrentUser() async {
    await _firestoreSubscription?.cancel();
    _firestoreSubscription = null;
    _hasMergedLocalIntoFirestore = false;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await _loadGoals();
      return;
    }

    final userKey = 'goals_${user.uid}';
    final local = await _loadGoalsFromPrefs(userKey);
    _goals = local;
    _isLoading = true;
    notifyListeners();

    _firestoreSubscription = _firestore.watchGoals(user.uid).listen(
      (remoteGoals) async {
        if (!_hasMergedLocalIntoFirestore) {
          _hasMergedLocalIntoFirestore = true;
          try {
            final remoteIds = remoteGoals.map((g) => g.id).toSet();
            for (final g in local) {
              if (!remoteIds.contains(g.id)) {
                await _firestore.upsertGoal(user.uid, g);
              }
            }
          } catch (e) {
            // Ignore migration errors; local cache remains
          }
        }

        _goals = remoteGoals;
        _goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _isLoading = false;
        notifyListeners();

        await _saveGoalsToPrefs(userKey, _goals);
      },
      onError: (_) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void addGoal(Goal goal) {
    _goals.add(goal);
    _goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _saveGoals();
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestore.upsertGoal(user.uid, goal).catchError((e) {
        if (kDebugMode) {
          debugPrint('Firestore goal save failed: $e');
        }
      });
    }
  }

  void updateGoal(Goal goal) {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      _goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _saveGoals();
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _firestore.upsertGoal(user.uid, goal).catchError((e) {
          if (kDebugMode) {
            debugPrint('Firestore goal update failed: $e');
          }
        });
      }
    }
  }

  /// Delete every goal at once. Clears the list first (so the UI updates and
  /// reserved money is released immediately), then deletes from the cloud
  /// using a snapshot of ids — never iterating the live list while modifying
  /// it, which throws "Concurrent modification" and leaves goals behind.
  Future<void> clearAllGoals() async {
    final ids = _goals.map((g) => g.id).toList(growable: false);

    _goals = [];
    await _saveGoals();
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      for (final id in ids) {
        _firestore.deleteGoal(user.uid, id).catchError((e) {
          if (kDebugMode) debugPrint('Firestore goal delete failed: $e');
        });
      }
    }
  }

  void removeGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    _saveGoals();
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _firestore.deleteGoal(user.uid, id).catchError((e) {
        if (kDebugMode) {
          debugPrint('Firestore goal delete failed: $e');
        }
      });
    }
  }

  /// Set a goal's reserved total directly by adding a balancing
  /// contribution/release. Kept for compatibility; prefer [addContribution]
  /// and [releaseAmount], which record the account the money came from.
  void updateGoalProgress(String id, double amount,
      {AccountType account = AccountType.cash}) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;

    final current = _goals[index].currentAmount;
    final delta = amount - current;
    if (delta == 0) return;

    if (delta > 0) {
      addContribution(id, amount: delta, account: account);
    } else {
      releaseAmount(id, amount: -delta);
    }
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
