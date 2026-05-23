import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/browser_state.dart';
import '../state/chapter_state.dart';
import '../state/ending_state.dart';
import '../state/files_state.dart';
import '../state/messages_state.dart';
import '../state/notes_state.dart';
import '../state/notifications_state.dart';
import '../state/phone_state.dart';
import '../state/photos_state.dart';
import '../services/audio_service.dart';
import '../services/persistence_service.dart';

/// Fullscreen ending overlay. Mounted above the navigator + banner host so
/// nothing else can be interacted with while it's visible.
class EndingOverlay extends StatelessWidget {
  const EndingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final ending = context.watch<EndingState>().activeEnding;
    if (ending == null) return const SizedBox.shrink();

    return _EndingScreen(ending: ending);
  }
}

class _EndingScreen extends StatefulWidget {
  const _EndingScreen({required this.ending});
  final GameEnding ending;

  @override
  State<_EndingScreen> createState() => _EndingScreenState();
}

class _EndingScreenState extends State<_EndingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _flashCtrl;

  @override
  void initState() {
    super.initState();
    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    // Flash first, then fade in the ending content.
    _flashCtrl.forward().then((_) {
      _flashCtrl.reverse();
      _ctrl.forward();
    });
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _flashCtrl.dispose();
    super.dispose();
  }

  Future<void> _restart(BuildContext context) async {
    await PersistenceService.instance.clearAll();
    await AudioService.instance.reset();
    if (!context.mounted) return;
    context.read<EndingState>().reset();
    context.read<MessagesState>().reset();
    context.read<NotesState>().reset();
    context.read<PhotosState>().reset();
    context.read<NotificationsState>().reset();
    context.read<FilesState>().reset();
    context.read<BrowserState>().reset();
    context.read<ChapterState>().reset();
    context.read<PhoneState>().reset();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_ctrl, _flashCtrl]),
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(_ctrl.value);
        final flash = _flashCtrl.value;
        return Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: t,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.ending.accentColor
                                  .withValues(alpha: 0.18),
                              border: Border.all(
                                color: widget.ending.accentColor
                                    .withValues(alpha: 0.7),
                                width: 1.4,
                              ),
                            ),
                            child: Icon(
                              widget.ending.icon,
                              color: widget.ending.accentColor,
                              size: 48,
                            ),
                          ),
                        ),
                        SizedBox(height: 32 * t),
                        Opacity(
                          opacity: t,
                          child: Text(
                            widget.ending.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Opacity(
                          opacity: t,
                          child: Text(
                            widget.ending.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Opacity(
                          opacity: t,
                          child: Text(
                            widget.ending.epilogue,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Opacity(
                          opacity: t,
                          child: OutlinedButton(
                            onPressed: () => _restart(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: widget.ending.accentColor,
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'Zagraj jeszcze raz',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Brief white flash for dramatic impact.
            if (flash > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.white.withValues(alpha: flash * 0.7),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
