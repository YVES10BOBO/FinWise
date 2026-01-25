import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/goal.dart';

class GoalProvider with ChangeNotifier {
  List<Goal> _goals = [];
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  GoalProvider() {
    _loadGoals();
  }

  // Load goals from local storage
  Future<void> _loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = prefs.getString('goals');
      
      if (goalsJson != null) {
        final List<dynamic> decoded = json.decode(goalsJson);
        _goals = decoded.map((json) => Goal.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save goals to local storage
  Future<void> _saveGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsJson = json.encode(
        _goals.map((g) => g.toJson()).toList(),
      );
      await prefs.setString('goals', goalsJson);
    } catch (e) {
      print('Error saving goals: $e');
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
