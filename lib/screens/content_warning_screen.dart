import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_extensions.dart';
import '../state/settings_state.dart';

/// First-launch screen that:
/// - shows a content warning about the game's themes,
/// - explains the optional location-based stalker mechanic,
/// - lets the player opt in (or out) of using their real location.
///
/// Both decisions are recorded in [SettingsState] (`contentWarningShown`)
/// and [LocationService] (`isOptedIn`). Subsequent launches skip this
/// screen unless the player resets via "factory reset" (not exposed in
/// v1.0).
class ContentWarningScreen extends StatefulWidget {
  const ContentWarningScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  State<ContentWarningScreen> createState() => _ContentWarningScreenState();
}

class _ContentWarningScreenState extends State<ContentWarningScreen> {
  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.shield_moon_outlined,
                  color: Color(0xFFFF9F0A), size: 36),
              const SizedBox(height: 12),
              Text(
                t.contentWarningTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Section(
                        icon: Icons.warning_amber,
                        title: t.contentWarningSectionThemesTitle,
                        body: t.contentWarningSectionThemesBody,
                      ),
                      _Section(
                        icon: Icons.flash_off,
                        title: t.contentWarningSectionVisualsTitle,
                        body: t.contentWarningSectionVisualsBody,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    final settings = context.read<SettingsState>();
                    settings.setContentWarningShown(true);
                    settings.setReducedMotion(false);
                    widget.onContinue();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF0A84FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    t.contentWarningContinue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.body,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 12),
            child: Icon(icon, color: Colors.white54, size: 22),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
