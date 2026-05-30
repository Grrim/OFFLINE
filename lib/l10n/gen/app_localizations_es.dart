// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'OFFLINE';

  @override
  String get lockEnterPin => 'Introducir código';

  @override
  String get lockHelperHint =>
      'Introduce el código de 4 dígitos para continuar.';

  @override
  String get lockWrongPin => 'Código incorrecto';

  @override
  String get lockHintOrwell => 'Podpowiedź: Orwell';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAudioMute => 'Silenciar sonidos';

  @override
  String get settingsAudioMuteSub =>
      'Desactiva el ambiente, la tensión y los efectos de sonido.';

  @override
  String get settingsReducedMotion => 'Reducir movimiento';

  @override
  String get settingsReducedMotionSub =>
      'Desactiva el glitch y los efectos de flash repentinos.';

  @override
  String get settingsHaptics => 'Vibración';

  @override
  String get settingsHapticsSub =>
      'Vibra al recibir eventos (ej. mensaje entrante).';

  @override
  String get settingsGuidedMode => 'Modo guiado';

  @override
  String get settingsGuidedModeSub =>
      'Sugerencias frecuentes del Desconocido si te quedas atascado.';

  @override
  String get settingsTelemetry => 'Enviar informes de errores';

  @override
  String get settingsTelemetrySub =>
      'Solo traza de pila y versión del juego. Sin datos personales.';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguagePolish => 'Polski';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsResetGame => 'Reiniciar partida';

  @override
  String get settingsResetGameSub =>
      'Borra el progreso. Se conservarán los ajustes.';

  @override
  String get settingsAbout => 'Sobre el juego';

  @override
  String get settingsResetConfirmTitle => '¿Reiniciar partida?';

  @override
  String get settingsResetConfirmBody =>
      'Esto borrará tu progreso: notas, capítulos, finales. Se conservarán los ajustes (idioma, sonido, vibración).';

  @override
  String get settingsResetConfirmCancel => 'Cancelar';

  @override
  String get settingsResetConfirmConfirm => 'Reiniciar';

  @override
  String aboutVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get aboutPrivacyPolicy => 'Política de privacidad';

  @override
  String get aboutLicenses => 'Licencias de código abierto';

  @override
  String get endingPlayAgain => 'Jugar de nuevo';

  @override
  String get endingShare => 'Compartir resultado';

  @override
  String get endingTimeLabel => 'Tiempo de juego';

  @override
  String get endingTitleLabel => 'Final';

  @override
  String get commonOk => 'Aceptar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonNoSignal => 'Sin señal';

  @override
  String get commonOffline => 'Desconectado';

  @override
  String get iapFullGameUnlock => 'Desbloquear juego completo';

  @override
  String get iapFullGameUnlockSub =>
      'Compra única para desbloquear todos los capítulos y finales.';

  @override
  String get iapRestore => 'Restaurar compras';

  @override
  String get telemetryTitle => 'Telemetría';

  @override
  String get telemetrySub =>
      'Envía informes de errores anónimos para ayudar a mejorar el juego.';

  @override
  String get phoneRecents => 'Recientes';

  @override
  String get phoneKeypad => 'Teclado';

  @override
  String get phoneMissed => 'Perdidas';

  @override
  String get phoneVoicemail => 'BUZÓN DE VOZ';

  @override
  String get phoneNoSignal => 'Error de llamada';

  @override
  String get phoneNoSignalBody =>
      'Sin señal de red. No se puede establecer la conexión.';

  @override
  String get phoneVoicemailTranscript => 'Transcripción:';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get calendarLastWeek => 'Semana pasada';

  @override
  String get calendarNoMoreEvents => 'No hay más entradas.';

  @override
  String get calendarEventDetail => 'Detalles del evento';

  @override
  String get contactsTitle => 'Contactos';

  @override
  String contactsCount(int count) {
    return '$count contactos';
  }

  @override
  String get contactsNoteLabel => 'Nota:';

  @override
  String get browserHistory => 'Historial';

  @override
  String get browserSearchHint => 'Buscar en el historial';

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
      'Las pestañas privadas están encriptadas. Introduce la contraseña que N. usaba para sus sesiones guardadas.';

  @override
  String get browserPrivatePasswordHint => 'Contraseña';

  @override
  String get browserPrivateUnlock => 'Desbloquear';

  @override
  String get browserPrivateWrongPassword => 'Contraseña incorrecta';

  @override
  String get browserPrivateLockedCardTitle =>
      'Las pestañas privadas están encriptadas';

  @override
  String get browserPrivateLockedCardSub =>
      'Toca para introducir la contraseña';

  @override
  String get homeAppLockedFiles => 'Revisa los Mensajes primero';

  @override
  String get homeAppLockedSafari =>
      'Historial vacío – revisa las Fotos primero';

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
