import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

/// The language the app is shown in. English by default; the user can switch
/// to Kinyarwanda (or back) at any time from Settings, and the choice is
/// remembered on this phone.
class LocaleProvider with ChangeNotifier {
  static const _key = 'app_language';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isKinyarwanda => _locale.languageCode == 'rw';

  LocaleProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_key);
      if (code == 'rw' || code == 'en') {
        _locale = Locale(code!);
        notifyListeners();
      }
    } catch (_) {
      // Keep English.
    }
  }

  Future<void> setLanguage(String code) async {
    if (code != 'en' && code != 'rw') return;
    _locale = Locale(code);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, code);
    } catch (_) {}
  }
}

/// Flutter ships no Kinyarwanda for its own built-in texts (date picker,
/// "OK", text-field menus). Without these, choosing Kinyarwanda would leave
/// those widgets with no localizations at all. They fall back to English —
/// FinWise's own screens are still fully in Kinyarwanda.
class KinyarwandaFallbackDelegate<T> extends LocalizationsDelegate<T> {
  final LocalizationsDelegate<T> english;

  const KinyarwandaFallbackDelegate(this.english);

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<T> load(Locale locale) => english.load(const Locale('en'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<T> old) => false;
}

const List<LocalizationsDelegate<dynamic>> kinyarwandaFallbacks = [
  KinyarwandaFallbackDelegate<MaterialLocalizations>(
      GlobalMaterialLocalizations.delegate),
  KinyarwandaFallbackDelegate<CupertinoLocalizations>(
      GlobalCupertinoLocalizations.delegate),
  KinyarwandaFallbackDelegate<WidgetsLocalizations>(
      GlobalWidgetsLocalizations.delegate),
];

/// The chosen language's texts for code that runs without a screen — the
/// SMS background isolate, notifications, the foreground service. Reads the
/// same saved setting as [LocaleProvider].
Future<AppLocalizations> savedAppLocalizations() async {
  var code = 'en';
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final saved = prefs.getString('app_language');
    if (saved == 'rw') code = 'rw';
  } catch (_) {}
  return lookupAppLocalizations(Locale(code));
}
