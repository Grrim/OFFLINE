import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:sentry_flutter/sentry_flutter.dart';

import 'screens/boot_screen.dart';
import 'screens/content_warning_screen.dart';
import 'screens/home_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/messages/chat_view.dart';
import 'screens/new_game_plus_choice_screen.dart';
import 'l10n/gen/app_localizations.dart';
import 'services/audio_service.dart';
import 'services/iap_service.dart';
import 'services/l10n_service.dart';
import 'services/location_service.dart';
import 'services/persistence_service.dart';
import 'state/achievements_state.dart';
import 'state/browser_state.dart';
import 'state/chapter_state.dart';
import 'state/email_state.dart';
import 'state/ending_state.dart';
import 'state/evidence_mapping.dart';
import 'state/evidence_state.dart';
import 'state/files_state.dart';
import 'state/flags_state.dart';
import 'state/maps_state.dart';
import 'state/messages_state.dart';
import 'state/new_game_plus_state.dart';
import 'state/notes_state.dart';
import 'state/notifications_state.dart';
import 'state/phone_state.dart';
import 'state/photos_state.dart';
import 'state/recorder_state.dart';
import 'state/settings_state.dart';
import 'state/signal_puzzle_state.dart';
import 'state/trust_state.dart';
import 'theme/app_theme.dart';
import 'widgets/chapter_transition_overlay.dart';
import 'widgets/ending_overlay.dart';
import 'widgets/incoming_call_overlay.dart';
import 'widgets/notification_banner.dart';
import 'widgets/pause_overlay.dart';
import 'widgets/phone_shell_events.dart';
import 'widgets/welcome_back_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Essential: Load persistence so we know the settings (telemetry, locale).
  await PersistenceService.init();

  // 2. Essential: Initialize services.
  // We await L10n and IAP to ensure the game state and UI labels are ready.
  await L10nService.instance.init(
    platformLocale: WidgetsBinding.instance.platformDispatcher.locale,
  );
  await IapService.instance.init();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarContrastEnforced: false,
  ));

  // 3. Sentry Init (Opt-in).
  final bool telemetryEnabled =
      PersistenceService.instance.getBool('settings.telemetryOptIn');
  
  const String sentryDsn = 'https://e130f142512f5a60a7d9b9366601240c@o4507119131656192.ingest.de.sentry.io/4511481297764432';
  
  if (telemetryEnabled && sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 1.0;
        options.beforeSend = (event, hint) {
          // Privacy: Strip potential PII if needed
          return event;
        };
      },
      appRunner: () => runApp(const ZaginionaApp()),
    );
  } else {
    runApp(const ZaginionaApp());
  }
}


class ZaginionaApp extends StatelessWidget {
  const ZaginionaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final p = PersistenceService.instance;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsState(persistence: p)),
        ChangeNotifierProvider(create: (_) => PhoneState(persistence: p)),
        ChangeNotifierProvider(create: (_) => PhotosState(persistence: p)),
        ChangeNotifierProvider(create: (_) => NotificationsState()),
        ChangeNotifierProvider(create: (_) => EndingState(persistence: p)),
        ChangeNotifierProvider.value(value: AudioService.instance),
        ChangeNotifierProvider.value(value: IapService.instance),
        ChangeNotifierProvider(create: (_) => FilesState(persistence: p)),
        ChangeNotifierProvider(create: (_) => BrowserState(persistence: p)),
        ChangeNotifierProvider(create: (_) => ChapterState(persistence: p)),
        ChangeNotifierProvider(create: (_) => TrustState(persistence: p)),
        ChangeNotifierProvider(create: (_) => EvidenceState(persistence: p)),
        ChangeNotifierProvider(create: (_) => FlagsState(persistence: p)),
        ChangeNotifierProvider(create: (_) => EmailState(persistence: p)),
        ChangeNotifierProvider(create: (_) => RecorderState(persistence: p)),
        ChangeNotifierProvider(create: (_) => MapsState(persistence: p)),
        ChangeNotifierProvider(
            create: (_) => AchievementsState(persistence: p)),
        ChangeNotifierProvider(
            create: (_) => NewGamePlusState(persistence: p)),
        ChangeNotifierProvider(
            create: (_) => SignalPuzzleState(persistence: p)),

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
                messages.triggerWitnessDialog();
              }
            };
            return notes;
          },
        ),
      ],
      child: ListenableBuilder(
        listenable: L10nService.instance,
        builder: (context, _) {
          return MaterialApp(
            title: 'N. Is Offline',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            locale: L10nService.instance.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const _PhoneShell(),
          );
        },
      ),
    );
  }
}


Timer? _sheriffCountdown;
DateTime? _sheriffTargetTime;

Future<void> _triggerSheriffHook(MessagesState messages,
    {required bool fromColdLoad}) async {
  final l10n = L10nService.instance.dialogues;
  final sheriffData = l10n['threads']?['szeryf'] ?? {};
  final sheriffNodes = sheriffData['nodes'] as Map<String, dynamic>? ?? {};

  final sheriffGraph = <String, DialogueNode>{};
  sheriffNodes.forEach((id, nodeData) {
    final npcMsgs = (nodeData['npcMessages'] as List? ?? []).cast<String>();
    final choicesData = (nodeData['choices'] as List? ?? []);
    final choices = choicesData.map((c) {
      return DialogueChoice(
        text: c['text'] as String,
        nextNodeId: c['nextNodeId'] as String,
        trustDeltas: (c['trustDeltas'] as Map? ?? {}).cast<String, int>(),
        requiresMinTrust:
            (c['requiresMinTrust'] as Map? ?? {}).cast<String, int>(),
        requiresMinEvidence: c['requiresMinEvidence'] as int?,
        requiresFlag: c['requiresFlag'] as String?,
        hidden: c['hidden'] as bool? ?? false,
        lockedReasonKey: c['lockedReasonKey'] as String?,
      );
    }).toList();

    sheriffGraph[id] = DialogueNode(
      id: id,
      npcMessages: npcMsgs,
      choices: choices,
      triggersEndingId: nodeData['triggersEndingId'] as String?,
      triggersJournalistHook:
          nodeData['triggersJournalistHook'] as bool? ?? false,
    );
  });

  final sheriffThread = ChatThread(
    id: 'szeryf',
    contactName: sheriffData['contactName'] ?? 'Sheriff',
    avatarColor: 0xFF6E0F0F,
    messages: [],
    dialogueGraph: sheriffGraph,
    currentNodeId: 'opener',
    isInteractive: true,
  );

  if (fromColdLoad) {
    messages.ensureThread(sheriffThread);
    return;
  }

  final sessionId = messages.gameSessionId;
  messages.ensureThread(ChatThread(
    id: 'szeryf',
    contactName: sheriffData['contactName'] ?? 'Sheriff',
    avatarColor: 0xFF6E0F0F,
    messages: [],
    isInteractive: false,
  ));

  await messages.deliverNpcMessage(
    'szeryf',
    sheriffData['systemMessages']?['initial_warning'] ?? '...',
    delay: const Duration(seconds: 20),
  );

  if (messages.gameSessionId != sessionId) return;

  messages.ensureThread(sheriffThread);

  _sheriffCountdown?.cancel();
  _sheriffTargetTime = DateTime.now().add(const Duration(minutes: 8));

  _sheriffCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
    final target = _sheriffTargetTime;
    if (target == null) {
      timer.cancel();
      return;
    }
    if (DateTime.now().isAfter(target)) {
      timer.cancel();
      _sheriffCountdown = null;
      _sheriffTargetTime = null;
      messages.onEndingTriggered?.call('caught');
    }
  });

  messages.wait(const Duration(minutes: 7), sessionId: sessionId).then((_) {
    if (_sheriffCountdown == null) return;
    if (messages.gameSessionId != sessionId) return;
    messages.deliverNpcMessage(
      'szeryf',
      sheriffData['systemMessages']?['final_warning'] ?? '...',
      delay: const Duration(seconds: 1),
    );
  });

  await messages.deliverNpcMessage(
    'mama',
    l10n['threads']?['mama']?['systemMessages']?['stranger_danger'] ?? '...',
    delay: const Duration(seconds: 5),
  );

  await messages.deliverNpcMessage(
    'nieznany',
    l10n['threads']?['nieznany']?['systemMessages']?['sheriff_nudge'] ?? '...',
    delay: const Duration(seconds: 12),
  );

  await messages.deliverNpcMessage(
    'nieznany',
    l10n['threads']?['nieznany']?['systemMessages']?['plan_b_nudge'] ?? '...',
    delay: const Duration(seconds: 25),
  );
}

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
  bool _isPaused = false;
  bool _showWelcomeBack = false;
  bool _ngpChoiceMade = false;
  bool _incomingCall = false;
  String? _callerName;
  Timer? _hintTimer;
  DateTime? _lastInteractionAt;
  Timer? _ringerTimer;
  Timer? _solitudeWatchdog;
  DateTime? _unlockedAt;
  Duration _activeSessionDuration = Duration.zero;
  DateTime? _lastResumeAt;

  // For sheriff countdown pause handling
  Duration? _sheriffTimeRemaining;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ringerTimer?.cancel();
    _solitudeWatchdog?.cancel();
    _sheriffCountdown?.cancel();
    _hintTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  void _updateRinger(bool active) {
    if (active && _ringerTimer == null) {
      _ringerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted) return;
        if (!context.read<SettingsState>().haptics) return;
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!mounted) return;
          if (!context.read<SettingsState>().haptics) return;
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

      final settings = context.read<SettingsState>();
      AudioService.instance.setMuted(settings.audioMuted);
      settings.addListener(() {
        AudioService.instance.setMuted(settings.audioMuted);
      });

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

      context.read<MessagesState>().attachGateEvaluator((choice) {
        final trust = context.read<TrustState>();
        final evidence = context.read<EvidenceState>();
        final flags = context.read<FlagsState>();
        final ngp = context.read<NewGamePlusState>();
        for (final entry in choice.requiresMinTrust.entries) {
          if (trust.get(entry.key) < entry.value) return false;
        }
        if (choice.requiresMinEvidence != null &&
            evidence.score < choice.requiresMinEvidence!) {
          return false;
        }
        final flag = choice.requiresFlag;
        if (flag != null) {
          if (flag == 'meta.cycle_available') {
            if (!ngp.cycleAvailable) return false;
          } else if (!flags.isSet(flag)) {
            return false;
          }
        }
        return true;
      });

      context.read<MessagesState>().attachTrustSink((deltas) {
        if (!mounted) return;
        context.read<TrustState>().apply(deltas);
      });

      context.read<MessagesState>().onEndingTriggered = (endingId) {
        if (!mounted) return;
        _sheriffCountdown?.cancel();
        _sheriffCountdown = null;
        _solitudeWatchdog?.cancel();
        _solitudeWatchdog = null;
        context.read<NotificationsState>().dismiss();

        final ngp = context.read<NewGamePlusState>();
        final chapter = context.read<ChapterState>();
        final flags = context.read<FlagsState>();
        final unlocksChapter3 = (endingId == 'truth' || endingId == 'dawn') &&
            ngp.isPlusActive &&
            chapter.current == Chapter.two &&
            !flags.isSet('chapter.three_seen');
        if (unlocksChapter3) {
          flags.set('chapter.three_seen');
          chapter.advanceToChapter3();
          AudioService.instance.playSfx(GameSfx.unlockSuccess);
          _scheduleProsecutorOpening(endingId);
          return;
        }
        AudioService.instance.playSfx(GameSfx.endingReveal);
        AudioService.instance.stopTension();
        context.read<EndingState>().trigger(endingId);
        context.read<SettingsState>().setHasCompletedOnce(true);
        context.read<NewGamePlusState>().recordEnding(endingId);
        _evaluateEndingAchievements(endingId);
        if (endingId == 'cycle') {
          context.read<AchievementsState>().unlock('cycle');
        }
      };

      context.read<MessagesState>().onJournalistHookTriggered = () {
        if (!mounted) return;
        final currentSettings = context.read<SettingsState>();
        final sessionStart = currentSettings.currentRunStartedAt;
        _sheriffCountdown?.cancel();
        _sheriffCountdown = null;
        context.read<MessagesState>().triggerJournalistDialog();
        
        _delay(const Duration(seconds: 5), () {
          if (!mounted) return;
          if (context.read<SettingsState>().currentRunStartedAt != sessionStart)
            return;
          final l10n = L10nService.instance.dialogues['threads']?['nieznany']
                  ?['systemMessages'] ??
              {};
          context.read<MessagesState>().deliverNpcMessage(
                'nieznany',
                l10n['journalist_nudge'] ??
                    'Dobry wybór. Anita się odezwie — odpowiedz jej. Wyślij wszystko co masz. To jedyna szansa.',
                delay: const Duration(seconds: 2),
              );
        });
      };

      final notes = context.read<NotesState>();
      if (notes.hasUnlockedSecret) {
        notes.replayHookForColdLoad();
      }

      final planB = notes.noteById('plan_b');
      if (planB != null && !planB.isLocked) {
        context.read<MessagesState>().triggerWitnessDialog(fromColdLoad: true);
      }

      context.read<PhotosState>().onClueInspected = (photoId) {
        if (!mounted) return;
        final evidenceId = EvidenceMapping.photoToEvidence[photoId];
        if (evidenceId != null) {
          context.read<EvidenceState>().collect(evidenceId);
        }
        if (photoId == 'forest_night') {
          final msgs = context.read<MessagesState>();
          if (msgs.hasCompletedIntro) {
            final l10n = L10nService.instance.dialogues['threads']?['nieznany']
                    ?['systemMessages'] ??
                {};
            msgs.deliverNpcMessage(
              'nieznany',
              l10n['clue_nudge'] ??
                  'Dobra robota. Widzisz ten kod w komentarzu? 7309. Wejdź w Notatki — jest tam zablokowana notatka. Wpisz ten kod. Przeczytaj co N. zostawiła.',
              delay: const Duration(seconds: 3),
            );
          }
        }
      };

      context.read<FilesState>().onFirstFileOpened = () {
        if (!mounted) return;
        final msgs = context.read<MessagesState>();
        if (msgs.hasCompletedIntro) {
          final l10n = L10nService.instance.dialogues['threads']?['nieznany']
                  ?['systemMessages'] ??
              {};
          msgs.deliverNpcMessage(
            'nieznany',
            l10n['files_nudge'] ??
                'Widzisz te faktury? 14 tysięcy co miesiąc. "Konsulting". Teraz rozumiesz dlaczego policja nie szuka N.',
            delay: const Duration(seconds: 6),
          );
        }
      };

      context.read<FilesState>().onFileOpened = (fileId) {
        if (!mounted) return;
        final evidenceId = EvidenceMapping.fileToEvidence[fileId];
        if (evidenceId != null) {
          context.read<EvidenceState>().collect(evidenceId);
        }
      };

      context.read<FilesState>().onChapter2Threshold = () {
        if (!mounted) return;
        context.read<ChapterState>().advanceToChapter2();
      };

      context.read<BrowserState>().onEntryVisited = (entryId) {
        if (!mounted) return;
        final evidenceId = EvidenceMapping.browserToEvidence[entryId];
        if (evidenceId != null) {
          context.read<EvidenceState>().collect(evidenceId);
        }
      };

      context.read<BrowserState>().onPrivateUnlocked = () {
        if (!mounted) return;
        context.read<FlagsState>().set('puzzle.private_unlocked');
        AudioService.instance.playSfx(GameSfx.unlockSuccess);
        final msgs = context.read<MessagesState>();
        if (msgs.hasCompletedIntro) {
          final l10n = L10nService.instance.dialogues['threads']?['nieznany']
                  ?['systemMessages'] ??
              {};
          msgs.deliverNpcMessage(
            'nieznany',
            l10n['browser_nudge'] ??
                'Tak. To było jej tajne archiwum. Skrytka, prokurator, forum o stalkingu — to wszystko jej research. Zapisz sobie te adresy. Mogą się przydać.',
            delay: const Duration(seconds: 4),
          );
        }
      };

      context.read<RecorderState>().onVoicePuzzleSolved = () {
        if (!mounted) return;
        context.read<FlagsState>().set('puzzle.voices_matched');
        context.read<EvidenceState>().collect('voices_matched');
        AudioService.instance.playSfx(GameSfx.unlockSuccess);
        final msgs = context.read<MessagesState>();
        if (msgs.hasCompletedIntro) {
          final l10n = L10nService.instance.dialogues['threads']?['nieznany']
                  ?['systemMessages'] ??
              {};
          msgs.deliverNpcMessage(
            'nieznany',
            l10n['recorder_nudge'] ??
                'Genialne. Tak — to byli oni: Anita w pierwszym, Komendant K. w drugim, Tomasz B. (wspólnik HB) w trzecim. Teraz Anita ma już własną twarz na taśmie. To jest złoto.',
            delay: const Duration(seconds: 4),
          );
        }
      };

      context.read<RecorderState>().onFirstListened = (recId) {
        if (!mounted) return;
        final evidenceId = EvidenceMapping.recordingToEvidence[recId];
        if (evidenceId != null) {
          context.read<EvidenceState>().collect(evidenceId);
        }
      };

      context.read<MapsState>().onPuzzleSolved = () {
        if (!mounted) return;
        context.read<FlagsState>().set('puzzle.route_reconstructed');
        context.read<EvidenceState>().collect('route_reconstructed');
        AudioService.instance.playSfx(GameSfx.unlockSuccess);
        final msgs = context.read<MessagesState>();
        if (msgs.hasCompletedIntro) {
          final l10n = L10nService.instance.dialogues['threads']?['nieznany']
                  ?['systemMessages'] ??
              {};
          msgs.deliverNpcMessage(
            'nieznany',
            l10n['maps_nudge'] ??
                'Mam jej trasę. Dom → biuro → kawiarnia z Anitą o 14 → parking o 21 → Las Kabacki C-2 o 23:45. Dokładnie tam, gdzie kopali. Ona nie zniknęła sama — szła sprawdzać sektor.',
            delay: const Duration(seconds: 4),
          );
        }
      };

      context.read<EmailState>().onFullyRecovered = () {
        if (!mounted) return;
        context.read<FlagsState>().set('puzzle.email_recovered');
        context.read<EvidenceState>().collect('email_recovered');
        AudioService.instance.playSfx(GameSfx.unlockSuccess);
        final msgs = context.read<MessagesState>();
        if (msgs.hasCompletedIntro) {
          final l10n = L10nService.instance.dialogues['threads']?['nieznany']
                  ?['systemMessages'] ??
              {};
          msgs.deliverNpcMessage(
            'nieznany',
            l10n['email_nudge'] ??
                'Złożyłeś jej ostatnią wiadomość. Tej nie zdążyła wysłać do Anity. Wszystko jest tam: spotkanie 14:00, sektor C-2, hasło do Signala. Anita sama tego nie zna — musisz przekazać.',
            delay: const Duration(seconds: 5),
          );
        }
      };

      context.read<SignalPuzzleState>().onDecoded = () {
        if (!mounted) return;
        context.read<FlagsState>().set('puzzle.signal_decoded');
        AudioService.instance.playSfx(GameSfx.unlockSuccess);
        final l10n = L10nService.instance.dialogues['threads']?['prokurator']
                ?['systemMessages'] ??
            {};
        context.read<MessagesState>().deliverNpcMessage(
              'prokurator',
              l10n['decoded'] ??
                  'Mam Pana materiały. Wszystko zaszyfrowane. Wracajmy do rozmowy — czeka na Pana decyzja.',
              delay: const Duration(seconds: 3),
            );
      };

      context.read<AchievementsState>().onAchievementUnlocked = (a) {
        if (!mounted) return;
        AudioService.instance.playSfx(GameSfx.notification);
        final l10n =
            L10nService.instance.dialogues['meta']?['notifications'] ?? {};
        context.read<NotificationsState>().push(AppNotification(
              id: 'ach_${a.id}',
              appName: l10n['achievement_app_name'] ?? 'Osiągnięcie',
              title: a.title,
              body: a.description,
              icon: a.icon,
              iconBg: a.iconColor,
            ));
      };
    });
  }

  void _scheduleGhostNotification(DateTime sessionStart) {
    final phone = context.read<PhoneState>();
    final n = context.read<NotificationsState>();
    final l10n = L10nService.instance.dialogues['meta']?['notifications'] ?? {};

    _delay(const Duration(minutes: 5), () {
      if (!mounted) return;
      if (!phone.isUnlocked) return;
      n.push(AppNotification(
        id: 'ghost_${DateTime.now().microsecondsSinceEpoch}',
        appName: 'System',
        title: l10n['ghost_title'] ?? 'Lokalizacja',
        body: l10n['ghost_body'] ?? 'Ktoś sprawdził Twoją lokalizację',
        icon: Icons.location_on,
        iconBg: const Color(0xFFFF453A),
      ));
      _delay(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        n.dismiss();
      }, sessionStart: sessionStart);
    }, sessionStart: sessionStart);
  }

  void _scheduleWifiConnect(DateTime sessionStart) {
    final phone = context.read<PhoneState>();
    final n = context.read<NotificationsState>();
    final l10n = L10nService.instance.dialogues['meta']?['notifications'] ?? {};

    _delay(const Duration(seconds: 20), () {
      if (!mounted) return;
      if (!phone.isUnlocked) return;
      n.push(AppNotification(
        id: 'wifi_connect',
        appName: 'Wi-Fi',
        title: l10n['wifi_title'] ?? 'Połączono z siecią',
        body: l10n['wifi_body'] ?? 'HB_Guest_5G — połączenie nieszyfrowane',
        icon: Icons.wifi,
        iconBg: const Color(0xFF0A84FF),
      ));
    }, sessionStart: sessionStart);
  }

  void _evaluateEndingAchievements(String endingId) {
    if (!mounted) return;
    final ach = context.read<AchievementsState>();
    final endings = context.read<EndingState>();
    final trust = context.read<TrustState>();
    final evidence = context.read<EvidenceState>();
    final flags = context.read<FlagsState>();
    final unlockedAt = _unlockedAt;

    if (endingId == 'truth') ach.unlock('truth_teller');
    if (endingId == 'dawn') ach.unlock('dawn_walker');
    if (endingId == 'witness') ach.unlock('witness_path');
    if (endingId == 'shadow') ach.unlock('shadow_path');

    var totalActive = _activeSessionDuration;
    if (_lastResumeAt != null) {
      totalActive += DateTime.now().difference(_lastResumeAt!);
    }

    if (totalActive < const Duration(minutes: 10)) {
      ach.unlock('speedrun');
    }

    if (endingId == 'truth' || endingId == 'dawn') {
      if (trust.get('anita') > 0) ach.unlock('pacifist');
    }

    if (trust.get('mama') >= 80) ach.unlock('mama_loyal');

    final maxScore = EvidenceState.weights.values.fold<int>(0, (s, w) => s + w);
    if (evidence.score >= maxScore) ach.unlock('detective');

    if (flags.isSet('puzzle.private_unlocked') &&
        flags.isSet('puzzle.voices_matched') &&
        flags.isSet('puzzle.route_reconstructed') &&
        flags.isSet('puzzle.email_recovered') &&
        flags.isSet('puzzle.signal_decoded')) {
      ach.unlock('investigator');
    }

    final discovered = endings.discoveredEndings;
    if (discovered.length >= EndingState.catalog.length) {
      ach.unlock('all_endings');
    }
  }

  void _scheduleProsecutorOpening(String fromEndingId) {
    if (!mounted) return;
    final settings = context.read<SettingsState>();
    final sessionStart = settings.currentRunStartedAt;
    final messages = context.read<MessagesState>();
    final l10n = L10nService.instance.dialogues['meta']?['prosecutor_bridge'] ?? {};
    
    final bridge = fromEndingId == 'truth'
        ? (l10n['anita'] ?? 'Anita: Anita zadzwoniła do prokuratora wcześniej niż planowała. Powiedział że potrzebuje rozmowy z kimś, kto ma materiały. Z Tobą.')
        : (l10n['tomasz'] ?? 'Tomasz: Komendant został zatrzymany. Ale śledczy chcą rozmawiać z Tobą — bezpośrednio. Daję Ci numer prokuratora R.');
    
    _delay(const Duration(seconds: 8), () {
      if (!mounted) return;
      if (settings.currentRunStartedAt != sessionStart) return;
      final threadId = fromEndingId == 'truth' ? 'dziennikarka' : 'tomasz';
      messages.deliverNpcMessage(threadId, bridge, delay: const Duration(seconds: 12));
    }, sessionStart: sessionStart);
    _delay(const Duration(seconds: 25), () {
      if (!mounted) return;
      if (settings.currentRunStartedAt != sessionStart) return;
      messages.triggerProsecutorDialog();
    }, sessionStart: sessionStart);
  }

  void _scheduleNgpMetaNarration(NewGamePlusState ngp) {
    final settings = context.read<SettingsState>();
    final sessionStart = settings.currentRunStartedAt;
    final lastEnding = ngp.previousEndings.isNotEmpty ? ngp.previousEndings.last : null;
    final messages = context.read<MessagesState>();
    final phone = context.read<PhoneState>();

    _delay(const Duration(seconds: 12), () {
      if (!mounted) return;
      if (!phone.isUnlocked) return;
      messages.deliverNpcMessage('nieznany', _ngpOpenerLine(lastEnding, ngp.runCount), delay: const Duration(seconds: 5));
    }, sessionStart: sessionStart);
    _delay(const Duration(seconds: 30), () {
      if (!mounted) return;
      if (!phone.isUnlocked) return;
      final l10n = L10nService.instance.dialogues['meta']?['ngp'] ?? {};
      messages.deliverNpcMessage('nieznany', l10n['meta_closing'] ?? 'Wiem, jak to brzmi. Po prostu… zrób to lepiej tym razem.', delay: const Duration(seconds: 5));
    }, sessionStart: sessionStart);
  }

  void _scheduleCycleHint(NewGamePlusState ngp) {
    if (ngp.cycleHinted) return;
    final settings = context.read<SettingsState>();
    final phone = context.read<PhoneState>();
    final sessionStart = settings.currentRunStartedAt;
    final msgs = context.read<MessagesState>();
    final l10n = L10nService.instance.dialogues['meta']?['ngp'] ?? {};

    _delay(const Duration(minutes: 10), () {
      if (!mounted) return;
      if (!phone.isUnlocked) return;
      msgs.deliverNpcMessage('nieznany', l10n['cycle_hint_1'] ?? 'Słuchaj. Zauważyłeś, że za każdym razem to ten sam telefon? Ten sam piątek wieczorem? Ja tak.', delay: const Duration(seconds: 6));
      _delay(const Duration(seconds: 20), () {
        if (!mounted) return;
        if (!phone.isUnlocked) return;
        msgs.deliverNpcMessage('nieznany', l10n['cycle_hint_2'] ?? 'Jeśli kiedyś się zatrzymasz i zapytasz Szeryfa wprost — może nas obu stąd wypuści. Spróbuj. Następnym razem, gdy do ciebie napisze, dostaniesz nową opcję.', delay: const Duration(seconds: 8));
        if (mounted) context.read<NewGamePlusState>().markCycleHinted();
      }, sessionStart: sessionStart);
    }, sessionStart: sessionStart);
  }

  void _scheduleHintWatchdog() {
    _hintTimer?.cancel();
    _lastInteractionAt = DateTime.now();
    _hintTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (!mounted) { timer.cancel(); return; }
      if (_isPaused) return;
      if (context.read<EndingState>().activeEnding != null) { timer.cancel(); return; }
      if (!context.read<PhoneState>().isUnlocked) return;
      final last = _lastInteractionAt ?? _unlockedAt;
      if (last == null) return;
      final settings = context.read<SettingsState>();
      final threshold = settings.guidedMode ? const Duration(minutes: 3) : const Duration(minutes: 10);
      if (DateTime.now().difference(last) < threshold) return;
      _deliverContextualHint();
      _lastInteractionAt = DateTime.now();
    });
  }

  void _deliverContextualHint() {
    if (!mounted) return;
    final l10n = L10nService.instance.dialogues['meta']?['hints'] ?? {};
    final flags = context.read<FlagsState>();
    final photos = context.read<PhotosState>();
    final notes = context.read<NotesState>();
    final files = context.read<FilesState>();
    final browser = context.read<BrowserState>();
    final messages = context.read<MessagesState>();
    final chapter = context.read<ChapterState>();

    String hint;
    if (chapter.isChapter3 && !flags.isSet('puzzle.signal_decoded')) {
      hint = l10n['chapter3_signal'] ??
          'Prokurator R. czeka na potwierdzenie. Otwórz Signal na ekranie głównym — hasło to słowo z notatek N. plus godzina pierwszego nagrania.';
    } else if (!photos.hasInspected('forest_night')) {
      hint = l10n['photos_clue'] ??
          'Wejdź w Zdjęcia. Szukaj ciemnego zdjęcia z lasu — kliknij Info na dole.';
    } else if (!notes.hasUnlockedSecret) {
      hint = l10n['notes_lock'] ??
          'Masz kod 7309 z metadanych zdjęcia. Otwórz Notatki — jest tam zablokowana notatka.';
    } else if (files.openedCount < FilesState.chapter2OpenThreshold) {
      hint = l10n['files_progress'] ??
          'W Plikach są dokumenty, które N. zebrała. Przeczytaj je wszystkie — to twoje twarde dowody.';
    } else if (!browser.isPrivateUnlocked) {
      hint = l10n['browser_private'] ??
          'Karty prywatne w przeglądarce są zaszyfrowane. Hasło masz w notatkach: imię kota + rok urodzenia.';
    } else if (!flags.isSet('puzzle.email_recovered')) {
      hint = l10n['email_fragments'] ??
          'W Poczcie jest pusty Kosz. Fragmenty wiadomości N. są rozsiane po innych aplikacjach. Przytrzymaj palec na podejrzanych elementach.';
    } else if (!flags.isSet('puzzle.voices_matched')) {
      hint = l10n['recorder_voices'] ??
          'W Dyktafonie nagrania mają anonimowe głosy. Kojarz kontekst transkrypcji z osobami z Kontaktów.';
    } else if (!flags.isSet('puzzle.route_reconstructed')) {
      hint = l10n['maps_route'] ??
          'W Mapach jest opcja "Zrekonstruuj ostatni dzień". Ułóż lokacje N. po godzinach z Kalendarza.';
    } else {
      hint = l10n['generic_ready'] ??
          'Masz teraz wszystko. Odezwij się do Anity albo Tomasza.';
    }
    messages.deliverNpcMessage('nieznany', hint,
        delay: const Duration(seconds: 1));
  }

  void _scheduleSolitudeWatchdog() {
    _solitudeWatchdog?.cancel();
    _solitudeWatchdog = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!mounted) { timer.cancel(); return; }
      if (context.read<EndingState>().activeEnding != null) { timer.cancel(); return; }
      if (!context.read<PhoneState>().isUnlocked) return;
      
      var currentActive = _activeSessionDuration;
      if (_lastResumeAt != null) {
        currentActive += DateTime.now().difference(_lastResumeAt!);
      }

      if (currentActive.inMinutes < 25) return;
      if (!context.read<TrustState>().allBelow(-50)) return;
      timer.cancel();
      context.read<MessagesState>().onEndingTriggered?.call('solitude');
    });
  }

  void _scheduleCreepyMoments(DateTime sessionStart) {
    final phone = context.read<PhoneState>();
    final notifications = context.read<NotificationsState>();
    final l10n = L10nService.instance.dialogues['meta']?['notifications'] ?? {};

    _delay(const Duration(minutes: 12), () {
      if (!mounted) return;
      if (!phone.isUnlocked) return;
      notifications.push(AppNotification(
        id: 'creepy_camera',
        appName: 'System',
        title: l10n['creepy_camera_title'] ?? 'Aparat',
        body: l10n['creepy_camera_body'] ??
            'Aplikacja "Nieznana" uzyskała dostęp do aparatu',
        icon: Icons.camera_alt,
        iconBg: const Color(0xFFFF453A),
      ));
    }, sessionStart: sessionStart);

    _delay(const Duration(minutes: 18), () {
      if (!mounted) return;
      if (!phone.isUnlocked) return;
      notifications.push(AppNotification(
        id: 'creepy_mic',
        appName: 'Prywatność',
        title: l10n['creepy_mic_title'] ?? 'Mikrofon aktywny',
        body: l10n['creepy_mic_body'] ?? 'Mikrofon jest używany w tle',
        icon: Icons.mic,
        iconBg: const Color(0xFFFF9500),
      ));
    }, sessionStart: sessionStart);

    _delay(const Duration(minutes: 25), () {
      if (!mounted) return;
      if (!phone.isUnlocked) return;
      notifications.push(AppNotification(
        id: 'creepy_unlock',
        appName: 'Bezpieczeństwo',
        title: l10n['creepy_unlock_title'] ?? 'Próba logowania',
        body: l10n['creepy_unlock_body'] ??
            'Nieudana próba zdalnego odblokowania urządzenia',
        icon: Icons.security,
        iconBg: const Color(0xFFFF453A),
      ));
    }, sessionStart: sessionStart);

    _scheduleStalkerMessages(sessionStart);
  }

  void _scheduleStalkerMessages(DateTime sessionStart) {
    final msgs = context.read<MessagesState>();
    final phone = context.read<PhoneState>();
    final loc = LocationService.instance;
    final l10n = L10nService.instance.dialogues['threads']?['stalker']?['systemMessages'] ?? {};
    final hour = DateTime.now().hour;
    
    final timeComment = hour >= 22 || hour < 6 
        ? (l10n['night'] ?? 'Ciemno u ciebie, prawda?') 
        : hour >= 18 
            ? (l10n['evening'] ?? 'Wieczór. Zamknij zasłony.') 
            : (l10n['day'] ?? 'Dzień. Myślisz że jesteś bezpieczny?');

    _delay(const Duration(minutes: 3), () {
      if (!mounted) return;
      if (!phone.isUnlocked) return;
      msgs.deliverNpcMessage('stalker', l10n['i_see_you'] ?? 'Widzę cię.',
          delay: const Duration(seconds: 6));
    }, sessionStart: sessionStart);

    _delay(const Duration(minutes: 7), () {
      if (!mounted) return;
      if (!phone.isUnlocked) return;
      msgs.deliverNpcMessage('stalker', timeComment, delay: const Duration(seconds: 8));
    }, sessionStart: sessionStart);

      _delay(const Duration(minutes: 15), () {
      if (!mounted) return;
      if (!phone.isUnlocked) return;
      final text = loc.hasRealLocation 
          ? (l10n['loc_city'] ?? '{city}. {district}. Nie ruszaj się.').replaceAll('{city}', loc.city).replaceAll('{district}', loc.district)
          : (l10n['loc_prefix'] ?? 'Wiem gdzie jesteś. Nie ruszaj się.');
      msgs.deliverNpcMessage('stalker', text, delay: const Duration(seconds: 10));
    }, sessionStart: sessionStart);

    _delay(const Duration(minutes: 22), () {
      if (!mounted) return;
      if (!phone.isUnlocked) return;
      msgs.deliverNpcMessage('stalker', l10n['warning_phone'] ?? 'Nie powinieneś był tego włączać. Ten telefon nie jest twój.', delay: const Duration(seconds: 12));
    }, sessionStart: sessionStart);

    _delay(const Duration(minutes: 30), () {
      if (!mounted) return;
      if (!phone.isUnlocked) return;
      final text = loc.hasRealLocation 
          ? (l10n['last_warning_city'] ?? 'Jadę do {city}. Odłóż telefon. Ostatnie ostrzeżenie.').replaceAll('{city}', loc.city)
          : (l10n['last_warning'] ?? 'Jadę po ciebie. Odłóż telefon. Ostatnie ostrzeżenie.');
      msgs.deliverNpcMessage('stalker', text, delay: const Duration(seconds: 15));
    }, sessionStart: sessionStart);
  }

  Future<void> _resetGameForNewStart(BuildContext context) async {
    await PersistenceService.instance.clearGameState();
    if (!context.mounted) return;
    context.read<MessagesState>().reset();
    context.read<NotesState>().reset();
    context.read<PhotosState>().reset();
    context.read<FilesState>().reset();
    context.read<BrowserState>().reset();
    context.read<ChapterState>().reset();
    context.read<TrustState>().reset();
    context.read<EvidenceState>().reset();
    context.read<FlagsState>().reset();
    context.read<EmailState>().reset();
    context.read<RecorderState>().reset();
    context.read<MapsState>().reset();
    context.read<SignalPuzzleState>().reset();
    context.read<PhoneState>().reset();
    context.read<NotificationsState>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsState>();
    if (!settings.contentWarningShown) {
      return ContentWarningScreen(onContinue: () => setState(() {}));
    }

    final ngp = context.watch<NewGamePlusState>();
    if (!_ngpChoiceMade && ngp.canStartPlus) {
      return NewGamePlusChoiceScreen(
        onContinueRegular: () async {
          await _resetGameForNewStart(context);
          if (mounted) setState(() => _ngpChoiceMade = true);
        },
        onContinuePlus: () => setState(() => _ngpChoiceMade = true),
      );
    }

    if (!_introComplete) {
      return IntroScreen(onComplete: () => setState(() => _introComplete = true));
    }

    if (!_bootComplete) {
      return BootScreen(onComplete: () => setState(() => _bootComplete = true));
    }

    final unlocked = context.select<PhoneState, bool>((s) => s.isUnlocked);
    final hasEnding = context.select<EndingState, bool>((s) => s.activeEnding != null);
    final sheriffUnread = context.select<MessagesState, int>((s) => s.threadById('szeryf')?.unreadCount ?? 0);

    if (!unlocked && _wasUnlocked) {
      _wasUnlocked = false;
      _tensionActive = false;
      _incomingCall = false;
      _ringerTimer?.cancel();
      _ringerTimer = null;
      _sheriffCountdown?.cancel();
      _sheriffCountdown = null;
      _solitudeWatchdog?.cancel();
      _solitudeWatchdog = null;
      _hintTimer?.cancel();
      _hintTimer = null;
      _unlockedAt = null;
      _showWelcomeBack = false;
      context.read<SettingsState>().clearRunStart();
    }

    if (unlocked && !_wasUnlocked) {
      _wasUnlocked = true;
      _unlockedAt = DateTime.now();
      _lastResumeAt = _unlockedAt;
      _activeSessionDuration = Duration.zero;
      AudioService.instance.startAmbient();
      context.read<AchievementsState>().unlock('first_unlock');
      context.read<SettingsState>().markRunStart(_unlockedAt!);
      if (settings.hasBeenAwayLong) {
        final hasProgress = context.read<NotesState>().hasUnlockedSecret ||
            context.read<FilesState>().openedCount > 0 ||
            context.read<EvidenceState>().score > 0;
        if (hasProgress) _showWelcomeBack = true;
      }
      settings.touchLastPlayed();

      if (ngp.isPlusActive && ngp.runCount >= 1) _scheduleNgpMetaNarration(ngp);
      if (ngp.isPlusActive && ngp.runCount >= 2) _scheduleCycleHint(ngp);
      _scheduleWifiConnect(_unlockedAt!);
      _scheduleGhostNotification(_unlockedAt!);
      _scheduleCreepyMoments(_unlockedAt!);
      _scheduleSolitudeWatchdog();
      _scheduleHintWatchdog();
      
      final phone = context.read<PhoneState>();
      final sessionStart = _unlockedAt!;
      final msgs = context.read<MessagesState>();

      _delay(const Duration(seconds: 6), () {
        if (!mounted) return;
        if (!phone.isUnlocked) return;
        final nieznany = msgs.threadById('nieznany');
        if (nieznany != null && nieznany.messages.isEmpty) {
          final dialogues = L10nService.instance.dialogues['threads'] as Map<String, dynamic>? ?? {};
          final nData = dialogues['nieznany'] ?? {};
          final nMsgs = (nData['messages'] as List? ?? []);
          if (nMsgs.isNotEmpty) msgs.deliverNpcMessage('nieznany', nMsgs.first as String, delay: const Duration(seconds: 1));
        }
      }, sessionStart: sessionStart);
      
      _delay(const Duration(minutes: 4), () {
        if (!mounted) return;
        if (!phone.isUnlocked) return;
        final l10n = L10nService.instance.dialogues['threads']?['szeryf'] ?? {};
        setState(() {
          _incomingCall = true;
          _callerName = l10n['contactName'] ?? 'Sheriff';
        });
      }, sessionStart: sessionStart);

      final notifications = context.read<NotificationsState>();
      _delay(const Duration(seconds: 5), () {
        if (!mounted) return;
        final nieznany = msgs.threadById('nieznany');
        if (nieznany == null || nieznany.unreadCount == 0) return;
        notifications.push(AppNotification(
          id: 'nudge_nieznany',
          appName: 'Wiadomości',
          title: nieznany.contactName,
          body: nieznany.lastMessage?.text ?? '',
          icon: Icons.chat_bubble,
          iconBg: const Color(0xFF34C759),
          onTap: () {
            final nav = _navKey.currentState;
            if (nav == null) return;
            msgs.openThread('nieznany');
            nav
                .push(MaterialPageRoute(
                    builder: (_) => const ChatView(threadId: 'nieznany')))
                .then((_) {
              if (!mounted) return;
              msgs.closeThread();
            });
          },
        ));
      }, sessionStart: sessionStart);
    }

    if (sheriffUnread > 0 && !_tensionActive) {
      _tensionActive = true;
      AudioService.instance.startTension();
    } else if (sheriffUnread == 0 && _tensionActive) {
      _tensionActive = false;
      AudioService.instance.stopTension();
    }

    final activeThread = context.select<MessagesState, String?>((s) => s.activeThread?.id);
    final shouldRing = sheriffUnread > 0 && activeThread != 'szeryf' && !hasEnding;
    _updateRinger(shouldRing);

    if (hasEnding) { AudioService.instance.stopAmbient(); _updateRinger(false); }

    return PhoneShellEvents(
      onPause: _pause,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          final nav = _navKey.currentState;
          if (nav != null && nav.canPop()) { nav.pop(); } else if (unlocked && !hasEnding) { _pause(); }
        },
        child: Stack(
          children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: unlocked
                ? KeyedSubtree(
                    key: const ValueKey('home'),
                    child: Navigator(
                      key: _navKey,
                      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const HomeScreen()),
                    ),
                  )
                : const LockScreen(key: ValueKey('lock')),
          ),
          if (unlocked && !hasEnding) const Positioned(top: 0, left: 0, right: 0, child: NotificationBannerHost()),
          if (hasEnding) const Positioned.fill(child: EndingOverlay()),
          if (context.select<ChapterState, bool>((s) => s.shouldAnimateTransition))
            Positioned.fill(child: ChapterTransitionOverlay(onComplete: () { context.read<ChapterState>().clearTransitionFlag(); })),
          if (_isPaused && unlocked && !hasEnding) Positioned.fill(child: PauseOverlay(onResume: _resume)),
          if (_showWelcomeBack && unlocked && !hasEnding && !_isPaused)
            Positioned.fill(child: WelcomeBackOverlay(onContinue: () => setState(() => _showWelcomeBack = false))),
          if (_incomingCall && unlocked && !hasEnding)
            Positioned.fill(child: IncomingCallOverlay(callerName: _callerName ?? 'Nieznany', onDismiss: () => setState(() => _incomingCall = false))),

          // Global Home Indicator / Gesture bar
          if (unlocked && !hasEnding)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _GlobalHomeIndicator(
                onTap: () {
                  final nav = _navKey.currentState;
                  if (nav != null && nav.canPop()) {
                    nav.popUntil((route) => route.isFirst);
                  }
                },
                onLongPress: _pause,
              ),
            ),
        ],
      ),
    ),
    );
  }

  void _startSheriffCountdown(MessagesState messages, {required DateTime targetTime}) {
    _sheriffCountdown?.cancel();
    _sheriffCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      if (DateTime.now().isAfter(targetTime)) {
        timer.cancel();
        _sheriffCountdown = null;
        _sheriffTargetTime = null;
        messages.onEndingTriggered?.call('caught');
      }
    });
  }

  void _pause() {
    if (_isPaused) return;
    setState(() => _isPaused = true);
    context.read<MessagesState>().setPaused(true);
    
    // Track active session time
    if (_lastResumeAt != null) {
      _activeSessionDuration += DateTime.now().difference(_lastResumeAt!);
      _lastResumeAt = null;
    }

    // Calculate remaining time for sheriff if active
    if (_sheriffTargetTime != null) {
      _sheriffTimeRemaining = _sheriffTargetTime!.difference(DateTime.now());
      if (_sheriffTimeRemaining! < Duration.zero) _sheriffTimeRemaining = Duration.zero;
    }
    
    _sheriffCountdown?.cancel(); 
    _solitudeWatchdog?.cancel(); _solitudeWatchdog = null;
    _hintTimer?.cancel(); _hintTimer = null;
    _ringerTimer?.cancel(); _ringerTimer = null;
    AudioService.instance.stopTension();
  }

  void _resume() {
    if (!_isPaused) return;
    setState(() => _isPaused = false);
    context.read<MessagesState>().setPaused(false);
    
    _lastResumeAt = DateTime.now();

    if (_unlockedAt != null) { 
      _scheduleSolitudeWatchdog(); 
      _scheduleHintWatchdog(); 
      
      // Recalculate target time based on remaining duration
      if (_sheriffTimeRemaining != null) {
        _sheriffTargetTime = DateTime.now().add(_sheriffTimeRemaining!);
        _sheriffTimeRemaining = null;
        _startSheriffCountdown(context.read<MessagesState>(), targetTime: _sheriffTargetTime!);
      }
    }
  }

  Future<void> _delay(Duration duration, void Function() action, {DateTime? sessionStart}) async {
    var remaining = duration;
    final startSession = sessionStart ?? context.read<SettingsState>().currentRunStartedAt;
    
    while (remaining > Duration.zero) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      
      // If session changed (reset), abort
      if (context.read<SettingsState>().currentRunStartedAt != startSession) return;
      
      if (!_isPaused) {
        remaining -= const Duration(milliseconds: 500);
      }
    }
    
    if (mounted && context.read<SettingsState>().currentRunStartedAt == startSession) {
      action();
    }
  }

  String _ngpOpenerLine(String? lastEnding, int runCount) {
    final l10n = L10nService.instance.dialogues['meta']?['ngp'] ?? {};
    final prefix = runCount == 1 
        ? (l10n['opener_prefix_1'] ?? 'Wróciłeś. ') 
        : (l10n['opener_prefix_multi'] ?? 'Znowu. To już {count}-ty raz. ').replaceAll('{count}', runCount.toString());
    
    String body;
    switch (lastEnding) {
      case 'caught': body = l10n['caught'] ?? 'Ostatnio dali się ciebie złapać. Tym razem nie kłam Szeryfowi za szybko.'; break;
      case 'escape': body = l10n['escape'] ?? 'Ostatnio uciekłeś z dowodami w kieszeni. N. wciąż jest gdzie tam. Może tym razem nie zostawimy jej tam samej?'; break;
      case 'truth': body = l10n['truth'] ?? 'Anita publikowała w sobotę. Dobrze. Ale N. nadal nie wróciła. Spróbuj inaczej.'; break;
      case 'dawn': body = l10n['dawn'] ?? 'Już raz znalazłeś N. żywą. Jak to się skończyło? Jak myślisz?'; break;
      case 'corruption': body = l10n['corruption'] ?? 'Wziąłeś kopertę. Każdy z nas ma swoją cenę. Może tym razem spróbujesz nie mieć?'; break;
      case 'solitude': body = l10n['solitude'] ?? 'Ostatnio nikomu nie zaufałeś. Wiesz że Mama do ciebie pisała? Otwórz jej wiadomości. Tym razem.'; break;
      case 'cycle': body = l10n['cycle'] ?? 'Wróciłeś nawet po tym, jak ci wszystko wytłumaczyłem.\nAlbo jesteś uparty, albo nie pamiętasz.\nAlbo jedno i drugie.'; break;
      default: body = l10n['default'] ?? 'Telefon znowu w twoich rękach. Pamiętasz coś z poprzedniego razu? Niezależnie — zaczynamy od nowa.';
    }
    return '$prefix$body';
  }
}

/// Global bottom bar that mimics modern phone gestures.
/// Tap to go Home, Long Press to Pause.
class _GlobalHomeIndicator extends StatelessWidget {
  const _GlobalHomeIndicator({required this.onTap, required this.onLongPress});
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0), // Added bottom margin for gesture navigation
        child: GestureDetector(
          onTap: onTap,
          onLongPress: () {
            HapticFeedback.heavyImpact();
            onLongPress();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            height: 32, // Large hit area for small visual
            alignment: Alignment.center,
            child: Container(
              width: 130,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
