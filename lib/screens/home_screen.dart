import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/messages_state.dart';
import '../state/notes_state.dart';
import '../state/phone_state.dart';
import '../state/photos_state.dart';
import '../widgets/status_bar.dart';
import 'messages/messages_list_view.dart';
import 'notes/notes_view.dart';
import 'photos/photos_grid_view.dart';
import 'settings/settings_view.dart';

/// Home screen / launcher with a 4-app grid.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch unread badge count from the messages module.
    final messagesUnread =
        context.select<MessagesState, int>((s) => s.totalUnread);

    // Phase 4 soft-gate signals for the Notatki tile.
    final cluePhotoSeen = context
        .select<PhotosState, bool>((s) => s.hasInspected('forest_night'));
    final hasLockedNote = context
        .select<NotesState, bool>((s) => s.notes.any((n) => n.isLocked));
    // Show a "1" badge once the player has the clue but hasn't unlocked it yet.
    final notesBadge = (cluePhotoSeen && hasLockedNote) ? 1 : 0;

    final apps = <_AppEntry>[
      _AppEntry(
        label: 'Wiadomości',
        icon: Icons.chat_bubble,
        color: const Color(0xFF34C759),
        badge: messagesUnread,
        onOpen: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(builder: (_) => const MessagesListView()),
        ),
      ),
      _AppEntry(
        label: 'Zdjęcia',
        icon: Icons.photo,
        color: const Color(0xFFFF9F0A),
        onOpen: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(builder: (_) => const PhotosGridView()),
        ),
      ),
      _AppEntry(
        label: 'Notatki',
        icon: Icons.sticky_note_2,
        color: const Color(0xFFFFD60A),
        iconColor: Colors.black87,
        badge: notesBadge,
        onOpen: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(builder: (_) => const NotesView()),
        ),
      ),
      _AppEntry(
        label: 'Ustawienia',
        icon: Icons.settings,
        color: const Color(0xFF8E8E93),
        onOpen: (ctx) => Navigator.of(ctx).push(
          MaterialPageRoute(builder: (_) => const SettingsView()),
        ),
      ),
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ---- Wallpaper ----
          // Place your home wallpaper at: assets/images/home_wallpaper.jpg
          Image.asset(
            'assets/images/home_wallpaper.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1C1C1E), Color(0xFF000000)],
                ),
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.25)),

          SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(child: StatusBar()),
                    // Lock button so we can return to the lock screen
                    // during playtests.
                    IconButton(
                      onPressed: () => context.read<PhoneState>().lock(),
                      icon: const Icon(Icons.lock_outline,
                          color: Colors.white70),
                      tooltip: 'Zablokuj',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 28,
                      crossAxisSpacing: 28,
                      childAspectRatio: 0.85,
                      children: [
                        for (final app in apps)
                          _AppIcon(
                            entry: app,
                            onTap: () {
                              if (app.onOpen != null) {
                                app.onOpen!(context);
                              } else {
                                _showComingSoon(context, app.label);
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                // Home indicator bar, like modern phones.
                Container(
                  margin: const EdgeInsets.only(bottom: 8, top: 4),
                  width: 130,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label - wkrótce'),
          duration: const Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _AppEntry {
  const _AppEntry({
    required this.label,
    required this.icon,
    required this.color,
    this.iconColor = Colors.white,
    this.badge = 0,
    this.onOpen,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final int badge;
  final void Function(BuildContext context)? onOpen;
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.entry, required this.onTap});

  final _AppEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: entry.color,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(entry.icon, color: entry.iconColor, size: 36),
              ),
              if (entry.badge > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 22, minHeight: 22),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.white, width: 1.4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${entry.badge}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              shadows: [
                Shadow(blurRadius: 4, color: Colors.black54),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
