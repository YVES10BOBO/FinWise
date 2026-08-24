import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/goal_provider.dart';
import '../screens/onboarding/financial_questionnaire_screen.dart';
import '../services/export_service.dart';
import '../services/account_deletion_service.dart';
import '../screens/calendar_view_screen.dart';
import '../providers/currency_provider.dart';
import '../providers/income_provider.dart';
import '../widgets/currency_picker_dialog.dart';
import '../widgets/sms_auto_detect_tile.dart';
import '../widgets/app_lock_tile.dart';
import 'legal_screen.dart';
import 'faq_screen.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Section
          _SettingsSection(
            title: 'Profile',
            children: [
              _SettingsTile(
                icon: Icons.person,
                title: 'Profile & onboarding',
                subtitle: 'Update your name and currency',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const FinancialQuestionnaireScreen(),
                    ),
                  );
                },
              ),
              Consumer2<IncomeProvider, CurrencyProvider>(
                builder: (context, income, currency, _) {
                  final subtitle = income.isSet
                      ? '${currency.formatCompact(income.monthlyIncome)}/month — used to measure your savings rate'
                      : 'Set an optional target to measure your savings rate';
                  return _SettingsTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Income target',
                    subtitle: subtitle,
                    onTap: () => _showIncomeDialog(context),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out and return to login',
                onTap: () => _showLogoutDialog(context),
                iconColor: AppTheme.expenseColor,
              ),
              // Required by Google Play for any app with user accounts, and
              // promised in our privacy policy.
              _SettingsTile(
                icon: Icons.person_remove_outlined,
                title: 'Delete account',
                subtitle: 'Permanently erase your account and all data',
                onTap: () => _showDeleteAccountDialog(context),
                iconColor: AppTheme.expenseColor,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Data Section
          _SettingsSection(
            title: 'Data Management',
            children: [
              _SettingsTile(
                icon: Icons.calendar_today,
                title: 'Calendar View',
                subtitle: 'View transactions by date',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalendarViewScreen(),
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.file_download,
                title: 'Export to CSV',
                subtitle: 'Download transactions as CSV',
                onTap: () => _exportData(context, 'csv'),
              ),
              _SettingsTile(
                icon: Icons.picture_as_pdf,
                title: 'Export Report',
                subtitle: 'Generate transaction report',
                onTap: () => _exportData(context, 'pdf'),
              ),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: 'Clear All Transactions',
                subtitle: 'Remove all transaction data',
                onTap: () => _showClearTransactionsDialog(context),
                iconColor: AppTheme.expenseColor,
              ),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: 'Clear All Goals',
                subtitle: 'Remove all goal data',
                onTap: () => _showClearGoalsDialog(context),
                iconColor: AppTheme.expenseColor,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Security
          const _SettingsSection(
            title: 'Security',
            children: [AppLockTile()],
          ),
          const SizedBox(height: 20),
          // Automation Section (Beta)
          const _SettingsSection(
            title: 'Automation',
            children: [
              SmsAutoDetectTile(),
              // The "Test SMS Parser" developer tool lives at
              // screens/sms_parser_test_screen.dart. It is intentionally NOT
              // linked here — it's a debugging aid, not a user feature.
            ],
          ),
          const SizedBox(height: 20),
          // Appearance Section
          _SettingsSection(
            title: 'Appearance',
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Toggle dark theme'),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.setTheme(value);
                    },
                    secondary: Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: AppTheme.primaryColor,
                    ),
                  );
                },
              ),
              Consumer<CurrencyProvider>(
                builder: (context, currencyProvider, child) {
                  return _SettingsTile(
                    icon: Icons.language,
                    title: 'Currency',
                    subtitle:
                        '${currencyProvider.currency.label} (${currencyProvider.currency.code})',
                    onTap: () => showCurrencyPicker(context),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // About Section
          _SettingsSection(
            title: 'About',
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: '1.0.0 (Build 1)',
                onTap: null,
              ),
              _SettingsTile(
                icon: Icons.help_outline,
                title: 'FAQ & Help',
                subtitle: 'Common questions, or contact us directly',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FaqScreen()),
                ),
              ),
              _SettingsTile(
                icon: Icons.description,
                title: 'Privacy Policy',
                subtitle: 'What we collect and what stays on your phone',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LegalScreen.privacy()),
                ),
              ),
              _SettingsTile(
                icon: Icons.gavel_outlined,
                title: 'Terms & Conditions',
                subtitle: 'The agreement you accepted at sign-up',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LegalScreen.terms()),
                ),
              ),
              // "Rate App" removed until the app is live on Play — a button
              // that says "coming soon" looks unfinished to reviewers. Once
              // published, point it at:
              // https://play.google.com/store/apps/details?id=com.yves.finwise
            ],
          ),
        ],
      ),
    );
  }

  void _showClearTransactionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Transactions'),
        content: const Text(
          'Are you sure you want to delete all transactions? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Safe bulk clear (no iterate-while-deleting) — updates the UI
              // immediately and removes everything, cloud included.
              final provider =
                  Provider.of<TransactionProvider>(context, listen: false);
              provider.clearAllTransactions();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All transactions cleared')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.expenseColor,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showIncomeDialog(BuildContext context) {
    final income = Provider.of<IncomeProvider>(context, listen: false);
    final currencyCode =
        Provider.of<CurrencyProvider>(context, listen: false).code;
    final controller = TextEditingController(
      text: income.amount != null ? income.amount!.toStringAsFixed(0) : '',
    );
    String frequency = income.frequency;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Income target'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'A planning target only — used to measure your savings rate. '
                'It is never added to your balance.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount ($currencyCode)',
                  prefixIcon:
                      const Icon(Icons.account_balance_wallet_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: frequency,
                decoration: const InputDecoration(
                  labelText: 'How often',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: const ['Daily', 'Weekly', 'Monthly', 'Yearly']
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setLocal(() => frequency = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                income.setIncome(null, frequency);
                Navigator.pop(ctx);
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                final value = double.tryParse(controller.text.trim());
                income.setIncome(value, frequency);
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, String format) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final currency = Provider.of<CurrencyProvider>(context, listen: false).currency;
    final transactions = provider.transactions;

    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export')),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      if (format == 'csv') {
        await ExportService.exportToCSV(transactions, currency: currency);
      } else {
        await ExportService.exportToPDF(transactions, currency: currency);
      }

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transactions exported successfully as $format'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppTheme.expenseColor,
          ),
        );
      }
    }
  }

  void _showClearGoalsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Goals'),
        content: const Text(
          'Are you sure you want to delete all goals? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Safe bulk clear (no iterate-while-deleting). Reserved money
              // returns to available automatically once the goals are gone.
              Provider.of<GoalProvider>(context, listen: false)
                  .clearAllGoals();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All goals cleared')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.expenseColor,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  /// Two-step account deletion: an explicit warning, then password
  /// confirmation. Deliberately high-friction — this is irreversible.
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text(
          'This permanently deletes:\n\n'
          '• All your transactions\n'
          '• All your goals and reserved money\n'
          '• Your profile and settings\n'
          '• Your sign-in account\n\n'
          'This cannot be undone. Consider exporting your data first '
          '(Data Management → Export).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: AppTheme.expenseColor),
            onPressed: () {
              Navigator.pop(ctx);
              _confirmDeleteWithPassword(context);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteWithPassword(BuildContext context) {
    final passwordController = TextEditingController();
    bool busy = false;
    String? error;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Confirm it\'s you'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the password you use to sign in to FinWise'
                '${FirebaseAuth.instance.currentUser?.email != null ? ' (${FirebaseAuth.instance.currentUser!.email})' : ''}.',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 6),
              const Text(
                'This is not your app-lock PIN.',
                style: TextStyle(fontSize: 11, color: AppTheme.textLight),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                enabled: !busy,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Sign-in password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error!,
                  style: const TextStyle(
                      color: AppTheme.expenseColor, fontSize: 12),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: AppTheme.expenseColor),
              onPressed: busy
                  ? null
                  : () async {
                      if (passwordController.text.isEmpty) {
                        setLocal(() => error = 'Please enter your password');
                        return;
                      }
                      setLocal(() {
                        busy = true;
                        error = null;
                      });

                      final result = await AccountDeletionService()
                          .deleteAccount(
                              password: passwordController.text);

                      if (result != null) {
                        setLocal(() {
                          busy = false;
                          error = result;
                        });
                        return;
                      }

                      // Deleted — return to the login screen.
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        Navigator.of(context, rootNavigator: true)
                            .pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const InitialScreen()),
                          (route) => false,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Your account has been deleted'),
                          ),
                        );
                      }
                    },
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Delete forever'),
            ),
          ],
        ),
      ),
    );
  }

  // The old privacy-policy dialog was replaced by LegalScreen.privacy(), which
  // accurately covers SMS reading, notifications, the app lock and what stays
  // on-device. That text must stay in sync with the Play Data Safety form.

  // Profile picture upload removed — Firebase Storage requires the paid Blaze
  // plan, and photo collection was flagged by Play Store review. Users get an
  // initial-letter avatar instead.

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? You will need to login again to access the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Close dialog first
              Navigator.pop(context);
              
              // Firebase logout + clear local cached profile/onboarding (avoid mixing users on same device)
              await FirebaseAuth.instance.signOut();
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user_name');
              await prefs.remove('user_income');
              await prefs.remove('income_frequency');
              await prefs.remove('user_spending');
              await prefs.remove('spending_frequency');
              await prefs.remove('spending_style');
              await prefs.remove('user_categories');
              await prefs.remove('questionnaire_complete');
              await prefs.remove('onboarding_complete');
              
              if (context.mounted) {
                // Show logout success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('You\'ve been logged out successfully'),
                      ],
                    ),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
                
                // Small delay to show the message, then navigate
                await Future.delayed(const Duration(milliseconds: 800));
                
                if (context.mounted) {
                  // Navigate to InitialScreen which will show login screen
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const InitialScreen()),
                    (route) => false, // Remove all previous routes
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.expenseColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.primaryColor).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: AppTheme.textLight)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
