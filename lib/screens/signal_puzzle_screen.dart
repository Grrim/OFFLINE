import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/signal_puzzle_state.dart';
import '../widgets/status_bar.dart';

/// Chapter 3 mini-puzzle screen — Signal handshake.
///
/// The player decodes a password from existing in-game clues
/// ("koperta" + 14:22 timestamp). Three or more failed attempts
/// surface a soft hint. UI mimics a Signal sign-in screen.
class SignalPuzzleScreen extends StatefulWidget {
  const SignalPuzzleScreen({super.key});

  @override
  State<SignalPuzzleScreen> createState() => _SignalPuzzleScreenState();
}

class _SignalPuzzleScreenState extends State<SignalPuzzleScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final state = context.read<SignalPuzzleState>();
    final ok = state.tryDecode(_controller.text);
    if (ok) {
      HapticFeedback.lightImpact();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      setState(() {
        _error = state.failedAttempts >= 3
            ? 'Trzy próby. Pomyśl o kopercie + godzinie z pierwszego nagrania.'
            : 'Nieprawidłowe hasło.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDecoded =
        context.select<SignalPuzzleState, bool>((s) => s.isDecoded);
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
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
                        color: Color(0xFF3A76F0), size: 22),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Signal',
                    style: TextStyle(
                      color: Color(0xFF3A76F0),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A76F0)
                              .withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outlined,
                          color: Color(0xFF3A76F0),
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Bezpieczny kanał',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isDecoded
                          ? 'Kanał odblokowany. Materiały N. są '
                              'dostępne dla prokuratora.'
                          : 'Wprowadź hasło, które N. uzgodniła z '
                              'prokuratorem R. — to słowo z notatek '
                              'oraz godzina pierwszego nagrania.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (!isDecoded) ...[
                      TextField(
                        controller: _controller,
                        autofocus: true,
                        obscureText: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 1.2),
                        decoration: InputDecoration(
                          hintText: 'Hasło',
                          hintStyle:
                              const TextStyle(color: Colors.white38),
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF1F2937)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF3A76F0)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          errorText: _error,
                          errorStyle: const TextStyle(
                              color: Color(0xFFFF7060), fontSize: 12),
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _submit,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF3A76F0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Połącz',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      const Center(
                        child: Icon(Icons.verified,
                            color: Color(0xFF34C759), size: 60),
                      ),
                    ],
                    const SizedBox(height: 24),
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
