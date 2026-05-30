// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'OFFLINE';

  @override
  String get lockEnterPin => 'Введите код';

  @override
  String get lockHelperHint => 'Введите 4-значный код, чтобы продолжить.';

  @override
  String get lockWrongPin => 'Неверный код';

  @override
  String get lockHintOrwell => 'Podpowiedź: Orwell';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAudioMute => 'Выключить звук';

  @override
  String get settingsAudioMuteSub =>
      'Отключает эмбиент, напряжение и звуковые эффекты.';

  @override
  String get settingsReducedMotion => 'Уменьшение движения';

  @override
  String get settingsReducedMotionSub =>
      'Отключает глитчи и эффекты внезапных вспышек.';

  @override
  String get settingsHaptics => 'Вибрация';

  @override
  String get settingsHapticsSub =>
      'Вибрация при событиях (например, входящее сообщение).';

  @override
  String get settingsGuidedMode => 'Режим подсказок';

  @override
  String get settingsGuidedModeSub =>
      'Частые подсказки от Неизвестного, если вы застряли.';

  @override
  String get settingsTelemetry => 'Отправлять отчеты об ошибках';

  @override
  String get settingsTelemetrySub =>
      'Только стек вызовов и версия игры. Без личных данных.';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguagePolish => 'Polski';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsResetGame => 'Сбросить игру';

  @override
  String get settingsResetGameSub =>
      'Стирает прогресс. Настройки будут сохранены.';

  @override
  String get settingsAbout => 'Об игре';

  @override
  String get settingsResetConfirmTitle => 'Сбросить игру?';

  @override
  String get settingsResetConfirmBody =>
      'Это сотрет ваш прогресс: заметки, главы, концовки. Настройки (язык, звук, вибрация) будут сохранены.';

  @override
  String get settingsResetConfirmCancel => 'Отмена';

  @override
  String get settingsResetConfirmConfirm => 'Сбросить';

  @override
  String aboutVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get aboutPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get aboutLicenses => 'Open-source лицензии';

  @override
  String get endingPlayAgain => 'Играть снова';

  @override
  String get endingShare => 'Поделиться результатом';

  @override
  String get endingTimeLabel => 'Время игры';

  @override
  String get endingTitleLabel => 'Финал';

  @override
  String get commonOk => 'ОК';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonNoSignal => 'Нет сигнала';

  @override
  String get commonOffline => 'Оффлайн';

  @override
  String get iapFullGameUnlock => 'Разблокировать полную игру';

  @override
  String get iapFullGameUnlockSub =>
      'Единоразовая покупка для разблокировки всех глав и концовок.';

  @override
  String get iapRestore => 'Восстановить покупки';

  @override
  String get telemetryTitle => 'Телеметрия';

  @override
  String get telemetrySub =>
      'Отправляйте анонимные отчеты об ошибках, чтобы помочь улучшить игру.';

  @override
  String get phoneRecents => 'Недавние';

  @override
  String get phoneKeypad => 'Клавиши';

  @override
  String get phoneMissed => 'Пропущенные';

  @override
  String get phoneVoicemail => 'АВТООТВЕТЧИК';

  @override
  String get phoneNoSignal => 'Вызов не удался';

  @override
  String get phoneNoSignalBody =>
      'Нет сигнала сети. Не удалось установить соединение.';

  @override
  String get phoneVoicemailTranscript => 'Транскрипция:';

  @override
  String get calendarTitle => 'Календарь';

  @override
  String get calendarLastWeek => 'Прошлая неделя';

  @override
  String get calendarNoMoreEvents => 'Больше записей нет.';

  @override
  String get calendarEventDetail => 'Детали события';

  @override
  String get contactsTitle => 'Контакты';

  @override
  String contactsCount(int count) {
    return '$count контактов';
  }

  @override
  String get contactsNoteLabel => 'Заметка:';

  @override
  String get browserHistory => 'История';

  @override
  String get browserSearchHint => 'Поиск по истории';

  @override
  String get browserPrivateMode => 'ПРИВАТНЫЙ РЕЖИМ';

  @override
  String browserPrivateEntriesCount(int count) {
    return '$count записей';
  }

  @override
  String get browserPrivateLocked => 'Заблокировано';

  @override
  String get browserPrivatePasswordTitle => 'Приватный режим';

  @override
  String get browserPrivatePasswordBody =>
      'Приватные вкладки зашифрованы. Введите пароль, который N. использовала для своих сохраненных сессий.';

  @override
  String get browserPrivatePasswordHint => 'Пароль';

  @override
  String get browserPrivateUnlock => 'Разблокировать';

  @override
  String get browserPrivateWrongPassword => 'Неверный пароль';

  @override
  String get browserPrivateLockedCardTitle => 'Приватные вкладки зашифрованы';

  @override
  String get browserPrivateLockedCardSub => 'Нажмите, чтобы ввести пароль';

  @override
  String get homeAppLockedFiles => 'Сначала проверьте Сообщения';

  @override
  String get homeAppLockedSafari => 'История пуста — сначала проверьте Фото';

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
