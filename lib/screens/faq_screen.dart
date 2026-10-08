import 'package:flutter/material.dart';
import '../services/support_contact_service.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_helpers.dart';
import '../widgets/whatsapp_preview_card.dart';

class _Faq {
  final String question;
  final String answer;
  const _Faq(this.question, this.answer);
}

class _FaqSection {
  final String title;
  final List<_Faq> items;
  const _FaqSection(this.title, this.items);
}

List<_FaqSection> _faqSections(AppLocalizations l) => [
  _FaqSection(l.faqS1, [
    _Faq(l.faqS1Q1, l.faqS1A1),
    _Faq(l.faqS1Q2, l.faqS1A2),
    _Faq(l.faqS1Q3, l.faqS1A3),
    _Faq(l.faqS1Q4, l.faqS1A4),
  ]),
  _FaqSection(l.faqS2, [
    _Faq(l.faqS2Q1, l.faqS2A1),
    _Faq(l.faqS2Q2, l.faqS2A2),
    _Faq(l.faqS2Q3, l.faqS2A3),
    _Faq(l.faqS2Q4, l.faqS2A4),
  ]),
  _FaqSection(l.faqS3, [
    _Faq(l.faqS3Q1, l.faqS3A1),
    _Faq(l.faqS3Q2, l.faqS3A2),
  ]),
  _FaqSection(l.faqS4, [
    _Faq(l.faqS4Q1, l.faqS4A1),
  ]),
  _FaqSection(l.faqS5, [
    _Faq(l.faqS5Q1, l.faqS5A1),
    _Faq(l.faqS5Q2, l.faqS5A2),
    _Faq(l.faqS5Q3, l.faqS5A3),
    _Faq(l.faqS5Q4, l.faqS5A4),
  ]),
  _FaqSection(l.faqS6, [
    _Faq(l.faqS6Q1, l.faqS6A1),
    _Faq(l.faqS6Q2, l.faqS6A2),
  ]),
];

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.faqHelp)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final section in _faqSections(context.l10n)) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Text(
                section.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (var i = 0; i < section.items.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          section.items[i].question,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        childrenPadding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.items[i].answer,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.stillNeedHelp,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.reachOutDirectly,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        onPressed: () => SupportContactService.emailUs(
                            subject: context.l10n.finwiseSupport),
                        icon: const Icon(Icons.email_outlined, size: 18),
                        label: Text(context.l10n.email),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        onPressed: () => showWhatsAppPreview(context),
                        icon: const Icon(Icons.chat_outlined, size: 18),
                        label: const Text('WhatsApp'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
