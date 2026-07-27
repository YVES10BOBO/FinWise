import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../main.dart';
// transaction_provider / transaction models are no longer imported here:
// onboarding used to create a fake "Onboarding income" transaction, which
// inflated the balance with money the user didn't have. Income is now stored
// as a planning target only (see IncomeProvider).
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_user_profile_service.dart';
import '../../providers/currency_provider.dart';
import '../../models/currency.dart';
import '../../services/sms_listener_service.dart';

class FinancialQuestionnaireScreen extends StatefulWidget {
  const FinancialQuestionnaireScreen({super.key});

  @override
  State<FinancialQuestionnaireScreen> createState() =>
      _FinancialQuestionnaireScreenState();
}

class _FinancialQuestionnaireScreenState
    extends State<FinancialQuestionnaireScreen> {
  int _currentStep = 0;
  
  // Step 1: About you
  final _nameController = TextEditingController();
  final _incomeController = TextEditingController();
  String _incomeFrequency = 'Monthly';
  
  // Step 2: Spending style
  String _spendingStyle = 'Balanced';
  
  // Step 3: Categories
  final Set<String> _selectedCategories = {};
  final TextEditingController _customCategoryController = TextEditingController();
  final List<String> _customCategories = [];

  // Step 4: Auto-tracking (the differentiator)
  bool _autoTrackEnabled = false;
  bool _enablingAutoTrack = false;

  // Onboarding is now a single essential step. Spending-style, categories,
  // and the auto-track intro were removed to reduce friction — auto-tracking
  // turns on by itself on the home screen, and categories/style are better
  // set inside the app once real transactions exist.
  static const int _lastStep = 0;
  
  final List<String> _defaultCategories = [
    'Transport',
    'Food',
    'Entertainment',
    'Vacation',
    'Clothes',
    'Electricity',
    'Water',
    'Rent',
    'Shoes',
    'Medicine',
    'Alcohol & Drinks',
    'Tobacco',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _incomeController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final name = prefs.getString('user_name');
      final income = prefs.getString('user_income');
      final incomeFreq = prefs.getString('income_frequency');
      final spendingStyle = prefs.getString('spending_style');
      final categories = prefs.getStringList('user_categories');

      if (!mounted) return;

      setState(() {
        if (name != null && name.trim().isNotEmpty) {
          _nameController.text = name;
        }
        if (income != null && income.trim().isNotEmpty) {
          _incomeController.text = income;
        }
        if (incomeFreq != null &&
            ['Daily', 'Weekly', 'Monthly', 'Yearly'].contains(incomeFreq)) {
          _incomeFrequency = incomeFreq;
        }

        if (spendingStyle != null &&
            ['Saver', 'Balanced', 'Spender', 'Overspender'].contains(spendingStyle)) {
          _spendingStyle = spendingStyle;
        }

        _selectedCategories.clear();
        _customCategories.clear();
        if (categories != null) {
          for (final c in categories) {
            if (_defaultCategories.contains(c)) {
              _selectedCategories.add(c);
            } else if (c.trim().isNotEmpty && !_customCategories.contains(c)) {
              _customCategories.add(c);
            }
          }
        }
      });
    } catch (_) {
      // Safe to ignore - onboarding can start empty.
    }
  }

  Future<void> _saveQuestionnaire() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save name
    await prefs.setString('user_name', _nameController.text.trim());

    // Save income as a planning TARGET only — never as a fake transaction.
    // Your real balance comes from actual transactions; this figure is just
    // used for analysis (savings rate, "vs your usual income"). It's optional
    // here and editable anytime in Settings.
    final incomeText = _incomeController.text.trim();
    if (incomeText.isNotEmpty && double.tryParse(incomeText) != null) {
      await prefs.setString('user_income', incomeText);
      await prefs.setString('income_frequency', _incomeFrequency);
    }

    // Save spending style (profile preference for future tips)
    await prefs.setString('spending_style', _spendingStyle);

    // Save categories
    final allCategories = [..._selectedCategories, ..._customCategories];
    await prefs.setStringList('user_categories', allCategories);

    // Mark questionnaire and onboarding as complete
    await prefs.setBool('questionnaire_complete', true);
    await prefs.setBool('onboarding_complete', true);

    // Sync profile to Firestore (name/income/categories) for the logged-in user
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final name = _nameController.text.trim();
        final income = double.tryParse(_incomeController.text.trim());
        final allCategories = [..._selectedCategories, ..._customCategories];

        await FirestoreUserProfileService().updateProfile(
          uid: user.uid,
          email: user.email,
          name: name.isEmpty ? null : name,
          income: income,
          incomeFrequency: _incomeFrequency,
          spendingStyle: _spendingStyle,
          categories: allCategories,
          onboardingComplete: true,
        );
      }
    } catch (_) {
      // Ignore profile sync failures; onboarding can still complete.
    }
    
    if (mounted) {
      // Replace the current onboarding route with the main app,
      // but keep the root _InitialScreen route alive so it can
      // respond to future auth state changes (logout/login).
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    }
  }

  void _addCustomCategory() {
    final category = _customCategoryController.text.trim();
    if (category.isNotEmpty && !_customCategories.contains(category)) {
      setState(() {
        _customCategories.add(category);
        _customCategoryController.clear();
      });
    }
  }

  void _removeCustomCategory(String category) {
    setState(() {
      _customCategories.remove(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up FinWise'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildStepContent(),
                ),
              ),
              // Navigation Buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _currentStep--;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppTheme.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _canProceed() ? _handleNext : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildAboutYouStep();
      case 1:
        return _buildSpendingStep();
      case 2:
        return _buildCategoriesStep();
      case 3:
        return _buildAutoTrackStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildAboutYouStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Let\'s set up your FinWise',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us a bit about you. You can change this anytime.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Why we need this:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Your name personalizes your dashboard\n'
                '• Your currency is used across the whole app\n'
                '• Add an income target later in Settings (optional)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Your Name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            textCapitalization: TextCapitalization.words,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<AppCurrency>(
            value: context.watch<CurrencyProvider>().currency,
            decoration: InputDecoration(
              labelText: 'Currency',
              prefixIcon: const Icon(Icons.language),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: AppCurrency.values
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text('${c.symbol}  ${c.label} (${c.code})'),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<CurrencyProvider>().setCurrency(value);
              }
            },
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'That\'s all we need to get started. You can set an income target and more anytime in Settings.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What\'s your spending style?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose what fits you best. This helps FinWise suggest realistic budgets.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'How this helps:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Spending style: Helps FinWise give personalized budget advice later\n'
                '• Real spending: We only use your actual transactions to calculate charts and budgets',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStyleChip(
              label: 'Saver',
              subtitle: 'I save a lot',
              icon: Icons.savings_outlined,
            ),
            _buildStyleChip(
              label: 'Balanced',
              subtitle: 'I\'m balanced',
              icon: Icons.balance_outlined,
            ),
            _buildStyleChip(
              label: 'Spender',
              subtitle: 'I spend most income',
              icon: Icons.shopping_bag_outlined,
            ),
            _buildStyleChip(
              label: 'Overspender',
              subtitle: 'I often overspend',
              icon: Icons.warning_amber_outlined,
            ),
          ],
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'FinWise will track your real spending automatically from the transactions you add on the dashboard.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStyleChip({
    required String label,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _spendingStyle == label;
    return ChoiceChip(
      labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : AppTheme.textPrimary,
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.9)
                      : AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _spendingStyle = label;
        });
      },
      selectedColor: AppTheme.primaryColor,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
        width: isSelected ? 2 : 1,
      ),
      showCheckmark: false,
    );
  }

  Widget _buildCategoriesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What do you spend on?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select all categories that apply to your spending',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'FinWise uses these 23 main categories on every page so your budgets and insights stay clear and simple.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Why categories matter:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Track spending by category (Food, Transport, etc.)\n'
                '• Get insights like "You spent 30% on Food this month"\n'
                '• Set budgets per category and get alerts\n'
                '• You can add more categories anytime',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Default Categories
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _defaultCategories.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
              selectedColor: AppTheme.primaryColor,
              checkmarkColor: Colors.white,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        // Custom Categories
        if (_customCategories.isNotEmpty) ...[
          const Text(
            'Your Custom Categories:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _customCategories.map((category) {
              return Chip(
                label: Text(
                  category,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                deleteIcon: const Icon(Icons.close, size: 18, color: AppTheme.textSecondary),
                onDeleted: () => _removeCustomCategory(category),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey[300]!),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
        // Add Custom Category
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customCategoryController,
                  decoration: InputDecoration(
                    hintText: 'Add custom category...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _addCustomCategory(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addCustomCategory,
                icon: const Icon(Icons.add_circle),
                color: AppTheme.primaryColor,
                iconSize: 32,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You can always add or remove categories later in settings.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        // Only the name is required now. Income moved to Settings as an
        // optional, editable target.
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return true; // spending step is optional (style has a default)
      case 2:
        return true; // categories are optional — no forced taps
      case 3:
        return true; // auto-track is optional (can enable later in Settings)
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentStep < _lastStep) {
      setState(() {
        _currentStep++;
      });
    } else {
      _saveQuestionnaire();
    }
  }

  Future<void> _enableAutoTrack() async {
    setState(() => _enablingAutoTrack = true);
    final granted = await SmsListenerService.requestPermissionAndEnable();
    if (!mounted) return;
    setState(() {
      _enablingAutoTrack = false;
      _autoTrackEnabled = granted;
    });
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Permission not granted. You can turn on auto-tracking later in Settings.',
          ),
        ),
      );
    }
  }

  Widget _buildAutoTrackStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Track money automatically',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This is what makes FinWise different. It reads your Mobile Money '
          'SMS and records every payment and deposit for you — no manual '
          'typing.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildAutoTrackFeature(
                Icons.bolt,
                'Instant',
                'New MoMo transactions appear on your balance within seconds.',
              ),
              const SizedBox(height: 16),
              _buildAutoTrackFeature(
                Icons.lock_outline,
                'Private',
                'Everything stays on your phone. Nothing is uploaded or shared.',
              ),
              const SizedBox(height: 16),
              _buildAutoTrackFeature(
                Icons.auto_awesome,
                'Automatic',
                'Amount, direction and category are filled in for you.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_autoTrackEnabled)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Auto-tracking is on. Tap Complete to finish.',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _enablingAutoTrack ? null : _enableAutoTrack,
              icon: _enablingAutoTrack
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    )
                  : const Icon(Icons.sms_outlined),
              label: Text(_enablingAutoTrack
                  ? 'Requesting permission…'
                  : 'Enable auto-tracking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Text(
          _autoTrackEnabled
              ? 'You can turn this off anytime in Settings.'
              : 'Optional — you can skip and turn it on later in Settings.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoTrackFeature(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
