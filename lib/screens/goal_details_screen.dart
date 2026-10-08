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
import '../widgets/goal_celebration.dart';
import '../l10n/l10n_helpers.dart';

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
            appBar: AppBar(title: Text(context.l10n.goalTitle)),
            body: Center(child: Text(context.l10n.goalNoLongerExists)),
          );
        }

        final currency = context.watch<CurrencyProvider>();
        final purchased = goal.isPurchased;
        final l = context.l10n;

        return Scaffold(
          appBar: AppBar(
            title: Text(goal.name),
            actions: [
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') showGoalDialog(context, existing: goal);
                  if (v == 'delete') _confirmDelete(context, goal);
                  if (v == 'undo') _confirmUndoPurchase(context, goal);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      const Icon(Icons.edit_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(l.editGoal),
                    ]),
                  ),
                  if (purchased)
                    PopupMenuItem(
                      value: 'undo',
                      child: Row(children: [
                        const Icon(Icons.undo, size: 18),
                        const SizedBox(width: 8),
                        Text(l.undoPurchase),
                      ]),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      const Icon(Icons.delete_outline,
                          size: 18, color: AppTheme.accentDark),
                      const SizedBox(width: 8),
                      Text(l.deleteGoal),
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
              if (purchased) ...[
                _purchaseSummary(context, goal, currency),
                const SizedBox(height: 20),
              ] else if (goal.priceWasUpdated) ...[
                _priceHistory(context, goal, currency),
                const SizedBox(height: 20),
              ],
              _reservedByAccount(context, goal, currency),
              const SizedBox(height: 20),
              _history(context, goal, currency),
              const SizedBox(height: 20),
              _manageActions(context, goal, purchased),
            ],
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, Goal goal, CurrencyProvider currency) {
    final purchased = goal.isPurchased;
    // Bought = complete at the real price paid, even below the target.
    final progress = purchased ? 1.0 : goal.progress.clamp(0.0, 1.0);
    final pct = purchased
        ? '100'
        : (goal.progress * 100).clamp(0, 999).toStringAsFixed(0);
    final paid = goal.purchasedAmount ?? 0;
    final l = context.l10n;

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
                          ? l.purchasedOn(formatDay(
                              context, goal.purchasedDate ?? DateTime.now()))
                          : l.target(formatDay(context, goal.targetDate)),
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
            currency.formatCompact(purchased ? paid : goal.currentAmount),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            purchased
                ? (paid != goal.plannedAmount
                    ? l.paidPlannedCompleted(
                        currency.formatCompact(goal.plannedAmount))
                    : l.paidCompleted)
                : l.reservedOfPct(
                    currency.formatCompact(goal.targetAmount), pct),
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
          if (!purchased) ...[
            const SizedBox(height: 12),
            Text(
              goal.extraReserved > 0
                  ? l.readyExtra(currency.formatCompact(goal.extraReserved))
                  : goal.isCompleted
                      ? l.fullyFundedBought
                      : l.stillNeed(currency.formatCompact(goal.remaining),
                          currency.formatCompact(goal.monthlyNeeded)),
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(height: 6),
            // The real price is often different from the first guess —
            // make updating it obvious, right where the target is shown.
            InkWell(
              onTap: () => _showUpdatePriceDialog(context, goal),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sell_outlined,
                        size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      goal.priceWasUpdated
                          ? l.plannedPriceChanged(
                              currency.formatCompact(goal.plannedAmount))
                          : l.differentPrice,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ],
                ),
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
            label: Text(context.l10n.reserve),
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
            label: Text(context.l10n.release),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          // Always available: people often buy the item without having
          // reserved anything in FinWise first, and must still be able to
          // close the goal by linking the real purchase from their history.
          child: ElevatedButton.icon(
            onPressed: () => showPurchaseDialog(context, goal),
            icon: const Icon(Icons.shopping_bag_outlined, size: 18),
            label: Text(context.l10n.bought),
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

  /// Manage actions shown plainly at the bottom instead of hidden behind the
  /// ⋮ menu, so editing, undoing and deleting are easy to find.
  Widget _manageActions(BuildContext context, Goal goal, bool purchased) {
    final l = context.l10n;
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            leading: const Icon(Icons.edit_outlined,
                color: AppTheme.primaryColor, size: 20),
            title: Text(l.editGoal, style: const TextStyle(fontSize: 14)),
            subtitle: Text(l.editGoalSub,
                style: const TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () => showGoalDialog(context, existing: goal),
          ),
          if (!purchased) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.sell_outlined,
                  color: AppTheme.primaryColor, size: 20),
              title: Text(l.updatePrice,
                  style: const TextStyle(fontSize: 14)),
              subtitle: Text(l.updatePriceSub,
                  style: const TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () => _showUpdatePriceDialog(context, goal),
            ),
          ],
          if (purchased) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.undo,
                  color: AppTheme.accentDark, size: 20),
              title: Text(l.undoPurchase,
                  style: const TextStyle(fontSize: 14)),
              subtitle: Text(l.undoPurchaseSub,
                  style: const TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () => _confirmUndoPurchase(context, goal),
            ),
          ],
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            leading: const Icon(Icons.delete_outline,
                color: AppTheme.expenseColor, size: 20),
            title: Text(l.deleteGoal,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.expenseColor)),
            subtitle: Text(l.deleteGoalSub,
                style: const TextStyle(fontSize: 11)),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () => _confirmDelete(context, goal),
          ),
        ],
      ),
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
          Text(
            context.l10n.reservedFromTitle,
            style: const TextStyle(
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
                        accountName(context, e.key),
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
          Text(
            context.l10n.contributionHistory,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              goal.isPurchased
                  ? context.l10n.undoToEdit
                  : context.l10n.tapToEdit,
              style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
            ),
          ],
          const SizedBox(height: 12),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                context.l10n.noMoneyReserved,
                style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
              ),
            )
          else
            ...items.map((c) {
              final release = c.isRelease;
              final editable = !goal.isPurchased;
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: editable
                    ? () => _showContributionActions(context, goal, c)
                    : null,
                child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
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
                            release
                                ? context.l10n.releasedLabel
                                : context.l10n.reservedLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '${accountName(context, c.account)} · ${formatDay(context, c.date)} · ${DateFormat('HH:mm').format(c.date)}',
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
                    if (editable)
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 18),
                        tooltip: context.l10n.editOrDelete,
                        color: AppTheme.textSecondary,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 32, minHeight: 32),
                        onPressed: () =>
                            _showContributionActions(context, goal, c),
                      ),
                  ],
                ),
                ),
              );
            }),
        ],
      ),
    );
  }

  /// What actually happened when the goal was bought: real price vs plan,
  /// every payment that paid for it, and how the saving went.
  Widget _purchaseSummary(
      BuildContext context, Goal goal, CurrencyProvider currency) {
    final txProvider = context.watch<TransactionProvider>();
    final paid = goal.purchasedAmount ?? 0;
    final planned = goal.plannedAmount;
    final diff = planned - paid;

    final payments = goal.purchaseTransactionIds
        .map((id) => txProvider.transactions.where((t) => t.id == id))
        .where((m) => m.isNotEmpty)
        .map((m) => m.first)
        .toList();
    final missing = goal.purchaseTransactionIds.length - payments.length;

    final l = context.l10n;
    final reserves = goal.contributions.where((c) => !c.isRelease).toList();
    final savingLine = reserves.isEmpty
        ? l.boughtWithoutReserving
        : l.savedOverContributions(
            savingSpanText(context, goal, until: goal.purchasedDate),
            reserves.length);

    Widget stat(String label, String value, {Color? color}) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color ?? AppTheme.textPrimary)),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.purchaseSummary,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              stat(l.paidCap, currency.formatCompact(paid)),
              stat(l.planned, currency.formatCompact(planned)),
              stat(
                diff >= 0 ? l.underPlan : l.overPlan,
                currency.formatCompact(diff.abs()),
                color: diff >= 0 ? AppTheme.incomeColor : AppTheme.accentDark,
              ),
            ],
          ),
          if (diff > 0) ...[
            const SizedBox(height: 10),
            Text(
              l.paidLessThanPlanned(currency.formatCompact(diff)),
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.incomeColor),
            ),
          ],
          const SizedBox(height: 14),
          Text(l.paidWith,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          if (payments.isEmpty && missing == 0)
            Text(l.noPaymentLinked,
                style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
          ...payments.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(_accountIcon(t.account),
                        size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${accountName(context, t.account)} · ${formatDay(context, t.date)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textPrimary),
                      ),
                    ),
                    Text(currency.formatCompact(t.amount),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
          if (missing > 0)
            Text(
              l.missingPayments(missing),
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.textLight),
            ),
          const SizedBox(height: 6),
          Text(savingLine,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
          if (goal.priceWasUpdated) ...[
            const SizedBox(height: 14),
            _priceChangeList(context, goal, currency),
          ],
        ],
      ),
    );
  }

  /// Price updates made while still saving (active goals only).
  Widget _priceHistory(
      BuildContext context, Goal goal, CurrencyProvider currency) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: _priceChangeList(context, goal, currency),
    );
  }

  Widget _priceChangeList(
      BuildContext context, Goal goal, CurrencyProvider currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.priceUpdates,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        ...goal.priceChanges.reversed.map((p) {
          final down = p.to < p.from;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(down ? Icons.trending_down : Icons.trending_up,
                    size: 16,
                    color: down ? AppTheme.incomeColor : AppTheme.accentDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${currency.formatCompact(p.from)} → ${currency.formatCompact(p.to)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Text(formatDay(context, p.date),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ---- Dialogs -------------------------------------------------------

  /// Edit / Delete for one reserve or release entry.
  void _showContributionActions(
      BuildContext context, Goal goal, GoalContribution c) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    final l = context.l10n;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${c.isRelease ? l.releasedLabel : l.reservedLabel} ${currency.formatCompact(c.amount)} · '
                  '${accountName(context, c.account)} · ${formatDay(context, c.date)}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined,
                  color: AppTheme.primaryColor),
              title: Text(
                  c.isRelease ? l.editThisRelease : l.editThisReserve),
              subtitle: Text(l.editEntrySub),
              onTap: () {
                Navigator.pop(sheetCtx);
                _showEditContributionDialog(context, goal, c);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: AppTheme.expenseColor),
              title: Text(
                  c.isRelease ? l.deleteThisRelease : l.deleteThisReserve,
                  style: const TextStyle(color: AppTheme.expenseColor)),
              subtitle: Text(c.isRelease
                  ? l.deleteReleaseSub
                  : l.deleteReserveSub),
              onTap: () {
                Navigator.pop(sheetCtx);
                _confirmDeleteContribution(context, goal, c);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditContributionDialog(
      BuildContext context, Goal goal, GoalContribution c) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    final amountController =
        TextEditingController(text: c.amount.toStringAsFixed(0));
    final noteController = TextEditingController(text: c.note);
    var account = c.account;
    final l = context.l10n;

    // Free money in an account, counting this entry's own reserve as free
    // (it is the one being changed).
    double availableFor(AccountType a) {
      var free = (txProvider.accountBalances[a] ?? 0) -
          goalProvider.reservedFor(a);
      if (!c.isRelease && a == c.account) free += c.amount;
      return free;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(c.isRelease ? l.editRelease : l.editReserve),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<AccountType>(
                  value: account,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: c.isRelease ? l.releasedTo : l.fromAccount,
                    prefixIcon:
                        const Icon(Icons.account_balance_wallet_outlined),
                  ),
                  items: AccountType.values
                      .map((a) => DropdownMenuItem(
                            value: a,
                            child: Text(
                              c.isRelease
                                  ? accountName(context, a)
                                  : l.freeAmount(accountName(context, a),
                                      currency.formatCompact(availableFor(a))),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setLocal(() => account = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l.amountWithCode(currency.code),
                    prefixIcon: Icon(
                        c.isRelease ? Icons.undo : Icons.savings_outlined),
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
              onPressed: () {
                final value = double.tryParse(amountController.text.trim());
                if (value == null || value <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.enterAmountAbove0)),
                  );
                  return;
                }
                // Same rule as reserving: can't set aside more than is free.
                if (!c.isRelease && value > availableFor(account)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l.onlyHasAvailable(
                          accountName(context, account),
                          currency.formatCompact(availableFor(account)))),
                    ),
                  );
                  return;
                }
                final error = goalProvider.updateContribution(
                  goal.id,
                  GoalContribution(
                    id: c.id,
                    amount: value,
                    date: c.date,
                    account: account,
                    note: noteController.text.trim(),
                    isRelease: c.isRelease,
                  ),
                );
                if (error != null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(goalErrorText(context, error))));
                  return;
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.entryUpdated)),
                );
              },
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteContribution(
      BuildContext context, Goal goal, GoalContribution c) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(c.isRelease
            ? context.l10n.deleteReleaseQ
            : context.l10n.deleteReserveQ),
        content: Text(
          c.isRelease
              ? context.l10n.deleteReleaseBody(
                  currency.formatCompact(c.amount), goal.name)
              : context.l10n.deleteReserveBody(
                  currency.formatCompact(c.amount)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.expenseColor),
            onPressed: () {
              final error = Provider.of<GoalProvider>(context, listen: false)
                  .removeContribution(goal.id, c.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error != null
                    ? goalErrorText(context, error)
                    : context.l10n.entryDeleted)),
              );
            },
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }

  /// The real price differs from the plan. Shows, before confirming, what
  /// the new price means: ready to buy (with any extra reserved), or how
  /// much more is still needed.
  void _showUpdatePriceDialog(BuildContext context, Goal goal) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    final controller =
        TextEditingController(text: goal.targetAmount.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final price = double.tryParse(controller.text.trim()) ?? 0;
          final reserved = goal.currentAmount;
          String preview;
          Color previewColor;
          if (price <= 0) {
            preview = context.l10n.enterRealPrice;
            previewColor = AppTheme.textSecondary;
          } else if (reserved >= price) {
            final extra = reserved - price;
            preview = extra > 0
                ? context.l10n.haveEnoughExtra(currency.formatCompact(extra))
                : context.l10n.haveExactlyEnough;
            previewColor = AppTheme.incomeColor;
          } else {
            preview =
                context.l10n.willStillNeed(currency.formatCompact(price - reserved));
            previewColor = AppTheme.accentDark;
          }

          return AlertDialog(
            title: Text(context.l10n.updatePrice),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.realPriceIntro(currency.formatCompact(goal.plannedAmount),
                      goal.priceWasUpdated ? context.l10n.currentPrice(currency.formatCompact(goal.targetAmount)) : ''),
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  onChanged: (_) => setLocal(() {}),
                  decoration: InputDecoration(
                    labelText: context.l10n.realPriceCode(currency.code),
                    prefixIcon: const Icon(Icons.sell_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                Text(preview,
                    style: TextStyle(fontSize: 12, color: previewColor)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(context.l10n.cancel),
              ),
              TextButton(
                onPressed: price <= 0
                    ? null
                    : () {
                        final provider =
                            Provider.of<GoalProvider>(context, listen: false);
                        provider.updatePrice(goal.id, price);
                        Navigator.pop(ctx);

                        final extra = goal.currentAmount - price;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(extra > 0
                                ? context.l10n.priceUpdatedExtra(currency.formatCompact(extra))
                                : context.l10n.priceUpdatedTo(currency.formatCompact(price))),
                            action: extra > 0
                                ? SnackBarAction(
                                    label: context.l10n.releaseExtra,
                                    onPressed: () => provider.releaseAmount(
                                      goal.id,
                                      amount: extra,
                                      note: context.l10n.noteDown,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                child: Text(context.l10n.update),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showReleaseDialog(BuildContext context, Goal goal) {
    final controller =
        TextEditingController(text: goal.currentAmount.toStringAsFixed(0));
    final currency = Provider.of<CurrencyProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.releaseReserved),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.releaseExplain(currency.formatCompact(goal.currentAmount)),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: context.l10n.amountToRelease(currency.code),
                prefixIcon: const Icon(Icons.undo),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Provider.of<GoalProvider>(context, listen: false)
                  .releaseAll(goal.id, note: context.l10n.noteReleasedAll);
              Navigator.pop(ctx);
            },
            child: Text(context.l10n.releaseAll),
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
                      context.l10n.releasedBack(currency.formatCompact(value))),
                ),
              );
            },
            child: Text(context.l10n.release),
          ),
        ],
      ),
    );
  }

  /// Marking a goal purchased has TWO jobs: record what was really paid, and
  /// close the goal at that REAL price (not the target guessed up front).
  ///
  /// The payments often already exist — Mobile Money purchases are
  /// auto-recorded from SMS, cash is often entered by hand — and a purchase
  /// is often split (e.g. 80,000 by Mobile Money + 20,000 in cash). So the
  /// user either LINKS every real payment, or CREATES one expense per account
  /// paid from. The app never guesses which transactions belong to a goal.
  void showPurchaseDialog(BuildContext context, Goal goal) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);

    final price = goal.targetAmount;
    var search = '';
    Category category = Category.shopping;

    // Expenses from the whole history not already tied to another goal.
    final linkedIds =
        goalProvider.goals.expand((g) => g.purchaseTransactionIds).toSet();
    final candidates = txProvider.transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.category != Category.savings &&
            !linkedIds.contains(t.id))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Start on "link" whenever there is something to link: linking never
    // double-counts. "Create new" remains one tap away.
    bool linkMode = candidates.isNotEmpty;
    final selectedIds = <String>{};

    // "Create new": one line per account paid from.
    final firstAccount = goal.reservedByAccount.keys.isNotEmpty
        ? goal.reservedByAccount.keys.first
        : AccountType.mobileMoney;
    final lines = <_PaymentLine>[
      _PaymentLine(firstAccount, price.toStringAsFixed(0)),
    ];

    double selectedTotal() => candidates
        .where((t) => selectedIds.contains(t.id))
        .fold(0.0, (s, t) => s + t.amount);
    double linesTotal() => lines.fold(0.0, (s, l) => s + l.amount);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final total = linkMode ? selectedTotal() : linesTotal();

          return AlertDialog(
            title: Text(context.l10n.markAsBought),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.alreadyRecorded,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                          value: true,
                          label: Text(context.l10n.linkExisting,
                              style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.link, size: 16),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text(context.l10n.createNew,
                              style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.add, size: 16),
                        ),
                      ],
                      selected: {linkMode},
                      onSelectionChanged: (s) =>
                          setLocal(() => linkMode = s.first),
                    ),
                    const SizedBox(height: 14),
                    if (linkMode)
                      ..._linkSection(
                        context: context,
                        candidates: candidates,
                        selectedIds: selectedIds,
                        search: search,
                        price: price,
                        currency: currency,
                        onSearch: (v) => setLocal(() => search = v),
                        onToggle: (id) => setLocal(() {
                          if (!selectedIds.remove(id)) selectedIds.add(id);
                        }),
                      )
                    else
                      ..._createSection(
                        context: context,
                        lines: lines,
                        category: category,
                        currency: currency,
                        txProvider: txProvider,
                        onChanged: () => setLocal(() {}),
                        onCategory: (c) => setLocal(() => category = c),
                      ),
                    const SizedBox(height: 14),
                    _totalVsPlan(context, total, goal, currency),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(context.l10n.cancel),
              ),
              TextButton(
                onPressed: () async {
                  // ---- Link existing payments (nothing new created) -----
                  if (linkMode) {
                    if (selectedIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.tickPayments),
                        ),
                      );
                      return;
                    }
                    final paid = selectedTotal();
                    goalProvider.markPurchased(
                      goal.id,
                      actualAmount: paid,
                      transactionIds: selectedIds.toList(),
                    );
                    Navigator.pop(ctx);
                    _showBoughtMessage(context, goal, paid, currency);
                    return;
                  }

                  // ---- Create one expense per payment line --------------
                  // Read before the shortfall dialog is awaited below.
                  final boughtDescription =
                      context.l10n.boughtDesc(goal.name);
                  if (lines.any((l) => l.amount <= 0)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(context.l10n.amountEveryPayment)),
                    );
                    return;
                  }

                  // Warn — never block — when an account would go negative.
                  // A shortfall usually just means income wasn't entered yet.
                  final byAccount = <AccountType, double>{};
                  for (final l in lines) {
                    byAccount[l.account] =
                        (byAccount[l.account] ?? 0) + l.amount;
                  }
                  final short = byAccount.entries
                      .where((e) =>
                          e.value > (txProvider.accountBalances[e.key] ?? 0))
                      .toList();
                  if (short.isNotEmpty) {
                    final proceed = await showDialog<bool>(
                      context: ctx,
                      builder: (warnCtx) => AlertDialog(
                        title: Text(context.l10n.moreThanHolds),
                        content: Text(
                          '${short.map((e) => context.l10n.accountShows(accountName(context, e.key), currency.formatCompact(txProvider.accountBalances[e.key] ?? 0))).join('\n')}\n\n'
                          '${context.l10n.recordNegative}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(warnCtx, false),
                            child: Text(context.l10n.goBack),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(warnCtx, true),
                            child: Text(context.l10n.recordAnyway),
                          ),
                        ],
                      ),
                    );
                    if (proceed != true) return;
                  }

                  final stamp = DateTime.now().millisecondsSinceEpoch;
                  final ids = <String>[];
                  for (var i = 0; i < lines.length; i++) {
                    final id = 'goalbuy_${stamp}_$i';
                    ids.add(id);
                    txProvider.addTransaction(
                      Transaction(
                        id: id,
                        type: TransactionType.expense,
                        category: category,
                        amount: lines[i].amount,
                        description: boughtDescription,
                        date: DateTime.now(),
                        account: lines[i].account,
                      ),
                    );
                  }
                  final paid = linesTotal();
                  goalProvider.markPurchased(
                    goal.id,
                    actualAmount: paid,
                    transactionIds: ids,
                  );

                  // The warning above is awaited, so the user may have
                  // navigated away — check before touching context.
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  if (!context.mounted) return;
                  _showBoughtMessage(context, goal, paid, currency);
                },
                child: Text(context.l10n.confirm),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Checklist of expenses from history; several can be ticked for a split
  /// payment. Amounts close to the price are marked as a hint, never chosen.
  List<Widget> _linkSection({
    required BuildContext context,
    required List<Transaction> candidates,
    required Set<String> selectedIds,
    required String search,
    required double price,
    required CurrencyProvider currency,
    required ValueChanged<String> onSearch,
    required ValueChanged<String> onToggle,
  }) {
    final q = search.trim().toLowerCase();
    final shown = candidates.where((t) =>
        q.isEmpty ||
        t.description.toLowerCase().contains(q) ||
        t.amount.toStringAsFixed(0).contains(q));

    return [
      Text(
        candidates.isEmpty
            ? context.l10n.noExpensesToLink
            : context.l10n.tickEveryPayment,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      if (candidates.isNotEmpty) ...[
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            hintText: context.l10n.searchNameAmount,
            prefixIcon: const Icon(Icons.search, size: 20),
            isDense: true,
          ),
          onChanged: onSearch,
        ),
      ],
      const SizedBox(height: 10),
      ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 240),
        child: ListView(
          shrinkWrap: true,
          children: shown.map((t) {
            final isSel = selectedIds.contains(t.id);
            final close = (t.amount - price).abs() <= price * 0.15;
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 6),
              color: isSel
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSel ? AppTheme.primaryColor : Colors.transparent,
                ),
              ),
              child: ListTile(
                dense: true,
                onTap: () => onToggle(t.id),
                leading: Icon(
                  isSel ? Icons.check_box : Icons.check_box_outline_blank,
                  size: 20,
                  color: isSel ? AppTheme.primaryColor : Colors.grey,
                ),
                title: Text(
                  displayDescription(context, t.description),
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${accountName(context, t.account)} · ${formatDay(context, t.date, withYear: t.date.year != DateTime.now().year)}'
                  '${close ? context.l10n.matchesPrice : ''}',
                  style: TextStyle(
                    fontSize: 11,
                    color: close ? AppTheme.primaryColor : AppTheme.textLight,
                  ),
                ),
                trailing: Text(
                  currency.formatCompact(t.amount),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ];
  }

  /// One row per account paid from, plus the expense category.
  List<Widget> _createSection({
    required BuildContext context,
    required List<_PaymentLine> lines,
    required Category category,
    required CurrencyProvider currency,
    required TransactionProvider txProvider,
    required VoidCallback onChanged,
    required ValueChanged<Category> onCategory,
  }) {
    return [
      Text(
        context.l10n.recordWhatPaid,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      const SizedBox(height: 12),
      for (var i = 0; i < lines.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: DropdownButtonFormField<AccountType>(
                  value: lines[i].account,
                  isExpanded: true,
                  isDense: true,
                  decoration: InputDecoration(labelText: context.l10n.paidFrom),
                  items: AccountType.values
                      .map((a) => DropdownMenuItem(
                            value: a,
                            child: Text(accountName(context, a),
                                style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      lines[i].account = v;
                      onChanged();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: TextField(
                  controller: lines[i].controller,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => onChanged(),
                  decoration: InputDecoration(
                    labelText: context.l10n.amount,
                    suffixText: currency.code,
                    isDense: true,
                  ),
                ),
              ),
              if (lines.length > 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  color: AppTheme.expenseColor,
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    lines.removeAt(i);
                    onChanged();
                  },
                ),
            ],
          ),
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () {
            // Suggest an account not used yet.
            final used = lines.map((l) => l.account).toSet();
            final next = AccountType.values.firstWhere(
              (a) => !used.contains(a),
              orElse: () => AccountType.cash,
            );
            lines.add(_PaymentLine(next, ''));
            onChanged();
          },
          icon: const Icon(Icons.add, size: 18),
          label: Text(context.l10n.addAnotherPayment),
        ),
      ),
      const SizedBox(height: 4),
      DropdownButtonFormField<Category>(
        value: category,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: context.l10n.expenseCategory,
          prefixIcon: const Icon(Icons.category_outlined),
        ),
        items: Category.values
            .where((c) => c != Category.income)
            .map((c) => DropdownMenuItem(
                  value: c,
                  child: Row(
                    children: [
                      Icon(c.icon, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      Text(categoryLabel(context, c),
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null) onCategory(v);
        },
      ),
    ];
  }

  /// Live "Total paid X · planned Y" line so the real price is clear before
  /// confirming — the goal is completed at THIS amount.
  Widget _totalVsPlan(BuildContext context, double total, Goal goal,
      CurrencyProvider currency) {
    final planned = goal.targetAmount;
    final diff = planned - total;
    final String note;
    final Color color;
    if (total <= 0) {
      note = context.l10n.nothingSelected;
      color = AppTheme.textSecondary;
    } else if (diff > 0) {
      note = context.l10n.underYourPrice(currency.formatCompact(diff));
      color = AppTheme.incomeColor;
    } else if (diff < 0) {
      note = context.l10n.overYourPrice(currency.formatCompact(-diff));
      color = AppTheme.accentDark;
    } else {
      note = context.l10n.exactlyYourPrice;
      color = AppTheme.incomeColor;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.totalPaidPrice(currency.formatCompact(total), currency.formatCompact(planned)),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(note, style: TextStyle(fontSize: 12, color: color)),
          if (total > 0)
            Text(
              context.l10n.completedAt(currency.formatCompact(total)),
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary),
            ),
        ],
      ),
    );
  }

  /// After marking bought: the "Goal completed" celebration the first time,
  /// otherwise (e.g. bought again after an undo) a plain message.
  /// [goal] is the goal as it was BEFORE purchase, so its reserved amount is
  /// still known for the "returned to available" line.
  Future<void> _showBoughtMessage(BuildContext context, Goal goal, double paid,
      CurrencyProvider currency) async {
    final leftover = goal.currentAmount - paid;
    final underPlan = goal.plannedAmount - paid;
    final span = savingSpanText(context, goal);
    final l = context.l10n;

    final lines = <String>[
      underPlan > 0
          ? l.celebratePaidUnder(goal.name, currency.formatCompact(paid),
              currency.formatCompact(underPlan))
          : l.celebratePaid(goal.name, currency.formatCompact(paid)),
      if (span.isNotEmpty) l.celebrateSavedOver(span),
      if (leftover > 0) l.celebrateReturned(currency.formatCompact(leftover)),
    ];

    final shown = await showGoalCelebration(
      context,
      goal: goal,
      kind: GoalCelebrationKind.completed,
      title: l.celebrateCompletedTitle,
      lines: lines,
      primaryLabel: l.done,
      secondaryLabel: l.startNewGoal,
      onSecondary: () {
        if (context.mounted) showGoalDialog(context);
      },
    );
    if (shown || !context.mounted) return;

    final parts = <String>[context.l10n.goalCompletedAt(currency.formatCompact(paid))];
    if (leftover > 0) {
      parts.add(context.l10n.returnedToAvailable(currency.formatCompact(leftover)));
    }
    if (underPlan > 0) {
      parts.add(context.l10n.underPlanParty(currency.formatCompact(underPlan)));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(parts.join(' '))),
    );
  }

  /// Undo a purchase. Expenses FinWise created (id starts with `goalbuy_`)
  /// are deleted; payments that already existed and were merely linked are
  /// kept and simply unlinked — deleting them would destroy real records the
  /// user entered or SMS detected.
  void _confirmUndoPurchase(BuildContext context, Goal goal) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    final ids = goal.purchaseTransactionIds;
    final created = ids.where((id) => id.startsWith('goalbuy_')).toList();
    final linkedCount = ids.length - created.length;

    final parts = <String>[];
    if (created.isNotEmpty) {
      parts.add(
          context.l10n.undoCreatedDeleted(created.length));
    }
    if (linkedCount > 0) {
      parts.add(
          context.l10n.undoLinkedStay(linkedCount));
    }
    parts.add(
        context.l10n.willBeReservedAgain(currency.formatCompact(goal.currentAmount)));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.undoPurchase),
        content: Text('${context.l10n.reopenGoal(goal.name)}\n\n${parts.join('\n')}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final txProvider =
                  Provider.of<TransactionProvider>(context, listen: false);
              for (final id in created) {
                txProvider.removeTransaction(id);
              }
              Provider.of<GoalProvider>(context, listen: false)
                  .undoPurchase(goal.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    created.isNotEmpty
                        ? context.l10n.undoneCreatedRemoved
                        : context.l10n.undoneKept,
                  ),
                ),
              );
            },
            child: Text(context.l10n.undo),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Goal goal) {
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    final reserved = goal.currentAmount;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteGoal),
        content: Text(
          reserved > 0
              ? context.l10n.deleteGoalReserved(goal.name, currency.formatCompact(reserved))
              : context.l10n.deleteGoalNoUndo(goal.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              final provider =
                  Provider.of<GoalProvider>(context, listen: false);
              // Release first so the money is explicitly returned, then remove.
              if (reserved > 0) {
                provider.releaseAll(goal.id, note: context.l10n.noteGoalDeleted);
              }
              provider.removeGoal(goal.id);
              Navigator.pop(ctx); // dialog
              Navigator.pop(context); // details screen
              if (reserved > 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.l10n.returnedToBalance(currency.formatCompact(reserved)),
                    ),
                  ),
                );
              }
            },
            child: Text(context.l10n.delete),
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

/// One payment in "Create new": which account, and how much.
class _PaymentLine {
  AccountType account;
  final TextEditingController controller;

  _PaymentLine(this.account, String amount)
      : controller = TextEditingController(text: amount);

  double get amount => double.tryParse(controller.text.trim()) ?? 0;
}

/// Turns a [GoalError] code into a message in the current language.
String goalErrorText(BuildContext context, String code) {
  final l = context.l10n;
  switch (code) {
    case GoalError.amount:
      return l.enterAmountAbove0;
    case GoalError.overRelease:
      return l.errOverRelease;
    case GoalError.overReleaseAccount:
      return l.errOverReleaseAccount;
    default:
      return l.errGoalNotFound;
  }
}
