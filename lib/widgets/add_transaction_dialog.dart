import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../services/categorization_service.dart';

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
  late Category _selectedCategory;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? TransactionType.expense;
    _selectedCategory = _selectedType == TransactionType.income
        ? Category.income
        : Category.food;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final description = _descriptionController.text.isEmpty
          ? _selectedCategory.name
          : _descriptionController.text;
      
      // Auto-categorize if user didn't manually select or if it's a new description
      final autoCategory = CategorizationService.categorizeTransaction(
        description,
        double.parse(_amountController.text),
      );
      
      final transaction = Transaction(
        id: widget.existingTransaction?.id ?? 
            DateTime.now().millisecondsSinceEpoch.toString(),
        type: _selectedType,
        category: _selectedType == TransactionType.income 
            ? Category.income 
            : autoCategory, // Use auto-categorized for expenses
        amount: double.parse(_amountController.text),
        description: description,
        date: widget.existingTransaction?.date ?? DateTime.now(),
      );
      widget.onSave(transaction);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.existingTransaction == null
                      ? 'Add Transaction'
                      : 'Edit Transaction',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                // Transaction Type
                Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        label: 'Income',
                        icon: '💰',
                        isSelected: _selectedType == TransactionType.income,
                        onTap: () {
                          setState(() {
                            _selectedType = TransactionType.income;
                            _selectedCategory = Category.income;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TypeButton(
                        label: 'Expense',
                        icon: '💸',
                        isSelected: _selectedType == TransactionType.expense,
                        onTap: () {
                          setState(() {
                            _selectedType = TransactionType.expense;
                            _selectedCategory = Category.food;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Amount
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (RWF)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
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
                const SizedBox(height: 16),
                // Category
                DropdownButtonFormField<Category>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: (_selectedType == TransactionType.income
                          ? [Category.income]
                          : [
                              Category.food,
                              Category.transport,
                              Category.entertainment,
                              Category.utilities,
                              Category.rent,
                              Category.shopping,
                            ])
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text('${category.emoji} ${category.name}'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Save'),
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
  final String icon;
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.grey[200],
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
