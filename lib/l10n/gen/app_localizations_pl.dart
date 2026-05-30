// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'N. IS OFFLINE';

  @override
  String get lockEnterPin => 'Wprowadź hasło';

  @override
  String get lockHelperHint => 'Aby kontynuować, wpisz 4-cyfrowy kod.';

  @override
  String get lockWrongPin => 'Nieprawidłowy kod';

  @override
  String get lockHintOrwell => 'Podpowiedź: Orwell';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsAudioMute => 'Wycisz dźwięki';

  @override
  String get settingsAudioMuteSub => 'Wyłącza ambient, tension i SFX.';

  @override
  String get settingsReducedMotion => 'Zmniejsz efekty wizualne';

  @override
  String get settingsReducedMotionSub => 'Wyłącza glitch i nagłe rozbłyski.';

  @override
  String get settingsHaptics => 'Wibracje';

  @override
  String get settingsHapticsSub =>
      'Wibracja przy zdarzeniach (np. nadchodząca wiadomość).';

  @override
  String get settingsGuidedMode => 'Tryb prowadzony';

  @override
  String get settingsGuidedModeSub =>
      'Częstsze podpowiedzi od Nieznanego, jeśli utkniesz.';

  @override
  String get settingsTelemetry => 'Wysyłaj raporty błędów';

  @override
  String get settingsTelemetrySub =>
      'Tylko stack trace i wersja gry. Bez danych osobowych.';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsLanguagePolish => 'Polski';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsResetGame => 'Resetuj rozgrywkę';

  @override
  String get settingsResetGameSub =>
      'Wymaże postępy. Ustawienia zostaną zachowane.';

  @override
  String get settingsAbout => 'O grze';

  @override
  String get settingsResetConfirmTitle => 'Zresetować rozgrywkę?';

  @override
  String get settingsResetConfirmBody =>
      'To wymaże twoje postępy: notatki, rozdziały, zakończenia. Ustawienia (język, dźwięk, wibracje) zostaną zachowane.';

  @override
  String get settingsResetConfirmCancel => 'Anuluj';

  @override
  String get settingsResetConfirmConfirm => 'Resetuj';

  @override
  String aboutVersion(String version) {
    return 'Wersja $version';
  }

  @override
  String get aboutPrivacyPolicy => 'Polityka prywatności';

  @override
  String get aboutLicenses => 'Licencje open-source';

  @override
  String get endingPlayAgain => 'Zagraj jeszcze raz';

  @override
  String get endingShare => 'Udostępnij wynik';

  @override
  String get endingTimeLabel => 'Czas rozgrywki';

  @override
  String get endingTitleLabel => 'Zakończenie';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonClose => 'Zamknij';

  @override
  String get commonRetry => 'Spróbuj ponownie';

  @override
  String get commonNoSignal => 'Brak zasięgu';

  @override
  String get commonOffline => 'Offline';

  @override
  String get iapFullGameUnlock => 'Odblokuj pełną wersję';

  @override
  String get iapFullGameUnlockSub =>
      'Jednorazowy zakup odblokowujący wszystkie rozdziały i zakończenia.';

  @override
  String get iapRestore => 'Przywróć zakupy';

  @override
  String get telemetryTitle => 'Telemetria';

  @override
  String get telemetrySub =>
      'Wysyłaj anonimowe raporty o błędach, aby pomóc ulepszyć grę.';

  @override
  String get phoneRecents => 'Ostatnie';

  @override
  String get phoneKeypad => 'Klawiatura';

  @override
  String get phoneMissed => 'Nieodebrane';

  @override
  String get phoneVoicemail => 'POCZTA GŁOSOWA';

  @override
  String get phoneNoSignal => 'Połączenie nieudane';

  @override
  String get phoneNoSignalBody =>
      'Brak zasięgu sieci komórkowej. Nie można nawiązać połączenia.';

  @override
  String get phoneVoicemailTranscript => 'Transkrypcja:';

  @override
  String get calendarTitle => 'Kalendarz';

  @override
  String get calendarLastWeek => 'Ostatni tydzień';

  @override
  String get calendarNoMoreEvents => 'Brak dalszych wpisów.';

  @override
  String get calendarEventDetail => 'Szczegóły wydarzenia';

  @override
  String get contactsTitle => 'Kontakty';

  @override
  String contactsCount(int count) {
    return '$count kontaktów';
  }

  @override
  String get contactsNoteLabel => 'Notatka:';

  @override
  String get browserHistory => 'Historia';

  @override
  String get browserSearchHint => 'Szukaj w historii';

  @override
  String get browserPrivateMode => 'TRYB PRYWATNY';

  @override
  String browserPrivateEntriesCount(int count) {
    return '$count wpisów';
  }

  @override
  String get browserPrivateLocked => 'Zablokowane';

  @override
  String get browserPrivatePasswordTitle => 'Tryb prywatny';

  @override
  String get browserPrivatePasswordBody =>
      'Karty prywatne są zaszyfrowane. Wpisz hasło, którego N. używała do swoich zapisanych sesji.';

  @override
  String get browserPrivatePasswordHint => 'Hasło';

  @override
  String get browserPrivateUnlock => 'Odblokuj';

  @override
  String get browserPrivateWrongPassword => 'Nieprawidłowe hasło';

  @override
  String get browserPrivateLockedCardTitle => 'Karty prywatne są zaszyfrowane';

  @override
  String get browserPrivateLockedCardSub => 'Stuknij, aby wpisać hasło';

  @override
  String get homeAppLockedFiles => 'Najpierw sprawdź Wiadomości';

  @override
  String get homeAppLockedSafari => 'Historia pusta — najpierw sprawdź Zdjęcia';

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
