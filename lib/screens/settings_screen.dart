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
import '../screens/calendar_view_screen.dart';

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
                subtitle: 'Update your name, income, and categories',
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
              // Clear transactions
              final provider = Provider.of<TransactionProvider>(context, listen: false);
              for (var transaction in provider.transactions) {
                provider.removeTransaction(transaction.id);
              }
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

  Future<void> _exportData(BuildContext context, String format) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
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
        await ExportService.exportToCSV(transactions);
      } else {
        await ExportService.exportToPDF(transactions);
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
              final provider = Provider.of<GoalProvider>(context, listen: false);
              for (var goal in provider.goals) {
                provider.removeGoal(goal.id);
              }
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
        content: const SingleChildScrollView(
          child: Text(
            'FinWise Privacy Policy\n\n'
            'Data Storage:\n'
            '• All data is stored locally on your device\n'
            '• No data is shared with third parties\n'
            '• You can export your data anytime\n\n'
            'Security:\n'
            '• Your financial data is private\n'
            '• No cloud sync (until you enable it)\n'
            '• You control your data\n\n'
            'Future Features:\n'
            '• Optional cloud backup\n'
            '• Multi-device sync\n'
            '• All optional and user-controlled\n\n'
            'Last Updated: 2024',
            style: TextStyle(fontSize: 14, height: 1.6),
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
                await Future.delayed(const Duration(milliseconds: 500));
                
                if (context.mounted) {
                  // Return to the root (_InitialScreen). Use the root navigator
                  // so we also pop the Settings screen route.
                  Navigator.of(context, rootNavigator: true)
                      .popUntil((route) => route.isFirst);
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
        const SizedBox(height: 12),
        ...children,
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
