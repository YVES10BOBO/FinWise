import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../theme/app_theme.dart';
import '../widgets/transaction_item.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        _loadEvents(provider.transactions);
        final selectedEvents = _getEventsForDay(_selectedDay);
        final dayTotal = selectedEvents.fold<double>(
          0.0,
          (sum, t) => sum + (t.type == TransactionType.income ? t.amount : -t.amount),
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Calendar View'),
            actions: [
              PopupMenuButton<CalendarFormat>(
                icon: const Icon(Icons.view_module),
                onSelected: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: CalendarFormat.month,
                    child: Text('Month'),
                  ),
                  const PopupMenuItem(
                    value: CalendarFormat.twoWeeks,
                    child: Text('2 Weeks'),
                  ),
                  const PopupMenuItem(
                    value: CalendarFormat.week,
                    child: Text('Week'),
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
                      color: Colors.black.withOpacity(0.05),
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
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
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
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.secondaryColor.withOpacity(0.1),
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
                          DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${selectedEvents.length} transaction${selectedEvents.length != 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      NumberFormat('#,###').format(dayTotal.abs()),
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
                            const Text('📅', style: TextStyle(fontSize: 64)),
                            const SizedBox(height: 20),
                            const Text(
                              'No transactions on this day',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
                              // TODO: Implement edit
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
