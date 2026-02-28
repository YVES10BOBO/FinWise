import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

/// Central place that knows which spending categories the user can use.
///
/// Popular "core" categories are always available across the app
/// (onboarding, add-transaction, budgets). Extra categories selected
/// in onboarding or added later are layered on top.
class CategoryProvider extends ChangeNotifier {
  /// Names of categories the user selected during onboarding.
  List<String> _userCategories = [];

  /// Free‑text custom category labels the user added later.
  List<String> _customCategories = [];

  bool _isLoading = false;

  /// Core categories that should always be visible as options,
  /// even if the user did not explicitly select them in onboarding.
  ///
  /// These are the most common day‑to‑day spending areas.
  static const List<Category> _coreExpenseCategories = [
    Category.food,
    Category.transport,
    Category.rent,
    Category.utilities,
    Category.entertainment,
    Category.shopping,
    Category.health,
    Category.education,
    Category.debt,
  ];

  List<String> get userCategories => _userCategories;
  List<String> get customCategories => _customCategories;

  /// All category *names* coming from onboarding + custom additions.
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

      // Load user categories from questionnaire (may include some synonyms).
      final savedCategories = prefs.getStringList('user_categories') ?? [];
      _userCategories = savedCategories;

      // Load custom categories the user added from the dashboard.
      final savedCustom = prefs.getStringList('custom_categories') ?? [];
      _customCategories = savedCustom;
    } catch (_) {
      // If anything goes wrong, fall back to a sensible default set.
      _userCategories = const [
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

    // Avoid duplicates between user + custom lists.
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
    } catch (_) {
      // Error saving custom categories - data will be lost on app restart
    }
  }

  /// Map a human‑readable name (from onboarding or custom input)
  /// to one of the built‑in Category enum values.
  ///
  /// This lets onboarding offer friendly names like "Electricity"
  /// while the rest of the app still uses `Category.utilities`.
  Category? getCategoryFromName(String name) {
    final lower = name.trim().toLowerCase();

    // Synonyms for utilities / bills
    if (lower == 'electricity' ||
        lower == 'power' ||
        lower == 'bills' ||
        lower == 'bill') {
      return Category.utilities;
    }

    // Synonym for water
    if (lower == 'water') {
      return Category.water;
    }

    // Health
    if (lower == 'health' ||
        lower == 'hospital' ||
        lower == 'clinic') {
      return Category.health;
    }

    // Medicine / Pharmacy
    if (lower == 'medicine' ||
        lower == 'pharmacy' ||
        lower == 'medication' ||
        lower == 'drugs' ||
        lower == 'prescription') {
      return Category.medicine;
    }

    // Alcohol & Drinks
    if (lower == 'alcohol' ||
        lower == 'drinks' ||
        lower == 'beer' ||
        lower == 'wine' ||
        lower == 'bar' ||
        lower == 'liquor') {
      return Category.alcohol;
    }

    // Tobacco / Smoking
    if (lower == 'tobacco' ||
        lower == 'cigarettes' ||
        lower == 'smoking' ||
        lower == 'cigar') {
      return Category.tobacco;
    }

    // Education / school
    if (lower == 'school' ||
        lower == 'education' ||
        lower == 'tuition' ||
        lower == 'university' ||
        lower == 'college') {
      return Category.education;
    }

    // Debt / loans
    if (lower == 'debt' ||
        lower == 'loan' ||
        lower == 'loans' ||
        lower == 'credit') {
      return Category.debt;
    }

    // Business / side hustle
    if (lower == 'business' ||
        lower == 'side hustle' ||
        lower == 'stock' ||
        lower == 'inventory') {
      return Category.business;
    }

    // Giving / church / charity
    if (lower == 'giving' ||
        lower == 'church' ||
        lower == 'tithe' ||
        lower == 'offering' ||
        lower == 'donation' ||
        lower == 'charity') {
      return Category.giving;
    }

    // Personal care
    if (lower == 'personal' ||
        lower == 'salon' ||
        lower == 'beauty' ||
        lower == 'hair' ||
        lower == 'makeup') {
      return Category.personal;
    }

    // Family support
    if (lower == 'family' ||
        lower == 'parents' ||
        lower == 'relatives' ||
        lower == 'support') {
      return Category.family;
    }

    // Try direct match on the enum display name.
    for (final cat in Category.values) {
      if (cat.name.toLowerCase() == lower) {
        return cat;
      }
    }

    // If we can't map it cleanly, treat it as shopping by default.
    return Category.shopping;
  }

  /// Get all available expense categories (excluding income and savings)
  /// that should be offered in the Add Transaction dialog and used
  /// by budgets/charts.
  ///
  /// Logic:
  /// - Always include a small set of "core" categories for everyone.
  /// - Add any extra categories the user selected or created.
  List<Category> getAvailableExpenseCategories() {
    final categories = <Category>{};

    // 1) Always‑on core categories (Food, Transport, Rent, Utilities, etc.)
    for (final core in _coreExpenseCategories) {
      categories.add(core);
    }

    // 2) Any categories coming from onboarding / custom names.
    for (final catName in allCategories) {
      final category = getCategoryFromName(catName);
      if (category != null &&
          category != Category.income &&
          category != Category.savings) {
        categories.add(category);
      }
    }

    // 3) As an extra safety net, if somehow still empty, fall back to defaults.
    if (categories.isEmpty) {
      categories.addAll(<Category>[
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
      ]);
    }

    return categories.toList();
  }

  // Check if a category name is custom (not matching any enum category)
  bool isCustomCategory(String name) {
    final lower = name.toLowerCase();
    final matchesEnum =
        Category.values.any((cat) => cat.name.toLowerCase() == lower);
    return _customCategories.contains(name) && !matchesEnum;
  }
}
