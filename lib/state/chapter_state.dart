import 'package:flutter/foundation.dart';

import '../services/persistence_service.dart';

/// Game chapters.
///
/// - **Chapter 1** is the starting state — Friday evening, shortly after
///   N. went missing. Player has full access to the phone.
/// - **Chapter 2** ("Świt") fires after enough evidence is collected
///   in the Files app. Time-skip overlay "8 godzin później" plays once.
/// - **Chapter 3** ("Po świcie") only opens up in NG+ runs after the
///   player has reached either TRUTH or DAWN. Adds the prosecutor
///   thread, a redacted Signal puzzle, and 2 fresh endings (ŚWIADEK,
///   CIEŃ).
enum Chapter { one, two, three }

/// Tracks the current chapter and emits a one-shot transition signal so
/// the shell can play a chapter-transition overlay.
class ChapterState extends ChangeNotifier {
  ChapterState({PersistenceService? persistence}) : _persistence = persistence {
    _load();
  }

  static const String _kChapter = 'game.chapter.current';

  final PersistenceService? _persistence;

  Chapter _current = Chapter.one;
  Chapter get current => _current;

  /// True for one frame after chapter advances, then cleared by the
  /// shell. Used to trigger the time-skip overlay animation.
  bool _shouldAnimateTransition = false;
  bool get shouldAnimateTransition => _shouldAnimateTransition;

  bool get isChapter2 => _current == Chapter.two;
  bool get isChapter3 => _current == Chapter.three;

  void _load() {
    final p = _persistence;
    if (p == null) return;
    final saved = p.getStringList(_kChapter);
    if (saved.isEmpty) return;
    switch (saved.first) {
      case 'two':
        _current = Chapter.two;
      case 'three':
        _current = Chapter.three;
    }
  }

  /// Advance to chapter 2. Idempotent. Triggers the transition animation
  /// only on the first call (not on cold-load).
  void advanceToChapter2({bool fromColdLoad = false}) {
    if (_current.index >= Chapter.two.index) return;
    _current = Chapter.two;
    _persistence?.setStringList(_kChapter, ['two']);
    if (!fromColdLoad) _shouldAnimateTransition = true;
    notifyListeners();
  }

  /// Advance to chapter 3 ("Po świcie"). Only valid path is from
  /// chapter 2 — calling earlier is rejected. Triggers the transition
  /// animation only on the first call.
  void advanceToChapter3({bool fromColdLoad = false}) {
    if (_current.index >= Chapter.three.index) return;
    if (_current != Chapter.two) return;
    _current = Chapter.three;
    _persistence?.setStringList(_kChapter, ['three']);
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
