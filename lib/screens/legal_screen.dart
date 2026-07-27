import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared legal document screen used for both Terms & Conditions and the
/// Privacy Policy, so the same content is reachable from sign-up and from
/// Settings without duplicating it.
class LegalScreen extends StatelessWidget {
  final String title;
  final String intro;
  final List<LegalSection> sections;

  const LegalScreen({
    super.key,
    required this.title,
    required this.intro,
    required this.sections,
  });

  /// Terms & Conditions — linked from the sign-up checkbox.
  static LegalScreen terms() => LegalScreen(
        title: 'Terms & Conditions',
        intro:
            'By creating a FinWise account you agree to these terms. Please '
            'read them carefully.',
        sections: const [
          LegalSection(
            title: '1. Using FinWise',
            content:
                '• FinWise helps you track your personal income, spending and savings goals.\n'
                '• You must be old enough to enter a binding agreement in your country.\n'
                '• You are responsible for keeping your account credentials secure.\n'
                '• Use the app only for lawful, personal financial management.',
          ),
          LegalSection(
            title: '2. Your Data Is Yours',
            content:
                '• The financial information you record belongs to you.\n'
                '• We store it to provide the service and sync it across your devices.\n'
                '• You can export or delete your data at any time from Settings.',
          ),
          LegalSection(
            title: '3. Mobile Money SMS Detection',
            content:
                '• This optional feature reads Mobile Money messages on your device to record transactions automatically.\n'
                '• Messages are processed entirely on your phone. Message content is never uploaded or shared.\n'
                '• Only financial messages are used; personal SMS are ignored.\n'
                '• You can turn this off at any time in Settings.',
          ),
          LegalSection(
            title: '4. Accuracy & Financial Decisions',
            content:
                '• FinWise is a tracking tool, not financial, investment, tax or legal advice.\n'
                '• Automatic detection and categorisation may occasionally be wrong — always review your records.\n'
                '• You remain responsible for your own financial decisions.',
          ),
          LegalSection(
            title: '5. Availability',
            content:
                '• We aim to keep FinWise available and accurate, but the service is provided "as is".\n'
                '• Features may change, and syncing depends on your internet connection.',
          ),
          LegalSection(
            title: '6. Ending Your Account',
            content:
                '• You may stop using FinWise and delete your data at any time.\n'
                '• We may suspend accounts that misuse the service or breach these terms.',
          ),
          LegalSection(
            title: '7. Changes to These Terms',
            content:
                'We may update these terms as the app evolves. Continuing to use '
                'FinWise after an update means you accept the revised terms.',
          ),
        ],
      );

  /// Privacy Policy — must accurately describe every permission and data
  /// flow, especially SMS. Google rejects apps whose policy omits sensitive
  /// permissions, and the Data Safety form must match this text.
  static LegalScreen privacy() => LegalScreen(
        title: 'Privacy Policy',
        intro:
            'FinWise helps you track your money. This policy explains exactly '
            'what we collect, what stays on your phone, and what we never do.',
        sections: const [
          LegalSection(
            title: '1. What Stays Only On Your Phone',
            content:
                'The following NEVER leaves your device and is never uploaded:\n\n'
                '• SMS message content. Mobile Money and bank messages are read and '
                'analysed entirely on your phone. We never upload, store or transmit '
                'message text.\n'
                '• Your app lock PIN. Stored only as a salted, irreversible hash.\n'
                '• Fingerprint / face data. Android verifies you in secure hardware '
                'and tells the app only "yes" or "no". FinWise never receives, sees '
                'or stores biometric data.',
          ),
          LegalSection(
            title: '2. Mobile Money SMS Detection (Optional)',
            content:
                'If you enable auto-detection, FinWise uses SMS permissions to '
                'record your transactions automatically.\n\n'
                '• Purpose: to read financial alerts from Mobile Money providers and '
                'banks so transactions are recorded without manual typing.\n'
                '• Only financial messages are used. Personal messages are ignored.\n'
                '• Only the extracted amount, direction, date and counterparty name '
                'are saved as a transaction — never the raw message.\n'
                '• Processing happens on your device, offline.\n'
                '• You can turn this off at any time in Settings, and revoke the '
                'permission in your phone settings.\n\n'
                'This use complies with Google Play\'s permitted use for SMS-based '
                'money management.',
          ),
          LegalSection(
            title: '3. Information We Collect',
            content:
                '• Account: email address and name (for sign-in and personalisation)\n'
                '• Financial records: transactions you add or that are detected — '
                'amount, description, category, date and account type\n'
                '• Goals: names, targets, dates and contribution history\n'
                '• Preferences: currency, optional income target, app settings\n\n'
                'We do NOT collect photos. FinWise has no photo upload and does '
                'not request camera or gallery access — your avatar is simply '
                'the first letter of your name.',
          ),
          LegalSection(
            title: '4. Where Your Data Is Stored',
            content:
                '• On your device: a local copy of your transactions and settings, '
                'so the app works offline and starts quickly.\n'
                '• In the cloud (Firebase, operated by Google): your account details, '
                'transactions and goals — so your data survives a lost phone and '
                'syncs across devices.\n\n'
                'Cloud data is encrypted in transit and at rest. Security rules '
                'ensure only your signed-in account can read your records.',
          ),
          LegalSection(
            title: '5. Notifications & Background Activity',
            content:
                '• FinWise shows a notification when a transaction is detected.\n'
                '• While auto-detection is on, a persistent notification indicates '
                'that FinWise is monitoring for transactions. Android requires this '
                'for any app doing background work, and it keeps detection reliable.\n'
                '• Background activity is used only to detect transactions. We do '
                'not track your location or usage of other apps.',
          ),
          LegalSection(
            title: '6. What We Never Do',
            content:
                '• We never sell your personal information.\n'
                '• We never share your financial data with advertisers or data brokers.\n'
                '• We never upload SMS content.\n'
                '• We do not move money, access your bank or Mobile Money account, '
                'or ask for your PIN or banking credentials.\n'
                '• We show no advertising.',
          ),
          LegalSection(
            title: '7. Third-Party Services',
            content:
                'We use Firebase (Google) for sign-in, database and file storage. '
                'Google\'s privacy policy applies to their handling of that data: '
                'https://policies.google.com/privacy\n\n'
                'No other third-party service receives your data.',
          ),
          LegalSection(
            title: '8. Your Rights & Control',
            content:
                '• Access: view all of your data inside the app\n'
                '• Export: download your transactions as CSV or PDF\n'
                '• Delete: remove individual records, clear all data, or delete your '
                'account entirely\n'
                '• Withdraw consent: turn off SMS detection at any time\n'
                '• Sign out: stops cloud sync on that device',
          ),
          LegalSection(
            title: '9. Data Retention',
            content:
                'Your data is kept until you delete it. Deleting a record removes it '
                'from your device and the cloud. Deleting your account removes your '
                'stored data permanently.',
          ),
          LegalSection(
            title: '10. Children\'s Privacy',
            content:
                'FinWise is not intended for anyone under 13. We do not knowingly '
                'collect information from children.',
          ),
          LegalSection(
            title: '11. Changes To This Policy',
            content:
                'If this policy changes, the date below is updated. Significant '
                'changes affecting how your data is used will be announced in the app.',
          ),
          LegalSection(
            title: '12. Contact',
            content:
                'For any privacy question or to request deletion of your data, '
                'contact us through Help & Support in the app.',
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            intro,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          ...sections.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.content,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Text(
            'Last updated: July 2026',
            style: TextStyle(fontSize: 12, color: AppTheme.textLight),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class LegalSection {
  final String title;
  final String content;

  const LegalSection({required this.title, required this.content});
}
