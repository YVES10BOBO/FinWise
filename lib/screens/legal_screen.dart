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
