import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/messages/chat_view.dart';
import 'services/persistence_service.dart';
import 'state/ending_state.dart';
import 'state/messages_state.dart';
import 'state/notes_state.dart';
import 'state/notifications_state.dart';
import 'state/phone_state.dart';
import 'state/photos_state.dart';
import 'theme/app_theme.dart';
import 'widgets/ending_overlay.dart';
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
        context.read<EndingState>().trigger(endingId);
      };

      // Cold-load: if the secret note was already unlocked in a previous
      // session, replay the hook (idempotent) so the Sheriff thread exists.
      final notes = context.read<NotesState>();
      if (notes.hasUnlockedSecret) {
        notes.replayHookForColdLoad();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = context.select<PhoneState, bool>((s) => s.isUnlocked);
    final hasEnding =
        context.select<EndingState, bool>((s) => s.activeEnding != null);

    return Stack(
      children: [
        Navigator(
          key: _navKey,
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: unlocked
                  ? const HomeScreen(key: ValueKey('home'))
                  : const LockScreen(key: ValueKey('lock')),
            ),
          ),
        ),
        if (unlocked && !hasEnding)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NotificationBannerHost(),
          ),
        if (hasEnding) const Positioned.fill(child: EndingOverlay()),
      ],
    );
  }
}
