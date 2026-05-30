// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'OFFLINE';

  @override
  String get lockEnterPin => 'Introduzir código';

  @override
  String get lockHelperHint =>
      'Introduza o código de 4 dígitos para continuar.';

  @override
  String get lockWrongPin => 'Código incorreto';

  @override
  String get lockHintOrwell => 'Podpowiedź: Orwell';

  @override
  String get settingsTitle => 'Definições';

  @override
  String get settingsAudioMute => 'Silenciar sons';

  @override
  String get settingsAudioMuteSub =>
      'Desativa o ambiente, a tensão e os efeitos sonoros.';

  @override
  String get settingsReducedMotion => 'Reduzir movimento';

  @override
  String get settingsReducedMotionSub =>
      'Desativa o glitch e os efeitos de flash repentinos.';

  @override
  String get settingsHaptics => 'Vibração';

  @override
  String get settingsHapticsSub => 'Vibrar em eventos (ex. mensagem recebida).';

  @override
  String get settingsGuidedMode => 'Modo guiado';

  @override
  String get settingsGuidedModeSub =>
      'Sugestões frequentes do Desconhecido se ficar preso.';

  @override
  String get settingsTelemetry => 'Enviar relatórios de erros';

  @override
  String get settingsTelemetrySub =>
      'Apenas rastreio de pilha e versão do jogo. Sem dados pessoais.';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguagePolish => 'Polski';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsResetGame => 'Reiniciar jogo';

  @override
  String get settingsResetGameSub =>
      'Apaga o progresso. As definições serão preservadas.';

  @override
  String get settingsAbout => 'Sobre o jogo';

  @override
  String get settingsResetConfirmTitle => 'Reiniciar o jogo?';

  @override
  String get settingsResetConfirmBody =>
      'Isto apagará o seu progresso: notas, capítulos, finais. As definições (idioma, som, vibração) serão preservadas.';

  @override
  String get settingsResetConfirmCancel => 'Cancelar';

  @override
  String get settingsResetConfirmConfirm => 'Reiniciar';

  @override
  String aboutVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get aboutPrivacyPolicy => 'Política de privacidade';

  @override
  String get aboutLicenses => 'Licenças de código aberto';

  @override
  String get endingPlayAgain => 'Jogar novamente';

  @override
  String get endingShare => 'Partilhar resultado';

  @override
  String get endingTimeLabel => 'Tempo de jogo';

  @override
  String get endingTitleLabel => 'Final';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonRetry => 'Tentar novamente';

  @override
  String get commonNoSignal => 'Sem sinal';

  @override
  String get commonOffline => 'Offline';

  @override
  String get iapFullGameUnlock => 'Desbloquear jogo completo';

  @override
  String get iapFullGameUnlockSub =>
      'Compra única para desbloquear todos os capítulos e finais.';

  @override
  String get iapRestore => 'Restaurar compras';

  @override
  String get telemetryTitle => 'Telemetria';

  @override
  String get telemetrySub =>
      'Envie relatórios de erros anónimos para ajudar a melhorar o jogo.';

  @override
  String get phoneRecents => 'Recentes';

  @override
  String get phoneKeypad => 'Teclado';

  @override
  String get phoneMissed => 'Perdidas';

  @override
  String get phoneVoicemail => 'CORREIO DE VOZ';

  @override
  String get phoneNoSignal => 'Chamada falhou';

  @override
  String get phoneNoSignalBody =>
      'Sem sinal de rede. Não é possível estabelecer ligação.';

  @override
  String get phoneVoicemailTranscript => 'Transcrição:';

  @override
  String get calendarTitle => 'Calendário';

  @override
  String get calendarLastWeek => 'Semana passada';

  @override
  String get calendarNoMoreEvents => 'Não há mais entradas.';

  @override
  String get calendarEventDetail => 'Detalhes do evento';

  @override
  String get contactsTitle => 'Contactos';

  @override
  String contactsCount(int count) {
    return '$count contactos';
  }

  @override
  String get contactsNoteLabel => 'Nota:';

  @override
  String get browserHistory => 'Histórico';

  @override
  String get browserSearchHint => 'Pesquisar no histórico';

  @override
  String get browserPrivateMode => 'MODO PRIVADO';

  @override
  String browserPrivateEntriesCount(int count) {
    return '$count entradas';
  }

  @override
  String get browserPrivateLocked => 'Bloqueado';

  @override
  String get browserPrivatePasswordTitle => 'Modo privado';

  @override
  String get browserPrivatePasswordBody =>
      'Os separadores privados estão encriptados. Introduza a palavra-passe que N. usava para as suas sessões guardadas.';

  @override
  String get browserPrivatePasswordHint => 'Palavra-passe';

  @override
  String get browserPrivateUnlock => 'Desbloquear';

  @override
  String get browserPrivateWrongPassword => 'Palavra-passe incorreta';

  @override
  String get browserPrivateLockedCardTitle =>
      'Os separadores privados estão encriptados';

  @override
  String get browserPrivateLockedCardSub =>
      'Toque para introduzir a palavra-passe';

  @override
  String get homeAppLockedFiles => 'Verifique as Mensagens primeiro';

  @override
  String get homeAppLockedSafari =>
      'Histórico vazio – verifique as Fotos primeiro';

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
