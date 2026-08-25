import 'package:flutter/material.dart';
import '../services/support_contact_service.dart';
import '../theme/app_theme.dart';
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

const List<_FaqSection> _faqSections = [
  _FaqSection('Automatic tracking (SMS)', [
    _Faq(
      'How does auto-detect work?',
      'When you turn it on, FinWise reads incoming Mobile Money SMS (MTN, '
          'Airtel, bank alerts) on your phone and records the transaction '
          'automatically — amount, whether it was money in or out, and who '
          'it was with. It works fully offline: nothing is sent anywhere '
          'except your own device and, if you\'re signed in, your own '
          'FinWise account.',
    ),
    _Faq(
      'Does FinWise read my personal messages?',
      'No. Only messages that look like Mobile Money or bank notifications '
          'are ever processed — everything else is ignored and never '
          'stored or transmitted.',
    ),
    _Faq(
      'Why did I get two notifications for one payment?',
      'That shouldn\'t happen. If the same amount, same person, and same '
          'type of message (both "received" or both "sent") arrives twice '
          'within a few minutes, FinWise treats the second one as a repeat '
          'and does not record it again. If you still see a duplicate, use '
          '"Email us" below with the date/amount so it can be fixed.',
    ),
    _Faq(
      'A promotional or "bundle expired" SMS was recorded as an expense.',
      'FinWise filters out common promotional wording, but providers change '
          'their message templates over time. If one slips through, delete '
          'it from your transaction list — swipe left, or tap it and delete.',
    ),
  ]),
  _FaqSection('Transfers between your own accounts', [
    _Faq(
      'I moved money from Mobile Money to my bank — why isn\'t it income or an expense?',
      'Moving money between accounts you own (Mobile Money ↔ bank, or '
          'saving/withdrawing MoCash) isn\'t a real gain or loss — it\'s '
          'still your money. FinWise records these as a neutral "Transfer" '
          'so they never inflate your income or spending totals.',
    ),
    _Faq(
      'How does FinWise know it\'s a transfer and not a real payment?',
      'Mostly by pattern: one movement between your own accounts usually '
          'produces two SMS — one saying money left an account, another '
          'saying the same amount arrived — with the same amount, the same '
          'name, within a few minutes of each other. FinWise pairs those up '
          'automatically. It does not rely on your profile name, so it '
          'works even if your accounts are registered under a different '
          'name.',
    ),
    _Faq(
      'What about a loan from MoCash?',
      'A loan genuinely changes what you have or owe, so it\'s recorded '
          'normally — receiving a loan is income, repaying it is an '
          'expense. Only a plain save/withdraw within MoCash is treated as '
          'a transfer.',
    ),
    _Faq(
      'Does a fee on a transfer get recorded?',
      'Yes. The transfer itself is neutral, but any fee charged on it is a '
          'real cost, so it\'s recorded separately as a small expense.',
    ),
  ]),
  _FaqSection('Goals & saved money', [
    _Faq(
      'When I put money toward a goal, does that count as spent?',
      'No. Money reserved for a goal is set aside, not spent — it still '
          'shows in your account. It only becomes a real expense once you '
          'mark the goal as purchased.',
    ),
    _Faq(
      'I marked a goal as purchased but I\'d already recorded that expense from an SMS — will it be counted twice?',
      'No — when marking a goal purchased, you can link it to a transaction '
          'that\'s already recorded (e.g. auto-detected from SMS) instead of '
          'creating a new one, so it\'s only counted once.',
    ),
  ]),
  _FaqSection('Currency & accounts', [
    _Faq(
      'What happens if I change my currency after adding transactions?',
      'Amounts are not converted — a transaction recorded as 500 RWF would '
          'simply display as 500 in the new currency, same number, '
          'different label. FinWise warns you about this before the '
          'change goes through, since it doesn\'t use live exchange rates.',
    ),
  ]),
  _FaqSection('Privacy & data', [
    _Faq(
      'Does FinWise collect my photo or profile picture?',
      'No. FinWise shows your initial as your avatar instead of a photo — '
          'no images are ever uploaded.',
    ),
    _Faq(
      'Can I use FinWise without SMS auto-detect?',
      'Yes — it\'s optional. You can add every transaction manually and '
          'never grant SMS permission at all.',
    ),
    _Faq(
      'How do I delete my account and data?',
      'Settings → Delete account. This permanently removes your '
          'transactions, goals, profile, and sign-in — it cannot be undone, '
          'so consider exporting your data first.',
    ),
    _Faq(
      'Can I export my data?',
      'Yes — Settings → Export to CSV or Export Report (PDF).',
    ),
  ]),
  _FaqSection('App lock', [
    _Faq(
      'How do I turn on PIN or fingerprint lock?',
      'Settings → Security → App Lock. You can use a PIN, or your phone\'s '
          'fingerprint/face unlock where supported.',
    ),
    _Faq(
      'I forgot my PIN.',
      'On the lock screen, tap "Forgot PIN?" — this signs you out and back '
          'in with your FinWise email/password, then lets you set a new '
          'PIN.',
    ),
  ]),
];

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ & Help')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final section in _faqSections) ...[
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
                const Text(
                  'Still need help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Reach out directly and we\'ll get back to you.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
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
                        onPressed: () => SupportContactService.emailUs(),
                        icon: const Icon(Icons.email_outlined, size: 18),
                        label: const Text('Email'),
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
