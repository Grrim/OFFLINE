import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../screens/achievements/achievements_view.dart';
import '../screens/endings/endings_gallery_view.dart';
import '../screens/settings/settings_view.dart';
import '../state/achievements_state.dart';
import '../state/ending_state.dart';

/// Modal pause overlay. Mounts above the navigator and pauses the
/// world (timers cancelled by the shell, audio dimmed) while open.
///
/// Closes on the "Wznów" button or by tapping outside the dialog.
/// "Ustawienia" pushes the existing SettingsView; the overlay re-opens
/// when the player pops back.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.onResume,
  });

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final hasGallery = context.select<EndingState, bool>(
        (s) => s.hasAnyDiscovered);
    final hasAchievements = context.select<AchievementsState, int>(
            (s) => s.unlockedCount) >
        0;
    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2C2C2E)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pause_circle_outline,
                    size: 48, color: Color(0xFF0A84FF)),
                const SizedBox(height: 12),
                const Text(
                  'Pauza',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Czas zatrzymany.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                _PauseAction(
                  icon: Icons.play_arrow,
                  label: 'Wznów',
                  primary: true,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onResume();
                  },
                ),
                const SizedBox(height: 8),
                _PauseAction(
                  icon: Icons.tune,
                  label: 'Ustawienia',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsView(),
                      ),
                    );
                  },
                ),
                if (hasGallery) ...[
                  const SizedBox(height: 8),
                  _PauseAction(
                    icon: Icons.collections_bookmark_outlined,
                    label: 'Zakończenia',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EndingsGalleryView(),
                        ),
                      );
                    },
                  ),
                ],
                if (hasAchievements) ...[
                  const SizedBox(height: 8),
                  _PauseAction(
                    icon: Icons.emoji_events_outlined,
                    label: 'Osiągnięcia',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AchievementsView(),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PauseAction extends StatelessWidget {
  const _PauseAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final bg =
        primary ? const Color(0xFF0A84FF) : const Color(0xFF2C2C2E);
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        style: TextButton.styleFrom(
          backgroundColor: bg,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
