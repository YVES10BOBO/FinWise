import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/goal.dart';
import '../models/transaction.dart';
import '../providers/goal_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/currency_provider.dart';
import '../widgets/add_goal_dialog.dart';
import '../widgets/goal_celebration.dart';
import '../l10n/l10n_helpers.dart';
import 'goal_details_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, child) {
        final goals = provider.goals;
        final l = context.l10n;

        if (goals.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l.goalsTitle),
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
                    Text(
                      l.goalsEmptyTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l.goalsEmptyBody,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                        label: Text(l.createFirstGoal),
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
            title: Text(l.goalsTitle),
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
                  Text(
                    l.activeGoals,
                    style: const TextStyle(
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
                  Text(
                    l.completed,
                    style: const TextStyle(
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
    final l = context.l10n;
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
          Row(
            children: [
              const Icon(Icons.flag_outlined, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                l.goalsOverview,
                style: const TextStyle(
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
            l.reservedOfTargeted(currency.formatCompact(totalTarget), pct),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _chip('${provider.goals.length}', l.total),
              const SizedBox(width: 8),
              _chip('${active.length}', l.active),
              const SizedBox(width: 8),
              _chip('${purchased.length}', l.completed),
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
                      l.goalsReady(provider.readyToPurchase.length),
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
    final l = context.l10n;
    final purchased = goal.isPurchased;
    // A bought goal is complete at whatever it really cost, even when that
    // was less than the target — so it always reads 100%.
    final progress = purchased ? 1.0 : goal.progress.clamp(0.0, 1.0);
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
      statusLabel = l.completed;
      statusColor = AppTheme.textLight;
    } else if (done) {
      statusLabel = l.statusReady;
      statusColor = AppTheme.primaryColor;
    } else if (daysLeft < 0) {
      statusLabel = l.statusOverdue;
      statusColor = AppTheme.accentDark;
    } else if (goal.progress >= timeFraction) {
      statusLabel = l.statusOnTrack;
      statusColor = AppTheme.primaryColor;
    } else {
      statusLabel = l.statusBehind;
      statusColor = AppTheme.accentDark;
    }

    final accent = purchased ? AppTheme.textLight : AppTheme.primaryColor;
    final pct = purchased
        ? '100'
        : (goal.progress * 100).clamp(0, 999).toStringAsFixed(0);

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ring + the category name beneath it, so the icon's
                    // meaning is never left to guesswork.
                    SizedBox(
                      width: 62,
                      child: Column(
                        children: [
                          _ProgressRing(
                            progress: progress,
                            color: accent,
                            icon: goal.icon,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goalIconName(context, goal.iconKey),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              height: 1.2,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
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
                                    ? formatDay(context,
                                        goal.purchasedDate ?? goal.targetDate)
                                    : (daysLeft < 0
                                        ? l.pastDue
                                        : l.daysLeft(daysLeft)),
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
                            ? ((goal.purchasedAmount ?? 0) != goal.plannedAmount
                                ? l.paidPlanned(
                                    currency.formatCompact(goal.plannedAmount))
                                : l.paid)
                            : l.ofAmount(
                                currency.formatCompact(goal.targetAmount)),
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
                      l.fullyFundedTap,
                      AppTheme.primaryColor,
                    )
                  else if (daysLeft > 0)
                    _hint(
                      Icons.trending_up,
                      l.addPerMonth(
                          currency.formatCompact(goal.monthlyNeeded)),
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
                          label: Text(l.addContribution),
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
                          child: Text(l.details),
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
  final l = context.l10n;

  double availableFor(AccountType a) =>
      (txProvider.accountBalances[a] ?? 0) - goalProvider.reservedFor(a);

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        title: Text(l.reserveMoney),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.reserveExplain,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<AccountType>(
                value: selected,
                decoration: InputDecoration(
                  labelText: l.fromAccount,
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                ),
                items: AccountType.values.map((a) {
                  return DropdownMenuItem(
                    value: a,
                    child: Text(
                      l.freeAmount(accountName(context, a),
                          currency.formatCompact(availableFor(a))),
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
                  labelText: l.amountWithCode(currency.code),
                  prefixIcon: const Icon(Icons.savings_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: l.noteOptional,
                  prefixIcon: const Icon(Icons.notes),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () async {
              final value = double.tryParse(controller.text.trim());
              if (value == null || value <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.enterAmountAbove0)),
                );
                return;
              }
              final free = availableFor(selected);
              if (value > free) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l.onlyHasAvailable(accountName(context, selected),
                          currency.formatCompact(free)),
                    ),
                  ),
                );
                return;
              }
              final wasFunded = goal.isCompleted;
              goalProvider.addContribution(
                goal.id,
                amount: value,
                account: selected,
                note: noteController.text.trim(),
              );
              Navigator.pop(ctx);

              // This reserve just reached the price → celebrate (once), and
              // offer to close the goal straight away, since people often
              // forget to come back and mark it bought.
              final updated = goalProvider.goals
                  .where((g) => g.id == goal.id)
                  .firstOrNull;
              if (!wasFunded &&
                  updated != null &&
                  updated.isCompleted &&
                  !updated.isPurchased) {
                final span = savingSpanText(context, updated);
                final shown = await showGoalCelebration(
                  context,
                  goal: updated,
                  kind: GoalCelebrationKind.funded,
                  title: l.celebrateFundedTitle(updated.name),
                  lines: [
                    span.isNotEmpty
                        ? l.celebrateFundedReservedSpan(
                            currency.formatCompact(updated.currentAmount), span)
                        : l.celebrateFundedReserved(
                            currency.formatCompact(updated.currentAmount)),
                    l.celebrateFundedAsk,
                  ],
                  primaryLabel: l.iBoughtIt,
                  secondaryLabel: l.later,
                  onPrimary: () {
                    if (context.mounted) {
                      GoalDetailsScreen(goalId: updated.id)
                          .showPurchaseDialog(context, updated);
                    }
                  },
                );
                if (shown) return;
              }
              if (!context.mounted) return;

              // Reserving beyond the target is allowed (you may have decided
              // the thing costs more), but say so plainly rather than
              // silently showing over 100%.
              final over = (goal.currentAmount + value) - goal.targetAmount;
              final msg = over > 0
                  ? l.reservedOver(currency.formatCompact(value),
                      currency.formatCompact(over))
                  : l.reservedFrom(currency.formatCompact(value),
                      accountName(context, selected));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  duration: Duration(seconds: over > 0 ? 5 : 3),
                ),
              );
            },
            child: Text(l.reserve),
          ),
        ],
      ),
    ),
  );
}
