import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable iOS-style numeric PIN keypad.
///
/// Stateless from the caller's perspective: you supply a [title], optional
/// [subtitle] and [icon], a [pinLength], a [pulseHalo] flag for soft-gate
/// hints, and either:
/// - [correctPin] + [onSuccess] for a fully-self-contained check, or
/// - [onSubmit] for a callback-based check (e.g. validating against a state
///   notifier). [onSubmit] should return `true` on success.
///
/// The widget animates the entry dots, shakes on a wrong PIN, optionally
/// glows yellow when [pulseHalo] is true, and clears the buffer between
/// failed attempts. It does not push or pop routes - that stays the
/// caller's responsibility.
class NumericKeypad extends StatefulWidget {
  const NumericKeypad({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.errorMessage = 'Nieprawidłowy kod',
    this.pinLength = 4,
    this.pulseHalo = false,
    this.haloColor = const Color(0xFFFFCC00),
    this.correctPin,
    this.onSuccess,
    this.onSubmit,
    this.bottomLeftButton,
    this.onBottomLeftTap,
  })  : assert(
          (correctPin != null && onSuccess != null) || onSubmit != null,
          'Provide either (correctPin + onSuccess) or onSubmit.',
        );

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String errorMessage;
  final int pinLength;
  final bool pulseHalo;
  final Color haloColor;

  /// Self-contained mode: validate locally against [correctPin] and call
  /// [onSuccess] on match.
  final String? correctPin;
  final VoidCallback? onSuccess;

  /// Callback mode: forward the entered pin to a notifier and use the
  /// returned bool to decide success/failure. Async-friendly.
  final Future<bool> Function(String pin)? onSubmit;

  /// Optional caption for the bottom-left key (the slot that's empty on
  /// real phones). Useful for things like "Anuluj" or "Awaryjne".
  final String? bottomLeftButton;
  final VoidCallback? onBottomLeftTap;

  @override
  State<NumericKeypad> createState() => _NumericKeypadState();
}

class _NumericKeypadState extends State<NumericKeypad>
    with TickerProviderStateMixin {
  String _pin = '';
  String? _error;
  bool _busy = false;

  late final AnimationController _shakeCtrl;
  late final AnimationController _haloCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _haloCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.pulseHalo) _haloCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant NumericKeypad old) {
    super.didUpdateWidget(old);
    if (widget.pulseHalo && !_haloCtrl.isAnimating) {
      _haloCtrl.repeat(reverse: true);
    } else if (!widget.pulseHalo && _haloCtrl.isAnimating) {
      _haloCtrl.stop();
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _haloCtrl.dispose();
    super.dispose();
  }

  void _digit(String d) {
    if (_busy || _pin.length >= widget.pinLength) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length == widget.pinLength) {
      Future.delayed(const Duration(milliseconds: 140), _submit);
    }
  }

  void _backspace() {
    if (_busy || _pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    setState(() => _busy = true);

    bool ok;
    if (widget.onSubmit != null) {
      ok = await widget.onSubmit!(_pin);
    } else {
      ok = _pin == widget.correctPin;
      if (ok) widget.onSuccess?.call();
    }

    if (!mounted) return;

    if (ok) {
      // Caller will likely navigate away on success.
      setState(() => _busy = false);
    } else {
      HapticFeedback.heavyImpact();
      _shakeCtrl.forward(from: 0);
      setState(() => _error = widget.errorMessage);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        _pin = '';
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, color: widget.haloColor, size: 56),
          const SizedBox(height: 16),
        ],
        Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              widget.subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ),
        ],
        const SizedBox(height: 28),
        AnimatedBuilder(
          animation: Listenable.merge([_shakeCtrl, _haloCtrl]),
          builder: (context, child) {
            final dx = _shakeCtrl.isAnimating
                ? (8 *
                    (1 - _shakeCtrl.value) *
                    ((_shakeCtrl.value * 8).floor().isEven ? 1 : -1))
                : 0.0;
            final glow = _haloCtrl.isAnimating ? _haloCtrl.value : 0.0;
            return Transform.translate(
              offset: Offset(dx, 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: glow > 0
                      ? [
                          BoxShadow(
                            color: widget.haloColor
                                .withValues(alpha: 0.25 + 0.35 * glow),
                            blurRadius: 16 + 16 * glow,
                            spreadRadius: 1,
                          ),
                        ]
                      : const [],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: child,
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.pinLength, (i) {
              final filled = i < _pin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.4),
                  color: filled ? Colors.white : Colors.transparent,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 18,
          child: AnimatedOpacity(
            opacity: _error == null ? 0 : 1,
            duration: const Duration(milliseconds: 150),
            child: Text(
              _error ?? '',
              style: const TextStyle(
                  color: Color(0xFFFF6B6B), fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _Grid(
          onDigit: _digit,
          onBackspace: _backspace,
          canBackspace: _pin.isNotEmpty,
          bottomLeftLabel: widget.bottomLeftButton,
          onBottomLeftTap: widget.onBottomLeftTap,
        ),
      ],
    );
  }
}

// ---------------- 3x4 keypad grid ----------------

class _Grid extends StatelessWidget {
  const _Grid({
    required this.onDigit,
    required this.onBackspace,
    required this.canBackspace,
    this.bottomLeftLabel,
    this.onBottomLeftTap,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final bool canBackspace;
  final String? bottomLeftLabel;
  final VoidCallback? onBottomLeftTap;

  @override
  Widget build(BuildContext context) {
    final letters = {
      '1': '',
      '2': 'ABC',
      '3': 'DEF',
      '4': 'GHI',
      '5': 'JKL',
      '6': 'MNO',
      '7': 'PQRS',
      '8': 'TUV',
      '9': 'WXYZ',
      '0': '',
    };
    final digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          for (var row = 0; row < 3; row++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var col = 0; col < 3; col++)
                    _Key.digit(
                      digit: digits[row * 3 + col],
                      letters: letters[digits[row * 3 + col]] ?? '',
                      onTap: () => onDigit(digits[row * 3 + col]),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (bottomLeftLabel != null && onBottomLeftTap != null)
                  _Key.text(label: bottomLeftLabel!, onTap: onBottomLeftTap!)
                else
                  const SizedBox(width: 72, height: 72),
                _Key.digit(digit: '0', letters: '', onTap: () => onDigit('0')),
                _Key.icon(
                  icon: Icons.backspace_outlined,
                  onTap: canBackspace ? onBackspace : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Key extends StatefulWidget {
  const _Key.digit({
    required String this.digit,
    required this.letters,
    required this.onTap,
  })  : icon = null,
        textLabel = null,
        transparent = false;
  const _Key.icon({required this.icon, required this.onTap})
      : digit = null,
        letters = '',
        textLabel = null,
        transparent = true;
  const _Key.text({required String this.textLabel, required this.onTap})
      : digit = null,
        letters = '',
        icon = null,
        transparent = true;

  final String? digit;
  final String letters;
  final IconData? icon;
  final String? textLabel;
  final VoidCallback? onTap;
  final bool transparent;

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    final base = widget.transparent
        ? Colors.transparent
        : Colors.white.withValues(alpha: 0.15);
    final pressed = widget.transparent
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.30);

    Widget content;
    if (widget.icon != null) {
      content = Icon(widget.icon, color: Colors.white, size: 24);
    } else if (widget.textLabel != null) {
      content = Text(
        widget.textLabel!,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      );
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.digit!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (widget.letters.isNotEmpty)
            Text(
              widget.letters,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                letterSpacing: 1.6,
              ),
            ),
        ],
      );
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: disabled ? Colors.transparent : (_pressed ? pressed : base),
          border: widget.transparent
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        alignment: Alignment.center,
        child: Opacity(
          opacity: disabled ? 0.4 : 1,
          child: content,
        ),
      ),
    );
  }
}
