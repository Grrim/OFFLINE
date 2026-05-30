import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/settings_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('SettingsState defaults', () {
    test('audio not muted, motion not reduced, haptics on, guided off', () {
      final s = SettingsState(persistence: PersistenceService.instance);
      expect(s.audioMuted, isFalse);
      expect(s.reducedMotion, isFalse);
      expect(s.haptics, isTrue);
      expect(s.guidedMode, isFalse);
      expect(s.telemetryOptIn, isFalse);
      expect(s.privacyAccepted, isFalse);
      expect(s.contentWarningShown, isFalse);
      expect(s.hasCompletedOnce, isFalse);
    });
  });

  group('SettingsState mutators', () {
    test('setAudioMuted persists + notifies', () {
      final s = SettingsState(persistence: PersistenceService.instance);
      var notifications = 0;
      s.addListener(() => notifications++);

      s.setAudioMuted(true);
      expect(s.audioMuted, isTrue);
      expect(notifications, 1);
      expect(PersistenceService.instance.getBool('settings.audio.muted'),
          isTrue);
    });

    test('all setters round-trip via persistence', () {
      final s1 = SettingsState(persistence: PersistenceService.instance);
      s1.setAudioMuted(true);
      s1.setReducedMotion(true);
      s1.setHaptics(false);
      s1.setGuidedMode(true);
      s1.setTelemetryOptIn(true);
      s1.setPrivacyAccepted(true);
      s1.setContentWarningShown(true);
      s1.setHasCompletedOnce(true);

      // New instance — values restored from prefs.
      final s2 = SettingsState(persistence: PersistenceService.instance);
      expect(s2.audioMuted, isTrue);
      expect(s2.reducedMotion, isTrue);
      expect(s2.haptics, isFalse);
      expect(s2.guidedMode, isTrue);
      expect(s2.telemetryOptIn, isTrue);
      expect(s2.privacyAccepted, isTrue);
      expect(s2.contentWarningShown, isTrue);
      expect(s2.hasCompletedOnce, isTrue);
    });
  });

  test('clearGameState preserves settings', () async {
    final s1 = SettingsState(persistence: PersistenceService.instance);
    s1.setAudioMuted(true);
    s1.setReducedMotion(true);
    s1.setHasCompletedOnce(true);

    await PersistenceService.instance.clearGameState();

    final s2 = SettingsState(persistence: PersistenceService.instance);
    expect(s2.audioMuted, isTrue);
    expect(s2.reducedMotion, isTrue);
    expect(s2.hasCompletedOnce, isTrue);
  });
}
