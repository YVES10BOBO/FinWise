import 'package:intl/intl.dart';
import 'transaction.dart';

/// Money in / spent / left for a list of transactions. One definition used
/// by both the Home card and History, so their figures always agree.
///
/// Transfers between the user's own accounts are neither income nor
/// spending, and legacy `Category.savings` entries are money set aside,
/// not consumption — both are excluded from "Spent".
class PeriodSummary {
  final double moneyIn;
  final double spent;
  final int count;

  const PeriodSummary(this.moneyIn, this.spent, this.count);

  double get left => moneyIn - spent;

  factory PeriodSummary.of(Iterable<Transaction> transactions) {
    double moneyIn = 0, spent = 0;
    var count = 0;
    for (final t in transactions) {
      count++;
      if (t.type == TransactionType.income) {
        moneyIn += t.amount;
      } else if (t.type == TransactionType.transfer ||
          t.category == Category.savings) {
        continue;
      } else {
        spent += t.amount;
      }
    }
    return PeriodSummary(moneyIn, spent, count);
  }
}

/// Which kind of window is being shown.
enum OverviewPeriodKind { month, year, lastDays, custom, allTime }

/// A date window used to analyse transactions: [start] inclusive, [end]
/// exclusive. Shared by the Home overview card and the History screen so
/// both always describe the same period.
///
/// Month and year periods can be stepped backwards/forwards; "last N days",
/// custom ranges and "all time" are fixed windows.
class OverviewPeriod {
  final OverviewPeriodKind kind;
  final DateTime start;
  final DateTime end;

  const OverviewPeriod._(this.kind, this.start, this.end);

  factory OverviewPeriod.month(int year, int month) => OverviewPeriod._(
      OverviewPeriodKind.month, DateTime(year, month), DateTime(year, month + 1));

  factory OverviewPeriod.year(int year) => OverviewPeriod._(
      OverviewPeriodKind.year, DateTime(year), DateTime(year + 1));

  /// The last [days] days, including today.
  factory OverviewPeriod.lastDays(int days) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return OverviewPeriod._(OverviewPeriodKind.lastDays,
        DateTime(now.year, now.month, now.day - days + 1), tomorrow);
  }

  /// [from] and [to] are both inclusive calendar days.
  factory OverviewPeriod.custom(DateTime from, DateTime to) => OverviewPeriod._(
      OverviewPeriodKind.custom,
      DateTime(from.year, from.month, from.day),
      DateTime(to.year, to.month, to.day + 1));

  /// Every transaction ever recorded.
  factory OverviewPeriod.allTime() => OverviewPeriod._(
      OverviewPeriodKind.allTime, DateTime(1970), DateTime(9999));

  static OverviewPeriod thisMonth() {
    final now = DateTime.now();
    return OverviewPeriod.month(now.year, now.month);
  }

  bool contains(DateTime d) => !d.isBefore(start) && d.isBefore(end);

  bool get canStep =>
      kind == OverviewPeriodKind.month || kind == OverviewPeriodKind.year;

  /// Stepping forward is pointless once the next period is in the future.
  bool get canStepForward => canStep && end.isBefore(DateTime.now());

  /// True while today falls inside the window (it is still "in progress").
  bool get isCurrent => contains(DateTime.now());

  OverviewPeriod step(int delta) {
    switch (kind) {
      case OverviewPeriodKind.month:
        return OverviewPeriod.month(start.year, start.month + delta);
      case OverviewPeriodKind.year:
        return OverviewPeriod.year(start.year + delta);
      default:
        return this;
    }
  }

  /// How many months the window spans, used to scale the monthly income
  /// target so "safe to spend" stays meaningful for any length of period.
  /// "All time" has no fixed length, so it is measured from [earliest]
  /// (the oldest transaction) to today.
  double monthsSpanned({DateTime? earliest}) {
    switch (kind) {
      case OverviewPeriodKind.month:
        return 1;
      case OverviewPeriodKind.year:
        return 12;
      case OverviewPeriodKind.allTime:
        if (earliest == null) return 1;
        final months = DateTime.now().difference(earliest).inDays / 30.4375;
        return months < 1 ? 1 : months;
      default:
        return end.difference(start).inDays / 30.4375;
    }
  }

  String get label {
    final now = DateTime.now();
    switch (kind) {
      case OverviewPeriodKind.month:
        final name = DateFormat('MMMM').format(start);
        if (start.year == now.year && start.month == now.month) {
          return 'This month · $name';
        }
        final prev = DateTime(now.year, now.month - 1);
        if (start.year == prev.year && start.month == prev.month) {
          return 'Last month · $name';
        }
        return start.year == now.year
            ? name
            : DateFormat('MMMM yyyy').format(start);
      case OverviewPeriodKind.year:
        return start.year == now.year
            ? 'This year · ${start.year}'
            : '${start.year}';
      case OverviewPeriodKind.lastDays:
        return 'Last ${end.difference(start).inDays} days';
      case OverviewPeriodKind.custom:
        final last = end.subtract(const Duration(days: 1));
        final fmt = start.year == last.year && start.year == now.year
            ? DateFormat('d MMM')
            : DateFormat('d MMM yyyy');
        return '${fmt.format(start)} – ${fmt.format(last)}';
      case OverviewPeriodKind.allTime:
        return 'All time';
    }
  }
}
