import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/goal.dart';
import '../models/transaction.dart';
import '../providers/goal_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/currency_provider.dart';
import 'goals_screen.dart';

/// Full view of one goal: progress, per-account reserved breakdown, the
/// complete contribution history, and every action (reserve, release, edit,
/// mark purchased, delete).
class GoalDetailsScreen extends StatelessWidget {
  final String goalId;

  const GoalDetailsScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, _) {
        final matches = provider.goals.where((g) => g.id == goalId).toList();
        final goal = matches.isEmpty ? null : matches.first;
        if (goal == null) {
          // Deleted while open.
          return Scaffold(
            appBar: AppBar(title: const Text('Goal')),
            body: const Center(child: Text('This goal no longer exists.')),
          );
        }

        final currency = context.watch<CurrencyProvider>();
        final purchased = goal.isPurchased;

        return Scaffold(
          appBar: AppBar(
            title: Text(goal.name),
            actions: [
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') showGoalDialog(context, existing: goal);
                  if (v == 'delete') _confirmDelete(context, goal);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Edit goal'),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete goal'),
                    ]),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _header(context, goal, currency),
              const SizedBox(height: 20),
              if (!purchased) _actions(context, goal),
              if (!purchased) const SizedBox(height: 20),
              _reservedByAccount(context, goal, currency),
              const SizedBox(height: 20),
              _history(context, goal, currency),
            ],
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, Goal goal, CurrencyProvider currency) {
    final progress = goal.progress.clamp(0.0, 1.0);
    final pct = (goal.progress * 100).clamp(0, 999).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(goal.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      goal.isPurchased
                          ? 'Purchased ${DateFormat('MMM d, y').format(goal.purchasedDate ?? DateTime.now())}'
                          : 'Target ${DateFormat('MMM d, y').format(goal.targetDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            currency.formatCompact(goal.currentAmount),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'reserved of ${currency.formatCompact(goal.targetAmount)} · $pct%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          if (!goal.isPurchased) ...[
            const SizedBox(height: 12),
            Text(
              goal.isCompleted
                  ? 'Fully funded — mark it purchased when you buy it.'
                  : 'Still need ${currency.formatCompact(goal.remaining)} · about ${currency.formatCompact(goal.monthlyNeeded)}/month',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actions(BuildContext context, Goal goal) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => showReserveDialog(context, goal),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Reserve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: goal.currentAmount > 0
                ? () => _showReleaseDialog(context, goal)
                : null,
            icon: const Icon(Icons.undo, size: 18),
            label: const Text('Release'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: goal.currentAmount > 0
                ? () => _showPurchaseDialog(context, goal)
                : null,
            icon: const Icon(Icons.shopping_bag_outlined, size: 18),
            label: const Text('Bought'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _reservedByAccount(
      BuildContext context, Goal goal, CurrencyProvider currency) {
    final byAccount = goal.reservedByAccount;
    if (byAccount.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reserved from',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...byAccount.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(_accountIcon(e.key),
                        size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        accountLabel(e.key),
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textPrimary),
                      ),
                    ),
                    Text(
                      currency.formatCompact(e.value),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _history(
      BuildContext context, Goal goal, CurrencyProvider currency) {
    final items = goal.contributions.reversed.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contribution history',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No money reserved yet.',
                style: TextStyle(color: AppTheme.textLight, fontSize: 13),
              ),
            )
          else
            ...items.map((c) {
              final release = c.isRelease;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: (release
                                ? AppTheme.accentDark
                                : AppTheme.primaryColor)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        release ? Icons.undo : Icons.savings_outlined,
                        size: 15,
                        color: release
                            ? AppTheme.accentDark
                            : AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            release ? 'Released' : 'Reserved',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '${accountLabel(c.account)} · ${DateFormat('MMM d, y · HH:mm').format(c.date)}',
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.textSecondary),
                          ),
                          if (c.note.isNotEmpty)
                            Text(
                              c.note,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textLight,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${release ? '−' : '+'}${currency.formatCompact(c.amount)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: release
                            ? AppTheme.accentDark
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ---- Dialogs -------------------------------------------------------

  void _showReleaseDialog(BuildContext context, Goal goal) {
    final controller =
        TextEditingController(text: goal.currentAmount.toStringAsFixed(0));
    final currency = Provider.of<CurrencyProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Release reserved money'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Returns money from this goal back to your available balance. '
              'Currently reserved: ${currency.formatCompact(goal.currentAmount)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount to release (${currency.code})',
                prefixIcon: const Icon(Icons.undo),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<GoalProvider>(context, listen: false)
                  .releaseAll(goal.id, note: 'Released all');
              Navigator.pop(ctx);
            },
            child: const Text('Release all'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value == null || value <= 0) return;
              Provider.of<GoalProvider>(context, listen: false)
                  .releaseAmount(goal.id, amount: value);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Released ${currency.formatCompact(value)} back to available'),
                ),
              );
            },
            child: const Text('Release'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, Goal goal) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    final amountController =
        TextEditingController(text: goal.currentAmount.toStringAsFixed(0));
    Category category = Category.shopping;
    AccountType account = goal.reservedByAccount.keys.isNotEmpty
        ? goal.reservedByAccount.keys.first
        : AccountType.cash;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Mark as purchased'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Records the real expense and frees the reserved money. '
                  'Anything left over returns to your available balance.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Actual price (${currency.code})',
                    prefixIcon: const Icon(Icons.shopping_bag_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Category>(
                  value: category,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Expense category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: Category.values
                      .where((c) => c != Category.income)
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text('${c.emoji} ${c.name}',
                                style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setLocal(() => category = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AccountType>(
                  value: account,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Paid from',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  ),
                  items: AccountType.values
                      .map((a) => DropdownMenuItem(
                            value: a,
                            child: Text(accountLabel(a),
                                style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setLocal(() => account = v);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final actual = double.tryParse(amountController.text.trim());
                if (actual == null || actual <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter the actual price')),
                  );
                  return;
                }

                final txId = 'goalbuy_${DateTime.now().millisecondsSinceEpoch}';
                // One real expense for what was actually paid.
                Provider.of<TransactionProvider>(context, listen: false)
                    .addTransaction(
                  Transaction(
                    id: txId,
                    type: TransactionType.expense,
                    category: category,
                    amount: actual,
                    description: 'Bought: ${goal.name}',
                    date: DateTime.now(),
                    account: account,
                  ),
                );

                // Goal keeps its history; it just stops reserving money.
                Provider.of<GoalProvider>(context, listen: false).markPurchased(
                  goal.id,
                  actualAmount: actual,
                  transactionId: txId,
                );

                Navigator.pop(ctx);

                final leftover = goal.currentAmount - actual;
                final msg = leftover > 0
                    ? 'Purchase recorded. ${currency.formatCompact(leftover)} returned to available.'
                    : 'Purchase recorded.';
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(msg)));
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Goal goal) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    final reserved = goal.currentAmount;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete goal'),
        content: Text(
          reserved > 0
              ? 'Delete "${goal.name}"? The ${currency.formatCompact(reserved)} reserved will return to your available balance.'
              : 'Delete "${goal.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              final provider =
                  Provider.of<GoalProvider>(context, listen: false);
              // Release first so the money is explicitly returned, then remove.
              if (reserved > 0) {
                provider.releaseAll(goal.id, note: 'Goal deleted');
              }
              provider.removeGoal(goal.id);
              Navigator.pop(ctx); // dialog
              Navigator.pop(context); // details screen
              if (reserved > 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${currency.formatCompact(reserved)} returned to your available balance',
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      );

  IconData _accountIcon(AccountType a) {
    switch (a) {
      case AccountType.cash:
        return Icons.payments_outlined;
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.mobileMoney:
        return Icons.phone_iphone;
    }
  }
}

String accountLabel(AccountType a) {
  switch (a) {
    case AccountType.cash:
      return 'Cash';
    case AccountType.bank:
      return 'Bank';
    case AccountType.mobileMoney:
      return 'Mobile Money';
  }
}
