import 'package:flutter/material.dart';
import '../screens/faq_screen.dart';
import '../services/support_contact_service.dart';
import '../theme/app_theme.dart';

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
            const Text(
              'Need help?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Most questions are answered in the FAQ. If not, reach out '
              'directly and we\'ll get back to you.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            _ContactOption(
              icon: Icons.quiz_outlined,
              color: AppTheme.primaryColor,
              title: 'Browse FAQ',
              subtitle: 'Answers to common questions about FinWise',
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
              title: 'Email us',
              subtitle: SupportContactService.supportEmail,
              onTap: () async {
                Navigator.pop(context);
                final ok = await SupportContactService.emailUs();
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Could not open an email app')),
                  );
                }
              },
            ),
            _ContactOption(
              icon: Icons.chat_outlined,
              color: AppTheme.accentDark,
              title: 'WhatsApp us',
              subtitle: 'Chat with us on WhatsApp',
              onTap: () async {
                Navigator.pop(context);
                final ok = await SupportContactService.whatsAppUs();
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Could not open WhatsApp')),
                  );
                }
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
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textLight),
      onTap: onTap,
    );
  }
}
