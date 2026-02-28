import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:async';
import '../models/goal.dart';
import '../services/firestore_goal_service.dart';

class GoalProvider with ChangeNotifier {
  List<Goal> _goals = [];
  bool _isLoading = false;
  StreamSubscription<List<Goal>>? _firestoreSubscription;
  bool _hasMergedLocalIntoFirestore = false;
  final FirestoreGoalService _firestore = FirestoreGoalService();

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

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

  void updateGoalProgress(String id, double amount) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(currentAmount: amount);
      _saveGoals();
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _firestore.upsertGoal(user.uid, _goals[index]).catchError((e) {
          if (kDebugMode) {
            debugPrint('Firestore goal progress save failed: $e');
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
