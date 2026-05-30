import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaginiona/l10n/gen/app_localizations.dart';
import 'package:zaginiona/l10n/l10n_extensions.dart';

Widget _harness({required Locale locale, required Widget child}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('PL locale resolves keys to Polish', (tester) async {
    String? captured;
    await tester.pumpWidget(_harness(
      locale: const Locale('pl'),
      child: Builder(builder: (context) {
        captured = context.l10n.settingsTitle;
        return const SizedBox.shrink();
      }),
    ));
    expect(captured, 'Ustawienia');
  });

  testWidgets('EN locale resolves keys to placeholder strings', (tester) async {
    String? captured;
    await tester.pumpWidget(_harness(
      locale: const Locale('en'),
      child: Builder(builder: (context) {
        captured = context.l10n.settingsTitle;
        return const SizedBox.shrink();
      }),
    ));
    // Until proper EN translations are dropped in, every EN value
    // begins with the [EN] sentinel.
    expect(captured, '[EN] Ustawienia');
  });

  test('fallbackToPl returns PL when EN starts with [EN] prefix', () {
    expect(fallbackToPl('[EN] Ustawienia', 'Ustawienia'), 'Ustawienia');
  });

  test('fallbackToPl returns EN when EN is a real translation', () {
    expect(fallbackToPl('Settings', 'Ustawienia'), 'Settings');
  });

  test('AppLocalizations supports both PL and EN', () {
    final codes = AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .toSet();
    expect(codes, containsAll(['pl', 'en']));
  });

  testWidgets('common keys are not empty in either locale', (tester) async {
    for (final locale in AppLocalizations.supportedLocales) {
      String? title;
      String? cancel;
      await tester.pumpWidget(_harness(
        locale: locale,
        child: Builder(builder: (context) {
          title = context.l10n.appTitle;
          cancel = context.l10n.commonCancel;
          return const SizedBox.shrink();
        }),
      ));
      expect(title, isNotEmpty, reason: 'appTitle empty for $locale');
      expect(cancel, isNotEmpty, reason: 'commonCancel empty for $locale');
    }
  });
}
