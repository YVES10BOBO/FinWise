import 'package:flutter/foundation.dart';
import '../models/overview_period.dart';

/// The period the user is currently looking at. Shared app-wide so that
/// choosing "Last 60 days" on the Home card also shows exactly those
/// transactions in History, and vice versa. Starts on the current month.
class PeriodProvider with ChangeNotifier {
  OverviewPeriod _period = OverviewPeriod.thisMonth();

  OverviewPeriod get period => _period;

  void setPeriod(OverviewPeriod period) {
    _period = period;
    notifyListeners();
  }

  void step(int delta) => setPeriod(_period.step(delta));
}
