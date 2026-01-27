import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../models/goal.dart';

class GoalProvider with ChangeNotifier {
  List<Goal> _goals = [];
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  GoalProvider() {
    _loadGoals();
    // Reload goals whenever the authenticated user changes
    FirebaseAuth.instance.authStateChanges().listen((_) {
      _loadGoals();
    });
  }

  String _storageKey() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'goals_guest';
    return 'goals_${user.uid}';
  }

  // Load goals from local storage (per user)
  Future<void> _loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _storageKey();
      final goalsJson = prefs.getString(key);
      
      if (goalsJson != null) {
        final List<dynamic> decoded = json.decode(goalsJson);
        _goals = decoded.map((json) => Goal.fromJson(json)).toList();
      }
    } catch (e) {
      // Error loading goals - will use empty list
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save goals to local storage (per user)
  Future<void> _saveGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _storageKey();
      final goalsJson = json.encode(
        _goals.map((g) => g.toJson()).toList(),
      );
      await prefs.setString(key, goalsJson);
    } catch (e) {
      // Error saving goals - data will be lost on app restart
    }
  }

  void addGoal(Goal goal) {
    _goals.add(goal);
    _saveGoals();
    notifyListeners();
  }

  void updateGoal(Goal goal) {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      _saveGoals();
      notifyListeners();
    }
  }

  void removeGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    _saveGoals();
    notifyListeners();
  }

  void updateGoalProgress(String id, double amount) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      _goals[index] = _goals[index].copyWith(currentAmount: amount);
      _saveGoals();
      notifyListeners();
    }
  }
}
