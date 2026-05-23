import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/notes_state.dart';
import '../../state/photos_state.dart';
import '../../widgets/numeric_keypad.dart';
import '../../widgets/status_bar.dart';

/// Notes app entry point. List of notes -> tap -> either reader or
/// (for the locked note) a PIN keypad overlay -> reader.
class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotesState>();

    final pulse = context
            .select<PhotosState, bool>((s) => s.hasInspected('forest_night')) &&
        notes.notes.any((n) => n.isLocked);

    return Scaffold(
      backgroundColor: const Color(0xFFFFCC00).withValues(alpha: 0.04),
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
                        color: Color(0xFFFFCC00), size: 22),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Notatki',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Nie można edytować — telefon zablokowany'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                    },
                    child: const Icon(Icons.create_outlined,
                        color: Color(0xFFFFCC00), size: 24),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: notes.notes.length,
                separatorBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Divider(height: 1, color: Color(0xFF1C1C1E)),
                ),
                itemBuilder: (context, i) {
                  final note = notes.notes[i];
                  return _NoteTile(
                    note: note,
                    pulseLocked: pulse && note.isLocked,
                    onTap: () => _openNote(context, note),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openNote(BuildContext context, NoteItem note) async {
    if (note.isLocked) {
      final ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => _NoteUnlockScreen(noteId: note.id),
        ),
      );
      if (ok != true || !context.mounted) return;
    }
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _NoteReaderScreen(noteId: note.id),
      ),
    );
  }
}

// ---------------- Note tile ----------------

class _NoteTile extends StatelessWidget {
  const _NoteTile({
    required this.note,
    required this.onTap,
    required this.pulseLocked,
  });

  final NoteItem note;
  final VoidCallback onTap;
  final bool pulseLocked;

  @override
  Widget build(BuildContext context) {
    final preview = note.isLocked
        ? 'Notatka zablokowana'
        : note.body.split('\n').take(2).join(' ').trim();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: pulseLocked
              ? const Color(0xFFFFCC00).withValues(alpha: 0.06)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            if (note.isLocked)
              _PulsingLockIcon(active: pulseLocked)
            else
              const SizedBox(width: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                          note.isLocked ? FontWeight.w700 : FontWeight.w600,
                      letterSpacing: note.isLocked ? 0.3 : 0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        note.dateString,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }
}

class _PulsingLockIcon extends StatefulWidget {
  const _PulsingLockIcon({required this.active});
  final bool active;

  @override
  State<_PulsingLockIcon> createState() => _PulsingLockIconState();
}

class _PulsingLockIconState extends State<_PulsingLockIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.active) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PulsingLockIcon old) {
    super.didUpdateWidget(old);
    if (widget.active && !_ctrl.isAnimating) _ctrl.repeat(reverse: true);
    if (!widget.active && _ctrl.isAnimating) _ctrl.stop();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = widget.active ? _ctrl.value : 0.0;
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFCC00).withValues(alpha: 0.15 + 0.25 * t),
            border: Border.all(
              color: const Color(0xFFFFCC00).withValues(alpha: 0.5 + 0.5 * t),
              width: 1.4,
            ),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.lock, color: Color(0xFFFFCC00), size: 16),
        );
      },
    );
  }
}

// ---------------- Unlock keypad ----------------

class _NoteUnlockScreen extends StatelessWidget {
  const _NoteUnlockScreen({required this.noteId});
  final String noteId;

  @override
  Widget build(BuildContext context) {
    // Soft-gate visual cue: halo pulses if the EXIF clue has been seen.
    final pulseHalo = context
        .select<PhotosState, bool>((s) => s.hasInspected('forest_night'));

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close,
                        color: Color(0xFFFFCC00), size: 26),
                  ),
                  const Spacer(),
                  const Text(
                    'Zablokowana notatka',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: NumericKeypad(
                  icon: Icons.lock,
                  title: 'Wprowadź hasło',
                  subtitle:
                      'Aby otworzyć tę notatkę, wpisz 4-cyfrowy kod.',
                  pulseHalo: pulseHalo,
                  onSubmit: (pin) async {
                    final ok = context.read<NotesState>().tryUnlock(noteId, pin);
                    if (ok) {
                      // Pop *after* the keypad's local state settles.
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) Navigator.of(context).pop(true);
                      });
                    }
                    return ok;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Reader ----------------

class _NoteReaderScreen extends StatelessWidget {
  const _NoteReaderScreen({required this.noteId});
  final String noteId;

  @override
  Widget build(BuildContext context) {
    final note = context.watch<NotesState>().noteById(noteId);
    if (note == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('Brak notatki', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFFFFCC00), size: 22),
                  ),
                  const Spacer(),
                  const Icon(Icons.ios_share,
                      color: Color(0xFFFFCC00), size: 22),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note.dateString,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    _FormattedNoteBody(body: note.body),
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

/// Renders note body with highlighted keywords for dramatic effect.
/// Lines in ALL CAPS or containing key phrases get accent coloring.
class _FormattedNoteBody extends StatelessWidget {
  const _FormattedNoteBody({required this.body});
  final String body;

  static final _highlightPatterns = [
    'NIE UFAJ',
    'HELION-BUD',
    'HELION-Bud',
    'Helion-Bud',
    'komendant',
    'Komendant',
    'szeryf',
    'Szeryf',
    'szeryfowi',
    'NIE PRZEKAZUJ',
    'CENTRALNA',
    'centralną',
    'skrytce 14B',
    'fikus',
    '7309',
    '1422',
    '14:22',
    'Anita',
    'Anity Z.',
    'drzewo, które padło na dachu',
  ];

  @override
  Widget build(BuildContext context) {
    final lines = body.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: _buildLine(line),
          ),
      ],
    );
  }

  Widget _buildLine(String line) {
    if (line.trim().isEmpty) return const SizedBox(height: 12);

    // Full-line ALL CAPS → red accent (warnings).
    final trimmed = line.trim();
    if (trimmed == trimmed.toUpperCase() &&
        trimmed.length > 3 &&
        RegExp(r'[A-ZĄĆĘŁŃÓŚŹŻ]').hasMatch(trimmed)) {
      return Text(
        line,
        style: const TextStyle(
          color: Color(0xFFFF6B6B),
          fontSize: 15,
          height: 1.5,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    // Build a RichText with highlighted keywords.
    final spans = <TextSpan>[];
    var remaining = line;

    while (remaining.isNotEmpty) {
      int? earliestIdx;
      String? matchedPattern;

      for (final pattern in _highlightPatterns) {
        final idx = remaining.indexOf(pattern);
        if (idx != -1 && (earliestIdx == null || idx < earliestIdx)) {
          earliestIdx = idx;
          matchedPattern = pattern;
        }
      }

      if (earliestIdx == null || matchedPattern == null) {
        spans.add(TextSpan(text: remaining));
        break;
      }

      if (earliestIdx > 0) {
        spans.add(TextSpan(text: remaining.substring(0, earliestIdx)));
      }
      spans.add(TextSpan(
        text: matchedPattern,
        style: const TextStyle(
          color: Color(0xFFFFCC00),
          fontWeight: FontWeight.w600,
        ),
      ));
      remaining = remaining.substring(earliestIdx + matchedPattern.length);
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.5,
        ),
        children: spans,
      ),
    );
  }
}
