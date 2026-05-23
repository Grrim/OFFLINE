import 'package:flutter/foundation.dart';

import '../services/persistence_service.dart';

class NoteItem {
  NoteItem({
    required this.id,
    required this.title,
    required this.body,
    required this.dateString,
    this.isLocked = false,
    this.pin,
  });

  final String id;
  final String title;
  final String body;
  final String dateString;

  bool isLocked;
  final String? pin;
}

/// State for the Notes app. Persists which previously-locked notes have
/// been unlocked, and whether the secret unlock hook has already fired.
class NotesState extends ChangeNotifier {
  NotesState({PersistenceService? persistence})
      : _persistence = persistence {
    _seed();
    _load();
  }

  static const String _kUnlockedIds = 'notes.unlockedIds';
  static const String _kHookFired = 'notes.hookFired';

  final PersistenceService? _persistence;
  final List<NoteItem> _notes = [];

  /// Wired in main.dart. Called once, the first time the secret note is
  /// successfully unlocked. On cold-load, if [hasUnlockedSecret] is true,
  /// we *also* re-fire it so the Sheriff thread is rebuilt - but the
  /// callback installer in main.dart suppresses the delay in that case.
  void Function(String unlockedNoteId, {bool fromColdLoad})?
      onLockedNoteUnlocked;

  bool _hasFiredUnlockHook = false;
  bool get hasUnlockedSecret => _hasFiredUnlockHook;

  List<NoteItem> get notes => List.unmodifiable(_notes);

  NoteItem? noteById(String id) {
    for (final n in _notes) {
      if (n.id == id) return n;
    }
    return null;
  }

  bool get hasUnlockedAnySecret => _hasFiredUnlockHook;

  bool tryUnlock(String noteId, String pin) {
    final note = noteById(noteId);
    if (note == null || !note.isLocked) return false;
    if (note.pin == null || note.pin != pin) return false;

    note.isLocked = false;
    _persistUnlocked(noteId);
    notifyListeners();

    // Fire the Sheriff hook specifically when the 'secret' note is unlocked.
    if (noteId == 'secret' && !_hasFiredUnlockHook) {
      _hasFiredUnlockHook = true;
      _persistence?.setBool(_kHookFired, true);
      onLockedNoteUnlocked?.call(noteId, fromColdLoad: false);
    }

    // Fire for plan_b too — activates the witness thread.
    if (noteId == 'plan_b') {
      onLockedNoteUnlocked?.call(noteId, fromColdLoad: false);
    }

    return true;
  }

  /// Called by main.dart once the hook callback is installed *if*
  /// [hasUnlockedSecret] was already true at boot. Lets the Sheriff thread
  /// be rebuilt without re-running the 3s delay.
  void replayHookForColdLoad() {
    if (!_hasFiredUnlockHook) return;
    onLockedNoteUnlocked?.call('secret', fromColdLoad: true);
  }

  void _persistUnlocked(String id) {
    final p = _persistence;
    if (p == null) return;
    final current = p.getStringList(_kUnlockedIds).toSet()..add(id);
    p.setStringList(_kUnlockedIds, current.toList());
  }

  void _load() {
    final p = _persistence;
    if (p == null) return;
    final unlocked = p.getStringList(_kUnlockedIds).toSet();
    for (final n in _notes) {
      if (unlocked.contains(n.id)) n.isLocked = false;
    }
    _hasFiredUnlockHook = p.getBool(_kHookFired);
  }

  void reset() {
    _notes.clear();
    _seed();
    _hasFiredUnlockHook = false;
    notifyListeners();
  }

  // ---------- Seed ----------

  void _seed() {
    _notes.addAll([
      NoteItem(
        id: 'secret',
        title: 'PRZECZYTAJ W RAZIE MOJEGO ZNIKNIĘCIA',
        body: _secretBody,
        dateString: 'Wczoraj, 23:51',
        isLocked: true,
        pin: '7309',
      ),
      NoteItem(
        id: 'plan_b',
        title: 'PLAN B (ostateczny)',
        body: _planBBody,
        dateString: 'Wczoraj, 23:58',
        isLocked: true,
        pin: '1422',
      ),
      NoteItem(
        id: 'shopping',
        title: 'Zakupy',
        body:
            '- mleko owsiane\n- pomidory\n- chleb żytni\n- karma dla Mruczka\n'
            '- baterie AA\n- aspiryna',
        dateString: '13 maja 2026',
      ),
      NoteItem(
        id: 'poem',
        title: 'wiersz (szkic)',
        body:
            'we mgle nad rzeką stoję sama,\n'
            'księżyc - cienki nóż na niebie.\n'
            'ktoś szepcze moje imię z tyłu,\n'
            'a ja udaję, że nie słyszę siebie.\n\n'
            '(za krótkie? do dopisania.)',
        dateString: '7 maja 2026',
      ),
      NoteItem(
        id: 'hasla',
        title: 'Hasła Wi-Fi',
        body:
            'Dom: kotmruczek2019\n'
            'Praca: nie pamiętam, zapytać Kasi z IT\n'
            'Cafe Relaks: gosc.relaks',
        dateString: '2 maja 2026',
      ),
      NoteItem(
        id: 'spotkanie',
        title: 'Spotkanie z Anitą - notatki',
        body:
            'Sobota, Kawiarnia Relaks, 16:00\n\n'
            '- A. potrzebuje skanów faktur (mam je w chmurze)\n'
            '- pytała o nazwiska — dałam jej tylko "K." na razie\n'
            '- jej redaktor naczelny się waha (proces!)\n'
            '- ustaliłyśmy: jak coś, kontakt przez Signal, nie SMS\n'
            '- jej numer: zachowany w kontaktach jako "Anita Z. (Gazeta)"\n\n'
            'Czuję, że ktoś nas obserwował. Kelner za długo stał przy '
            'naszym stoliku. Może paranoja. Może nie.',
        dateString: '10 maja 2026',
      ),
    ]);
  }

  static const String _secretBody = '''
Jeśli to czytasz, znaczy że stało się coś złego. Piszę to w pośpiechu.

Przez ostatnie trzy miesiące zbierałam dokumenty na firmę Helion-Bud. Wszystko zaczęło się od raportu, który dostałam anonimowo - faktury, przelewy, transkrypcje rozmów.

Helion-Bud przez lata płacił komendzie powiatowej za "ochronę" swoich nielegalnych wycinek w Lesie Kabackim. Komendant K. brał kopertę co miesiąc. Mam zdjęcia, mam nagrania, mam jego podpisy.

W zeszłym tygodniu ktoś włamał mi się do mieszkania. Nic nie zginęło. Tylko moje notatki zostały przełożone.

Wczoraj wieczorem śledził mnie samochód spod komendy. Zatrzymał się dwie ulice od domu, zgasił światła i czekał.

Jeżeli coś mi się stanie - to nie był wypadek. Wszystkie dowody są w skrytce 14B na dworcu. Klucz schowałam w doniczce z fikusem.

Jeśli ktokolwiek to czyta i wie co robi: napisz do Anity Z. z Gazety. Ona ma już połowę materiału, brakuje jej tylko mojego potwierdzenia. Powiedz jej "fikus 14B" - zrozumie.

I jeszcze jedno: NIE UFAJ NIKOMU Z MUNDURU. Szczególnie szeryfowi — tak go wszyscy nazywają, bo rządzi tu jak w westernach. Naprawdę to komendant K. z powiatowej. To on odbiera koperty.

- N.
''';

  static const String _planBBody = '''
Jeśli czytasz tę notatkę, to znaczy że pierwszej nie wystarczyło.

Zostawiam to jako absolutny ostateczny plan. Nikt poza mną tego nie wie:

NIE PRZEKAZUJ DOWODÓW POLICJI. NIE MA TEGO W PROTOKOLE.

Zamiast tego idź do osoby, która jest w mojej liście kontaktów jako "T.W. (sąsiad)". To Tomasz, mieszka pod numerem 14, drugie piętro. On wie wszystko. Ma kopię nagrania, ma kopię zdjęć. Pracował kiedyś w Helion-Bud zanim zwolnili go za to, że zaczął zadawać pytania.

Hasło, którym się rozpozna ze mną: "drzewo, które padło na dachu". Tylko on i ja je znamy.

Jeśli on też zniknął - schowaj telefon. Idź na komendę CENTRALNĄ w Warszawie (nie powiatową), poproś rozmowę z prokuratorem dyżurnym. Powiedz że masz dowody w sprawie Helion-Bud i że masz powody sądzić, że lokalne komendy są skompromitowane.

Plan B jest po to, żeby nigdy nie został użyty. Ale jeśli czytasz, to znaczy że zawiodły wszystkie poprzednie.

Przepraszam, że to na ciebie spadło.

- N.
''';
}
