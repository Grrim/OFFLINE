import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/audio_service.dart';
import '../../state/messages_state.dart';
import '../../widgets/status_bar.dart';

/// One-on-one conversation. Shows message bubbles and either choice
/// buttons (interactive thread) or an inert input bar (static thread).
class ChatView extends StatefulWidget {
  const ChatView({super.key, required this.threadId});

  final String threadId;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _scrollController = ScrollController();
  int _lastSeenMessageCount = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _autoScroll() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<MessagesState>();
    final thread = messages.threadById(widget.threadId);

    if (thread == null) {
      // Should never happen, but fail gracefully.
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('Brak wątku', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    // Auto-scroll whenever the message count changes (new NPC line, new player line).
    final isTypingHere = messages.isTypingInThread(widget.threadId);
    final isProcessing = messages.isProcessingChoice;
    final visibleCount = thread.messages.length + (isTypingHere ? 1 : 0);
    if (visibleCount != _lastSeenMessageCount) {
      // Play message received sound when a new NPC message appears.
      if (visibleCount > _lastSeenMessageCount && _lastSeenMessageCount > 0) {
        final lastMsg = thread.messages.isNotEmpty ? thread.messages.last : null;
        if (lastMsg != null && lastMsg.sender == MessageSender.npc) {
          AudioService.instance.playSfx(GameSfx.messageReceived);
          HapticFeedback.lightImpact();
        }
      }
      _lastSeenMessageCount = visibleCount;
      _autoScroll();
    }

    final gated = thread.isInteractive &&
            thread.dialogueGraph != null &&
            !isTypingHere
        ? messages.gatedChoices
        : const <GatedChoice>[];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const StatusBar(),
            _ChatHeader(thread: thread),
            const Divider(height: 1, color: Color(0xFF1C1C1E)),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                itemCount: thread.messages.length +
                    (isTypingHere ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == thread.messages.length && isTypingHere) {
                    return const _TypingBubble();
                  }
                  final msg = thread.messages[i];

                  // Day separator — show date header when day changes.
                  Widget? daySeparator;
                  if (i == 0 ||
                      !_sameDay(thread.messages[i - 1].timestamp,
                          msg.timestamp)) {
                    daySeparator = _DaySeparator(date: msg.timestamp);
                  }

                  final isLastPlayer = msg.sender == MessageSender.player &&
                      (i == thread.messages.length - 1 ||
                          thread.messages[i + 1].sender == MessageSender.npc);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (daySeparator != null) daySeparator,
                      _MessageBubble(message: msg),
                      if (isLastPlayer)
                        const Padding(
                          padding: EdgeInsets.only(right: 4, top: 2, bottom: 4),
                          child: Text(
                            'Dostarczono',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            _ChoiceBar(
              choices: gated,
              isInteractive: thread.isInteractive,
              isTyping: isTypingHere,
              isProcessing: isProcessing,
              onPick: (c) {
                HapticFeedback.selectionClick();
                messages.selectChoice(c);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ----- Header -----

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.thread});
  final ChatThread thread;

  String _lastSeenText() {
    if (thread.id == 'szeryf') return 'online';
    if (thread.id == 'nieznany') return 'online';
    if (thread.id == 'dziennikarka') return 'ostatnio: 3 dni temu';
    if (thread.id == 'mama') return 'ostatnio: 10 min temu';
    if (thread.id == 'tomasz') return 'online';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(thread.avatarColor ?? 0xFF3A3A3C);
    final initial = thread.contactName.isNotEmpty
        ? thread.contactName.characters.first.toUpperCase()
        : '?';
    final lastSeen = _lastSeenText();

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Color(0xFF0A84FF), size: 20),
          ),
          Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  thread.contactName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (lastSeen.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    lastSeen,
                    style: TextStyle(
                      color: lastSeen == 'online'
                          ? const Color(0xFF34C759)
                          : Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

// ----- Bubbles -----

class _MessageBubble extends StatefulWidget {
  const _MessageBubble({required this.message});
  final ChatMessage message;

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlayer = widget.message.sender == MessageSender.player;
    final bg = isPlayer ? const Color(0xFF0A84FF) : const Color(0xFF2C2C2E);
    final align = isPlayer ? Alignment.centerRight : Alignment.centerLeft;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isPlayer ? 18 : 4),
      bottomRight: Radius.circular(isPlayer ? 4 : 18),
    );

    return FadeTransition(
      opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(isPlayer ? 0.1 : -0.1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut)),
        child: Align(
          alignment: align,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: bg, borderRadius: radius),
              child: Text(
                widget.message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF2C2C2E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final phase = (_ctrl.value + i * 0.2) % 1.0;
                final opacity = 0.3 + 0.7 * (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Opacity(
                    opacity: opacity,
                    child: const CircleAvatar(
                      radius: 3.5,
                      backgroundColor: Colors.white70,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

// ----- Choice / input bar -----

class _ChoiceBar extends StatelessWidget {
  const _ChoiceBar({
    required this.choices,
    required this.isInteractive,
    required this.isTyping,
    required this.isProcessing,
    required this.onPick,
  });

  final List<GatedChoice> choices;
  final bool isInteractive;
  final bool isTyping;
  final bool isProcessing;
  final ValueChanged<DialogueChoice> onPick;

  @override
  Widget build(BuildContext context) {
    // Static threads (e.g. Mama) get a disabled-looking input bar instead of choices.
    if (!isInteractive) {
      return _DeadInputBar();
    }

    // Interactive but no current choices: either NPC is typing or end of branch.
    if (choices.isEmpty || isProcessing) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        color: Colors.black,
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              (isTyping || isProcessing) ? 'Pisze...' : 'Koniec rozmowy',
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Color(0xFF1C1C1E)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final g in choices) ...[
            _ChoiceButton(
              label: g.choice.text,
              available: g.isAvailable,
              onTap: g.isAvailable ? () => onPick(g.choice) : null,
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.available,
    required this.onTap,
  });

  final String label;
  final bool available;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        available ? const Color(0xFF0A84FF) : const Color(0xFF3A3A3C);
    final textColor = available ? Colors.white : Colors.white38;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          disabledForegroundColor: textColor,
          side: BorderSide(color: borderColor, width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.centerLeft,
        ),
        child: Row(
          children: [
            if (!available) ...[
              const Icon(Icons.lock_outline,
                  size: 14, color: Colors.white38),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _DaySeparator extends StatelessWidget {
  const _DaySeparator({required this.date});
  final DateTime date;

  String _format(DateTime t) {
    final now = DateTime.now();
    if (_sameDay(t, now)) return 'Dzisiaj';
    final yesterday = now.subtract(const Duration(days: 1));
    if (_sameDay(t, yesterday)) return 'Wczoraj';
    const days = ['Pon', 'Wt', 'Śr', 'Czw', 'Pt', 'Sob', 'Ndz'];
    const months = [
      'sty', 'lut', 'mar', 'kwi', 'maj', 'cze',
      'lip', 'sie', 'wrz', 'paź', 'lis', 'gru',
    ];
    return '${days[t.weekday - 1]}, ${t.day} ${months[t.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _format(date),
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ),
      ),
    );
  }
}

class _DeadInputBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      color: Colors.black,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2C2C2E)),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerLeft,
              child: const Text(
                'iMessage',
                style: TextStyle(color: Colors.white24, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_circle_up,
              color: Colors.white24, size: 32),
        ],
      ),
    );
  }
}
