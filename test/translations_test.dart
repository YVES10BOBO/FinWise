import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Guards the English/Kinyarwanda files against the mistakes that are easy
/// to make by hand: a text missing in one language, an empty translation, or
/// a translation that drops a {placeholder} — which would silently hide an
/// amount, a name or a date from the user.
void main() {
  Map<String, dynamic> load(String name) =>
      jsonDecode(File('lib/l10n/$name').readAsStringSync())
          as Map<String, dynamic>;

  final en = load('app_en.arb');
  final rw = load('app_rw.arb');
  bool isText(String k) => !k.startsWith('@');

  // Plain {name} placeholders plus the variable of plural/select forms.
  Set<String> placeholders(String s) => {
        ...RegExp(r'\{(\w+)\}').allMatches(s).map((m) => m.group(1)!),
        ...RegExp(r'\{(\w+),').allMatches(s).map((m) => m.group(1)!),
      };

  test('both languages have exactly the same texts', () {
    final enKeys = en.keys.where(isText).toSet();
    final rwKeys = rw.keys.where(isText).toSet();
    expect(enKeys.difference(rwKeys), isEmpty, reason: 'missing in Kinyarwanda');
    expect(rwKeys.difference(enKeys), isEmpty, reason: 'missing in English');
  });

  test('no Kinyarwanda text is empty', () {
    final empty = rw.entries
        .where((e) => isText(e.key) && (e.value as String).trim().isEmpty)
        .map((e) => e.key);
    expect(empty, isEmpty);
  });

  test('translations keep every placeholder', () {
    final broken = <String>[];
    for (final key in en.keys.where(isText)) {
      final a = placeholders(en[key] as String);
      final b = placeholders(rw[key] as String);
      if (a.difference(b).isNotEmpty) broken.add(key);
    }
    expect(broken, isEmpty);
  });
}
