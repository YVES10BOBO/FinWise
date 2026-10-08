import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
import '../widgets/device_name_tile.dart';
import '../widgets/app_lock_tile.dart';
import 'legal_screen.dart';
import 'faq_screen.dart';
import '../main.dart';
import '../l10n/l10n_helpers.dart';
import '../providers/locale_provider.dart';
import '../services/foreground_service_handler.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Section
          _SettingsSection(
            title: l.sectionProfile,
            children: [
              _SettingsTile(
                icon: Icons.person,
                title: l.profileOnboarding,
                subtitle: l.profileOnboardingSub,
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
                      ? l.incomeTargetSet(
                          currency.formatCompact(income.monthlyIncome))
                      : l.incomeTargetUnset;
                  return _SettingsTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: l.incomeTarget,
                    subtitle: subtitle,
                    onTap: () => _showIncomeDialog(context),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.logout,
                title: l.logout,
                subtitle: l.logoutSub,
                onTap: () => _showLogoutDialog(context),
                iconColor: AppTheme.expenseColor,
              ),
              // Required by Google Play for any app with user accounts, and
              // promised in our privacy policy.
              _SettingsTile(
                icon: Icons.person_remove_outlined,
                title: l.deleteAccount,
                subtitle: l.deleteAccountSub,
                onTap: () => _showDeleteAccountDialog(context),
                iconColor: AppTheme.expenseColor,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Data Section
          _SettingsSection(
            title: l.sectionData,
            children: [
              _SettingsTile(
                icon: Icons.calendar_today,
                title: l.calendarView,
                subtitle: l.calendarViewSub,
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
                title: l.exportCsv,
                subtitle: l.exportCsvSub,
                onTap: () => _exportData(context, 'csv'),
              ),
              _SettingsTile(
                icon: Icons.picture_as_pdf,
                title: l.exportReport,
                subtitle: l.exportReportSub,
                onTap: () => _exportData(context, 'pdf'),
              ),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: l.clearTransactions,
                subtitle: l.clearTransactionsSub,
                onTap: () => _showClearTransactionsDialog(context),
                iconColor: AppTheme.expenseColor,
              ),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: l.clearGoals,
                subtitle: l.clearGoalsSub,
                onTap: () => _showClearGoalsDialog(context),
                iconColor: AppTheme.expenseColor,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Security
          _SettingsSection(
            title: l.sectionSecurity,
            children: const [AppLockTile()],
          ),
          const SizedBox(height: 20),
          // Automation Section (Beta)
          _SettingsSection(
            title: l.sectionAutomation,
            children: const [
              SmsAutoDetectTile(),
              // Sits with Automation because it's auto-detected transactions
              // from a second signed-in phone that most need identifying.
              DeviceNameTile(),
              // The old on-device "Test SMS Parser" screen was removed —
              // parsing is now covered by test/sms_transaction_parser_test.dart,
              // which checks real provider messages automatically instead of
              // needing a hidden debug screen in the shipped app.
            ],
          ),
          const SizedBox(height: 20),
          // Appearance Section
          _SettingsSection(
            title: l.sectionAppearance,
            children: [
              // English by default; anyone can switch at any time.
              Consumer<LocaleProvider>(
                builder: (context, localeProvider, _) => _SettingsTile(
                  icon: Icons.translate,
                  title: l.language,
                  subtitle: localeProvider.isKinyarwanda
                      ? l.languageKinyarwanda
                      : l.languageEnglish,
                  onTap: () => _showLanguagePicker(context),
                ),
              ),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return SwitchListTile(
                    title: Text(l.darkMode),
                    subtitle: Text(l.darkModeSub),
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
                    title: l.currency,
                    subtitle:
                        '${currencyName(context, currencyProvider.currency)} (${currencyProvider.currency.code})',
                    onTap: () => showCurrencyPicker(context),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          // About Section
          _SettingsSection(
            title: l.sectionAbout,
            children: [
              // Read at runtime — a hardcoded string here had silently drifted
              // to "1.0.0 (Build 1)" while the app shipped as 1.2.x, which is
              // misleading for users and useless for support.
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final info = snapshot.data;
                  return _SettingsTile(
                    icon: Icons.info_outline,
                    title: l.appVersion,
                    subtitle: info == null
                        ? l.loading
                        : context.l10n.versionBuild(info.version, info.buildNumber),
                    onTap: null,
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.help_outline,
                title: l.faqHelp,
                subtitle: l.faqHelpSub,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FaqScreen()),
                ),
              ),
              _SettingsTile(
                icon: Icons.description,
                title: l.privacyPolicy,
                subtitle: l.privacyPolicySub,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LegalScreen.privacy()),
                ),
              ),
              _SettingsTile(
                icon: Icons.gavel_outlined,
                title: l.terms,
                subtitle: l.termsSub,
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
        title: Text(context.l10n.clearTransactions),
        content: Text(
          context.l10n.clearTransactionsConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
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
                SnackBar(content: Text(context.l10n.transactionsCleared)),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.expenseColor,
            ),
            child: Text(context.l10n.clearAll),
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
          title: Text(context.l10n.incomeTarget),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.incomeTargetExplain,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.amountWithCode(currencyCode),
                  prefixIcon:
                      const Icon(Icons.account_balance_wallet_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: frequency,
                decoration: InputDecoration(
                  labelText: context.l10n.howOften,
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: const ['Daily', 'Weekly', 'Monthly', 'Yearly']
                    .map((f) => DropdownMenuItem(
                        value: f, child: Text(frequencyLabel(context, f))))
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
              child: Text(context.l10n.clear),
            ),
            TextButton(
              onPressed: () {
                final value = double.tryParse(controller.text.trim());
                income.setIncome(value, frequency);
                Navigator.pop(ctx);
              },
              child: Text(context.l10n.save),
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
        SnackBar(content: Text(context.l10n.noTxToExport)),
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
        await ExportService.exportToCSV(transactions,
            currency: currency, l: context.l10n);
      } else {
        await ExportService.exportToPDF(transactions,
            currency: currency, l: context.l10n);
      }

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.exportedAs(format.toUpperCase())),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.exportFailed('$e')),
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
        title: Text(context.l10n.clearGoals),
        content: Text(
          context.l10n.clearGoalsConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // Safe bulk clear (no iterate-while-deleting). Reserved money
              // returns to available automatically once the goals are gone.
              Provider.of<GoalProvider>(context, listen: false)
                  .clearAllGoals();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.l10n.goalsCleared)),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.expenseColor,
            ),
            child: Text(context.l10n.clearAll),
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
        title: Text(context.l10n.deleteAccountQ),
        content: Text(
          context.l10n.deleteAccountBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: AppTheme.expenseColor),
            onPressed: () {
              Navigator.pop(ctx);
              _confirmDeleteWithPassword(context);
            },
            child: Text(context.l10n.continueBtn),
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
          title: Text(context.l10n.confirmItsYou),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.enterSignInPassword(FirebaseAuth.instance.currentUser?.email != null
                    ? ' (${FirebaseAuth.instance.currentUser!.email})'
                    : ''),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.notAppLockPin,
                style: TextStyle(fontSize: 11, color: AppTheme.textLight),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                enabled: !busy,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: context.l10n.signInPassword,
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
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: AppTheme.expenseColor),
              onPressed: busy
                  ? null
                  : () async {
                      if (passwordController.text.isEmpty) {
                        setLocal(() => error = context.l10n.enterPassword);
                        return;
                      }
                      setLocal(() {
                        busy = true;
                        error = null;
                      });

                      final result = await AccountDeletionService()
                          .deleteAccount(
                              password: passwordController.text,
                              l: context.l10n);

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
                          SnackBar(
                            content: Text(context.l10n.accountDeleted),
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
                  : Text(context.l10n.deleteForever),
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

  /// English / Kinyarwanda. Applies instantly and is remembered.
  void _showLanguagePicker(BuildContext context) {
    final l = context.l10n;
    final provider = context.read<LocaleProvider>();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) {
        Widget option(String code, String label) {
          final selected = provider.locale.languageCode == code;
          return ListTile(
            leading: Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: AppTheme.primaryColor,
            ),
            title: Text(label,
                style: TextStyle(
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal)),
            onTap: () async {
              Navigator.pop(sheetCtx);
              await provider.setLanguage(code);
              // The always-on monitoring notification follows the language.
              await ForegroundServiceHandler.updateLanguage();
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l.chooseLanguage,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              // Each language is shown in its own name so anyone can find it.
              option('en', 'English'),
              option('rw', 'Ikinyarwanda'),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.logout),
        content: Text(
          context.l10n.logoutConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
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
              // Offer the app lock again after the next sign-in. It's a
              // one-time prompt per session, not once per install — a user
              // who skipped it (or a different user on the same phone)
              // should still be invited to protect their data.
              await prefs.remove('app_lock_prompt_shown');
              
              if (context.mounted) {
                // Show logout success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text(context.l10n.loggedOut),
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
            child: Text(context.l10n.logout),
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
