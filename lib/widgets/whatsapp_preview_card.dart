import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/support_contact_service.dart';
import '../theme/app_theme.dart';

/// WhatsApp's brand green, shared so the contact sheet tile and this card
/// use exactly the same colour.
const Color whatsAppGreen = Color(0xFF25D366);

/// The little "chat widget" popup familiar from business websites — a short
/// greeting and an "Open chat" button — shown before actually leaving the
/// app for WhatsApp. Same idea as those website widgets, restyled to
/// match FinWise (its own colors, its own copy) rather than copied wholesale.
Future<void> showWhatsAppPreview(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'WhatsApp preview',
    barrierColor: Colors.black.withValues(alpha: 0.15),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, __) => const _WhatsAppPreviewCard(),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 90),
          child: FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 0.9, end: 1.0).animate(curved),
              alignment: Alignment.bottomRight,
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

class _WhatsAppPreviewCard extends StatelessWidget {
  const _WhatsAppPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header — WhatsApp green, so the card reads as "this opens
            // WhatsApp" at a glance and matches the Open chat button below.
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              color: whatsAppGreen,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: whatsAppGreen,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'FinWise Support',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 16,
                  ),
                ],
              ),
            ),
            // Body.
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Hi! Have a question about FinWise, or need help with '
                'something? Send us a message and we\'ll get back to you as '
                'soon as we can.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whatsAppGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    final ok = await SupportContactService.whatsAppUs();
                    if (!ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Could not open WhatsApp')),
                      );
                    }
                  },
                  icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 16),
                  label: const Text('Open chat'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
