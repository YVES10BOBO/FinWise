import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/transaction_item.dart';
import '../providers/transaction_provider.dart';
import '../widgets/add_transaction_dialog.dart';
import '../models/transaction.dart';
import '../models/overview_period.dart';
import '../providers/currency_provider.dart';
import '../providers/period_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/period_picker.dart';
import '../l10n/l10n_helpers.dart';

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
    return Consumer2<TransactionProvider, PeriodProvider>(
      builder: (context, provider, periodProvider, child) {
        var transactions = provider.transactions;

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          transactions = provider.searchTransactions(_searchQuery);
        }

        // Only the period chosen here or on the Home card (shared).
        final period = periodProvider.period;
        transactions =
            transactions.where((t) => period.contains(t.date)).toList();

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

        final l = context.l10n;
        final activeFilters =
            (_selectedCategory != null ? 1 : 0) + (_selectedType != null ? 1 : 0);

        return Scaffold(
          appBar: AppBar(
            title: Text(l.historyTitle),
            actions: [
              _FilterButton(
                activeCount: activeFilters,
                onPressed: () => _showFilterDialog(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.yourHistory,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.historySubtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // Period (shared with the Home card) + its totals.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _PeriodSummaryCard(
                  summary: PeriodSummary.of(transactions),
                ),
              ),
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l.searchTransactions,
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
                          label: categoryLabel(context, _selectedCategory!),
                          onRemove: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
                        ),
                      if (_selectedType != null)
                        _FilterChip(
                          label: switch (_selectedType!) {
                            TransactionType.income => l.income,
                            TransactionType.expense => l.expense,
                            TransactionType.transfer => l.transfer,
                          },
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
                            const Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              l.noTransactions,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                period.kind == OverviewPeriodKind.allTime
                                    ? l.tryAdjusting
                                    : l.nothingInPeriod(
                                        periodLabel(context, period)),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
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
    final l = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.filterTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.filterByType, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Text(l.all),
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
                        label: Text(l.income),
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
                        label: Text(l.expense),
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
                Text(l.filterByCategory, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(l.all),
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
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category.icon,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                categoryLabel(context, category),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
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
          ),
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
            child: Text(l.clearAll),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.close),
          ),
        ],
      ),
    );
  }
}

/// The top-right "Filter" button. A labelled, filled button instead of a
/// bare icon so it's easy to spot, with a badge counting active filters.
class _FilterButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onPressed;

  const _FilterButton({required this.activeCount, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final active = activeCount > 0;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Badge(
        isLabelVisible: active,
        label: Text('$activeCount'),
        backgroundColor: AppTheme.accentDark,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.filter_list, size: 18),
          label: Text(context.l10n.filter),
          style: FilledButton.styleFrom(
            backgroundColor: active ? AppTheme.accentDark : AppTheme.primaryColor,
            foregroundColor: Colors.white,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
    );
  }
}

/// Period selector plus Money in / Spent / Left for exactly the
/// transactions listed below it (period, search and filters applied).
class _PeriodSummaryCard extends StatelessWidget {
  final PeriodSummary summary;

  const _PeriodSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final l = context.l10n;

    Widget stat(String label, double value, Color color) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 2),
            Text(
              currency.formatCompact(value),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          const PeriodSelector(leadingIcon: Icons.calendar_month),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                stat(l.moneyIn, summary.moneyIn, AppTheme.incomeColor),
                stat(l.spent, summary.spent, AppTheme.expenseColor),
                stat(l.left, summary.left,
                    summary.left < 0
                        ? AppTheme.expenseColor
                        : AppTheme.textPrimary),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(l.items,
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(
                      '${summary.count}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
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
