import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final visibleCount = thread.messages.length + (messages.isNpcTyping ? 1 : 0);
    if (visibleCount != _lastSeenMessageCount) {
      _lastSeenMessageCount = visibleCount;
      _autoScroll();
    }

    final choices = messages.currentChoices;

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
                    (messages.isNpcTyping ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == thread.messages.length && messages.isNpcTyping) {
                    return const _TypingBubble();
                  }
                  final msg = thread.messages[i];
                  return _MessageBubble(message: msg);
                },
              ),
            ),
            _ChoiceBar(
              choices: choices,
              isInteractive: thread.isInteractive,
              isTyping: messages.isNpcTyping,
              onPick: (c) => messages.selectChoice(c),
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

  @override
  Widget build(BuildContext context) {
    final color = Color(thread.avatarColor ?? 0xFF3A3A3C);
    final initial = thread.contactName.isNotEmpty
        ? thread.contactName.characters.first.toUpperCase()
        : '?';

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
              ],
            ),
          ),
          const SizedBox(width: 36), // visual balance with back button
        ],
      ),
    );
  }
}

// ----- Bubbles -----

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isPlayer = message.sender == MessageSender.player;
    final bg = isPlayer ? const Color(0xFF0A84FF) : const Color(0xFF2C2C2E);
    final align = isPlayer ? Alignment.centerRight : Alignment.centerLeft;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isPlayer ? 18 : 4),
      bottomRight: Radius.circular(isPlayer ? 4 : 18),
    );

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: bg, borderRadius: radius),
          child: Text(
            message.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.3,
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
    required this.onPick,
  });

  final List<DialogueChoice> choices;
  final bool isInteractive;
  final bool isTyping;
  final ValueChanged<DialogueChoice> onPick;

  @override
  Widget build(BuildContext context) {
    // Static threads (e.g. Mama) get a disabled-looking input bar instead of choices.
    if (!isInteractive) {
      return _DeadInputBar();
    }

    // Interactive but no current choices: either NPC is typing or end of branch.
    if (choices.isEmpty) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        color: Colors.black,
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              isTyping ? 'Pisze...' : 'Koniec rozmowy',
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
          for (final c in choices) ...[
            _ChoiceButton(label: c.text, onTap: () => onPick(c)),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF0A84FF), width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.centerLeft,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, height: 1.3),
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
