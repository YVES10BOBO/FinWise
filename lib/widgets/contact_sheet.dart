import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/faq_screen.dart';
import '../services/support_contact_service.dart';
import '../theme/app_theme.dart';
import 'whatsapp_preview_card.dart';
import '../l10n/l10n_helpers.dart';

/// Bottom sheet shown by the help icon: browse the FAQ, or reach out
/// directly. Reusable from anywhere in the app — see [showContactSheet].
Future<void> showContactSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _ContactSheet(),
  );
}

class _ContactSheet extends StatelessWidget {
  const _ContactSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              context.l10n.needHelp,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.needHelpBody,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            _ContactOption(
              icon: Icons.quiz_outlined,
              color: AppTheme.primaryColor,
              title: context.l10n.browseFaq,
              subtitle: context.l10n.browseFaqSub,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FaqScreen()),
                );
              },
            ),
            _ContactOption(
              icon: Icons.email_outlined,
              color: AppTheme.secondaryColor,
              title: context.l10n.emailUs,
              subtitle: SupportContactService.supportEmail,
              onTap: () async {
                Navigator.pop(context);
                final ok = await SupportContactService.emailUs(
                    subject: context.l10n.finwiseSupport);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(context.l10n.noEmailApp)),
                  );
                }
              },
            ),
            _ContactOption(
              icon: FontAwesomeIcons.whatsapp,
              color: whatsAppGreen,
              title: context.l10n.whatsappUs,
              subtitle: context.l10n.whatsappSub,
              onTap: () {
                Navigator.pop(context);
                showWhatsAppPreview(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        // FaIcon renders both Material and FontAwesome glyphs correctly,
        // so the WhatsApp mark can sit alongside the Material ones.
        child: FaIcon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textLight),
      onTap: onTap,
    );
  }
}
