import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/achievements_state.dart';
import '../../widgets/status_bar.dart';

/// Gallery of all achievements. Locked ones show a generic icon and
/// the title; secret ones hide both title and description until
/// unlocked.
class AchievementsView extends StatelessWidget {
  const AchievementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AchievementsState>();
    final ids = AchievementsState.catalog.keys.toList();

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
                    'Osiągnięcia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${state.unlockedCount}/${state.totalCount}',
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ids.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final id = ids[i];
                  final a = AchievementsState.catalog[id]!;
                  final unlocked = state.isUnlocked(id);
                  final hideContent = a.secret && !unlocked;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: unlocked
                          ? a.iconColor.withValues(alpha: 0.06)
                          : const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: unlocked
                            ? a.iconColor.withValues(alpha: 0.4)
                            : const Color(0xFF2C2C2E),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (unlocked ? a.iconColor : Colors.white12)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            unlocked ? a.icon : Icons.lock_outline,
                            color: unlocked ? a.iconColor : Colors.white38,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hideContent ? '???' : a.title,
                                style: TextStyle(
                                  color: unlocked
                                      ? Colors.white
                                      : Colors.white38,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hideContent
                                    ? 'Nie odkryte'
                                    : a.description,
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
