import 'package:flutter/foundation.dart';

import '../services/persistence_service.dart';

/// Game chapters. Chapter 1 is the starting state (evening). Chapter 2
/// fires after the player has dug deep enough into the evidence — it
/// represents a time skip to dawn with a new wave of content.
enum Chapter { one, two }

/// Tracks the current chapter and emits a one-shot transition signal so
/// the shell can play a "8 godzin później" overlay.
class ChapterState extends ChangeNotifier {
  ChapterState({PersistenceService? persistence}) : _persistence = persistence {
    _load();
  }

  static const String _kChapter = 'chapter.current';

  final PersistenceService? _persistence;

  Chapter _current = Chapter.one;
  Chapter get current => _current;

  /// True for one frame after chapter advances, then cleared by the
  /// shell. Used to trigger the time-skip overlay animation.
  bool _shouldAnimateTransition = false;
  bool get shouldAnimateTransition => _shouldAnimateTransition;

  bool get isChapter2 => _current == Chapter.two;

  void _load() {
    final p = _persistence;
    if (p == null) return;
    final saved = p.getStringList(_kChapter);
    if (saved.isNotEmpty && saved.first == 'two') {
      _current = Chapter.two;
    }
  }

  /// Advance to chapter 2. Idempotent. Triggers the transition animation
  /// only on the first call (not on cold-load).
  void advanceToChapter2({bool fromColdLoad = false}) {
    if (_current == Chapter.two) return;
    _current = Chapter.two;
    _persistence?.setStringList(_kChapter, ['two']);
    if (!fromColdLoad) _shouldAnimateTransition = true;
    notifyListeners();
  }

  /// Called by the shell after the transition overlay finishes playing.
  void clearTransitionFlag() {
    if (!_shouldAnimateTransition) return;
    _shouldAnimateTransition = false;
    notifyListeners();
  }

  void reset() {
    _current = Chapter.one;
    _shouldAnimateTransition = false;
    notifyListeners();
  }
}
