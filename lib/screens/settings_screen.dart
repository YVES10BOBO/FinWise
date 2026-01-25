import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/goal_provider.dart';
import '../screens/onboarding/profile_setup_screen.dart';
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
                title: 'Edit Profile',
                subtitle: 'Update your name and income',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileSetupScreen(),
                    ),
                  );
                },
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
                subtitle: '1.0.0',
                onTap: null,
              ),
              _SettingsTile(
                icon: Icons.description,
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap: () {
                  // TODO: Show privacy policy
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
          color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
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
