import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/ending_state.dart';
import '../../widgets/status_bar.dart';

/// Read-only gallery of all endings. Discovered ones are shown in full
/// colour with title and accent; undiscovered ones are blacked out with
/// a question-mark icon. Tapping a discovered ending opens a reader
/// page with the epilogue.
class EndingsGalleryView extends StatelessWidget {
  const EndingsGalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EndingState>();
    final allIds = EndingState.catalog.keys.toList()
      ..sort((a, b) => _sortOrder(a).compareTo(_sortOrder(b)));

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const StatusBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF0A84FF), size: 22),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Zakończenia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${state.discoveredEndings.length} / ${allIds.length}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: allIds.length,
                itemBuilder: (context, i) {
                  final id = allIds[i];
                  final ending = EndingState.catalog[id]!;
                  final discovered = state.isDiscovered(id);
                  return _EndingCard(
                    ending: ending,
                    discovered: discovered,
                    onTap: discovered
                        ? () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    _EndingReaderScreen(ending: ending),
                              ),
                            )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sort order — "happy" endings (witness, dawn, truth) first, then
  /// neutral (escape, shadow), then dark (caught, corruption, solitude),
  /// then secret (cycle). Stable across runs.
  int _sortOrder(String id) => switch (id) {
        'witness' => 0,
        'dawn' => 1,
        'truth' => 2,
        'shadow' => 3,
        'escape' => 4,
        'caught' => 5,
        'corruption' => 6,
        'solitude' => 7,
        'cycle' => 8,
        _ => 99,
      };
}

class _EndingCard extends StatelessWidget {
  const _EndingCard({
    required this.ending,
    required this.discovered,
    required this.onTap,
  });

  final GameEnding ending;
  final bool discovered;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = discovered ? ending.accentColor : Colors.white12;
    // Secret endings stay anonymous in the gallery until discovered —
    // even the title is hidden (CYKL is the canonical case).
    final hideContent = ending.secret && !discovered;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: discovered
              ? accent.withValues(alpha: 0.08)
              : const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accent.withValues(alpha: discovered ? 0.4 : 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              discovered ? ending.icon : Icons.help_outline,
              color: accent,
              size: 36,
            ),
            const Spacer(),
            Text(
              discovered
                  ? ending.title
                  : (hideContent ? '???' : '???'),
              style: TextStyle(
                color: discovered ? Colors.white : Colors.white24,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              discovered
                  ? ending.subtitle
                  : (hideContent
                      ? 'Zakończenie ukryte'
                      : 'Nie odkryto'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: discovered ? Colors.white70 : Colors.white24,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EndingReaderScreen extends StatelessWidget {
  const _EndingReaderScreen({required this.ending});
  final GameEnding ending;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const StatusBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF0A84FF), size: 22),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(ending.icon, color: ending.accentColor, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      ending.title,
                      style: TextStyle(
                        color: ending.accentColor,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ending.subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      ending.epilogue,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.6,
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
