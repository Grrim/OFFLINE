import 'package:flutter/foundation.dart';

import '../services/persistence_service.dart';

/// One recording in N.'s dictaphone.
class GameRecording {
  const GameRecording({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    required this.location,
    required this.transcript,
    this.isImportant = false,
    this.voiceContactId,
  });

  final String id;
  final String title;
  final String date;
  final String duration;
  final String location;
  final String transcript;
  final bool isImportant;

  /// If non-null, this recording features a real-but-anonymous voice
  /// the player must match to a contact. Used by the voice-match puzzle.
  /// Value is the canonical contactId — see `voiceContactCandidates` for
  /// the multi-choice options shown in the UI.
  final String? voiceContactId;
}

/// Recorder app state with the voice-match mini-puzzle.
///
/// Three of the four recordings have an unknown voice. For each, the
/// player picks a contact id from a dropdown. Once all three are
/// assigned correctly, the puzzle is solved, evidence is awarded and a
/// flag is set.
class RecorderState extends ChangeNotifier {
  RecorderState({PersistenceService? persistence})
      : _persistence = persistence {
    _seed();
    _load();
  }

  static const String _kAssignments = 'game.recorder.voiceAssignments';
  static const String _kListened = 'game.recorder.listened';

  final PersistenceService? _persistence;
  final List<GameRecording> _recordings = [];

  /// Map of recording id → contact id chosen by the player.
  final Map<String, String> _voiceAssignments = {};

  /// Recordings the player has opened (= "listened to" in immersion).
  final Set<String> _listenedIds = {};

  /// Contacts available as voice-match candidates. Keys are stable
  /// contact ids that match the seed of `ContactsView`.
  static const Map<String, String> voiceContactCandidates = {
    'tomasz_b': 'Tomasz B. (HB)',
    'anita_z': 'Anita Z. (Gazeta)',
    'komendant_k': 'Komendant K. (Szeryf)',
    'mama': 'Mama',
    'kasia_it': 'Kasia (IT, praca)',
    'tata': 'Tata',
    'unknown': 'Nieznany',
  };

  List<GameRecording> get recordings => List.unmodifiable(_recordings);

  /// Recording the player has listened to (used for evidence + UI badge).
  bool hasListened(String id) => _listenedIds.contains(id);
  int get unreadCount =>
      _recordings.where((r) => !_listenedIds.contains(r.id)).length;

  /// Currently picked contact id for [recordingId], or null if no pick.
  String? assignmentFor(String recordingId) =>
      _voiceAssignments[recordingId];

  /// Mark a recording as opened (counts as "listened" for the
  /// immersion). Returns true on first listen.
  bool markListened(String id) {
    if (_listenedIds.add(id)) {
      _persistence?.setStringList(_kListened, _listenedIds.toList());
      notifyListeners();
      onFirstListened?.call(id);
      return true;
    }
    return false;
  }

  /// Wired by the shell. Called on first listen of a recording.
  void Function(String recordingId)? onFirstListened;

  /// Wired by the shell. Called once all three voice-match assignments
  /// are correct.
  void Function()? onVoicePuzzleSolved;

  bool _puzzleSolvedFired = false;

  /// Pick a contact for a recording's voice. Persists the choice.
  void assignVoice(String recordingId, String contactId) {
    final prev = _voiceAssignments[recordingId];
    if (prev == contactId) return;
    _voiceAssignments[recordingId] = contactId;
    _persistAssignments();
    notifyListeners();
    _maybeFirePuzzleSolved();
  }

  /// Clear an assignment.
  void clearAssignment(String recordingId) {
    if (_voiceAssignments.remove(recordingId) != null) {
      _persistAssignments();
      notifyListeners();
    }
  }

  /// True if all matched recordings have a non-null assignment.
  bool get isFullyMatched {
    for (final r in _recordings) {
      if (r.voiceContactId == null) continue;
      if (!_voiceAssignments.containsKey(r.id)) return false;
    }
    return true;
  }

  /// True if [isFullyMatched] AND every assignment is correct.
  bool get hasCorrectMatches {
    if (!isFullyMatched) return false;
    for (final r in _recordings) {
      final expected = r.voiceContactId;
      if (expected == null) continue;
      if (_voiceAssignments[r.id] != expected) return false;
    }
    return true;
  }

  /// Number of currently-correct assignments (0..3).
  int get correctCount {
    var n = 0;
    for (final r in _recordings) {
      final expected = r.voiceContactId;
      if (expected == null) continue;
      if (_voiceAssignments[r.id] == expected) n++;
    }
    return n;
  }

  void _maybeFirePuzzleSolved() {
    if (_puzzleSolvedFired) return;
    if (!hasCorrectMatches) return;
    _puzzleSolvedFired = true;
    onVoicePuzzleSolved?.call();
  }

  void reset() {
    _voiceAssignments.clear();
    _listenedIds.clear();
    _puzzleSolvedFired = false;
    notifyListeners();
  }

  // ---------- Persistence ----------

  void _persistAssignments() {
    final list = _voiceAssignments.entries
        .map((e) => '${e.key}=${e.value}')
        .toList();
    _persistence?.setStringList(_kAssignments, list);
  }

  void _load() {
    final p = _persistence;
    if (p == null) return;
    _listenedIds.addAll(p.getStringList(_kListened));
    for (final raw in p.getStringList(_kAssignments)) {
      final eq = raw.indexOf('=');
      if (eq <= 0) continue;
      final recId = raw.substring(0, eq);
      final contactId = raw.substring(eq + 1);
      _voiceAssignments[recId] = contactId;
    }
    // Re-arm the puzzle-solved hook only if not already correct on
    // load — the shell replays it via cold-load wiring if needed.
    if (hasCorrectMatches) _puzzleSolvedFired = true;
  }

  // ---------- Seed ----------

  void _seed() {
    _recordings.addAll(const [
      GameRecording(
        id: 'rec_003',
        title: 'Nagranie 003',
        date: '10 maja 2026, 22:14',
        duration: '6:48',
        location: 'Parking hipermarket',
        voiceContactId: 'tomasz_b',
        isImportant: true,
        transcript:
            'Jestem na parkingu za hipermarketem. Jest 22:14. '
            'Czarny SUV już stoi — rejestracja WI 38274. '
            'K. przyjechał sam, jak zawsze. Czekam.\n\n'
            '[szum, kroki na żwirze]\n\n'
            'Podchodzi do SUV-a. Otwiera okno. Widzę kopertę. '
            'Gazeta codzienna — Rzeczpospolita, chyba. '
            'Przekazanie trwa może 10 sekund.\n\n'
            '[cisza]\n\n'
            'K. zostaje. Pali papierosa. SUV odjeżdża. '
            'Mam to. Trzecie nagranie. Trzecia koperta.\n\n'
            'Kwota na fakturze: 14 tysięcy. Jak ostatnio.\n\n'
            '[NAGRANIE Z OKNA SUV-a, MĘSKI GŁOS:]\n'
            '"Następna w czerwcu. Tym razem 16. Sektor C-3. "',
      ),
      GameRecording(
        id: 'rec_002',
        title: 'Nagranie 002',
        date: '25 kwietnia 2026, 22:08',
        duration: '4:22',
        location: 'Parking hipermarket',
        voiceContactId: 'komendant_k',
        transcript:
            'Drugie nagranie. Ten sam parking. K. i ten sam '
            'czarny SUV. Tym razem widzę twarz kierowcy — '
            'to Tomasz B., wspólnik Helion-Bud (51% udziałów, '
            'sprawdziłam w KRS).\n\n'
            'Koperta jest grubsza niż ostatnio. K. chowa ją '
            'do wewnętrznej kieszeni kurtki.\n\n'
            'Muszę to skończyć. Jeszcze jedno nagranie i idę '
            'do Anity.\n\n'
            '[GŁOS PRZYJMUJĄCEGO KOPERTĘ:]\n'
            '"Niech pan się nie martwi. Z patrolami w tym '
            'tygodniu jest umowa. Sektor B-3 do piątku."',
      ),
      GameRecording(
        id: 'rec_001',
        title: 'Nagranie 001',
        date: '28 marca 2026, 14:22',
        duration: '3:15',
        location: 'Stacja Orlen, Mokotów',
        voiceContactId: 'anita_z',
        isImportant: true,
        transcript:
            'Pierwsze nagranie. Stacja benzynowa na Mokotowie. '
            'Jest 14:22. Widzę K. — komendant powiatowy. '
            'Wszyscy mówią na niego Szeryf.\n\n'
            'Podjeżdża czarny SUV. Nie widzę rejestracji. '
            'K. podchodzi do okna. Ktoś podaje mu coś — '
            'wygląda jak koperta w gazecie.\n\n'
            'Nie mam jeszcze dowodu. Ale wiem co widziałam.\n\n'
            '[N.: to był początek. 14:22. Zapamiętam tę godzinę.]\n\n'
            '[ROZMOWA TELEFONICZNA, KOBIECY GŁOS Z DRUGIEJ STRONY:]\n'
            '"N., jeśli to prawda — masz w mojej redakcji '
            'pełne plecy. Sobota o 16. Kawiarnia Relaks. '
            'Przynieś co masz."',
      ),
      GameRecording(
        id: 'voicemail_threat',
        title: 'Notatka głosowa',
        date: '16 maja 2026, 23:40',
        duration: '0:34',
        location: 'Dom',
        // No voice match — it's just N.
        transcript:
            '[szept, ciężki oddech]\n\n'
            'Ktoś jest pod domem. Ten sam samochód co wczoraj. '
            'Zgaszone światła. Nie ruszam się.\n\n'
            'Jeśli mi się coś stanie — wszystko jest w skrytce '
            '14B na dworcu. Klucz w doniczce.\n\n'
            'Mamo, przepraszam.\n\n'
            '[koniec nagrania]',
      ),
    ]);
  }
}
