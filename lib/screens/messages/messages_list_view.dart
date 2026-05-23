import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/messages_state.dart';
import '../../widgets/status_bar.dart';
import 'chat_view.dart';

/// Inbox / chat list. Mimics a modern OS messages app.
class MessagesListView extends StatelessWidget {
  const MessagesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = context.watch<MessagesState>();
    final threads = messages.threads;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const StatusBar(),
            // ---- App header ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF0A84FF), size: 22),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Wiadomości',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Nie można tworzyć nowych wiadomości'),
                            duration: Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                    },
                    child: const Icon(Icons.edit_outlined,
                        color: Color(0xFF0A84FF), size: 24),
                  ),
                ],
              ),
            ),
            // ---- Search field (tapping shows "no results" — feels real) ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Brak wyników'),
                        duration: Duration(milliseconds: 800),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                },
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.white38, size: 18),
                      SizedBox(width: 8),
                      Text('Szukaj',
                          style: TextStyle(color: Colors.white38, fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ---- Threads ----
            Expanded(
              child: ListView.separated(
                itemCount: threads.length,
                separatorBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(left: 88),
                  child: Divider(height: 1, color: Color(0xFF2C2C2E)),
                ),
                itemBuilder: (context, i) {
                  final t = threads[i];
                  return _ThreadTile(
                    thread: t,
                    onTap: () {
                      messages.openThread(t.id);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatView(threadId: t.id),
                        ),
                      ).then((_) => messages.closeThread());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.thread, required this.onTap});

  final ChatThread thread;
  final VoidCallback onTap;

  String _formatStamp(DateTime t) {
    final now = DateTime.now();
    final sameDay = t.year == now.year && t.month == now.month && t.day == now.day;
    if (sameDay) {
      final hh = t.hour.toString().padLeft(2, '0');
      final mm = t.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = t.year == yesterday.year &&
        t.month == yesterday.month &&
        t.day == yesterday.day;
    if (isYesterday) return 'wczoraj';
    return '${t.day.toString().padLeft(2, '0')}.${t.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final last = thread.lastMessage;
    final hasUnread = thread.unreadCount > 0;
    final avatarColor = Color(thread.avatarColor ?? 0xFF3A3A3C);
    final initials = thread.contactName.isNotEmpty
        ? thread.contactName.characters.first.toUpperCase()
        : '?';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot column
            SizedBox(
              width: 14,
              child: hasUnread
                  ? const Padding(
                      padding: EdgeInsets.only(top: 22),
                      child: Icon(Icons.circle,
                          color: Color(0xFF0A84FF), size: 10),
                    )
                  : null,
            ),
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: avatarColor,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + snippet
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.contactName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    last?.text ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasUnread ? Colors.white : Colors.white60,
                      fontSize: 14,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Stamp + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  last == null ? '' : _formatStamp(last.timestamp),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right,
                    color: Colors.white24, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
