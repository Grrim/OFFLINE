// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'OFFLINE';

  @override
  String get lockEnterPin => 'Code eingeben';

  @override
  String get lockHelperHint =>
      'Geben Sie den 4-stelligen Code ein, um fortzufahren.';

  @override
  String get lockWrongPin => 'Falscher Code';

  @override
  String get lockHintOrwell => 'Podpowiedź: Orwell';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsAudioMute => 'Töne stummschalten';

  @override
  String get settingsAudioMuteSub => 'Deaktiviert Ambient, Spannung und SFX.';

  @override
  String get settingsReducedMotion => 'Bewegung reduzieren';

  @override
  String get settingsReducedMotionSub =>
      'Deaktiviert Glitch- und plötzliche Blitzeffekte.';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsHapticsSub =>
      'Vibration bei Ereignissen (z. B. eingehende Nachricht).';

  @override
  String get settingsGuidedMode => 'Geführter Modus';

  @override
  String get settingsGuidedModeSub =>
      'Häufige Hinweise von Unbekannt, falls du nicht weiterkommst.';

  @override
  String get settingsTelemetry => 'Fehlerberichte senden';

  @override
  String get settingsTelemetrySub =>
      'Nur Stacktrace und Spielversion. Keine persönlichen Daten.';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguagePolish => 'Polski';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsResetGame => 'Spielstand zurücksetzen';

  @override
  String get settingsResetGameSub =>
      'Löscht den Fortschritt. Einstellungen bleiben erhalten.';

  @override
  String get settingsAbout => 'Über das Spiel';

  @override
  String get settingsResetConfirmTitle => 'Spielstand zurücksetzen?';

  @override
  String get settingsResetConfirmBody =>
      'Dies löscht deinen Fortschritt: Notizen, Kapitel, Enden. Einstellungen (Sprache, Ton, Vibration) bleiben erhalten.';

  @override
  String get settingsResetConfirmCancel => 'Abbrechen';

  @override
  String get settingsResetConfirmConfirm => 'Zurücksetzen';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get aboutLicenses => 'Open-Source-Lizenzen';

  @override
  String get endingPlayAgain => 'Nochmal spielen';

  @override
  String get endingShare => 'Ergebnis teilen';

  @override
  String get endingTimeLabel => 'Spielzeit';

  @override
  String get endingTitleLabel => 'Ende';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonRetry => 'Wiederholen';

  @override
  String get commonNoSignal => 'Kein Signal';

  @override
  String get commonOffline => 'Offline';

  @override
  String get iapFullGameUnlock => 'Vollversion freischalten';

  @override
  String get iapFullGameUnlockSub =>
      'Einmaliger Kauf, um alle Kapitel und Enden freizuschalten.';

  @override
  String get iapRestore => 'Käufe wiederherstellen';

  @override
  String get telemetryTitle => 'Telemetrie';

  @override
  String get telemetrySub =>
      'Sende anonyme Fehlerberichte, um das Spiel zu verbessern.';

  @override
  String get phoneRecents => 'Anrufe';

  @override
  String get phoneKeypad => 'Tastenfeld';

  @override
  String get phoneMissed => 'Verpasst';

  @override
  String get phoneVoicemail => 'MAILBOX';

  @override
  String get phoneNoSignal => 'Anruf fehlgeschlagen';

  @override
  String get phoneNoSignalBody =>
      'Kein Mobilfunksignal. Verbindung kann nicht hergestellt werden.';

  @override
  String get phoneVoicemailTranscript => 'Transkript:';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get calendarLastWeek => 'Letzte Woche';

  @override
  String get calendarNoMoreEvents => 'Keine weiteren Einträge.';

  @override
  String get calendarEventDetail => 'Termindetails';

  @override
  String get contactsTitle => 'Kontakte';

  @override
  String contactsCount(int count) {
    return '$count Kontakte';
  }

  @override
  String get contactsNoteLabel => 'Notiz:';

  @override
  String get browserHistory => 'Verlauf';

  @override
  String get browserSearchHint => 'Verlauf durchsuchen';

  @override
  String get browserPrivateMode => 'PRIVATER MODUS';

  @override
  String browserPrivateEntriesCount(int count) {
    return '$count Einträge';
  }

  @override
  String get browserPrivateLocked => 'Gesperrt';

  @override
  String get browserPrivatePasswordTitle => 'Privater Modus';

  @override
  String get browserPrivatePasswordBody =>
      'Private Tabs sind verschlüsselt. Gib das Passwort ein, das N. für ihre gespeicherten Sitzungen verwendet hat.';

  @override
  String get browserPrivatePasswordHint => 'Passwort';

  @override
  String get browserPrivateUnlock => 'Entsperren';

  @override
  String get browserPrivateWrongPassword => 'Falsches Passwort';

  @override
  String get browserPrivateLockedCardTitle => 'Private Tabs sind verschlüsselt';

  @override
  String get browserPrivateLockedCardSub =>
      'Tippen, um das Passwort einzugeben';

  @override
  String get homeAppLockedFiles => 'Zuerst Nachrichten prüfen';

  @override
  String get homeAppLockedSafari => 'Verlauf leer – zuerst Fotos prüfen';

  @override
  String get commonComingSoon => 'wkrótce';

  @override
  String get appLabelPhone => 'Telefon';

  @override
  String get appLabelMessages => 'Wiadomości';

  @override
  String get appLabelMail => 'Poczta';

  @override
  String get appLabelContacts => 'Kontakty';

  @override
  String get appLabelPhotos => 'Zdjęcia';

  @override
  String get appLabelNotes => 'Notatki';

  @override
  String get appLabelFiles => 'Pliki';

  @override
  String get appLabelSafari => 'Safari';

  @override
  String get appLabelCalendar => 'Kalendarz';

  @override
  String get appLabelRecorder => 'Dyktafon';

  @override
  String get appLabelMaps => 'Mapy';

  @override
  String get appLabelSettings => 'Ustawienia';

  @override
  String get appLabelSignal => 'Signal';

  @override
  String get settingsSectionGeneral => 'OGÓLNE';

  @override
  String get settingsSectionLanguage => 'JĘZYK';

  @override
  String get settingsSectionGame => 'GRA';

  @override
  String get settingsSectionPrivacy => 'PRYWATNOŚĆ';

  @override
  String get settingsSectionInfo => 'INFORMACJE';

  @override
  String get settingsFlavourAirplane => 'Tryb samolotowy';

  @override
  String get settingsFlavourWifi => 'Wi-Fi';

  @override
  String get settingsFlavourBluetooth => 'Bluetooth';

  @override
  String get settingsFlavourCellular => 'Komórkowe';

  @override
  String get settingsFlavourNotifications => 'Powiadomienia';

  @override
  String get settingsFlavourPasscode => 'Kod i Face ID';

  @override
  String get settingsFlavourModel => 'Model';

  @override
  String get settingsFlavourBattery => 'Bateria';

  @override
  String get settingsFlavourStorage => 'Pamięć';

  @override
  String get settingsFlavourOwner => 'Właściciel';

  @override
  String get settingsFlavourFeedbackAirplane =>
      'Tryb samolotowy jest wyłączony';

  @override
  String get settingsFlavourFeedbackWifi =>
      'Połączono z: HB_Guest_5G (nieszyfrowane)';

  @override
  String get settingsFlavourFeedbackBluetooth => 'Bluetooth jest wyłączony';

  @override
  String get settingsFlavourFeedbackCellular => 'Brak karty SIM lub zasięgu';

  @override
  String get settingsFlavourFeedbackNotifications =>
      'Nie można zmienić ustawień powiadomień';

  @override
  String get settingsFlavourFeedbackPasscode =>
      'Wymagane uwierzytelnienie właściciela';

  @override
  String get settingsFlavourFeedbackIapAttempt =>
      'Próba przywrócenia zakupów została wysłana.';

  @override
  String get settingsFlavourFeedbackIapError => 'Błąd przywracania zakupów.';

  @override
  String get settingsFlavourValueBluetoothOff => 'Wyłączony';

  @override
  String get settingsFlavourValueCellNoSignal => 'Brak zasięgu';

  @override
  String get settingsFlavourValueEnabled => 'Włączone';

  @override
  String get settingsFlavourValueOwnerName => 'N.';

  @override
  String get settingsFlavourValueStorage => '47 GB / 256 GB';

  @override
  String get settingsFlavourAboutSub =>
      'Wersja, polityka prywatności, licencje.';

  @override
  String settingsFlavourValueBattery(Object percent) {
    return '$percent%';
  }

  @override
  String settingsFlavourFeedbackBattery(Object percent) {
    return 'Stan baterii: $percent% · Ostatnie ładowanie: wczoraj 18:00';
  }

  @override
  String get settingsFlavourFeedbackStorage =>
      'Zdjęcia: 12 GB · Aplikacje: 28 GB · System: 7 GB';

  @override
  String get settingsFlavourFeedbackOwner =>
      'Apple ID: n.***@icloud.com · Zalogowano';

  @override
  String get contentWarningTitle => 'Zanim zaczniesz';

  @override
  String get contentWarningSectionThemesTitle => 'Tematyka 13+';

  @override
  String get contentWarningSectionThemesBody =>
      'OFFLINE to gra detektywistyczna o zaginięciu osoby. Pojawiają się motywy stalkingu, korupcji i przemocy psychicznej. Brak fizycznej przemocy, treści seksualnych ani nadużyć wobec dzieci.';

  @override
  String get contentWarningSectionVisualsTitle => 'Efekty wizualne';

  @override
  String get contentWarningSectionVisualsBody =>
      'Gra używa krótkich glitchy i przyciemniających rozbłysków. Jeśli masz fotosensytywność, możesz je wyłączyć w Ustawieniach → Zmniejsz efekty wizualne.';

  @override
  String get contentWarningContinue => 'Rozumiem, kontynuuj';
}
