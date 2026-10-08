import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../l10n/l10n_helpers.dart';

// Profile pictures were removed: Firebase Storage now requires the paid Blaze
// plan, and Play Store flagged photo collection. Users get a clean avatar with
// their initial instead — no uploads, no photo permissions, no billing risk.

class PersonalizedHeader extends StatefulWidget {
  const PersonalizedHeader({super.key});

  @override
  State<PersonalizedHeader> createState() => _PersonalizedHeaderState();
}

class _PersonalizedHeaderState extends State<PersonalizedHeader> {
  /// Null until loaded; a translated "User" is shown meanwhile.
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name');
      if (name != null && name.trim().isNotEmpty && mounted) {
        setState(() {
          _userName = name.split(' ').first; // Get first name only
        });
      }
    } catch (e) {
      // Keep default
    }
  }

  /// Worked out at build time so it follows the chosen language.
  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l = context.l10n;
    if (hour < 12) return l.goodMorning;
    if (hour < 17) return l.goodAfternoon;
    return l.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_greeting(context)}, ${_userName ?? context.l10n.userFallback}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 5),
                Text(
                  context.l10n.manageWisely,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Initial-letter avatar. No photo upload, so no camera badge and
          // nothing to tap.
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withValues(alpha: 0.22),
            child: Text(
              (_userName ?? context.l10n.userFallback)[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
