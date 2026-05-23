import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/browser_state.dart';
import '../../widgets/status_bar.dart';

/// Browser app — shows N.'s history. Static history-only view, like
/// looking at a real Safari Recently Closed list.
class BrowserView extends StatelessWidget {
  const BrowserView({super.key});

  @override
  Widget build(BuildContext context) {
    final browser = context.watch<BrowserState>();
    final entries = browser.entries;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const StatusBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF0A84FF), size: 22),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Historia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Decorative URL bar — never functional, just for the "real
            // Safari" feel.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, color: Colors.white54, size: 14),
                    SizedBox(width: 6),
                    Text('Szukaj w historii',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 14)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Divider(height: 1, color: Color(0xFF1C1C1E)),
                ),
                itemBuilder: (context, i) {
                  final entry = entries[i];
                  return _HistoryTile(
                    entry: entry,
                    isUnread: !browser.hasVisited(entry.id),
                    onTap: () {
                      browser.markVisited(entry.id);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            _BrowserReaderScreen(entryId: entry.id),
                      ));
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

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.entry,
    required this.isUnread,
    required this.onTap,
  });

  final BrowserEntry entry;
  final bool isUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: entry.isPrivate
                    ? const Color(0xFF8E8E93).withValues(alpha: 0.2)
                    : const Color(0xFF0A84FF).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                entry.isPrivate ? Icons.shield : Icons.public,
                color: entry.isPrivate
                    ? Colors.white70
                    : const Color(0xFF0A84FF),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight:
                                isUnread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0A84FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0A84FF),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    entry.timestamp,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrowserReaderScreen extends StatelessWidget {
  const _BrowserReaderScreen({required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context) {
    final entry = context
        .read<BrowserState>()
        .entries
        .firstWhere((e) => e.id == entryId);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Mini "URL bar" up top.
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF0A84FF), size: 22),
                  ),
                  Expanded(
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(
                            entry.isPrivate ? Icons.shield : Icons.lock,
                            size: 12,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              entry.url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF1C1C1E)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${entry.url} · ${entry.timestamp}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      entry.preview,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
