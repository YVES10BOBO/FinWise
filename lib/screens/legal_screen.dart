import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_helpers.dart';

enum _LegalDoc { terms, privacy }

/// Shared legal document screen used for both Terms & Conditions and the
/// Privacy Policy, so the same content is reachable from sign-up and from
/// Settings without duplicating it. The text comes from the language files,
/// so it follows the app language; the English version is the official one.
class LegalScreen extends StatelessWidget {
  final _LegalDoc _doc;

  const LegalScreen._(this._doc);

  /// Terms & Conditions — linked from the sign-up checkbox.
  factory LegalScreen.terms() => const LegalScreen._(_LegalDoc.terms);

  /// Privacy Policy — must accurately describe every permission and data
  /// flow, especially SMS. Google rejects apps whose policy omits sensitive
  /// permissions, and the Data Safety form must match this text.
  factory LegalScreen.privacy() => const LegalScreen._(_LegalDoc.privacy);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final terms = _doc == _LegalDoc.terms;
    final title = terms ? l.legalTermsTitle : l.legalPrivacyTitle;
    final intro = terms ? l.legalTermsIntro : l.legalPrivacyIntro;
    final sections = terms ? _termsSections(l) : _privacySections(l);

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
          // In Kinyarwanda, say plainly that English is the official text.
          if (l.legalTranslationNote.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                l.legalTranslationNote,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
          ],
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
            l.legalLastUpdated(l.legalUpdatedDate),
            style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static List<LegalSection> _termsSections(AppLocalizations l) => [
          LegalSection(title: l.legalTermsS1T, content: l.legalTermsS1C),
          LegalSection(title: l.legalTermsS2T, content: l.legalTermsS2C),
          LegalSection(title: l.legalTermsS3T, content: l.legalTermsS3C),
          LegalSection(title: l.legalTermsS4T, content: l.legalTermsS4C),
          LegalSection(title: l.legalTermsS5T, content: l.legalTermsS5C),
          LegalSection(title: l.legalTermsS6T, content: l.legalTermsS6C),
          LegalSection(title: l.legalTermsS7T, content: l.legalTermsS7C),
      ];

  static List<LegalSection> _privacySections(AppLocalizations l) => [
          LegalSection(title: l.legalPrivacyS1T, content: l.legalPrivacyS1C),
          LegalSection(title: l.legalPrivacyS2T, content: l.legalPrivacyS2C),
          LegalSection(title: l.legalPrivacyS3T, content: l.legalPrivacyS3C),
          LegalSection(title: l.legalPrivacyS4T, content: l.legalPrivacyS4C),
          LegalSection(title: l.legalPrivacyS5T, content: l.legalPrivacyS5C),
          LegalSection(title: l.legalPrivacyS6T, content: l.legalPrivacyS6C),
          LegalSection(title: l.legalPrivacyS7T, content: l.legalPrivacyS7C),
          LegalSection(title: l.legalPrivacyS8T, content: l.legalPrivacyS8C),
          LegalSection(title: l.legalPrivacyS9T, content: l.legalPrivacyS9C),
          LegalSection(title: l.legalPrivacyS10T, content: l.legalPrivacyS10C),
          LegalSection(title: l.legalPrivacyS11T, content: l.legalPrivacyS11C),
          LegalSection(title: l.legalPrivacyS12T, content: l.legalPrivacyS12C),
      ];
}

class LegalSection {
  final String title;
  final String content;

  const LegalSection({required this.title, required this.content});
}
