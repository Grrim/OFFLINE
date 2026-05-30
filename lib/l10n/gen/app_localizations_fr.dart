// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'OFFLINE';

  @override
  String get lockEnterPin => 'Entrer le code';

  @override
  String get lockHelperHint => 'Entrez le code à 4 chiffres pour continuer.';

  @override
  String get lockWrongPin => 'Code incorrect';

  @override
  String get lockHintOrwell => 'Podpowiedź: Orwell';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsAudioMute => 'Couper les sons';

  @override
  String get settingsAudioMuteSub =>
      'Désactive l\'ambiance, la tension et les effets sonores.';

  @override
  String get settingsReducedMotion => 'Réduire les animations';

  @override
  String get settingsReducedMotionSub =>
      'Désactive les effets de glitch et de flash soudains.';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsHapticsSub =>
      'Vibration lors des événements (ex. message entrant).';

  @override
  String get settingsGuidedMode => 'Mode guidé';

  @override
  String get settingsGuidedModeSub =>
      'Indices fréquents de l\'Inconnu si vous êtes bloqué.';

  @override
  String get settingsTelemetry => 'Envoyer des rapports d\'erreurs';

  @override
  String get settingsTelemetrySub =>
      'Trace de pile et version du jeu uniquement. Pas de données personnelles.';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguagePolish => 'Polski';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsResetGame => 'Réinitialiser la partie';

  @override
  String get settingsResetGameSub =>
      'Efface la progression. Les réglages seront conservés.';

  @override
  String get settingsAbout => 'À propos du jeu';

  @override
  String get settingsResetConfirmTitle => 'Réinitialiser la partie ?';

  @override
  String get settingsResetConfirmBody =>
      'Cela effacera votre progression : notes, chapitres, fins. Les réglages (langue, son, vibration) seront conservés.';

  @override
  String get settingsResetConfirmCancel => 'Annuler';

  @override
  String get settingsResetConfirmConfirm => 'Réinitialiser';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get aboutLicenses => 'Licences open-source';

  @override
  String get endingPlayAgain => 'Rejouer';

  @override
  String get endingShare => 'Partager le résultat';

  @override
  String get endingTimeLabel => 'Temps de jeu';

  @override
  String get endingTitleLabel => 'Fin';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonNoSignal => 'Pas de signal';

  @override
  String get commonOffline => 'Hors ligne';

  @override
  String get iapFullGameUnlock => 'Débloquer le jeu complet';

  @override
  String get iapFullGameUnlockSub =>
      'Achat unique pour débloquer tous les chapitres et toutes les fins.';

  @override
  String get iapRestore => 'Restaurer les achats';

  @override
  String get telemetryTitle => 'Télémétrie';

  @override
  String get telemetrySub =>
      'Envoyez des rapports d\'erreurs anonymes pour aider à améliorer le jeu.';

  @override
  String get phoneRecents => 'Récents';

  @override
  String get phoneKeypad => 'Clavier';

  @override
  String get phoneMissed => 'Appels manqués';

  @override
  String get phoneVoicemail => 'MESSAGERIE';

  @override
  String get phoneNoSignal => 'Échec de l\'appel';

  @override
  String get phoneNoSignalBody =>
      'Pas de signal réseau. Impossible d\'établir la connexion.';

  @override
  String get phoneVoicemailTranscript => 'Transcription :';

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get calendarLastWeek => 'Semaine dernière';

  @override
  String get calendarNoMoreEvents => 'Plus d\'entrées.';

  @override
  String get calendarEventDetail => 'Détails de l\'événement';

  @override
  String get contactsTitle => 'Contacts';

  @override
  String contactsCount(int count) {
    return '$count contacts';
  }

  @override
  String get contactsNoteLabel => 'Note :';

  @override
  String get browserHistory => 'Historique';

  @override
  String get browserSearchHint => 'Rechercher dans l\'historique';

  @override
  String get browserPrivateMode => 'MODE PRIVÉ';

  @override
  String browserPrivateEntriesCount(int count) {
    return '$count entrées';
  }

  @override
  String get browserPrivateLocked => 'Verrouillé';

  @override
  String get browserPrivatePasswordTitle => 'Mode privé';

  @override
  String get browserPrivatePasswordBody =>
      'Les onglets privés sont chiffrés. Entrez le mot de passe que N. utilisait pour ses sessions enregistrées.';

  @override
  String get browserPrivatePasswordHint => 'Mot de passe';

  @override
  String get browserPrivateUnlock => 'Déverrouiller';

  @override
  String get browserPrivateWrongPassword => 'Mot de passe incorrect';

  @override
  String get browserPrivateLockedCardTitle =>
      'Les onglets privés sont chiffrés';

  @override
  String get browserPrivateLockedCardSub =>
      'Appuyez pour entrer le mot de passe';

  @override
  String get homeAppLockedFiles => 'Consultez les Messages d\'abord';

  @override
  String get homeAppLockedSafari =>
      'Historique vide – consultez les Photos d\'abord';

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
