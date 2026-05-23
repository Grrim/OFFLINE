import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/boot_screen.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/messages/chat_view.dart';
import 'services/audio_service.dart';
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

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
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
            };
            return notes;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Zaginiona',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const _PhoneShell(),
      ),
    );
  }
}

/// Adds the Sheriff thread (idempotent), schedules the threat message,
/// then chains a panic message from Mama 1 second after the Sheriff's
/// banner lands - creating a double-threat moment (Sheriff coming for
/// the player, Mama in danger at home).
///
/// On cold-load both messages are already persisted in their transcripts,
/// so we only re-attach the Sheriff dialogue graph and bail out.
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

  // 1) Sheriff's threat lands first (3s typing delay).
  await messages.deliverNpcMessage(
    'szeryf',
    'Wiem, że grzebiesz w tym telefonie. Odłóż go, zanim sam po niego przyjadę.',
    delay: const Duration(seconds: 3),
  );

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
}

/// Top-level swap between lock and home + the global notification banner +
/// the ending overlay.
class _PhoneShell extends StatefulWidget {
  const _PhoneShell();

  @override
  State<_PhoneShell> createState() => _PhoneShellState();
}

class _PhoneShellState extends State<_PhoneShell> {
  final _navKey = GlobalKey<NavigatorState>();
  bool _wasUnlocked = false;
  bool _tensionActive = false;
  bool _bootComplete = false;
  Timer? _ringerTimer;

  @override
  void dispose() {
    _ringerTimer?.cancel();
    super.dispose();
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
        AudioService.instance.playSfx(GameSfx.endingReveal);
        AudioService.instance.stopTension();
        context.read<EndingState>().trigger(endingId);
      };

      // Journalist hook — opens the TRUTH path. Triggered by the
      // Sheriff dialogue's third choice ("Już za późno...").
      context.read<MessagesState>().onJournalistHookTriggered = () {
        if (!mounted) return;
        context.read<MessagesState>().triggerJournalistDialog();
      };

      // Cold-load: if the secret note was already unlocked in a previous
      // session, replay the hook (idempotent) so the Sheriff thread exists.
      final notes = context.read<NotesState>();
      if (notes.hasUnlockedSecret) {
        notes.replayHookForColdLoad();
      }

      // Files threshold → advance to chapter 2.
      // DISABLED: Chapter 2 is locked for now. Uncomment to enable.
      // context.read<FilesState>().onChapter2Threshold = () {
      //   if (!mounted) return;
      //   context.read<ChapterState>().advanceToChapter2();
      //   context.read<MessagesState>().triggerWitnessDialog();
      // };

      // Cold-load: if we're already in chapter 2, re-attach the witness
      // thread so its dialogue graph is restored.
      if (context.read<ChapterState>().isChapter2) {
        context
            .read<MessagesState>()
            .triggerWitnessDialog(fromColdLoad: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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

    // Audio: start ambient on first unlock.
    if (unlocked && !_wasUnlocked) {
      _wasUnlocked = true;
      AudioService.instance.startAmbient();
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
