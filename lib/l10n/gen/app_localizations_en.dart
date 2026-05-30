// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OFFLINE';

  @override
  String get lockEnterPin => 'Enter Passcode';

  @override
  String get lockHelperHint => 'Enter the 4-digit code to continue.';

  @override
  String get lockWrongPin => 'Incorrect Passcode';

  @override
  String get lockHintOrwell => 'Hint: Orwell';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAudioMute => 'Mute Sounds';

  @override
  String get settingsAudioMuteSub => 'Disables ambient, tension, and SFX.';

  @override
  String get settingsReducedMotion => 'Reduce Motion';

  @override
  String get settingsReducedMotionSub =>
      'Disables glitch and sudden flash effects.';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsHapticsSub => 'Vibrate on events (e.g. incoming message).';

  @override
  String get settingsGuidedMode => 'Guided Mode';

  @override
  String get settingsGuidedModeSub =>
      'Frequent hints from Unknown if you get stuck.';

  @override
  String get settingsTelemetry => 'Send Error Reports';

  @override
  String get settingsTelemetrySub =>
      'Stack trace and game version only. No personal data.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguagePolish => 'Polski';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsResetGame => 'Reset Gameplay';

  @override
  String get settingsResetGameSub =>
      'Erases progress. Settings will be preserved.';

  @override
  String get settingsAbout => 'About the Game';

  @override
  String get settingsResetConfirmTitle => 'Reset gameplay?';

  @override
  String get settingsResetConfirmBody =>
      'This will erase your progress: notes, chapters, endings. Settings (language, sound, vibration) will be preserved.';

  @override
  String get settingsResetConfirmCancel => 'Cancel';

  @override
  String get settingsResetConfirmConfirm => 'Reset';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPrivacyPolicy => 'Privacy Policy';

  @override
  String get aboutLicenses => 'Open-source Licenses';

  @override
  String get endingPlayAgain => 'Play Again';

  @override
  String get endingShare => 'Share Result';

  @override
  String get endingTimeLabel => 'Playtime';

  @override
  String get endingTitleLabel => 'Ending';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonNoSignal => 'No Signal';

  @override
  String get commonOffline => 'Offline';

  @override
  String get iapFullGameUnlock => 'Unlock Full Game';

  @override
  String get iapFullGameUnlockSub =>
      'One-time purchase to unlock all chapters and endings.';

  @override
  String get iapRestore => 'Restore Purchases';

  @override
  String get telemetryTitle => 'Telemetry';

  @override
  String get telemetrySub =>
      'Send anonymous error reports to help improve the game.';

  @override
  String get phoneRecents => 'Recents';

  @override
  String get phoneKeypad => 'Keypad';

  @override
  String get phoneMissed => 'Missed';

  @override
  String get phoneVoicemail => 'VOICEMAIL';

  @override
  String get phoneNoSignal => 'Call Failed';

  @override
  String get phoneNoSignalBody =>
      'No cellular signal. Unable to establish connection.';

  @override
  String get phoneVoicemailTranscript => 'Transcript:';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarLastWeek => 'Last Week';

  @override
  String get calendarNoMoreEvents => 'No more entries.';

  @override
  String get calendarEventDetail => 'Event Details';

  @override
  String get contactsTitle => 'Contacts';

  @override
  String contactsCount(int count) {
    return '$count contacts';
  }

  @override
  String get contactsNoteLabel => 'Note:';

  @override
  String get browserHistory => 'History';

  @override
  String get browserSearchHint => 'Search history';

  @override
  String get browserPrivateMode => 'PRIVATE MODE';

  @override
  String browserPrivateEntriesCount(int count) {
    return '$count entries';
  }

  @override
  String get browserPrivateLocked => 'Locked';

  @override
  String get browserPrivatePasswordTitle => 'Private Mode';

  @override
  String get browserPrivatePasswordBody =>
      'Private tabs are encrypted. Enter the password N. used for her saved sessions.';

  @override
  String get browserPrivatePasswordHint => 'Password';

  @override
  String get browserPrivateUnlock => 'Unlock';

  @override
  String get browserPrivateWrongPassword => 'Incorrect Password';

  @override
  String get browserPrivateLockedCardTitle => 'Private tabs are encrypted';

  @override
  String get browserPrivateLockedCardSub => 'Tap to enter password';

  @override
  String get homeAppLockedFiles => 'Check Messages first';

  @override
  String get homeAppLockedSafari => 'History empty — check Photos first';

  @override
  String get commonComingSoon => 'Coming Soon';

  @override
  String get appLabelPhone => 'Phone';

  @override
  String get appLabelMessages => 'Messages';

  @override
  String get appLabelMail => 'Mail';

  @override
  String get appLabelContacts => 'Contacts';

  @override
  String get appLabelPhotos => 'Photos';

  @override
  String get appLabelNotes => 'Notes';

  @override
  String get appLabelFiles => 'Files';

  @override
  String get appLabelSafari => 'Safari';

  @override
  String get appLabelCalendar => 'Calendar';

  @override
  String get appLabelRecorder => 'Recorder';

  @override
  String get appLabelMaps => 'Maps';

  @override
  String get appLabelSettings => 'Settings';

  @override
  String get appLabelSignal => 'Signal';

  @override
  String get settingsSectionGeneral => 'GENERAL';

  @override
  String get settingsSectionLanguage => 'LANGUAGE';

  @override
  String get settingsSectionGame => 'GAME';

  @override
  String get settingsSectionPrivacy => 'PRIVACY';

  @override
  String get settingsSectionInfo => 'INFORMATION';

  @override
  String get settingsFlavourAirplane => 'Airplane Mode';

  @override
  String get settingsFlavourWifi => 'Wi-Fi';

  @override
  String get settingsFlavourBluetooth => 'Bluetooth';

  @override
  String get settingsFlavourCellular => 'Cellular';

  @override
  String get settingsFlavourNotifications => 'Notifications';

  @override
  String get settingsFlavourPasscode => 'Passcode & Face ID';

  @override
  String get settingsFlavourModel => 'Model';

  @override
  String get settingsFlavourBattery => 'Battery';

  @override
  String get settingsFlavourStorage => 'Storage';

  @override
  String get settingsFlavourOwner => 'Owner';

  @override
  String get settingsFlavourFeedbackAirplane => 'Airplane Mode is off';

  @override
  String get settingsFlavourFeedbackWifi =>
      'Connected to: HB_Guest_5G (unencrypted)';

  @override
  String get settingsFlavourFeedbackBluetooth => 'Bluetooth is off';

  @override
  String get settingsFlavourFeedbackCellular => 'No SIM card or signal';

  @override
  String get settingsFlavourFeedbackNotifications =>
      'Notification settings cannot be changed';

  @override
  String get settingsFlavourFeedbackPasscode => 'Owner authentication required';

  @override
  String get settingsFlavourFeedbackIapAttempt =>
      'Purchase restoration attempt sent.';

  @override
  String get settingsFlavourFeedbackIapError => 'Purchase restoration error.';

  @override
  String get settingsFlavourValueBluetoothOff => 'Off';

  @override
  String get settingsFlavourValueCellNoSignal => 'No signal';

  @override
  String get settingsFlavourValueEnabled => 'Enabled';

  @override
  String get settingsFlavourValueOwnerName => 'N.';

  @override
  String get settingsFlavourValueStorage => '47 GB / 256 GB';

  @override
  String get settingsFlavourAboutSub => 'Version, privacy policy, licenses.';

  @override
  String settingsFlavourValueBattery(Object percent) {
    return '$percent%';
  }

  @override
  String settingsFlavourFeedbackBattery(Object percent) {
    return 'Battery state: $percent% · Last charge: yesterday 6:00 PM';
  }

  @override
  String get settingsFlavourFeedbackStorage =>
      'Photos: 12 GB · Apps: 28 GB · System: 7 GB';

  @override
  String get settingsFlavourFeedbackOwner =>
      'Apple ID: n.***@icloud.com · Logged in';

  @override
  String get contentWarningTitle => 'Before you start';

  @override
  String get contentWarningSectionThemesTitle => '13+ Themes';

  @override
  String get contentWarningSectionThemesBody =>
      'OFFLINE is a detective game about a missing person. Themes include stalking, corruption, and psychological violence. No physical violence, sexual content, or child abuse.';

  @override
  String get contentWarningSectionVisualsTitle => 'Visual Effects';

  @override
  String get contentWarningSectionVisualsBody =>
      'The game uses short glitches and darkening flashes. If you have photosensitivity, you can disable them in Settings → Reduce Motion.';

  @override
  String get contentWarningContinue => 'I understand, continue';
}
