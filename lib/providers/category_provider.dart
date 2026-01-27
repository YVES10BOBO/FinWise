import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class CategoryProvider extends ChangeNotifier {
  List<String> _userCategories = [];
  List<String> _customCategories = [];
  bool _isLoading = false;

  List<String> get userCategories => _userCategories;
  List<String> get customCategories => _customCategories;
  List<String> get allCategories => [..._userCategories, ..._customCategories];
  bool get isLoading => _isLoading;

  CategoryProvider() {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load user categories from questionnaire
      final savedCategories = prefs.getStringList('user_categories') ?? [];
      _userCategories = savedCategories;
      
      // Load custom categories
      final savedCustom = prefs.getStringList('custom_categories') ?? [];
      _customCategories = savedCustom;
    } catch (e) {
      // Error loading categories - use default ones
      _userCategories = [
        'Food',
        'Transport',
        'Entertainment',
        'Utilities',
        'Rent',
        'Shopping',
      ];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCustomCategory(String category) async {
    if (category.trim().isEmpty) return;
    
    final trimmedCategory = category.trim();
    
    // Check if category already exists
    if (_customCategories.contains(trimmedCategory) ||
        _userCategories.contains(trimmedCategory)) {
      return;
    }

    _customCategories.add(trimmedCategory);
    await _saveCustomCategories();
    notifyListeners();
  }

  Future<void> removeCustomCategory(String category) async {
    if (_customCategories.contains(category)) {
      _customCategories.remove(category);
      await _saveCustomCategories();
      notifyListeners();
    }
  }

  Future<void> _saveCustomCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('custom_categories', _customCategories);
    } catch (e) {
      // Error saving custom categories - data will be lost on app restart
    }
  }

  // Get Category enum from string name
  Category? getCategoryFromName(String name) {
    try {
      return Category.values.firstWhere(
        (cat) => cat.name.toLowerCase() == name.toLowerCase(),
        orElse: () => Category.food, // Default fallback
      );
    } catch (e) {
      return Category.food;
    }
  }

  // Get all available expense categories (excluding income and savings)
  List<Category> getAvailableExpenseCategories() {
    final categories = <Category>[];
    
    // Add categories from user selection
    for (final catName in allCategories) {
      final category = getCategoryFromName(catName);
      if (category != null && 
          category != Category.income && 
          category != Category.savings) {
        if (!categories.contains(category)) {
          categories.add(category);
        }
      }
    }
    
    // If no categories, return default expense categories
    if (categories.isEmpty) {
      return [
        Category.food,
        Category.transport,
        Category.entertainment,
        Category.utilities,
        Category.rent,
        Category.shopping,
        Category.vacation,
        Category.clothes,
        Category.water,
        Category.shoes,
      ];
    }
    
    return categories;
  }

  // Check if a category name is custom (not in enum)
  bool isCustomCategory(String name) {
    return _customCategories.contains(name) &&
        !Category.values.any((cat) => cat.name.toLowerCase() == name.toLowerCase());
  }
}
