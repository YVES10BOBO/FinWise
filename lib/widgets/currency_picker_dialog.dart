import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/currency.dart';
import '../providers/currency_provider.dart';
import '../theme/app_theme.dart';

/// A simple list dialog letting the user pick their home currency.
/// Call `showCurrencyPicker(context)` from anywhere in the app.
Future<void> showCurrencyPicker(BuildContext context) async {
  final currencyProvider = context.read<CurrencyProvider>();

  final selected = await showModalBottomSheet<AppCurrency>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _CurrencyPickerSheet(current: currencyProvider.currency),
  );

  if (selected != null && context.mounted) {
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
