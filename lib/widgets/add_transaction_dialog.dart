import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../services/categorization_service.dart';
import '../providers/category_provider.dart';
import '../providers/currency_provider.dart';

class AddTransactionDialog extends StatefulWidget {
  final Function(Transaction) onSave;
  final TransactionType? initialType;
  final Transaction? existingTransaction;

  const AddTransactionDialog({
    super.key,
    required this.onSave,
    this.initialType,
    this.existingTransaction,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType _selectedType;
  Category? _selectedCategory;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customCategoryController = TextEditingController();
  bool _showAddCategory = false;
  AccountType _selectedAccount = AccountType.mobileMoney;
  SpendingReason _selectedReason = SpendingReason.necessity;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? TransactionType.expense;
    
    if (widget.existingTransaction != null) {
      _selectedType = widget.existingTransaction!.type;
      _selectedCategory = widget.existingTransaction!.category;
      _amountController.text = widget.existingTransaction!.amount.toString();
      _descriptionController.text = widget.existingTransaction!.description;
      _selectedAccount = widget.existingTransaction!.account;
      _selectedReason =
          widget.existingTransaction!.reason ?? SpendingReason.necessity;
    } else {
      _selectedCategory = _selectedType == TransactionType.income
          ? Category.income
          : null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == TransactionType.expense && _selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final description = _descriptionController.text.isEmpty
          ? (_selectedCategory?.name ?? 'Transaction')
          : _descriptionController.text;
      
      // Use selected category or auto-categorize
      Category finalCategory;
      if (_selectedCategory != null) {
        finalCategory = _selectedCategory!;
      } else {
        finalCategory = CategorizationService.categorizeTransaction(
          description,
          double.parse(_amountController.text),
          type: _selectedType,
        );
      }
      
      final transaction = Transaction(
        id: widget.existingTransaction?.id ?? 
            DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedType,
        category: finalCategory,
        amount: double.parse(_amountController.text),
        description: description,
        date: widget.existingTransaction?.date ?? DateTime.now(),
        account: _selectedAccount,
        reason: _selectedType == TransactionType.expense ? _selectedReason : null,
      );
      widget.onSave(transaction);
      Navigator.of(context).pop();
    }
  }

  void _addCustomCategory() {
    final categoryName = _customCategoryController.text.trim();
    if (categoryName.isNotEmpty) {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      categoryProvider.addCustomCategory(categoryName);
      _customCategoryController.clear();
      setState(() {
        _showAddCategory = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category "$categoryName" added'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    // Show ALL expense categories (21 categories: all 23 minus income and savings)
    // This ensures users can select from ALL available categories, not just ones from onboarding
    final allExpenseCategories = Category.values
        .where((cat) => cat != Category.income && cat != Category.savings)
        .toList()
        ..sort((a, b) => a.name.compareTo(b.name)); // Sort alphabetically for easier finding
    final availableCategories = _selectedType == TransactionType.income
        ? [Category.income]
        : allExpenseCategories;

    final screen = MediaQuery.of(context).size;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      content: SizedBox(
        width: 420,
        // Use most of the screen height so the form has room to breathe and
        // the single scroll view has somewhere to go.
        height: screen.height * 0.75,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  widget.existingTransaction == null
                      ? 'Add Transaction'
                      : 'Edit Transaction',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                // Transaction Type
                Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        label: 'Income',
                        icon: Icons.arrow_downward_rounded,
                        isSelected: _selectedType == TransactionType.income,
                        onTap: () {
                          setState(() {
                            _selectedType = TransactionType.income;
                            _selectedCategory = Category.income;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TypeButton(
                        label: 'Expense',
                        icon: Icons.arrow_upward_rounded,
                        isSelected: _selectedType == TransactionType.expense,
                        onTap: () {
                          setState(() {
                            _selectedType = TransactionType.expense;
                            _selectedCategory = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Account selection
                const Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _AccountChip(
                      label: 'Cash',
                      icon: Icons.payments_outlined,
                      isSelected: _selectedAccount == AccountType.cash,
                      onTap: () {
                        setState(() {
                          _selectedAccount = AccountType.cash;
                        });
                      },
                    ),
                    _AccountChip(
                      label: 'Mobile Money',
                      icon: Icons.phone_iphone,
                      isSelected: _selectedAccount == AccountType.mobileMoney,
                      onTap: () {
                        setState(() {
                          _selectedAccount = AccountType.mobileMoney;
                        });
                      },
                    ),
                    _AccountChip(
                      label: 'Bank',
                      icon: Icons.account_balance,
                      isSelected: _selectedAccount == AccountType.bank,
                      onTap: () {
                        setState(() {
                          _selectedAccount = AccountType.bank;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                // Amount
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText:
                        'Amount (${context.watch<CurrencyProvider>().code})',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // Neutral icon — a dollar sign would be wrong for the 12
                    // non-dollar currencies the app supports.
                    prefixIcon:
                        const Icon(Icons.account_balance_wallet_outlined),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Category Selection (only for expenses)
                if (_selectedType == TransactionType.expense) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${availableCategories.length} categories',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Categories flow inline — NO nested scroll view. A scroller
                  // inside a scroller steals the drag gesture and makes the
                  // dialog feel stuck, so the whole form is one smooth scroll.
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableCategories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return FilterChip(
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.icon,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : null;
                          });
                        },
                        selectedColor: AppTheme.primaryColor,
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey[300]!,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Add Custom Category Button
                  if (!_showAddCategory)
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showAddCategory = true;
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text('Add Custom Category'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  // Custom Category Input
                  if (_showAddCategory) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customCategoryController,
                            decoration: InputDecoration(
                              hintText: 'Enter category name...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
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
                          icon: const Icon(Icons.check_circle),
                          color: AppTheme.primaryColor,
                          iconSize: 32,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showAddCategory = false;
                              _customCategoryController.clear();
                            });
                          },
                          icon: const Icon(Icons.cancel),
                          color: Colors.grey,
                          iconSize: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Show custom categories with delete option
                    if (categoryProvider.customCategories.isNotEmpty) ...[
                      const Text(
                        'Your Custom Categories:',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'FinWise will group these under the closest main category so your budgets stay simple.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categoryProvider.customCategories.map((catName) {
                          return Chip(
                            label: Text(
                              catName,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              categoryProvider.removeCustomCategory(catName);
                              if (_selectedCategory != null &&
                                  _selectedCategory!.name.toLowerCase() == catName.toLowerCase()) {
                                setState(() {
                                  _selectedCategory = null;
                                });
                              }
                            },
                            backgroundColor: Colors.grey[100],
                            side: BorderSide(color: Colors.grey[300]!),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  // Spending reason (why)
                  const Text(
                    'Why are you spending this?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ReasonChip(
                        label: 'Necessity',
                        icon: Icons.receipt_long_outlined,
                        reason: SpendingReason.necessity,
                        selectedReason: _selectedReason,
                        onSelected: (reason) {
                          setState(() {
                            _selectedReason = reason;
                          });
                        },
                      ),
                      _ReasonChip(
                        label: 'Business',
                        icon: Icons.business_center_outlined,
                        reason: SpendingReason.business,
                        selectedReason: _selectedReason,
                        onSelected: (reason) {
                          setState(() {
                            _selectedReason = reason;
                          });
                        },
                      ),
                      _ReasonChip(
                        label: 'Enjoyment',
                        icon: Icons.celebration_outlined,
                        reason: SpendingReason.enjoyment,
                        selectedReason: _selectedReason,
                        onSelected: (reason) {
                          setState(() {
                            _selectedReason = reason;
                          });
                        },
                      ),
                      _ReasonChip(
                        label: 'Emergency',
                        icon: Icons.warning_amber_outlined,
                        reason: SpendingReason.emergency,
                        selectedReason: _selectedReason,
                        onSelected: (reason) {
                          setState(() {
                            _selectedReason = reason;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  // Income category (always income)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 20,
                          color: AppTheme.primaryColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Income',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: AppTheme.textLight),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveTransaction,
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
                          'Save',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.15)
              : Colors.grey[100],
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primaryColor,
      backgroundColor: Colors.grey[100],
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
        width: isSelected ? 2 : 1,
      ),
      showCheckmark: false,
    );
  }
}

class _ReasonChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final SpendingReason reason;
  final SpendingReason selectedReason;
  final ValueChanged<SpendingReason> onSelected;

  const _ReasonChip({
    required this.label,
    required this.icon,
    required this.reason,
    required this.selectedReason,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedReason == reason;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(reason),
      selectedColor: AppTheme.primaryColor,
      backgroundColor: Colors.grey[100],
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
        width: isSelected ? 2 : 1,
      ),
      showCheckmark: false,
    );
  }
}
