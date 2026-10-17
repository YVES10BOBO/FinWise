import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/overview_period.dart';
import '../providers/period_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_helpers.dart';

/// Opens the "Show period" popup and applies the choice to the shared
/// [PeriodProvider], so every screen that reads it updates together.
Future<void> showPeriodPicker(BuildContext context) async {
  final now = DateTime.now();
  final provider = context.read<PeriodProvider>();
  final l = context.l10n;

  // Each option returns a callback that builds its period; "Custom range"
  // returns one that opens the date-range picker. Closing the popup leaves the
  // current period unchanged.
  final choice = await showGeneralDialog<Future<OverviewPeriod?> Function()>(
    context: context,
    barrierDismissible: true,
    barrierLabel: l.showPeriod,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      final maxHeight = MediaQuery.sizeOf(ctx).height * 0.88;
      const optionCount = 9;
      final rowHeight =
          ((maxHeight - 76) / optionCount).clamp(38.0, 48.0).toDouble();

      Widget option(String label, IconData icon, OverviewPeriod? value) {
        return SizedBox(
          height: rowHeight,
          child: InkWell(
            onTap: () => Navigator.pop(
              ctx,
              value != null
                  ? () async => value
                  : () => _pickCustomRange(context, provider.period),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(icon, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 14),
                  Expanded(child: Text(label)),
                ],
              ),
            ),
          ),
        );
      }

      return SafeArea(
        child: Center(
          child: Material(
            color: Theme.of(ctx).colorScheme.surface,
            elevation: 12,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420, maxHeight: maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l.showPeriod,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  option(l.periodThisMonth, Icons.calendar_today,
                      OverviewPeriod.month(now.year, now.month)),
                  option(l.periodLastMonth, Icons.history,
                      OverviewPeriod.month(now.year, now.month - 1)),
                  option(l.periodLastDays(30), Icons.date_range,
                      OverviewPeriod.lastDays(30)),
                  option(l.periodLastDays(60), Icons.date_range,
                      OverviewPeriod.lastDays(60)),
                  option(l.periodLastDays(90), Icons.date_range,
                      OverviewPeriod.lastDays(90)),
                  option(l.periodThisYear, Icons.event_note,
                      OverviewPeriod.year(now.year)),
                  option(l.periodAllTime, Icons.all_inclusive,
                      OverviewPeriod.allTime()),
                  option(l.periodCustom, Icons.edit_calendar, null),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );

  if (choice == null || !context.mounted) return;
  final picked = await choice();
  if (picked != null) provider.setPeriod(picked);
}

/// Any from–to range, e.g. 26 September to 15 October. Both days are
/// included in full.
Future<OverviewPeriod?> _pickCustomRange(
    BuildContext context, OverviewPeriod current) async {
  if (!context.mounted) return null;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  DateTime clamp(DateTime d) => d.isAfter(today)
      ? today
      : d.isBefore(DateTime(2000))
          ? DateTime(2000)
          : d;

  final range = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2000),
    lastDate: today,
    initialDateRange: DateTimeRange(
      start: clamp(current.start),
      end: clamp(current.end.subtract(const Duration(days: 1))),
    ),
    helpText: context.l10n.selectPeriod,
    saveText: context.l10n.show,
  );
  if (range == null) return null;
  return OverviewPeriod.custom(range.start, range.end);
}

/// Compact "‹ Last 60 days ▾ ›" control. [color] lets it sit on the green
/// Home card (white) or on a plain screen (theme colour).
class PeriodSelector extends StatelessWidget {
  final Color color;
  final TextStyle? textStyle;

  /// Optional leading icon (the Home card shows its insights icon).
  final IconData? leadingIcon;

  const PeriodSelector({
    super.key,
    this.color = AppTheme.primaryColor,
    this.textStyle,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PeriodProvider>();
    final period = provider.period;

    Widget arrow(IconData icon, String tooltip, VoidCallback? onTap) {
      return IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: onTap,
        color: color,
        disabledColor: color.withValues(alpha: 0.3),
        iconSize: 22,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      );
    }

    return Row(
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, color: color, size: 18),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => showPeriodPicker(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      periodLabel(context, period),
                      style: textStyle ??
                          TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: color, size: 22),
                ],
              ),
            ),
          ),
        ),
        if (period.canStep) ...[
          arrow(Icons.chevron_left, context.l10n.previous,
              () => provider.step(-1)),
          arrow(Icons.chevron_right, context.l10n.next,
              period.canStepForward ? () => provider.step(1) : null),
        ],
      ],
    );
  }
}
