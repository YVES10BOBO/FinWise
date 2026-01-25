import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/transaction_item.dart';
import '../providers/transaction_provider.dart';
import '../widgets/add_transaction_dialog.dart';
import '../models/transaction.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Category? _selectedCategory;
  TransactionType? _selectedType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        var transactions = provider.transactions;

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          transactions = provider.searchTransactions(_searchQuery);
        }

        // Apply category filter
        if (_selectedCategory != null) {
          transactions = transactions
              .where((t) => t.category == _selectedCategory)
              .toList();
        }

        // Apply type filter
        if (_selectedType != null) {
          transactions = transactions
              .where((t) => t.type == _selectedType)
              .toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Transaction History'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              // Active Filters
              if (_selectedCategory != null || _selectedType != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_selectedCategory != null)
                        _FilterChip(
                          label: '${_selectedCategory!.emoji} ${_selectedCategory!.name}',
                          onRemove: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
                        ),
                      if (_selectedType != null)
                        _FilterChip(
                          label: _selectedType == TransactionType.income
                              ? 'Income'
                              : 'Expense',
                          onRemove: () {
                            setState(() {
                              _selectedType = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              // Transaction List
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '💰',
                              style: TextStyle(fontSize: 64),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No transactions found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          // Refresh data
                          await Future.delayed(const Duration(seconds: 1));
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return TransactionItem(
                              transaction: transaction,
                              onEdit: () => _editTransaction(context, transaction),
                              onDelete: () {
                                provider.removeTransaction(transaction.id);
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editTransaction(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(
        existingTransaction: transaction,
        onSave: (updatedTransaction) {
          Provider.of<TransactionProvider>(context, listen: false)
              .updateTransaction(updatedTransaction);
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter by Type:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedType == null,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = null;
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Income'),
                    selected: _selectedType == TransactionType.income,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = TransactionType.income;
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Expense'),
                    selected: _selectedType == TransactionType.expense,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = TransactionType.expense;
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Filter by Category:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = null;
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
                ...Category.values.map((category) {
                  if (category == Category.income || category == Category.savings) {
                    return const SizedBox.shrink();
                  }
                  return ChoiceChip(
                    label: Text('${category.emoji} ${category.name}'),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                        Navigator.pop(context);
                      }
                    },
                  );
                }),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _selectedType = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        onDeleted: onRemove,
        deleteIcon: const Icon(Icons.close, size: 18),
      ),
    );
  }
}
