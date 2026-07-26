import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/goal_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../screens/onboarding/financial_questionnaire_screen.dart';
import '../services/export_service.dart';
import '../services/profile_picture_service.dart';
import '../screens/calendar_view_screen.dart';
import '../providers/currency_provider.dart';
import '../providers/income_provider.dart';
import '../widgets/currency_picker_dialog.dart';
import '../widgets/sms_auto_detect_tile.dart';
import '../widgets/app_lock_tile.dart';
import '../screens/sms_parser_test_screen.dart';
import 'legal_screen.dart';
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
                icon: Icons.camera_alt,
                title: 'Change Profile Picture',
                subtitle: 'Update your profile photo',
                onTap: () => _changeProfilePicture(context),
              ),
              _SettingsTile(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out and return to login',
                onTap: () => _showLogoutDialog(context),
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
          _SettingsSection(
            title: 'Automation (Beta)',
            children: [
              const SmsAutoDetectTile(),
              _SettingsTile(
                icon: Icons.bug_report_outlined,
                title: 'Test SMS Parser',
                subtitle: 'Paste a sample SMS to see what gets detected',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SmsParserTestScreen(),
                    ),
                  );
                },
              ),
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
                    icon: Icons.attach_money,
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
                title: 'Help & Support',
                subtitle: 'Get help using FinWise',
                onTap: () => _showHelpDialog(context),
              ),
              _SettingsTile(
                icon: Icons.description,
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap: () {
                  _showPrivacyPolicy(context);
                },
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
              _SettingsTile(
                icon: Icons.star_outline,
                title: 'Rate App',
                subtitle: 'Love FinWise? Rate us!',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thank you! Rating feature coming soon.'),
                    ),
                  );
                },
              ),
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HelpSection(
                title: 'Getting Started',
                items: [
                  'Add your first transaction using the + button',
                  'Set up financial goals to track savings',
                  'View spending by category in Budget tab',
                  'Check your financial health score on Home',
                ],
              ),
              const SizedBox(height: 16),
              _HelpSection(
                title: 'Managing Transactions',
                items: [
                  'Tap + button to add income or expense',
                  'Select category from chips',
                  'Swipe left on transaction to delete',
                  'Tap transaction to edit',
                ],
              ),
              const SizedBox(height: 16),
              _HelpSection(
                title: 'Categories',
                items: [
                  'Add custom categories during onboarding',
                  'Add more categories when adding transactions',
                  'View spending by category in Budget tab',
                  'Delete custom categories anytime',
                ],
              ),
              const SizedBox(height: 16),
              _HelpSection(
                title: 'Tips',
                items: [
                  'Track all expenses for accurate insights',
                  'Set realistic financial goals',
                  'Check AI tips for budget recommendations',
                  'Export data for backup',
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'FinWise Privacy Policy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              _PrivacySection(
                title: '1. Information We Collect',
                content:
                    '• Account Information: Email address, name\n'
                    '• Financial Data: Transactions, income, spending categories, financial goals\n'
                    '• Profile Data: Profile picture (optional)\n'
                    '• Device Data: Cached data stored locally for offline access',
              ),
              const SizedBox(height: 12),
              _PrivacySection(
                title: '2. How We Use Your Information',
                content:
                    '• Provide financial tracking and budgeting features\n'
                    '• Sync your data across devices when logged in\n'
                    '• Generate financial insights and reports\n'
                    '• Improve app functionality and user experience',
              ),
              const SizedBox(height: 12),
              _PrivacySection(
                title: '3. Data Storage & Security',
                content:
                    '• Your data is stored securely using Firebase (Google Cloud Platform)\n'
                    '• All data is encrypted in transit and at rest\n'
                    '• Each user account is private and isolated\n'
                    '• We use Firebase Authentication and security rules to protect your data',
              ),
              const SizedBox(height: 12),
              _PrivacySection(
                title: '4. Third-Party Services',
                content:
                    '• We use Firebase (Google) for authentication, database, and storage\n'
                    '• Firebase\'s privacy policy applies to their services\n'
                    '• We do not share your data with other third parties\n'
                    '• We do not sell your personal information',
              ),
              const SizedBox(height: 12),
              _PrivacySection(
                title: '5. Your Rights',
                content:
                    '• Access: View all your data within the app\n'
                    '• Export: Download your transactions as CSV or PDF\n'
                    '• Delete: Remove transactions, goals, or your entire account\n'
                    '• Control: Logout anytime to stop cloud sync',
              ),
              const SizedBox(height: 12),
              _PrivacySection(
                title: '6. Data Retention',
                content:
                    '• Your data is retained until you delete it\n'
                    '• When you delete your account, all data is permanently removed\n'
                    '• Local cached data is cleared when you logout',
              ),
              const SizedBox(height: 12),
              _PrivacySection(
                title: '7. Children\'s Privacy',
                content:
                    'FinWise is not intended for users under 13 years of age. We do not knowingly collect personal information from children.',
              ),
              const SizedBox(height: 12),
              _PrivacySection(
                title: '8. Changes to This Policy',
                content:
                    'We may update this privacy policy from time to time. The "Last Updated" date will reflect the most recent changes.',
              ),
              const SizedBox(height: 12),
              const Text(
                'Last Updated: January 2026\n\n'
                'For questions or concerns about your privacy, please contact us through the app\'s Help & Support section.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeProfilePicture(BuildContext context) async {
    try {
      // Show dialog to choose source
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Profile Picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (source == null) return;

      // Pick image
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image == null) return;

      // Upload image to backend (Firebase Storage) and update Firestore profile
      final service = ProfilePictureService();
      await service.uploadProfilePicture(File(image.path));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated!'),
            backgroundColor: AppTheme.primaryColor,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.expenseColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

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

class _HelpSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _HelpSection({required this.title, required this.items});

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
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppTheme.primaryColor)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

class _PrivacySection extends StatelessWidget {
  final String title;
  final String content;

  const _PrivacySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 13,
            height: 1.6,
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
