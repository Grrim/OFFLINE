import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/l10n_service.dart';
import '../state/browser_state.dart';
import '../state/chapter_state.dart';
import '../state/evidence_state.dart';
import '../state/files_state.dart';
import '../state/flags_state.dart';
import '../state/notes_state.dart';
import '../state/photos_state.dart';
import '../state/trust_state.dart';

/// "Co się dotąd wydarzyło" — shown on resume after >24h away.
/// Builds a brief recap from the current state so the player doesn't
/// feel dropped mid-mystery.
class WelcomeBackOverlay extends StatelessWidget {
  const WelcomeBackOverlay({
    super.key,
    required this.onContinue,
  });

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = L10nService.instance.dialogues['recap'] ?? {};
    final lines = _buildRecap(context, l10n);

    return Material(
      color: Colors.black.withValues(alpha: 0.95),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                l10n['title_sub'] ?? 'Back after a break',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n['title_main'] ?? 'What\'s happened so far',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: lines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4, right: 10),
                        child: Icon(Icons.fiber_manual_record,
                            size: 8, color: Color(0xFF0A84FF)),
                      ),
                      Expanded(
                        child: Text(
                          lines[i],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onContinue,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF0A84FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    l10n['continue'] ?? 'Continue',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _buildRecap(BuildContext context, Map<String, dynamic> l10n) {
    final notes = context.read<NotesState>();
    final photos = context.read<PhotosState>();
    final files = context.read<FilesState>();
    final browser = context.read<BrowserState>();
    final trust = context.read<TrustState>();
    final evidence = context.read<EvidenceState>();
    final flags = context.read<FlagsState>();
    final chapter = context.read<ChapterState>();

    final lines = <String>[];

    // Helper for parameter replacement
    String p(String? text, Map<String, dynamic> params) {
      if (text == null) return '';
      String result = text;
      params.forEach((key, value) {
        result = result.replaceAll('{$key}', value.toString());
      });
      return result;
    }

    // Chapter
    if (chapter.isChapter3) {
      lines.add(l10n['chapter3'] ?? 'Chapter 3 underway.');
    } else if (chapter.isChapter2) {
      lines.add(l10n['chapter2'] ?? 'You are in Chapter 2.');
    } else {
      lines.add(l10n['chapter1'] ?? 'Chapter 1 underway.');
    }

    // Notes
    if (notes.hasUnlockedSecret) {
      lines.add(l10n['notes_secret'] ?? 'Unlocked N.\'s secret note.');
    }
    final planB = notes.noteById('plan_b');
    if (planB != null && !planB.isLocked) {
      lines.add(l10n['notes_plan_b'] ?? 'Unlocked Plan B note.');
    }

    // Files
    if (files.openedCount > 0) {
      lines.add(p(l10n['files_progress'], {'count': files.openedCount, 'total': files.files.length}));
    }

    // Photos clues
    final clues = photos.photos
        .where((p) => p.isCluePhoto && photos.hasInspected(p.id))
        .length;
    if (clues > 0) {
      lines.add(p(l10n['photos_clues'], {'count': clues}));
    }

    // Evidence score
    if (evidence.score > 0) {
      lines.add(p(l10n['evidence_score'], {'score': evidence.score}));
    }

    // Browser private
    if (browser.isPrivateUnlocked) {
      lines.add(l10n['browser_private'] ?? 'Unlocked private browser mode.');
    }

    // Puzzles
    if (flags.isSet('puzzle.email_recovered')) {
      lines.add(l10n['puzzle_email'] ?? 'Recovered N.\'s deleted email.');
    }
    if (flags.isSet('puzzle.voices_matched')) {
      lines.add(l10n['puzzle_voices'] ?? 'Matched voices from recordings.');
    }
    if (flags.isSet('puzzle.route_reconstructed')) {
      lines.add(l10n['puzzle_route'] ?? 'Reconstructed N.\'s route.');
    }
    if (flags.isSet('puzzle.signal_decoded')) {
      lines.add(l10n['puzzle_signal'] ?? 'Decoded Signal password.');
    }

    // Trust highlights
    final tomaszT = trust.get('tomasz');
    final anitaT = trust.get('anita');
    final mamaT = trust.get('mama');
    if (tomaszT >= 30) {
      lines.add(l10n['trust_tomasz_high'] ?? 'Tomasz trusts you.');
    } else if (tomaszT <= -30) {
      lines.add(l10n['trust_tomasz_low'] ?? 'Tomasz rejected you.');
    }
    if (anitaT >= 30) {
      lines.add(l10n['trust_anita_high'] ?? 'Anita believes you.');
    }
    if (mamaT <= -30) {
      lines.add(l10n['trust_mama_low'] ?? 'Mom is mad at you.');
    }

    if (lines.isEmpty) {
      lines.add(l10n['empty'] ?? 'The game is just beginning.');
    }

    return lines;
  }
}
