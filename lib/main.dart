import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/boot_screen.dart';
import 'screens/home_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/messages/chat_view.dart';
import 'services/audio_service.dart';
import 'services/location_service.dart';
import 'services/persistence_service.dart';
import 'state/browser_state.dart';
import 'state/chapter_state.dart';
import 'state/ending_state.dart';
import 'state/files_state.dart';
import 'state/messages_state.dart';
import 'state/notes_state.dart';
import 'state/notifications_state.dart';
import 'state/phone_state.dart';
import 'state/photos_state.dart';
import 'theme/app_theme.dart';
import 'widgets/chapter_transition_overlay.dart';
import 'widgets/ending_overlay.dart';
import 'widgets/glitch_overlay.dart';
import 'widgets/notification_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PersistenceService.init();
  // Delay location fetch — don't interrupt boot with permission dialog.
  Future.delayed(const Duration(seconds: 30), () {
    LocationService.instance.tryGetLocation();
  });

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Edge-to-edge mode — hides navigation bar but allows swipe gestures.
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersive,
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const ZaginionaApp());
}

class ZaginionaApp extends StatelessWidget {
  const ZaginionaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final p = PersistenceService.instance;

    // Provider tree:
    // - All independent notifiers receive the persistence service.
    // - MessagesState depends on NotificationsState (banner pushes).
    // - NotesState depends on MessagesState (Sheriff hook on first unlock).
    // - EndingState is independent; the Sheriff hook reaches into it via a
    //   callback installed by the phone shell.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PhoneState(persistence: p)),
        ChangeNotifierProvider(create: (_) => PhotosState(persistence: p)),
        ChangeNotifierProvider(create: (_) => NotificationsState()),
        ChangeNotifierProvider(create: (_) => EndingState(persistence: p)),
        ChangeNotifierProvider(create: (_) => AudioService.instance),
        ChangeNotifierProvider(create: (_) => FilesState(persistence: p)),
        ChangeNotifierProvider(create: (_) => BrowserState(persistence: p)),
        ChangeNotifierProvider(create: (_) => ChapterState(persistence: p)),

        ChangeNotifierProxyProvider<NotificationsState, MessagesState>(
          create: (_) => MessagesState(persistence: p),
          update: (_, notifications, messages) {
            messages!.attachNotifications(notifications);
            return messages;
          },
        ),

        ChangeNotifierProxyProvider<MessagesState, NotesState>(
          create: (_) => NotesState(persistence: p),
          update: (_, messages, notes) {
            notes!.onLockedNoteUnlocked = (unlockedId, {fromColdLoad = false}) {
              if (unlockedId == 'secret') {
                _triggerSheriffHook(messages, fromColdLoad: fromColdLoad);
              }
              if (unlockedId == 'plan_b' && !fromColdLoad) {
                // Plan B unlocked — activate the witness thread (Tomasz).
                messages.triggerWitnessDialog();
              }
            };
            return notes;
          },
        ),
      ],
      child: MaterialApp(
        title: 'OFFLINE',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _PhoneShell(),
      ),
    );
  }
}

/// Adds the Sheriff thread (idempotent), schedules the threat message,
/// then chains a panic message from Mama 1 second after the Sheriff's
/// banner lands - creating a double-threat moment.
///
/// Also starts a 5-minute countdown — if the player doesn't respond
/// to the Sheriff in time, auto-triggers the CAUGHT ending.
Timer? _sheriffCountdown;

Future<void> _triggerSheriffHook(MessagesState messages,
    {required bool fromColdLoad}) async {
  final sheriffGraph = <String, DialogueNode>{
    'opener': const DialogueNode(
      id: 'opener',
      // No npc lines on this node; the threat line is delivered separately
      // (either now via deliverNpcMessage or already in the transcript).
      choices: [
        DialogueChoice(
          text:
              'Nie wiem o czym mówisz, znalazłem ten telefon w parku.',
          nextNodeId: 'choice_dumb',
        ),
        DialogueChoice(
          text:
              'Wiem wszystko o Helion-Budzie. Zdjęcia i notatki są już zabezpieczone.',
          nextNodeId: 'choice_defy',
        ),
        DialogueChoice(
          text:
              'Już za późno. Wszystko jest w drodze do redakcji.',
          nextNodeId: 'choice_truth',
        ),
      ],
    ),
    'choice_dumb': const DialogueNode(
      id: 'choice_dumb',
      npcMessages: [
        'Dobry żart. Mój człowiek już po ciebie jedzie. Nie ruszaj się.',
      ],
      triggersEndingId: 'caught',
    ),
    'choice_defy': const DialogueNode(
      id: 'choice_defy',
      npcMessages: [
        'Myślisz, że jesteś sprytny? Rozejrzyj się za siebie.',
      ],
      triggersEndingId: 'escape',
    ),
    'choice_truth': const DialogueNode(
      id: 'choice_truth',
      npcMessages: [
        'Blefujesz. Nie zdążyłeś.',
      ],
      // No ending here — the player must now actually deliver the
      // evidence to the journalist via her thread.
      triggersJournalistHook: true,
    ),
  };

  final sheriffThread = ChatThread(
    id: 'szeryf',
    contactName: 'Szeryf',
    avatarColor: 0xFF6E0F0F,
    messages: const [],
    dialogueGraph: sheriffGraph,
    currentNodeId: 'opener',
    isInteractive: true,
  );

  messages.ensureThread(sheriffThread);

  if (fromColdLoad) {
    // Thread + transcript already exist in storage; nothing else to do.
    return;
  }

  // 1) Sheriff's threat lands after a dramatic pause (20s) — gives
  // the player time to read the secret note before the confrontation.
  await messages.deliverNpcMessage(
    'szeryf',
    'Wiem, że grzebiesz w tym telefonie. Odłóż go, zanim sam po niego przyjadę.',
    delay: const Duration(seconds: 20),
  );

  // Start countdown — 8 minutes to respond or auto-CAUGHT ending.
  _sheriffCountdown = Timer(const Duration(minutes: 8), () {
    if (_sheriffCountdown == null) return;
    messages.onEndingTriggered?.call('caught');
  });

  // Warning at 7 minutes (1 min before deadline).
  Future.delayed(const Duration(minutes: 7), () {
    if (_sheriffCountdown == null) return;
    messages.deliverNpcMessage(
      'szeryf',
      'Minuta. Albo odpowiadasz, albo jadę.',
      delay: const Duration(seconds: 1),
    );
  });

  // 2) 1s after the Sheriff banner slides down, Mama panics.
  // Reuses the same delivery path: appends to her (non-interactive)
  // thread, raises a banner, and the existing banner-tap handler deep
  // links into her chat. Her unread badge bumps independently of
  // Sheriff's so the player sees both threats waiting in the inbox.
  await messages.deliverNpcMessage(
    'mama',
    'Kochanie, przed domem stoi jakiś dziwny samochód. Ktoś kręci się '
        'przy oknach. Gdzie jesteś?! Odpowiedz mi!',
    delay: const Duration(seconds: 1),
  );

  // 3) Nieznany warns the player — don't rush the Sheriff response.
  await messages.deliverNpcMessage(
    'nieznany',
    'Szeryf się odezwał. Masz kilka minut zanim przyjedzie. '
        'NIE odpowiadaj mu od razu — najpierw przeczytaj Pliki i '
        'Pocztę. Im więcej wiesz, tym lepszą odpowiedź wybierzesz.',
    delay: const Duration(seconds: 4),
  );

  // 4) Hint about the second locked note.
  await messages.deliverNpcMessage(
    'nieznany',
    'Jeszcze jedno — jest druga zamknięta notatka, "Plan B". '
        'Kod do niej znajdziesz w transkrypcji nagrania w Plikach. '
        'Szukaj godziny. To ważne.',
    delay: const Duration(seconds: 6),
  );
}

/// Top-level swap between lock and home + the global notification banner +
/// the ending overlay.
class _PhoneShell extends StatefulWidget {
  const _PhoneShell();

  @override
  State<_PhoneShell> createState() => _PhoneShellState();
}

class _PhoneShellState extends State<_PhoneShell> with WidgetsBindingObserver {
  final _navKey = GlobalKey<NavigatorState>();
  bool _wasUnlocked = false;
  bool _tensionActive = false;
  bool _introComplete = false;
  bool _bootComplete = false;
  Timer? _ringerTimer;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ringerTimer?.cancel();
    _sheriffCountdown?.cancel();
    super.dispose();
  }

  /// Re-apply fullscreen when app resumes (Android resets UI mode).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
  }

  /// Cyclic "phone is ringing" vibration while the Sheriff has unread
  /// messages and the player is not currently inside his chat. Mimics
  /// the feeling of a phone buzzing on the table.
  void _updateRinger(bool active) {
    if (active && _ringerTimer == null) {
      _ringerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 200), () {
          HapticFeedback.heavyImpact();
        });
      });
    } else if (!active && _ringerTimer != null) {
      _ringerTimer?.cancel();
      _ringerTimer = null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Banner taps -> open the chat.
      context.read<MessagesState>().setBannerTapHandler((threadId) {
        final nav = _navKey.currentState;
        if (nav == null) return;
        context.read<MessagesState>().openThread(threadId);
        nav.push(MaterialPageRoute(
          builder: (_) => ChatView(threadId: threadId),
        )).then((_) {
          if (!mounted) return;
          context.read<MessagesState>().closeThread();
        });
      });

      // Dialogue node ending triggers -> EndingState.
      context.read<MessagesState>().onEndingTriggered = (endingId) {
        if (!mounted) return;
        // Cancel sheriff countdown — player responded in time.
        _sheriffCountdown?.cancel();
        _sheriffCountdown = null;
        AudioService.instance.playSfx(GameSfx.endingReveal);
        AudioService.instance.stopTension();
        context.read<EndingState>().trigger(endingId);
      };

      // Journalist hook — opens the TRUTH path.
      context.read<MessagesState>().onJournalistHookTriggered = () {
        if (!mounted) return;
        _sheriffCountdown?.cancel();
        _sheriffCountdown = null;
        context.read<MessagesState>().triggerJournalistDialog();
        // Nieznany confirms the player made the right choice.
        Future.delayed(const Duration(seconds: 5), () {
          if (!mounted) return;
          context.read<MessagesState>().deliverNpcMessage(
            'nieznany',
            'Dobry wybór. Anita się odezwie — odpowiedz jej. '
                'Wyślij wszystko co masz. To jedyna szansa.',
            delay: const Duration(seconds: 2),
          );
        });
      };

      // Cold-load: if the secret note was already unlocked in a previous
      // session, replay the hook (idempotent) so the Sheriff thread exists.
      final notes = context.read<NotesState>();
      if (notes.hasUnlockedSecret) {
        notes.replayHookForColdLoad();
      }

      // Cold-load: if Plan B was already unlocked, ensure Tomasz thread exists.
      final planB = notes.noteById('plan_b');
      if (planB != null && !planB.isLocked) {
        context.read<MessagesState>().triggerWitnessDialog(fromColdLoad: true);
      }

      // Reactive: Nieznany reacts when player inspects the clue photo.
      context.read<PhotosState>().onClueInspected = (photoId) {
        if (!mounted) return;
        if (photoId == 'forest_night') {
          context.read<MessagesState>().deliverNpcMessage(
            'nieznany',
            'Dobra robota. Widzisz ten kod w komentarzu? 7309. '
                'Wejdź w Notatki — jest tam zablokowana notatka. '
                'Wpisz ten kod. Przeczytaj co N. zostawiła.',
            delay: const Duration(seconds: 3),
          );
        }
      };

      // Reminder: if player hasn't opened photos after 60s, nudge them.
      Future.delayed(const Duration(seconds: 60), () {
        if (!mounted) return;
        if (!context.read<PhoneState>().isUnlocked) return;
        final photos = context.read<PhotosState>();
        if (!photos.hasInspected('forest_night')) {
          final msgs = context.read<MessagesState>();
          if (msgs.hasCompletedIntro) {
            msgs.deliverNpcMessage(
              'nieznany',
              'Pospiesz się. Wejdź w Zdjęcia — szukaj ciemnego zdjęcia '
                  'z lasu. Kliknij na nie, potem przycisk Info (ⓘ) na dole.',
              delay: const Duration(seconds: 2),
            );
          }
        }
      });

      // Reactive: Nieznany reacts when player opens first file.
      context.read<FilesState>().onFirstFileOpened = () {
        if (!mounted) return;
        context.read<MessagesState>().deliverNpcMessage(
          'nieznany',
          'Widzisz te faktury? 14 tysięcy co miesiąc. "Konsulting". '
              'Teraz rozumiesz dlaczego policja nie szuka N.',
          delay: const Duration(seconds: 6),
        );
      };
    });
  }

  /// Ghost notification — a brief flash of a banner that disappears
  /// before the player can read it. Creates paranoia.
  void _scheduleGhostNotification() {
    Future.delayed(const Duration(minutes: 2), () {
      if (!mounted) return;
      // Don't fire if game was reset (phone locked again).
      if (!context.read<PhoneState>().isUnlocked) return;
      final n = context.read<NotificationsState>();
      n.push(AppNotification(
        id: 'ghost_${DateTime.now().microsecondsSinceEpoch}',
        appName: 'System',
        title: 'Lokalizacja',
        body: 'Ktoś sprawdził Twoją lokalizację',
        icon: Icons.location_on,
        iconBg: const Color(0xFFFF453A),
      ));
      // Dismiss after just 1.5s — too fast to fully read.
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        n.dismiss();
      });
    });
  }

  /// Low battery warning after 3 minutes of gameplay.
  void _scheduleLowBatteryAlert() {
    Future.delayed(const Duration(minutes: 3), () {
      if (!mounted) return;
      if (!context.read<PhoneState>().isUnlocked) return;
      final n = context.read<NotificationsState>();
      n.push(AppNotification(
        id: 'battery_low',
        appName: 'System',
        title: 'Bateria',
        body: 'Pozostało 15% baterii. Włącz tryb oszczędzania energii.',
        icon: Icons.battery_alert,
        iconBg: const Color(0xFFFF9500),
      ));
    });
  }

  /// Wi-Fi auto-connect notification — explains how Sheriff can message
  /// despite no cellular. Fires 10s after unlock.
  void _scheduleWifiConnect() {
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      if (!context.read<PhoneState>().isUnlocked) return;
      final n = context.read<NotificationsState>();
      n.push(AppNotification(
        id: 'wifi_connect',
        appName: 'Wi-Fi',
        title: 'Połączono z siecią',
        body: 'HB_Guest_5G — połączenie nieszyfrowane',
        icon: Icons.wifi,
        iconBg: const Color(0xFF0A84FF),
      ));
    });
  }

  /// Creepy moments — unsettling system notifications at intervals.
  void _scheduleCreepyMoments() {
    // 1:30 — camera access
    Future.delayed(const Duration(seconds: 90), () {
      if (!mounted || !context.read<PhoneState>().isUnlocked) return;
      context.read<NotificationsState>().push(AppNotification(
        id: 'creepy_camera',
        appName: 'System',
        title: 'Aparat',
        body: 'Aplikacja "Nieznana" uzyskała dostęp do aparatu',
        icon: Icons.camera_alt,
        iconBg: const Color(0xFFFF453A),
      ));
    });

    // 4:00 — microphone
    Future.delayed(const Duration(minutes: 4), () {
      if (!mounted || !context.read<PhoneState>().isUnlocked) return;
      context.read<NotificationsState>().push(AppNotification(
        id: 'creepy_mic',
        appName: 'Prywatność',
        title: 'Mikrofon aktywny',
        body: 'Mikrofon jest używany w tle',
        icon: Icons.mic,
        iconBg: const Color(0xFFFF9500),
      ));
    });

    // 5:30 — someone tried to unlock
    Future.delayed(const Duration(minutes: 5, seconds: 30), () {
      if (!mounted || !context.read<PhoneState>().isUnlocked) return;
      context.read<NotificationsState>().push(AppNotification(
        id: 'creepy_unlock',
        appName: 'Bezpieczeństwo',
        title: 'Próba logowania',
        body: 'Nieudana próba zdalnego odblokowania urządzenia',
        icon: Icons.security,
        iconBg: const Color(0xFFFF453A),
      ));
      // Trigger a glitch burst for extra scare.
      AudioService.instance.playSfx(GameSfx.glitchBurst);
    });

    // Stalker messages — anonymous threatening texts at intervals.
    _scheduleStalkerMessages();
  }

  /// Anonymous stalker sends creepy messages at timed intervals.
  /// Uses real location and time of day for maximum horror.
  void _scheduleStalkerMessages() {
    final msgs = context.read<MessagesState>();
    final loc = LocationService.instance;
    final hour = DateTime.now().hour;
    final timeComment = hour >= 22 || hour < 6
        ? 'Ciemno u ciebie, prawda?'
        : hour >= 18
            ? 'Wieczór. Zamknij zasłony.'
            : 'Dzień. Myślisz że jesteś bezpieczny?';

    // 1:00 — first message (generic)
    Future.delayed(const Duration(minutes: 1), () {
      if (!mounted || !context.read<PhoneState>().isUnlocked) return;
      msgs.deliverNpcMessage(
        'stalker',
        'Widzę cię.',
        delay: const Duration(seconds: 1),
      );
    });

    // 2:30 — uses real time
    Future.delayed(const Duration(minutes: 2, seconds: 30), () {
      if (!mounted || !context.read<PhoneState>().isUnlocked) return;
      msgs.deliverNpcMessage(
        'stalker',
        timeComment,
        delay: const Duration(seconds: 1),
      );
    });

    // 4:00 — uses real location
    Future.delayed(const Duration(minutes: 4), () {
      if (!mounted || !context.read<PhoneState>().isUnlocked) return;
      final city = loc.city;
      final district = loc.district;
      final text = loc.hasRealLocation
          ? '$city. $district. Nie ruszaj się.'
          : 'Wiem gdzie jesteś. Nie ruszaj się.';
      msgs.deliverNpcMessage(
        'stalker',
        text,
        delay: const Duration(seconds: 1),
      );
    });

    // 5:30 — escalation
    Future.delayed(const Duration(minutes: 5, seconds: 30), () {
      if (!mounted || !context.read<PhoneState>().isUnlocked) return;
      msgs.deliverNpcMessage(
        'stalker',
        'Nie powinieneś był tego włączać. Ten telefon nie jest twój.',
        delay: const Duration(seconds: 1),
      );
    });

    // 7:00 — final warning with location
    Future.delayed(const Duration(minutes: 7), () {
      if (!mounted || !context.read<PhoneState>().isUnlocked) return;
      final text = loc.hasRealLocation
          ? 'Jadę do ${loc.city}. Odłóż telefon. Ostatnie ostrzeżenie.'
          : 'Jadę po ciebie. Odłóż telefon. Ostatnie ostrzeżenie.';
      msgs.deliverNpcMessage(
        'stalker',
        text,
        delay: const Duration(seconds: 1),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Intro sequence — narrative frame before boot.
    if (!_introComplete) {
      return IntroScreen(
        onComplete: () => setState(() => _introComplete = true),
      );
    }

    // Boot sequence — show once on app start.
    if (!_bootComplete) {
      return BootScreen(
        onComplete: () => setState(() => _bootComplete = true),
      );
    }

    final unlocked = context.select<PhoneState, bool>((s) => s.isUnlocked);
    final hasEnding =
        context.select<EndingState, bool>((s) => s.activeEnding != null);

    // Glitch activates when the Sheriff thread exists and has unread
    // messages or the NPC is typing in it — creates digital unease.
    final sheriffUnread = context.select<MessagesState, int>(
        (s) => s.threadById('szeryf')?.unreadCount ?? 0);
    final isNpcTyping =
        context.select<MessagesState, bool>((s) => s.isNpcTyping);
    final glitchActive = unlocked &&
        !hasEnding &&
        (sheriffUnread > 0 || isNpcTyping);

    // Detect game reset — phone locked again after being unlocked.
    if (!unlocked && _wasUnlocked) {
      _wasUnlocked = false;
      _tensionActive = false;
      _ringerTimer?.cancel();
      _ringerTimer = null;
      _sheriffCountdown?.cancel();
      _sheriffCountdown = null;
    }

    // Audio: start ambient on first unlock.
    if (unlocked && !_wasUnlocked) {
      _wasUnlocked = true;
      AudioService.instance.startAmbient();
      // Start immersive timers only after first unlock.
      _scheduleWifiConnect();
      _scheduleGhostNotification();
      _scheduleLowBatteryAlert();
      _scheduleCreepyMoments();

      // Immediate nudge — Nieznany's unread message raises a banner
      // so the player knows to check Messages first.
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        final msgs = context.read<MessagesState>();
        final nieznany = msgs.threadById('nieznany');
        if (nieznany != null && nieznany.unreadCount > 0) {
          context.read<NotificationsState>().push(AppNotification(
            id: 'nudge_nieznany',
            appName: 'Wiadomości',
            title: 'Nieznany',
            body: nieznany.lastMessage?.text ?? '',
            icon: Icons.chat_bubble,
            iconBg: const Color(0xFF34C759),
            onTap: () {
              // Navigate to chat if banner is tapped.
              final nav = _navKey.currentState;
              if (nav == null) return;
              msgs.openThread('nieznany');
              nav.push(MaterialPageRoute(
                builder: (_) => ChatView(threadId: 'nieznany'),
              )).then((_) {
                if (!mounted) return;
                msgs.closeThread();
              });
            },
          ));
        }
      });
    }

    // Audio: tension track when Sheriff is active.
    if (glitchActive && !_tensionActive) {
      _tensionActive = true;
      AudioService.instance.startTension();
    } else if (!glitchActive && _tensionActive) {
      _tensionActive = false;
      AudioService.instance.stopTension();
    }

    // Cyclic vibration while Sheriff is "ringing" — only when the
    // player isn't actively in his chat.
    final activeThread =
        context.select<MessagesState, String?>((s) => s.activeThread?.id);
    final shouldRing = sheriffUnread > 0 && activeThread != 'szeryf' && !hasEnding;
    _updateRinger(shouldRing);

    // Audio: stop everything on ending.
    if (hasEnding) {
      AudioService.instance.stopAmbient();
      _updateRinger(false);
    }

    return Stack(
      children: [
        // Main content — lock/home switch.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: unlocked
              ? KeyedSubtree(
                  key: const ValueKey('home'),
                  child: Navigator(
                    key: _navKey,
                    onGenerateRoute: (_) => MaterialPageRoute(
                      builder: (_) => const HomeScreen(),
                    ),
                  ),
                )
              : const LockScreen(key: ValueKey('lock')),
        ),
        if (unlocked && !hasEnding)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NotificationBannerHost(),
          ),
        if (unlocked && !hasEnding)
          Positioned.fill(child: GlitchOverlay(active: glitchActive)),
        if (hasEnding) const Positioned.fill(child: EndingOverlay()),

        // Chapter 2 transition overlay — appears once when crossing
        // the file-threshold trigger.
        if (context.select<ChapterState, bool>(
            (s) => s.shouldAnimateTransition))
          Positioned.fill(
            child: ChapterTransitionOverlay(
              onComplete: () {
                context.read<ChapterState>().clearTransitionFlag();
              },
            ),
          ),
      ],
    );
  }
}
