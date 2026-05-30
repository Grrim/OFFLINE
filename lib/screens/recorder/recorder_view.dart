import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/audio_service.dart';
import '../../state/recorder_state.dart';
import '../../widgets/status_bar.dart';

/// Voice recorder app — list of N.'s recordings. Tapping opens a
/// player + transcript reader. Three of them carry the voice-match puzzle.
class RecorderView extends StatelessWidget {
  const RecorderView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RecorderState>();
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
                        color: Color(0xFFFF453A), size: 22),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Dyktafon',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (state.hasCorrectMatches)
                    const Icon(Icons.verified,
                        color: Color(0xFF34C759), size: 22)
                  else
                    Text(
                      '${state.correctCount}/3 dopasowań',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final r in state.recordings)
                    _RecordingTile(recording: r),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordingTile extends StatelessWidget {
  const _RecordingTile({required this.recording});
  final GameRecording recording;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RecorderState>();
    final hasVoicePuzzle = recording.voiceContactId != null;
    final assigned = state.assignmentFor(recording.id);

    return InkWell(
      onTap: () {
        state.markListened(recording.id);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _TranscriptScreen(recording: recording),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: recording.isImportant
              ? const Color(0xFFFF453A).withValues(alpha: 0.06)
              : const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          border: recording.isImportant
              ? Border.all(
                  color: const Color(0xFFFF453A).withValues(alpha: 0.3))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF453A).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.mic,
                      color: Color(0xFFFF453A), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recording.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 2),
                      Text('${recording.date} · ${recording.duration}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12)),
                      Text(recording.location,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
                if (!state.hasListened(recording.id))
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0A84FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                const Icon(Icons.play_arrow,
                    color: Colors.white38, size: 22),
              ],
            ),
            if (hasVoicePuzzle && state.hasListened(recording.id)) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFF2C2C2E)),
              const SizedBox(height: 10),
              _VoiceMatchPicker(recording: recording, assigned: assigned),
            ],
          ],
        ),
      ),
    );
  }
}

class _VoiceMatchPicker extends StatelessWidget {
  const _VoiceMatchPicker({
    required this.recording,
    required this.assigned,
  });

  final GameRecording recording;
  final String? assigned;

  @override
  Widget build(BuildContext context) {
    final state = context.read<RecorderState>();
    final isCorrect =
        assigned != null && assigned == recording.voiceContactId;
    final isWrong = assigned != null && !isCorrect;
    final pickedId = assigned;
    final pickedLabel = pickedId == null
        ? null
        : (RecorderState.voiceContactCandidates[pickedId] ?? pickedId);

    return Row(
      children: [
        const Icon(Icons.record_voice_over,
            color: Colors.white54, size: 16),
        const SizedBox(width: 6),
        const Text(
          'Czyj to głos?',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final pick = await _showContactPicker(context, assigned);
              if (pick == null || !context.mounted) return;
              if (pick == '__clear__') {
                state.clearAssignment(recording.id);
              } else {
                HapticFeedback.lightImpact();
                state.assignVoice(recording.id, pick);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isCorrect
                    ? const Color(0xFF34C759).withValues(alpha: 0.15)
                    : isWrong
                        ? const Color(0xFFFF9500).withValues(alpha: 0.12)
                        : const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCorrect
                      ? const Color(0xFF34C759).withValues(alpha: 0.45)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      pickedLabel ?? 'Wybierz kontakt',
                      style: TextStyle(
                        color: pickedLabel == null
                            ? Colors.white54
                            : Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    const Icon(Icons.check_circle,
                        color: Color(0xFF34C759), size: 16)
                  else
                    const Icon(Icons.expand_more,
                        color: Colors.white54, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<String?> _showContactPicker(
      BuildContext context, String? current) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => SafeArea(
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'Kogo słyszysz na nagraniu?',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              ),
              for (final entry in RecorderState.voiceContactCandidates.entries)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  title: Text(entry.value,
                      style: const TextStyle(color: Colors.white, fontSize: 16)),
                  trailing: current == entry.key
                      ? const Icon(Icons.check,
                          color: Color(0xFF0A84FF), size: 24)
                      : null,
                  onTap: () => Navigator.of(ctx).pop(entry.key),
                ),
              if (current != null) ...[
                const Divider(color: Colors.white10),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.close, color: Colors.white54),
                  title: const Text('Wyczyść wybór',
                      style: TextStyle(color: Colors.white54, fontSize: 15)),
                  onTap: () => Navigator.of(ctx).pop('__clear__'),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TranscriptScreen extends StatefulWidget {
  const _TranscriptScreen({required this.recording});
  final GameRecording recording;

  @override
  State<_TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<_TranscriptScreen> {
  bool _isPlaying = false;

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      AudioService.instance.playSfx(GameSfx.uiClick);
      // In v1.0, real voice assets will be linked here.
      // For now, we simulate "playback" with a snackbar.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('Odtwarzanie: ${widget.recording.title}...'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        color: Color(0xFFFF453A), size: 22),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(widget.recording.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            )),
                        Text(
                          '${widget.recording.date} · ${widget.recording.duration}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            // Playback controls.
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10, color: Colors.white70),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF453A),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.forward_10, color: Colors.white70),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: LinearProgressIndicator(
                      value: 0.0,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation(Color(0xFFFF453A)),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF1C1C1E)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TRANSKRYPCJA AUTOMATYCZNA',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.recording.transcript,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
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
