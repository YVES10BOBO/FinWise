import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/currency.dart';
import '../providers/currency_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';

/// A simple list dialog letting the user pick their home currency.
/// Call `showCurrencyPicker(context)` from anywhere in the app.
Future<void> showCurrencyPicker(BuildContext context) async {
  final currencyProvider = context.read<CurrencyProvider>();
  final previous = currencyProvider.currency;

  final selected = await showModalBottomSheet<AppCurrency>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _CurrencyPickerSheet(current: currencyProvider.currency),
  );

  if (selected == null || selected == previous || !context.mounted) return;

  // Amounts are stored as plain numbers — the currency is only a label. So
  // switching currency RE-LABELS existing records rather than converting
  // them: 500 RWF would suddenly read as 500 USD, which is a very different
  // amount of money. We don't convert (that would need live exchange rates,
  // a network dependency and an ongoing cost), so the user must be told
  // plainly before their history changes meaning.
  final hasTransactions =
      context.read<TransactionProvider>().transactions.isNotEmpty;

  if (hasTransactions) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change currency?'),
        content: Text(
          'Your existing transactions will NOT be converted.\n\n'
          'An amount recorded as 500 ${previous.code} will simply display as '
          '500 ${selected.code} — the number stays the same, only the label '
          'changes.\n\n'
          'Change currency only if you entered those amounts in '
          '${selected.code}, or if you plan to clear your data.',
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: AppTheme.accentDark),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Change to ${selected.code}'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
  }

  if (context.mounted) {
    await currencyProvider.setCurrency(selected);
  }
}

class _CurrencyPickerSheet extends StatelessWidget {
  final AppCurrency current;

  const _CurrencyPickerSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Choose your currency',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: AppCurrency.values.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final currency = AppCurrency.values[index];
                  final isSelected = currency == current;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        currency.symbol,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    title: Text('${currency.label} (${currency.code})'),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                        : null,
                    onTap: () => Navigator.pop(context, currency),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
