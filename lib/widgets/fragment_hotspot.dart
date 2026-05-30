import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../state/email_state.dart';

/// Subtle interactive hotspot for the "recover deleted email"
/// puzzle. Wraps any child widget; first long-press recovers the
/// fragment and plays a short visual + audio confirmation.
///
/// We use long-press (not tap) so the hotspot doesn't accidentally
/// fire on regular content interaction. Once recovered the hotspot
/// becomes a no-op pass-through — the child renders normally.
class FragmentHotspot extends StatelessWidget {
  const FragmentHotspot({
    super.key,
    required this.fragmentId,
    required this.child,
  });

  final String fragmentId;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final email = context.watch<EmailState>();
    final recovered = email.isRecovered(fragmentId);
    if (recovered) return child;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        if (email.recover(fragmentId)) {
          HapticFeedback.heavyImpact();
          AudioService.instance.playSfx(GameSfx.unlockSuccess);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.restore_from_trash,
                        color: Color(0xFFFFCC00), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fragment wiadomości odzyskany. Sprawdź Pocztę.',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF1C1C1E),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                elevation: 0,
              ),
            );
        }
      },
      child: child,
    );
  }
}
