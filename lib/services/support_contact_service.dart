import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:url_launcher/url_launcher.dart';

/// Where "Contact us" in the app actually goes. Kept in one place so the
/// email address / WhatsApp number only need updating here.
///
/// No backend, no live chat service — that would mean an ongoing cost (same
/// reason Firebase Storage was dropped for profile pictures) and someone
/// staffing it. This just hands off to apps the user already has installed.
class SupportContactService {
  static const String supportEmail = 'yvesrutembeza@gmail.com';

  /// WhatsApp number in international format, digits only (no "+", no
  /// leading zero) — the format wa.me links require.
  static const String whatsAppNumber = '250787461999';

  static Future<bool> emailUs({String? subject, String? body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': subject ?? 'FinWise Support',
        'body': body ?? '',
      },
    );
    return _launch(uri);
  }

  static Future<bool> whatsAppUs({String? message}) async {
    final uri = Uri.parse(
      'https://wa.me/$whatsAppNumber'
      '${message != null ? '?text=${Uri.encodeComponent(message)}' : ''}',
    );
    return _launch(uri);
  }

  static Future<bool> _launch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (kDebugMode) debugPrint('FinWise: could not launch $uri ($e)');
      return false;
    }
  }
}
