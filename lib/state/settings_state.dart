import 'package:flutter/foundation.dart';

import '../services/persistence_service.dart';

/// Durable user preferences. Persisted under the `settings.*` namespace
/// so that gameplay reset never wipes them.
///
/// All toggles are exposed as plain fields with explicit setters that
/// persist + notify. UI binds to this single notifier.
class SettingsState extends ChangeNotifier {
  SettingsState({PersistenceService? persistence})
      : _persistence = persistence {
    _load();
  }

  static const String _kAudioMuted = 'settings.audio.muted';
  static const String _kReducedMotion = 'settings.reducedMotion';
  static const String _kHaptics = 'settings.haptics';
  static const String _kGuidedMode = 'settings.guidedMode';
  static const String _kTelemetryOptIn = 'settings.telemetryOptIn';
  static const String _kPrivacyAccepted = 'settings.privacyAccepted';
  static const String _kContentWarningShown = 'settings.contentWarningShown';
  static const String _kHasCompletedOnce = 'settings.hasCompletedOnce';
  static const String _kLastPlayedAtMs = 'settings.lastPlayedAtMs';

  final PersistenceService? _persistence;

  bool _audioMuted = false;
  bool _reducedMotion = false;
  bool _haptics = true;
  bool _guidedMode = false;
  bool _telemetryOptIn = false;
  bool _privacyAccepted = false;
  bool _contentWarningShown = false;
  bool _hasCompletedOnce = false;
  DateTime? _lastPlayedAt;

  bool get audioMuted => _audioMuted;
  bool get reducedMotion => _reducedMotion;
  bool get haptics => _haptics;
  bool get guidedMode => _guidedMode;
  bool get telemetryOptIn => _telemetryOptIn;
  bool get privacyAccepted => _privacyAccepted;
  bool get contentWarningShown => _contentWarningShown;
  bool get hasCompletedOnce => _hasCompletedOnce;
  DateTime? get lastPlayedAt => _lastPlayedAt;

  /// Set in-memory by the shell at the moment the player first unlocks
  /// the phone in this app session. Used only for ending stats; not
  /// persisted across launches.
  DateTime? _currentRunStartedAt;
  DateTime? get currentRunStartedAt => _currentRunStartedAt;
  // ignore: use_setters_to_change_properties
  void markRunStart(DateTime at) {
    _currentRunStartedAt = at;
  }

  /// Reset in-memory only. Called when the player resets gameplay.
  void clearRunStart() {
    _currentRunStartedAt = null;
  }

  /// True if the player came back after at least 24 hours away.
  bool get hasBeenAwayLong {
    final last = _lastPlayedAt;
    if (last == null) return false;
    return DateTime.now().difference(last) >= const Duration(hours: 24);
  }

  /// Update the "last played" timestamp to now. Persisted.
  void touchLastPlayed() {
    _lastPlayedAt = DateTime.now();
    _persistence?.setInt(
        _kLastPlayedAtMs, _lastPlayedAt!.millisecondsSinceEpoch);
    notifyListeners();
  }

  void setAudioMuted(bool value) => _setBool(_kAudioMuted, value, (v) {
        _audioMuted = v;
      });

  void setReducedMotion(bool value) => _setBool(_kReducedMotion, value, (v) {
        _reducedMotion = v;
      });

  void setHaptics(bool value) => _setBool(_kHaptics, value, (v) {
        _haptics = v;
      });

  void setGuidedMode(bool value) => _setBool(_kGuidedMode, value, (v) {
        _guidedMode = v;
      });

  void setTelemetryOptIn(bool value) =>
      _setBool(_kTelemetryOptIn, value, (v) {
        _telemetryOptIn = v;
      });

  void setPrivacyAccepted(bool value) =>
      _setBool(_kPrivacyAccepted, value, (v) {
        _privacyAccepted = v;
      });

  void setContentWarningShown(bool value) =>
      _setBool(_kContentWarningShown, value, (v) {
        _contentWarningShown = v;
      });

  void setHasCompletedOnce(bool value) =>
      _setBool(_kHasCompletedOnce, value, (v) {
        _hasCompletedOnce = v;
      });

  // ---------- Internals ----------

  void _setBool(String key, bool value, void Function(bool) apply) {
    apply(value);
    _persistence?.setBool(key, value);
    notifyListeners();
  }

  void _load() {
    final p = _persistence;
    if (p == null) return;
    _audioMuted = p.getBool(_kAudioMuted);
    _reducedMotion = p.getBool(_kReducedMotion);
    _haptics = p.getBool(_kHaptics, defaultValue: true);
    _guidedMode = p.getBool(_kGuidedMode);
    _telemetryOptIn = p.getBool(_kTelemetryOptIn);
    _privacyAccepted = p.getBool(_kPrivacyAccepted);
    _contentWarningShown = p.getBool(_kContentWarningShown);
    _hasCompletedOnce = p.getBool(_kHasCompletedOnce);
    final lastMs = p.getInt(_kLastPlayedAtMs);
    if (lastMs > 0) {
      _lastPlayedAt = DateTime.fromMillisecondsSinceEpoch(lastMs);
    }
  }
}
