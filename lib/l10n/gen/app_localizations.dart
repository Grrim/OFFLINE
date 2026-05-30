import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('pl'),
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('ru')
  ];

  /// Tytuł aplikacji w trybie systemowym
  ///
  /// In pl, this message translates to:
  /// **'OFFLINE'**
  String get appTitle;

  /// No description provided for @lockEnterPin.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź hasło'**
  String get lockEnterPin;

  /// No description provided for @lockHelperHint.
  ///
  /// In pl, this message translates to:
  /// **'Aby kontynuować, wpisz 4-cyfrowy kod.'**
  String get lockHelperHint;

  /// No description provided for @lockWrongPin.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowy kod'**
  String get lockWrongPin;

  /// No description provided for @lockHintOrwell.
  ///
  /// In pl, this message translates to:
  /// **'Podpowiedź: Orwell'**
  String get lockHintOrwell;

  /// No description provided for @settingsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get settingsTitle;

  /// No description provided for @settingsAudioMute.
  ///
  /// In pl, this message translates to:
  /// **'Wycisz dźwięki'**
  String get settingsAudioMute;

  /// No description provided for @settingsAudioMuteSub.
  ///
  /// In pl, this message translates to:
  /// **'Wyłącza ambient, tension i SFX.'**
  String get settingsAudioMuteSub;

  /// No description provided for @settingsReducedMotion.
  ///
  /// In pl, this message translates to:
  /// **'Zmniejsz efekty wizualne'**
  String get settingsReducedMotion;

  /// No description provided for @settingsReducedMotionSub.
  ///
  /// In pl, this message translates to:
  /// **'Wyłącza glitch i nagłe rozbłyski.'**
  String get settingsReducedMotionSub;

  /// No description provided for @settingsHaptics.
  ///
  /// In pl, this message translates to:
  /// **'Wibracje'**
  String get settingsHaptics;

  /// No description provided for @settingsHapticsSub.
  ///
  /// In pl, this message translates to:
  /// **'Wibracja przy zdarzeniach (np. nadchodząca wiadomość).'**
  String get settingsHapticsSub;

  /// No description provided for @settingsGuidedMode.
  ///
  /// In pl, this message translates to:
  /// **'Tryb prowadzony'**
  String get settingsGuidedMode;

  /// No description provided for @settingsGuidedModeSub.
  ///
  /// In pl, this message translates to:
  /// **'Częstsze podpowiedzi od Nieznanego, jeśli utkniesz.'**
  String get settingsGuidedModeSub;

  /// No description provided for @settingsTelemetry.
  ///
  /// In pl, this message translates to:
  /// **'Wysyłaj raporty błędów'**
  String get settingsTelemetry;

  /// No description provided for @settingsTelemetrySub.
  ///
  /// In pl, this message translates to:
  /// **'Tylko stack trace i wersja gry. Bez danych osobowych.'**
  String get settingsTelemetrySub;

  /// No description provided for @settingsLanguage.
  ///
  /// In pl, this message translates to:
  /// **'Język'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguagePolish.
  ///
  /// In pl, this message translates to:
  /// **'Polski'**
  String get settingsLanguagePolish;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In pl, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsResetGame.
  ///
  /// In pl, this message translates to:
  /// **'Resetuj rozgrywkę'**
  String get settingsResetGame;

  /// No description provided for @settingsResetGameSub.
  ///
  /// In pl, this message translates to:
  /// **'Wymaże postępy. Ustawienia zostaną zachowane.'**
  String get settingsResetGameSub;

  /// No description provided for @settingsAbout.
  ///
  /// In pl, this message translates to:
  /// **'O grze'**
  String get settingsAbout;

  /// No description provided for @settingsResetConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zresetować rozgrywkę?'**
  String get settingsResetConfirmTitle;

  /// No description provided for @settingsResetConfirmBody.
  ///
  /// In pl, this message translates to:
  /// **'To wymaże twoje postępy: notatki, rozdziały, zakończenia. Ustawienia (język, dźwięk, wibracje) zostaną zachowane.'**
  String get settingsResetConfirmBody;

  /// No description provided for @settingsResetConfirmCancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get settingsResetConfirmCancel;

  /// No description provided for @settingsResetConfirmConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Resetuj'**
  String get settingsResetConfirmConfirm;

  /// No description provided for @aboutVersion.
  ///
  /// In pl, this message translates to:
  /// **'Wersja {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutPrivacyPolicy.
  ///
  /// In pl, this message translates to:
  /// **'Polityka prywatności'**
  String get aboutPrivacyPolicy;

  /// No description provided for @aboutLicenses.
  ///
  /// In pl, this message translates to:
  /// **'Licencje open-source'**
  String get aboutLicenses;

  /// No description provided for @endingPlayAgain.
  ///
  /// In pl, this message translates to:
  /// **'Zagraj jeszcze raz'**
  String get endingPlayAgain;

  /// No description provided for @endingShare.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnij wynik'**
  String get endingShare;

  /// No description provided for @endingTimeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Czas rozgrywki'**
  String get endingTimeLabel;

  /// No description provided for @endingTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Zakończenie'**
  String get endingTitleLabel;

  /// No description provided for @commonOk.
  ///
  /// In pl, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In pl, this message translates to:
  /// **'Zamknij'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get commonRetry;

  /// No description provided for @commonNoSignal.
  ///
  /// In pl, this message translates to:
  /// **'Brak zasięgu'**
  String get commonNoSignal;

  /// No description provided for @commonOffline.
  ///
  /// In pl, this message translates to:
  /// **'Offline'**
  String get commonOffline;

  /// No description provided for @iapFullGameUnlock.
  ///
  /// In pl, this message translates to:
  /// **'Odblokuj pełną wersję'**
  String get iapFullGameUnlock;

  /// No description provided for @iapFullGameUnlockSub.
  ///
  /// In pl, this message translates to:
  /// **'Jednorazowy zakup odblokowujący wszystkie rozdziały i zakończenia.'**
  String get iapFullGameUnlockSub;

  /// No description provided for @iapRestore.
  ///
  /// In pl, this message translates to:
  /// **'Przywróć zakupy'**
  String get iapRestore;

  /// No description provided for @telemetryTitle.
  ///
  /// In pl, this message translates to:
  /// **'Telemetria'**
  String get telemetryTitle;

  /// No description provided for @telemetrySub.
  ///
  /// In pl, this message translates to:
  /// **'Wysyłaj anonimowe raporty o błędach, aby pomóc ulepszyć grę.'**
  String get telemetrySub;

  /// No description provided for @phoneRecents.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnie'**
  String get phoneRecents;

  /// No description provided for @phoneKeypad.
  ///
  /// In pl, this message translates to:
  /// **'Klawiatura'**
  String get phoneKeypad;

  /// No description provided for @phoneMissed.
  ///
  /// In pl, this message translates to:
  /// **'Nieodebrane'**
  String get phoneMissed;

  /// No description provided for @phoneVoicemail.
  ///
  /// In pl, this message translates to:
  /// **'POCZTA GŁOSOWA'**
  String get phoneVoicemail;

  /// No description provided for @phoneNoSignal.
  ///
  /// In pl, this message translates to:
  /// **'Połączenie nieudane'**
  String get phoneNoSignal;

  /// No description provided for @phoneNoSignalBody.
  ///
  /// In pl, this message translates to:
  /// **'Brak zasięgu sieci komórkowej. Nie można nawiązać połączenia.'**
  String get phoneNoSignalBody;

  /// No description provided for @phoneVoicemailTranscript.
  ///
  /// In pl, this message translates to:
  /// **'Transkrypcja:'**
  String get phoneVoicemailTranscript;

  /// No description provided for @calendarTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kalendarz'**
  String get calendarTitle;

  /// No description provided for @calendarLastWeek.
  ///
  /// In pl, this message translates to:
  /// **'Ostatni tydzień'**
  String get calendarLastWeek;

  /// No description provided for @calendarNoMoreEvents.
  ///
  /// In pl, this message translates to:
  /// **'Brak dalszych wpisów.'**
  String get calendarNoMoreEvents;

  /// No description provided for @calendarEventDetail.
  ///
  /// In pl, this message translates to:
  /// **'Szczegóły wydarzenia'**
  String get calendarEventDetail;

  /// No description provided for @contactsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kontakty'**
  String get contactsTitle;

  /// No description provided for @contactsCount.
  ///
  /// In pl, this message translates to:
  /// **'{count} kontaktów'**
  String contactsCount(int count);

  /// No description provided for @contactsNoteLabel.
  ///
  /// In pl, this message translates to:
  /// **'Notatka:'**
  String get contactsNoteLabel;

  /// No description provided for @browserHistory.
  ///
  /// In pl, this message translates to:
  /// **'Historia'**
  String get browserHistory;

  /// No description provided for @browserSearchHint.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj w historii'**
  String get browserSearchHint;

  /// No description provided for @browserPrivateMode.
  ///
  /// In pl, this message translates to:
  /// **'TRYB PRYWATNY'**
  String get browserPrivateMode;

  /// No description provided for @browserPrivateEntriesCount.
  ///
  /// In pl, this message translates to:
  /// **'{count} wpisów'**
  String browserPrivateEntriesCount(int count);

  /// No description provided for @browserPrivateLocked.
  ///
  /// In pl, this message translates to:
  /// **'Zablokowane'**
  String get browserPrivateLocked;

  /// No description provided for @browserPrivatePasswordTitle.
  ///
  /// In pl, this message translates to:
  /// **'Tryb prywatny'**
  String get browserPrivatePasswordTitle;

  /// No description provided for @browserPrivatePasswordBody.
  ///
  /// In pl, this message translates to:
  /// **'Karty prywatne są zaszyfrowane. Wpisz hasło, którego N. używała do swoich zapisanych sesji.'**
  String get browserPrivatePasswordBody;

  /// No description provided for @browserPrivatePasswordHint.
  ///
  /// In pl, this message translates to:
  /// **'Hasło'**
  String get browserPrivatePasswordHint;

  /// No description provided for @browserPrivateUnlock.
  ///
  /// In pl, this message translates to:
  /// **'Odblokuj'**
  String get browserPrivateUnlock;

  /// No description provided for @browserPrivateWrongPassword.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowe hasło'**
  String get browserPrivateWrongPassword;

  /// No description provided for @browserPrivateLockedCardTitle.
  ///
  /// In pl, this message translates to:
  /// **'Karty prywatne są zaszyfrowane'**
  String get browserPrivateLockedCardTitle;

  /// No description provided for @browserPrivateLockedCardSub.
  ///
  /// In pl, this message translates to:
  /// **'Stuknij, aby wpisać hasło'**
  String get browserPrivateLockedCardSub;

  /// No description provided for @homeAppLockedFiles.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw sprawdź Wiadomości'**
  String get homeAppLockedFiles;

  /// No description provided for @homeAppLockedSafari.
  ///
  /// In pl, this message translates to:
  /// **'Historia pusta — najpierw sprawdź Zdjęcia'**
  String get homeAppLockedSafari;

  /// No description provided for @commonComingSoon.
  ///
  /// In pl, this message translates to:
  /// **'wkrótce'**
  String get commonComingSoon;

  /// No description provided for @appLabelPhone.
  ///
  /// In pl, this message translates to:
  /// **'Telefon'**
  String get appLabelPhone;

  /// No description provided for @appLabelMessages.
  ///
  /// In pl, this message translates to:
  /// **'Wiadomości'**
  String get appLabelMessages;

  /// No description provided for @appLabelMail.
  ///
  /// In pl, this message translates to:
  /// **'Poczta'**
  String get appLabelMail;

  /// No description provided for @appLabelContacts.
  ///
  /// In pl, this message translates to:
  /// **'Kontakty'**
  String get appLabelContacts;

  /// No description provided for @appLabelPhotos.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia'**
  String get appLabelPhotos;

  /// No description provided for @appLabelNotes.
  ///
  /// In pl, this message translates to:
  /// **'Notatki'**
  String get appLabelNotes;

  /// No description provided for @appLabelFiles.
  ///
  /// In pl, this message translates to:
  /// **'Pliki'**
  String get appLabelFiles;

  /// No description provided for @appLabelSafari.
  ///
  /// In pl, this message translates to:
  /// **'Safari'**
  String get appLabelSafari;

  /// No description provided for @appLabelCalendar.
  ///
  /// In pl, this message translates to:
  /// **'Kalendarz'**
  String get appLabelCalendar;

  /// No description provided for @appLabelRecorder.
  ///
  /// In pl, this message translates to:
  /// **'Dyktafon'**
  String get appLabelRecorder;

  /// No description provided for @appLabelMaps.
  ///
  /// In pl, this message translates to:
  /// **'Mapy'**
  String get appLabelMaps;

  /// No description provided for @appLabelSettings.
  ///
  /// In pl, this message translates to:
  /// **'Ustawienia'**
  String get appLabelSettings;

  /// No description provided for @appLabelSignal.
  ///
  /// In pl, this message translates to:
  /// **'Signal'**
  String get appLabelSignal;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In pl, this message translates to:
  /// **'OGÓLNE'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In pl, this message translates to:
  /// **'JĘZYK'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsSectionGame.
  ///
  /// In pl, this message translates to:
  /// **'GRA'**
  String get settingsSectionGame;

  /// No description provided for @settingsSectionPrivacy.
  ///
  /// In pl, this message translates to:
  /// **'PRYWATNOŚĆ'**
  String get settingsSectionPrivacy;

  /// No description provided for @settingsSectionInfo.
  ///
  /// In pl, this message translates to:
  /// **'INFORMACJE'**
  String get settingsSectionInfo;

  /// No description provided for @settingsFlavourAirplane.
  ///
  /// In pl, this message translates to:
  /// **'Tryb samolotowy'**
  String get settingsFlavourAirplane;

  /// No description provided for @settingsFlavourWifi.
  ///
  /// In pl, this message translates to:
  /// **'Wi-Fi'**
  String get settingsFlavourWifi;

  /// No description provided for @settingsFlavourBluetooth.
  ///
  /// In pl, this message translates to:
  /// **'Bluetooth'**
  String get settingsFlavourBluetooth;

  /// No description provided for @settingsFlavourCellular.
  ///
  /// In pl, this message translates to:
  /// **'Komórkowe'**
  String get settingsFlavourCellular;

  /// No description provided for @settingsFlavourNotifications.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia'**
  String get settingsFlavourNotifications;

  /// No description provided for @settingsFlavourPasscode.
  ///
  /// In pl, this message translates to:
  /// **'Kod i Face ID'**
  String get settingsFlavourPasscode;

  /// No description provided for @settingsFlavourModel.
  ///
  /// In pl, this message translates to:
  /// **'Model'**
  String get settingsFlavourModel;

  /// No description provided for @settingsFlavourBattery.
  ///
  /// In pl, this message translates to:
  /// **'Bateria'**
  String get settingsFlavourBattery;

  /// No description provided for @settingsFlavourStorage.
  ///
  /// In pl, this message translates to:
  /// **'Pamięć'**
  String get settingsFlavourStorage;

  /// No description provided for @settingsFlavourOwner.
  ///
  /// In pl, this message translates to:
  /// **'Właściciel'**
  String get settingsFlavourOwner;

  /// No description provided for @settingsFlavourFeedbackAirplane.
  ///
  /// In pl, this message translates to:
  /// **'Tryb samolotowy jest wyłączony'**
  String get settingsFlavourFeedbackAirplane;

  /// No description provided for @settingsFlavourFeedbackWifi.
  ///
  /// In pl, this message translates to:
  /// **'Połączono z: HB_Guest_5G (nieszyfrowane)'**
  String get settingsFlavourFeedbackWifi;

  /// No description provided for @settingsFlavourFeedbackBluetooth.
  ///
  /// In pl, this message translates to:
  /// **'Bluetooth jest wyłączony'**
  String get settingsFlavourFeedbackBluetooth;

  /// No description provided for @settingsFlavourFeedbackCellular.
  ///
  /// In pl, this message translates to:
  /// **'Brak karty SIM lub zasięgu'**
  String get settingsFlavourFeedbackCellular;

  /// No description provided for @settingsFlavourFeedbackNotifications.
  ///
  /// In pl, this message translates to:
  /// **'Nie można zmienić ustawień powiadomień'**
  String get settingsFlavourFeedbackNotifications;

  /// No description provided for @settingsFlavourFeedbackPasscode.
  ///
  /// In pl, this message translates to:
  /// **'Wymagane uwierzytelnienie właściciela'**
  String get settingsFlavourFeedbackPasscode;

  /// No description provided for @settingsFlavourFeedbackIapAttempt.
  ///
  /// In pl, this message translates to:
  /// **'Próba przywrócenia zakupów została wysłana.'**
  String get settingsFlavourFeedbackIapAttempt;

  /// No description provided for @settingsFlavourFeedbackIapError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd przywracania zakupów.'**
  String get settingsFlavourFeedbackIapError;

  /// No description provided for @settingsFlavourValueBluetoothOff.
  ///
  /// In pl, this message translates to:
  /// **'Wyłączony'**
  String get settingsFlavourValueBluetoothOff;

  /// No description provided for @settingsFlavourValueCellNoSignal.
  ///
  /// In pl, this message translates to:
  /// **'Brak zasięgu'**
  String get settingsFlavourValueCellNoSignal;

  /// No description provided for @settingsFlavourValueEnabled.
  ///
  /// In pl, this message translates to:
  /// **'Włączone'**
  String get settingsFlavourValueEnabled;

  /// No description provided for @settingsFlavourValueOwnerName.
  ///
  /// In pl, this message translates to:
  /// **'N.'**
  String get settingsFlavourValueOwnerName;

  /// No description provided for @settingsFlavourValueStorage.
  ///
  /// In pl, this message translates to:
  /// **'47 GB / 256 GB'**
  String get settingsFlavourValueStorage;

  /// No description provided for @settingsFlavourAboutSub.
  ///
  /// In pl, this message translates to:
  /// **'Wersja, polityka prywatności, licencje.'**
  String get settingsFlavourAboutSub;

  /// No description provided for @settingsFlavourValueBattery.
  ///
  /// In pl, this message translates to:
  /// **'{percent}%'**
  String settingsFlavourValueBattery(Object percent);

  /// No description provided for @settingsFlavourFeedbackBattery.
  ///
  /// In pl, this message translates to:
  /// **'Stan baterii: {percent}% · Ostatnie ładowanie: wczoraj 18:00'**
  String settingsFlavourFeedbackBattery(Object percent);

  /// No description provided for @settingsFlavourFeedbackStorage.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcia: 12 GB · Aplikacje: 28 GB · System: 7 GB'**
  String get settingsFlavourFeedbackStorage;

  /// No description provided for @settingsFlavourFeedbackOwner.
  ///
  /// In pl, this message translates to:
  /// **'Apple ID: n.***@icloud.com · Zalogowano'**
  String get settingsFlavourFeedbackOwner;

  /// No description provided for @contentWarningTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zanim zaczniesz'**
  String get contentWarningTitle;

  /// No description provided for @contentWarningSectionThemesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Tematyka 13+'**
  String get contentWarningSectionThemesTitle;

  /// No description provided for @contentWarningSectionThemesBody.
  ///
  /// In pl, this message translates to:
  /// **'OFFLINE to gra detektywistyczna o zaginięciu osoby. Pojawiają się motywy stalkingu, korupcji i przemocy psychicznej. Brak fizycznej przemocy, treści seksualnych ani nadużyć wobec dzieci.'**
  String get contentWarningSectionThemesBody;

  /// No description provided for @contentWarningSectionVisualsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Efekty wizualne'**
  String get contentWarningSectionVisualsTitle;

  /// No description provided for @contentWarningSectionVisualsBody.
  ///
  /// In pl, this message translates to:
  /// **'Gra używa krótkich glitchy i przyciemniających rozbłysków. Jeśli masz fotosensytywność, możesz je wyłączyć w Ustawieniach → Zmniejsz efekty wizualne.'**
  String get contentWarningSectionVisualsBody;

  /// No description provided for @contentWarningContinue.
  ///
  /// In pl, this message translates to:
  /// **'Rozumiem, kontynuuj'**
  String get contentWarningContinue;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'it',
        'pl',
        'pt',
        'ru'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
