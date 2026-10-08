import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_item.dart';
import '../widgets/add_transaction_dialog.dart';
import '../providers/currency_provider.dart';
import '../l10n/l10n_helpers.dart';

class CalendarViewScreen extends StatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, List<Transaction>> _events = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  List<Transaction> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _loadEvents(List<Transaction> transactions) {
    _events = {};
    for (var transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      if (_events[date] == null) {
        _events[date] = [];
      }
      _events[date]!.add(transaction);
    }
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

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        _loadEvents(provider.transactions);
        final selectedEvents = _getEventsForDay(_selectedDay);
        final dayTotal = selectedEvents.fold<double>(
          0.0,
          // Transfers are excluded — money moving between the user's own
          // accounts is neither a gain nor a loss for the day's net figure.
          (sum, t) => sum +
              switch (t.type) {
                TransactionType.income => t.amount,
                TransactionType.expense => -t.amount,
                TransactionType.transfer => 0.0,
              },
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.calendarView),
            actions: [
              PopupMenuButton<CalendarFormat>(
                icon: const Icon(Icons.view_module),
                onSelected: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: CalendarFormat.month,
                    child: Text(context.l10n.calMonth),
                  ),
                  PopupMenuItem(
                    value: CalendarFormat.twoWeeks,
                    child: Text(context.l10n.calTwoWeeks),
                  ),
                  PopupMenuItem(
                    value: CalendarFormat.week,
                    child: Text(context.l10n.calWeek),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Calendar
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TableCalendar<Transaction>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  eventLoader: _getEventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: const TextStyle(color: AppTheme.primaryColor),
                    selectedDecoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    // Month title in the app's language ("Ukwakira 2026").
                    titleTextFormatter: (date, _) =>
                        '${monthName(context, date)} ${date.year}',
                    formatButtonVisible: false,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    leftChevronIcon: const Icon(Icons.chevron_left, color: AppTheme.primaryColor),
                    rightChevronIcon: const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarBuilders: CalendarBuilders(
                    // Weekday headers in the app's language.
                    dowBuilder: (context, day) => Center(
                      child: Text(
                        weekdayShort(context, day),
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ),
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return const SizedBox.shrink();
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Selected Day Summary
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                      AppTheme.secondaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatFullDate(context, _selectedDay),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.txCount(selectedEvents.length),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      context.watch<CurrencyProvider>().formatCompact(dayTotal.abs()),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: dayTotal >= 0 ? AppTheme.incomeColor : AppTheme.expenseColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Transactions for Selected Day
              Expanded(
                child: selectedEvents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              context.l10n.noTxThisDay,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              context.l10n.addForThisDate,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: selectedEvents.length,
                        itemBuilder: (context, index) {
                          return TransactionItem(
                            transaction: selectedEvents[index],
                            onEdit: () {
                              _editTransaction(
                                context,
                                selectedEvents[index],
                              );
                            },
                            onDelete: () {
                              provider.removeTransaction(selectedEvents[index].id);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
