// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'OFFLINE';

  @override
  String get lockEnterPin => 'Inserisci codice';

  @override
  String get lockHelperHint => 'Inserisci il codice a 4 cifre per continuare.';

  @override
  String get lockWrongPin => 'Codice errato';

  @override
  String get lockHintOrwell => 'Podpowiedź: Orwell';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsAudioMute => 'Disattiva suoni';

  @override
  String get settingsAudioMuteSub =>
      'Disattiva ambiente, tensione ed effetti sonori.';

  @override
  String get settingsReducedMotion => 'Riduci movimento';

  @override
  String get settingsReducedMotionSub =>
      'Disattiva il glitch e gli effetti flash improvvisi.';

  @override
  String get settingsHaptics => 'Vibrazione';

  @override
  String get settingsHapticsSub =>
      'Vibra al verificarsi di eventi (es. messaggio in arrivo).';

  @override
  String get settingsGuidedMode => 'Modalità guidata';

  @override
  String get settingsGuidedModeSub =>
      'Suggerimenti frequenti dallo Sconosciuto se rimani bloccato.';

  @override
  String get settingsTelemetry => 'Invia rapporti errori';

  @override
  String get settingsTelemetrySub =>
      'Solo stack trace e versione del gioco. Nessun dato personale.';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguagePolish => 'Polski';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsResetGame => 'Reinizia partita';

  @override
  String get settingsResetGameSub =>
      'Cancella i progressi. Le impostazioni verranno conservate.';

  @override
  String get settingsAbout => 'Info sul gioco';

  @override
  String get settingsResetConfirmTitle => 'Reiniziare la partita?';

  @override
  String get settingsResetConfirmBody =>
      'Questo cancellerà i tuoi progressi: note, capitoli, finali. Le impostazioni (lingua, suono, vibrazione) verranno conservate.';

  @override
  String get settingsResetConfirmCancel => 'Annulla';

  @override
  String get settingsResetConfirmConfirm => 'Reinizia';

  @override
  String aboutVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get aboutPrivacyPolicy => 'Informativa sulla privacy';

  @override
  String get aboutLicenses => 'Licenze open source';

  @override
  String get endingPlayAgain => 'Gioca ancora';

  @override
  String get endingShare => 'Condividi risultato';

  @override
  String get endingTimeLabel => 'Tempo di gioco';

  @override
  String get endingTitleLabel => 'Finale';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonRetry => 'Riprova';

  @override
  String get commonNoSignal => 'Nessun segnale';

  @override
  String get commonOffline => 'Offline';

  @override
  String get iapFullGameUnlock => 'Sblocca gioco completo';

  @override
  String get iapFullGameUnlockSub =>
      'Acquisto una tantum per sbloccare tutti i capitoli e i finali.';

  @override
  String get iapRestore => 'Ripristina acquisti';

  @override
  String get telemetryTitle => 'Telemetria';

  @override
  String get telemetrySub =>
      'Invia rapporti errori anonimi per aiutare a migliorare il gioco.';

  @override
  String get phoneRecents => 'Recenti';

  @override
  String get phoneKeypad => 'Tastierino';

  @override
  String get phoneMissed => 'Perse';

  @override
  String get phoneVoicemail => 'SEGRETERIA';

  @override
  String get phoneNoSignal => 'Chiamata fallita';

  @override
  String get phoneNoSignalBody =>
      'Nessun segnale di rete. Impossibile stabilire la connessione.';

  @override
  String get phoneVoicemailTranscript => 'Trascrizione:';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get calendarLastWeek => 'Settimana scorsa';

  @override
  String get calendarNoMoreEvents => 'Nessuna altra voce.';

  @override
  String get calendarEventDetail => 'Dettagli evento';

  @override
  String get contactsTitle => 'Contatti';

  @override
  String contactsCount(int count) {
    return '$count contatti';
  }

  @override
  String get contactsNoteLabel => 'Nota:';

  @override
  String get browserHistory => 'Cronologia';

  @override
  String get browserSearchHint => 'Cerca nella cronologia';

  @override
  String get browserPrivateMode => 'MODALITÀ PRIVATA';

  @override
  String browserPrivateEntriesCount(int count) {
    return '$count voci';
  }

  @override
  String get browserPrivateLocked => 'Bloccato';

  @override
  String get browserPrivatePasswordTitle => 'Modalità privata';

  @override
  String get browserPrivatePasswordBody =>
      'Le schede private sono crittografate. Inserisci la password che N. usava per le sue sessioni salvate.';

  @override
  String get browserPrivatePasswordHint => 'Password';

  @override
  String get browserPrivateUnlock => 'Sblocca';

  @override
  String get browserPrivateWrongPassword => 'Password errata';

  @override
  String get browserPrivateLockedCardTitle =>
      'Le schede private sono crittografate';

  @override
  String get browserPrivateLockedCardSub => 'Tocca per inserire la password';

  @override
  String get homeAppLockedFiles => 'Controlla prima i Messaggi';

  @override
  String get homeAppLockedSafari =>
      'Cronologia vuota – controlla prima le Foto';

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
