import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'persistence_service.dart';

/// Runtime-switchable locale and dialogue loader.
class L10nService extends ChangeNotifier {
  L10nService._();

  static final L10nService instance = L10nService._();

  static const String _kLocale = 'settings.locale';

  static const List<Locale> supported = [
    Locale('pl'),
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('ru'),
  ];

  Locale _locale = const Locale('pl');
  Locale get locale => _locale;

  bool _explicit = false;
  bool get isExplicit => _explicit;

  Map<String, dynamic> _dialogues = {};
  Map<String, dynamic> get dialogues => _dialogues;

  Future<void> init({Locale? platformLocale}) async {
    final p = PersistenceService.instance;
    final saved = p.getString(_kLocale);
    if (saved.isNotEmpty) {
      _locale = Locale(saved);
      _explicit = true;
    } else if (platformLocale != null) {
      for (final s in supported) {
        if (s.languageCode == platformLocale.languageCode) {
          _locale = s;
          break;
        }
      }
    } else {
      _locale = const Locale('pl');
    }
    await _loadDialogues();
  }

  Future<void> _loadDialogues() async {
    try {
      final String jsonString = await rootBundle.loadString(
          'assets/l10n/dialogues_${_locale.languageCode}.json');
      _dialogues = jsonDecode(jsonString);
    } catch (e) {
      debugPrint('Error loading dialogues: $e');
      _dialogues = {};
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    if (!supported.any((l) => l.languageCode == newLocale.languageCode)) {
      return;
    }
    _locale = newLocale;
    _explicit = true;
    PersistenceService.instance.setString(_kLocale, newLocale.languageCode);
    await _loadDialogues();
    notifyListeners();
  }

  Future<void> toggle() async {
    await setLocale(_locale.languageCode == 'pl'
        ? const Locale('en')
        : const Locale('pl'));
  }
}

/// Convenience wrapper that turns the [L10nService] into a [Listenable]
/// suitable for `MaterialApp.locale`-driven rebuilds via
/// [ListenableBuilder]. Keeps a single source of truth.
ValueListenable<Locale> l10nLocaleListenable() {
  final notifier = ValueNotifier<Locale>(L10nService.instance.locale);
  L10nService.instance.addListener(() {
    notifier.value = L10nService.instance.locale;
  });
  return notifier;
}
