import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/new_game_plus_state.dart';
import '../services/iap_service.dart';

/// Boot-time choice between starting a fresh run and continuing in
/// New Game+ mode. Only shown when [NewGamePlusState.canStartPlus]
/// is true AND the current run hasn't begun yet (no unlocked phone).
///
/// Mounting policy: shown ONCE per app launch by the phone shell.
/// User picks one branch and we hand off to the regular Intro/Boot.
class NewGamePlusChoiceScreen extends StatelessWidget {
  const NewGamePlusChoiceScreen({
    super.key,
    required this.onContinueRegular,
    required this.onContinuePlus,
  });

  /// Called when the player picks "Nowa gra" (regular run).
  final VoidCallback onContinueRegular;

  /// Called when the player picks "Kontynuuj NG+".
  final VoidCallback onContinuePlus;

  @override
  Widget build(BuildContext context) {
    final ngp = context.read<NewGamePlusState>();
    final iap = context.watch<IapService>();
    final lastEnding = ngp.previousEndings.isNotEmpty
        ? ngp.previousEndings.last
        : null;

    final canAccessNGP = iap.isFullGamePurchased;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Telefon znów dzwoni',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ngp.runCount == 1
                    ? 'Tym razem wiesz już więcej.'
                    : 'Już ${ngp.runCount} raz to widziałeś.',
                style: const TextStyle(
                    color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 32),
              if (lastEnding != null) _LastEndingChip(endingId: lastEnding),
              const SizedBox(height: 48),
              _ChoiceCard(
                title: 'Kontynuuj NG+',
                body: canAccessNGP
                    ? 'Pamiętasz coś z poprzedniego razu. Nieznany też. Niektóre dialogi będą inne.'
                    : 'Wymaga pełnej wersji gry. Kontynuuj narrację z zachowaniem wspomnień.',
                accent: canAccessNGP ? const Color(0xFFFFCC00) : Colors.white24,
                isLocked: !canAccessNGP,
                onTap: () {
                  if (canAccessNGP) {
                    HapticFeedback.lightImpact();
                    context.read<NewGamePlusState>().enterPlusRun();
                    onContinuePlus();
                  } else {
                    HapticFeedback.heavyImpact();
                    iap.buyFullGame();
                  }
                },
              ),
              const SizedBox(height: 12),
              _ChoiceCard(
                title: 'Zacznij od nowa',
                body: 'Świeży run, bez wspomnień. Zwykła rozgrywka.',
                accent: const Color(0xFF8E8E93),
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.read<NewGamePlusState>().leavePlusRun();
                  onContinueRegular();
                },
              ),
              const SizedBox(height: 24),
              if (!canAccessNGP)
                Center(
                  child: TextButton(
                    onPressed: () => iap.restorePurchases(),
                    child: const Text(
                      'Przywróć zakupy',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
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

class _LastEndingChip extends StatelessWidget {
  const _LastEndingChip({required this.endingId});
  final String endingId;

  @override
  Widget build(BuildContext context) {
    final label = _humanLabel(endingId);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, color: Colors.white38, size: 14),
          const SizedBox(width: 8),
          Text(
            'Ostatnie zakończenie: $label',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  static String _humanLabel(String id) => switch (id) {
        'caught' => 'ZŁAPANY',
        'escape' => 'UCIECZKA',
        'truth' => 'PRAWDA',
        'dawn' => 'ŚWIT',
        'corruption' => 'KORUPCJA',
        'solitude' => 'SAMOTNIA',
        'cycle' => 'CYKL',
        _ => id,
      };
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.body,
    required this.accent,
    required this.onTap,
    this.isLocked = false,
  });

  final String title;
  final String body;
  final Color accent;
  final VoidCallback onTap;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: accent,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: TextStyle(
                      color: isLocked ? Colors.white38 : Colors.white,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              const Icon(Icons.lock_outline, color: Colors.white24, size: 24),
          ],
        ),
      ),
    );
  }
}
