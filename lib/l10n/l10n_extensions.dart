import 'package:flutter/widgets.dart';

import 'gen/app_localizations.dart';

/// Sentinel prefix for English keys that haven't been translated yet —
/// we ship the EN ARB with keys filled with `[EN] {polish}` placeholders
/// so we can detect them at runtime and gracefully fall back to PL.
const String _untranslatedPrefix = '[EN] ';

/// Helper that picks the localized value for [key] from
/// [AppLocalizations.of(context)] and, if the EN string is a placeholder
/// `[EN] ...`, returns the corresponding PL value instead.
///
/// Use this when you have a locale-agnostic getter — for the
/// generated AppLocalizations getters this is rarely needed, but for
/// stories, dialogues and content that we route through an indirection
/// (e.g. content layer) it's the central fallback point.
String fallbackToPl(String englishValue, String polishValue) {
  if (englishValue.startsWith(_untranslatedPrefix)) {
    return polishValue;
  }
  return englishValue;
}

/// Convenience extension to access [AppLocalizations] as `context.l10n`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
