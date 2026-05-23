import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../state/notifications_state.dart';

/// Slides system-style notification banners down from the top of the screen.
/// Mount it as the last child of a Stack at the root of the app so it
/// floats above everything else.
class NotificationBannerHost extends StatefulWidget {
  const NotificationBannerHost({super.key});

  @override
  State<NotificationBannerHost> createState() => _NotificationBannerHostState();
}

class _NotificationBannerHostState extends State<NotificationBannerHost> {
  String? _lastNotificationId;

  @override
  Widget build(BuildContext context) {
    final n = context.watch<NotificationsState>().current;

    // Trigger haptic and sound when a *new* notification slides in.
    if (n != null && n.id != _lastNotificationId) {
      _lastNotificationId = n.id;
      HapticFeedback.mediumImpact();
      AudioService.instance.playSfx(GameSfx.notification);
    }

    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      offset: n == null ? const Offset(0, -1.2) : Offset.zero,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: n == null ? 0 : 1,
        child: SafeArea(
          child: n == null
              ? const SizedBox.shrink()
              : _BannerCard(notification: n),
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.notification});
  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<NotificationsState>();

    // Sheriff notifications get a menacing red-tinted border.
    final isThreat = notification.title == 'Szeryf';
    final borderColor = isThreat
        ? const Color(0xFFFF453A).withValues(alpha: 0.4)
        : Colors.white.withValues(alpha: 0.08);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.up,
      onDismissed: (_) => notifier.dismiss(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              HapticFeedback.lightImpact();
              // Capture before dismiss because dismiss clears `current`.
              final cb = notification.onTap;
              notifier.dismiss();
              cb?.call();
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 14, 12),
              decoration: BoxDecoration(
                color: isThreat
                    ? const Color(0xFF1A0A0A).withValues(alpha: 0.95)
                    : const Color(0xFF1C1C1E).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: isThreat
                        ? const Color(0xFFFF0000).withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.5),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: notification.iconBg,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(notification.icon,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              notification.appName.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'teraz',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          notification.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          notification.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
