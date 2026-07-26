import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/goal.dart';
import '../models/transaction.dart';
import '../providers/goal_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/currency_provider.dart';
import '../widgets/add_goal_dialog.dart';
import 'goal_details_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, child) {
        final goals = provider.goals;

        if (goals.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Goals'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => showGoalDialog(context),
                ),
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.savings_outlined,
                          size: 52, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Save for what matters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Set a target, reserve money towards it, and watch your '
                      'progress. Reserved money stays yours — it just won\'t '
                      'be counted as spendable.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => showGoalDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Create your first goal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final active = provider.activeGoals;
        final purchased = provider.purchasedGoals;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Goals'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => showGoalDialog(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GoalsDashboard(provider: provider),
                const SizedBox(height: 20),
                if (active.isNotEmpty) ...[
                  const Text(
                    'Active goals',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...active.map((g) => _GoalCard(goal: g)),
                ],
                if (purchased.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...purchased.map((g) => _GoalCard(goal: g)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Opens the create/edit goal dialog. Passing [existing] switches it to edit
/// mode, preserving contributions and status.
void showGoalDialog(BuildContext context, {Goal? existing}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AddGoalDialog(
      existingGoal: existing,
      onSave: (goal) {
        final provider = Provider.of<GoalProvider>(context, listen: false);
        if (existing == null) {
          provider.addGoal(goal);
        } else {
          provider.updateGoal(goal);
        }
      },
    ),
  );
}

/// Summary strip: totals, reserved, active vs completed.
class _GoalsDashboard extends StatelessWidget {
  final GoalProvider provider;

  const _GoalsDashboard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final active = provider.activeGoals;
    final purchased = provider.purchasedGoals;
    final totalTarget =
        active.fold<double>(0, (s, g) => s + g.targetAmount);
    final reserved = provider.totalReserved;
    final pct = totalTarget > 0
        ? (reserved / totalTarget * 100).clamp(0, 100).toStringAsFixed(0)
        : '0';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        // Shared brand gradient — one definition, used app-wide.
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag_outlined, size: 18, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Goals overview',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            currency.formatCompact(reserved),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'reserved of ${currency.formatCompact(totalTarget)} targeted · $pct%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _chip('${provider.goals.length}', 'Total'),
              const SizedBox(width: 8),
              _chip('${active.length}', 'Active'),
              const SizedBox(width: 8),
              _chip('${purchased.length}', 'Completed'),
            ],
          ),
          if (provider.readyToPurchase.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.celebration_outlined,
                      size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${provider.readyToPurchase.length} goal(s) fully funded — ready to purchase',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final progress = goal.progress.clamp(0.0, 1.0);
    final purchased = goal.isPurchased;
    final done = goal.isCompleted;
    final daysLeft = goal.daysRemaining;

    final totalDays = goal.targetDate.difference(goal.createdAt).inDays;
    final elapsed = DateTime.now().difference(goal.createdAt).inDays;
    final timeFraction =
        totalDays > 0 ? (elapsed / totalDays).clamp(0.0, 1.0) : 1.0;

    // Palette is intentionally limited to the app's two brand colours plus
    // neutrals: teal = good/active, amber = needs attention, grey = done.
    final String statusLabel;
    final Color statusColor;
    if (purchased) {
      statusLabel = 'Purchased';
      statusColor = AppTheme.textLight;
    } else if (done) {
      statusLabel = 'Ready to buy';
      statusColor = AppTheme.primaryColor;
    } else if (daysLeft < 0) {
      statusLabel = 'Overdue';
      statusColor = AppTheme.accentDark;
    } else if (goal.progress >= timeFraction) {
      statusLabel = 'On track';
      statusColor = AppTheme.primaryColor;
    } else {
      statusLabel = 'Behind';
      statusColor = AppTheme.accentDark;
    }

    final accent = purchased ? AppTheme.textLight : AppTheme.primaryColor;
    final pct = (goal.progress * 100).clamp(0, 999).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GoalDetailsScreen(goalId: goal.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: icon ring + name + status ──────────────────
                Row(
                  children: [
                    _ProgressRing(
                      progress: progress,
                      color: accent,
                      icon: goal.icon,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                purchased
                                    ? DateFormat('MMM d, y').format(
                                        goal.purchasedDate ?? goal.targetDate)
                                    : (daysLeft < 0
                                        ? 'Past due'
                                        : '$daysLeft days left'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Amounts ───────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      purchased
                          ? currency.formatCompact(goal.purchasedAmount ?? 0)
                          : currency.formatCompact(goal.currentAmount),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        purchased
                            ? 'spent'
                            : 'of ${currency.formatCompact(goal.targetAmount)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$pct%',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Progress bar ──────────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Container(height: 10, color: Colors.grey[200]),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accent.withValues(alpha: 0.75),
                                accent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (!purchased) ...[
                  const SizedBox(height: 12),

                  // ── Hint line ───────────────────────────────────────
                  if (done)
                    _hint(
                      Icons.celebration_outlined,
                      'Fully funded — tap to mark it purchased',
                      AppTheme.primaryColor,
                    )
                  else if (daysLeft > 0)
                    _hint(
                      Icons.trending_up,
                      'Add ${currency.formatCompact(goal.monthlyNeeded)}/month to finish on time',
                      AppTheme.textSecondary,
                    ),

                  const SizedBox(height: 14),

                  // ── Actions ─────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          onPressed: () => showReserveDialog(context, goal),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add contribution'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  GoalDetailsScreen(goalId: goal.id),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.textSecondary,
                            side: BorderSide(color: Colors.grey[300]!),
                            padding:
                                const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Details'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hint(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: color, height: 1.3),
          ),
        ),
      ],
    );
  }
}

/// Circular progress ring with the goal's icon in the middle.
class _ProgressRing extends StatelessWidget {
  final double progress;
  final Color color;
  final IconData icon;

  const _ProgressRing({
    required this.progress,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Icon(icon, size: 22, color: color),
        ],
      ),
    );
  }
}

/// Shared reserve dialog used by the details screen.
void showReserveDialog(BuildContext context, Goal goal) {
  final controller = TextEditingController();
  final noteController = TextEditingController();
  final currency = Provider.of<CurrencyProvider>(context, listen: false);
  final txProvider = Provider.of<TransactionProvider>(context, listen: false);
  final goalProvider = Provider.of<GoalProvider>(context, listen: false);

  AccountType selected = AccountType.mobileMoney;

  double availableFor(AccountType a) =>
      (txProvider.accountBalances[a] ?? 0) - goalProvider.reservedFor(a);

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: const Text('Reserve money'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Moves money from an account into this goal. It stays yours — '
                'just reserved, so it is not counted as spending.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<AccountType>(
                value: selected,
                decoration: const InputDecoration(
                  labelText: 'From account',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: AccountType.values.map((a) {
                  return DropdownMenuItem(
                    value: a,
                    child: Text(
                      '${_accountLabel(a)} · ${currency.formatCompact(availableFor(a))} free',
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setLocal(() => selected = v);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (${currency.code})',
                  prefixIcon: const Icon(Icons.savings_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  prefixIcon: Icon(Icons.notes),
                ),
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
              final value = double.tryParse(controller.text.trim());
              if (value == null || value <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter an amount above 0')),
                );
                return;
              }
              final free = availableFor(selected);
              if (value > free) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${_accountLabel(selected)} only has ${currency.formatCompact(free)} available.',
                    ),
                  ),
                );
                return;
              }
              goalProvider.addContribution(
                goal.id,
                amount: value,
                account: selected,
                note: noteController.text.trim(),
              );
              Navigator.pop(ctx);

              // Reserving beyond the target is allowed (you may have decided
              // the thing costs more), but say so plainly rather than
              // silently showing over 100%.
              final over = (goal.currentAmount + value) - goal.targetAmount;
              final msg = over > 0
                  ? 'Reserved ${currency.formatCompact(value)} — that is ${currency.formatCompact(over)} more than this goal needs. Release it any time.'
                  : 'Reserved ${currency.formatCompact(value)} from ${_accountLabel(selected)}';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  duration: Duration(seconds: over > 0 ? 5 : 3),
                ),
              );
            },
            child: const Text('Reserve'),
          ),
        ],
      ),
    ),
  );
}

String _accountLabel(AccountType a) {
  switch (a) {
    case AccountType.cash:
      return 'Cash';
    case AccountType.bank:
      return 'Bank';
    case AccountType.mobileMoney:
      return 'Mobile Money';
  }
}
