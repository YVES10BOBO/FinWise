import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finewise/l10n/app_localizations.dart';
import 'package:finewise/providers/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  test('English and Kinyarwanda are both available', () {
    expect(AppLocalizations.supportedLocales,
        containsAll([const Locale('en'), const Locale('rw')]));
    expect(lookupAppLocalizations(const Locale('en')).navHome, 'Home');
    expect(lookupAppLocalizations(const Locale('rw')).navHome, 'Ahabanza');
    expect(lookupAppLocalizations(const Locale('rw')).periodLastDays(60),
        'Iminsi 60 ishize');
  });

  testWidgets('the app can switch to Kinyarwanda without missing texts',
      (tester) async {
    // Flutter has no Kinyarwanda for its own widgets; without the fallback
    // delegates this would fail with "No MaterialLocalizations found".
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('rw'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        ...kinyarwandaFallbacks,
      ],
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context).navGoals)),
          body: const BackButton(),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Intego'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
