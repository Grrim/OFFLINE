# Design — OFFLINE 1.0

## Wprowadzenie

Ten dokument przekłada wymagania (`requirements.md`) na konkretną
architekturę techniczną, schematy danych, integracje zewnętrzne i
strategię testowania. Stack: Flutter 3.19+, Dart 3.3+, Provider,
SharedPreferences. Doklejamy: `flutter_localizations`, `intl_utils`,
`in_app_purchase`, `package_info_plus`, `sentry_flutter` (opt-in).

## Architektura wysokiego poziomu

### Warstwy

```
┌──────────────────────────────────────────────────────────┐
│  UI (screens/, widgets/)                                  │
│  — bezstanowe, czytają state z Provider                   │
└──────────────────────────────────────────────────────────┘
              ▲
              │ context.watch / select
┌──────────────────────────────────────────────────────────┐
│  State (state/) — ChangeNotifier                          │
│  PhoneState, MessagesState, NotesState, FilesState,       │
│  PhotosState, BrowserState, EmailState (NOWY),            │
│  RecorderState (NOWY), MapsState (NOWY),                  │
│  TrustState (NOWY), EvidenceState (NOWY),                 │
│  ChapterState, EndingState, NotificationsState,           │
│  AchievementsState (NOWY), SettingsState (NOWY)           │
└──────────────────────────────────────────────────────────┘
              ▲
              │ getX/setX
┌──────────────────────────────────────────────────────────┐
│  Services (services/)                                     │
│  PersistenceService (versioned SharedPreferences),        │
│  AudioService, LocationService,                           │
│  IapService (NOWY — in_app_purchase),                     │
│  TelemetryService (NOWY — Sentry, opt-in),                │
│  L10nService (NOWY — runtime locale switch),              │
│  PlayGamesService (NOWY — opcjonalne achievements)        │
└──────────────────────────────────────────────────────────┘
              ▲
              │
┌──────────────────────────────────────────────────────────┐
│  Content (content/) — NOWA WARSTWA                        │
│  Statyczne dane gry: dialogi, dokumenty, zdjęcia,         │
│  puzzle definitions. Czysty Dart, żadnego state.          │
│  Importowany przez `_seed()` w state.                     │
└──────────────────────────────────────────────────────────┘
```

### Kluczowe decyzje

1. **Provider zostaje.** Działa, jest prosty, nie ma powodu na Riverpod
   tuż przed releasem.
2. **Rozdzielamy content od state.** Obecnie seed danych jest wewnątrz
   `_seed()` w state. Wydzielamy do `lib/content/*` żeby testy mogły
   ładować inne wersje danych (np. test fixtures z 2 plikami zamiast 5).
3. **Nowe state classes są lekkie.** `TrustState` i `EvidenceState`
   to mała mapa + persist. Nie tworzymy event-bus-a; one same emitują
   zmiany przez `notifyListeners`.
4. **Brak nowego frameworka dialogów.** Aktualny `DialogueNode` /
   `DialogueChoice` jest wystarczający. Rozszerzamy go o pole
   `trustDeltas` i `requiresMinTrust`.

## Modele danych — rozszerzenia

### `DialogueChoice` — nowe pola

```dart
class DialogueChoice {
  const DialogueChoice({
    required this.text,
    required this.nextNodeId,
    this.trustDeltas = const {},   // {'mama': -10, 'anita': +5}
    this.requiresMinTrust = const {}, // {'tomasz': 30}
    this.requiresMinEvidence,         // null lub int
    this.requiresFlag,                // 'inspected_forest_night'
    this.hidden = false,              // ukryty póki warunek niespełniony
  });
  ...
}
```

Choice z niespełnionym warunkiem może być:
- `hidden: true` → niewidoczny w UI
- `hidden: false` → widoczny ale wyszarzony z tooltipem ("brak zaufania
  Anity, brak dowodów, ...")

### `TrustState` (NOWA)

```dart
class TrustState extends ChangeNotifier {
  static const _kPrefix = 'trust.v1.';

  final Map<String, int> _values = {
    'mama': 0,
    'anita': 0,
    'tomasz': 0,
    'nieznany': 0,
  };

  int get(String npcId) => _values[npcId] ?? 0;
  void apply(Map<String, int> deltas) {...}  // clamp -100..+100
  void reset() {...}
  Map<String, int> snapshot() => Map.unmodifiable(_values);
}
```

Persist w postaci par klucz-wartość w SharedPreferences. Ładowane przy
boocie. Zapisywane po każdym `apply()`.

### `EvidenceState` (NOWA)

```dart
class EvidenceState extends ChangeNotifier {
  static const _kCollected = 'evidence.collected.v1';

  final Set<String> _collected = {};

  static const Map<String, int> weights = {
    'photo_forest_night': 20,
    'photo_parking': 15,
    'photo_document': 25,
    'file_invoice_05': 10,
    'file_invoice_04': 5,
    'file_transcript': 30,
    'file_envelopes': 15,
    'file_map': 10,
    'recording_001': 15,
    'recording_002': 15,
    'recording_003': 25,
    'voicemail_threat': 10,
    'email_anita': 10,
    'email_strazn_lasu': 10,
    'browser_krs': 5,
    'browser_centralna': 15,
    'note_secret': 0,    // narrative, nie evidence
    'note_plan_b': 0,
  };

  static const int truthEndingThreshold = 80;
  static const int dawnEndingThreshold = 120;

  int get score => _collected.fold(
        0, (a, id) => a + (weights[id] ?? 0),
      );
  bool has(String id) => _collected.contains(id);
  void collect(String id) {...}
}
```

### `SettingsState` (NOWA)

Centralizuje przełączniki UX:

```dart
class SettingsState extends ChangeNotifier {
  bool muteAudio = false;
  bool reducedMotion = false;     // wyłącza glitch + flash
  bool haptics = true;
  bool guidedMode = false;        // hinty co 90s
  bool telemetryOptIn = false;
  String localeCode = 'pl';
  bool privacyConsentAccepted = false;
  bool contentWarningShown = false;
  ...
}
```

### `AchievementsState` (NOWA)

```dart
class GameAchievement {
  final String id;
  final String titleKey;          // 'ach.detective.title'
  final String descKey;
  final IconData icon;
  final bool secret;              // ukryty póki nieodblokowany
}

class AchievementsState extends ChangeNotifier {
  static const catalog = <String, GameAchievement>{...};
  final Set<String> _unlocked = {};
  ...
  void unlock(String id) {...}    // notify + persist + Play Games
}
```

## Schemat persystencji

Obecnie persistence to luźne klucze w SharedPreferences. Dodajemy
**versioned schema**:

```dart
class PersistenceSchema {
  static const int currentVersion = 1;
  static const String _kVersion = '__schema_version__';

  static Future<void> migrate(SharedPreferences p) async {
    final saved = p.getInt(_kVersion) ?? 0;
    if (saved == currentVersion) return;
    if (saved < 1) await _migrateTo1(p);
    await p.setInt(_kVersion, currentVersion);
  }
}
```

Wszystkie klucze stanu są normalizowane do prefixu (`messages.`,
`trust.v1.`, `evidence.`). Reset rozgrywki kasuje **wszystkie** klucze
z prefixów stanów gry, ale zachowuje `settings.*`.

## Lokalizacja

### Pipeline

1. `pubspec.yaml` → `flutter_localizations`, `intl: ^0.20.0`.
2. Plik `l10n.yaml` w katalogu głównym konfiguruje `gen_l10n`.
3. `lib/l10n/intl_pl.arb` — kompletne PL (źródłowe).
4. `lib/l10n/intl_en.arb` — szkielet, wartości `[EN] {pl_value}` jako
   placeholder.
5. Generowane `AppLocalizations` w `lib/gen/l10n/`.
6. W kodzie: `AppLocalizations.of(context).sheriffOpener` zamiast
   stringów inline.

### Strategia migracji stringów

Migrujemy progresywnie — najpierw nowe ekrany dostają i18n od razu,
potem kolejno przepisujemy istniejące pliki: `lock_screen.dart`,
`home_screen.dart`, dialogi z `messages_state.dart`, ending texts,
itd. Pełna migracja to kilkanaście godzin pracy mechanicznej.

### Runtime switch

`L10nService` przechowuje aktualny `Locale` i emituje przez `ValueNotifier`.
`MaterialApp.locale` jest podpięty do tego notifiera, więc zmiana
języka w Ustawieniach przerysowuje całe drzewo.

Fallback: jeśli `localeCode == 'en'` i klucz w `intl_en.arb` zaczyna
się od `[EN] ` (placeholder), używamy wersji PL. Robimy to przez
custom delegate.

## Monetyzacja — IAP

### Model

**One free chapter + one paid IAP unlock.** Brak subskrypcji, brak
consumables. Produkt: `offline_full_unlock` (non-consumable).

### Architektura

```dart
class IapService {
  static const String unlockProductId = 'offline_full_unlock';

  late final InAppPurchase _iap;
  bool _isFullVersion = false;

  Future<void> init() async {...}
  Future<void> buyFullVersion() async {...}
  Future<void> restorePurchases() async {...}
  Stream<bool> get fullVersionStream => ...;
}
```

### Gating

`ChapterState.advanceToChapter2()` najpierw sprawdza:
```dart
if (!iap.isFullVersion) {
  showPaywall();
  return;
}
```

Paywall to ekran "Kontynuuj historię" z 1 przyciskiem "Kup pełną wersję
(19,99 zł)" + "Przywróć zakup". Bez liczników, bez fałszywych zniżek.

### Free-tier scope

- Rozdział 1 do końca (do dialogu Szeryfa włącznie).
- Dostępne zakończenia: ZŁAPANY, UCIECZKA.
- Zakończenia PRAWDA / ŚWIT / SAMOTNIA / KORUPCJA → paywall.

### Bezpieczeństwo

Zakup walidowany przez `purchaseDetails.verificationData` lokalnie.
Dla v1.0 nie potrzebujemy server-side validation (akceptowalny risk
piracy w grach single-player).

## Telemetria (opt-in)

```dart
class TelemetryService {
  static Future<void> init({required bool optIn}) async {
    if (!optIn) return;
    await SentryFlutter.init((options) {
      options.dsn = '...';
      options.tracesSampleRate = 0.0;
      options.beforeSend = _stripPii;
    });
  }

  static SentryEvent? _stripPii(SentryEvent event, {Hint? hint}) {
    // Usuń lokalizację, IP, breadcrumbs zawierające save data.
    return event.copyWith(user: null, contexts: ...);
  }
}
```

Konfiguracja Sentry: tylko crash reports, brak performance monitoring,
brak session tracking.

## Audio — produkcyjne assety

`AudioService` zostaje. Zamiast generated WAV-ów docelowo:

- `ambient_drone.ogg` (stereo, 192 kbps, 60s loop)
- `tension_loop.ogg` (stereo, 192 kbps, 60s loop)
- 7 SFX: `sfx_keypad_tap.ogg`, `sfx_keypad_error.ogg`,
  `sfx_message.ogg`, `sfx_notification.ogg`, `sfx_unlock.ogg`,
  `sfx_ending.ogg`, `sfx_glitch.ogg`

Źródła: freesound.org (CC0 / CC-BY z atrybucją), opcjonalnie
nagrania własne.

## Nowe ekrany / state objects

### `EmailState` + Email-puzzle "Odzyskaj usuniętą wiadomość"

Aktualny `EmailView` jest hardcoded. Wydzielamy do `EmailState`:

```dart
class EmailState extends ChangeNotifier {
  final List<EmailMessage> _inbox = [];  // standardowe
  final List<DeletedFragment> _trashFragments = [];  // 5 fragmentów
  final Set<String> _recoveredFragmentIds = {};
  String? _reconstructedBody;

  bool get isFullyRecovered => _recoveredFragmentIds.length == 5;
  ...
}
```

Mechanika: 5 fragmentów rozsianych "w grafice tła" 5 innych ekranów
(Notatki, Kalendarz, Mapy, Browser, Settings). Tap na fragment
przerzuca do Poczty z animacją "fragment dodany do trash". Kompletne 5
→ `_reconstructedBody` ujawnia kolejną wiadomość Anity z prośbą o
spotkanie w konkretnym miejscu (linka do mapy).

### `RecorderState` + Voice-match-puzzle

```dart
class RecorderState extends ChangeNotifier {
  final List<Recording> _recordings = [];
  final Map<String, String?> _voiceAssignments = {};  // recId → contactId
  ...
  bool get isFullyMatched => _voiceAssignments.values.every((v) => v != null);
  bool get hasCorrectMatches => _matchesAreCorrect();
}
```

UI: w detalu nagrania, po odsłuchaniu (== otwarciu transkrypcji),
pokazuje się dropdown "Kto to mówi? Wybierz z kontaktów". 3 nagrania,
3 dopasowania. Wszystkie poprawne → odsłania ukrytą scenę.

### `MapsState` + Route-reconstruction-puzzle

```dart
class MapsState extends ChangeNotifier {
  final List<MapPin> _significantLocations = [];
  final List<String> _userOrderedRoute = [];
  ...
  bool get isCorrectRoute => _userOrderedRoute == _expectedRoute;
}
```

UI: lista lokacji z timestampami. Gracz przeciąga je w kolejność
chronologiczną. Poprawne ułożenie odsłania trasę N. w noc zaginięcia.

### `BrowserState` — tryb prywatny + hasło

Aktualny `BrowserState` ma `isPrivate: true` na 4 wpisach. Dodajemy
gating: te wpisy są zablokowane, dopóki gracz nie wpisze hasła
znalezionego w innej notatce (np. `mruczek2019` z notatki "Hasła Wi-Fi"
+ podpowiedź w dialogu Nieznanego). Wpisanie hasła → unlocked.

## Refaktor istniejących problemów

### `BuildContext` async gaps w `main.dart`

Linia 676 i 679: dotyczy bannerów Nieznanego po `Future.delayed`.
Naprawa:

```dart
// PRZED:
Future.delayed(const Duration(seconds: 2), () {
  final msgs = context.read<MessagesState>(); // ❌ async gap
  ...
});

// PO:
Future.delayed(const Duration(seconds: 2), () {
  if (!mounted) return;                        // ✅ guarded
  final msgs = context.read<MessagesState>();
  ...
});
```

Albo lepiej — przepisujemy te lambdy żeby pobierały referencję do
state ZANIM odpalą `Future.delayed`.

### Linty `prefer_const_constructors`

`dart fix --apply` rozwiązuje większość. Resztę poprawiamy ręcznie po
analizie. Cel: 0 issues.

## Plan testów

### Unit tests

Pokrycie minimum 70% dla:

- `MessagesState` — fixtures: stub persistence, weryfikacja
  `selectChoice`, `_runNode`, cold-load idempotency, `triggerJournalistDialog`,
  `triggerWitnessDialog`.
- `NotesState` — `tryUnlock` happy/sad path, `replayHookForColdLoad`,
  reset.
- `FilesState` — `markOpened` triggers, threshold callbacks.
- `PhotosState` — `markInspected` callback.
- `EndingState` — `trigger`, persist, reset.
- `ChapterState` — advance idempotency, transition flag clearing.
- `TrustState` (nowe) — apply/clamp/persist/reset.
- `EvidenceState` (nowe) — collect/score/threshold.
- `BrowserState`, `EmailState`, `RecorderState`, `MapsState` (nowe).

### Widget tests

Smoke testy dla:
- Lock screen: PIN entry happy + wrong PIN.
- Notes: open locked note → keypad → unlock.
- Chat view: render dialog choices.
- Ending overlay: render + "play again" button.

### Integration tests (opcjonalnie post-launch)

End-to-end test scenariusza ZŁAPANY (najszybsze przejście) — test, że
boot → unlock → ścieżka Szeryfa → ending wykona się bez crashy.

## Plan publikacji

### Etapy

1. **Foundation patch** (Faza 1) — czyszczenie kodu, testy, i18n
   szkielet. Wewnętrzne, bez release.
2. **Content expansion** (Faza 2) — TrustState, EvidenceState, nowe
   puzzle, rozdział 3, nowe zakończenia. Internal Testing track.
3. **Polish & Compliance** (Faza 3) — finalne assety audio/grafika,
   privacy policy, ratings. Closed Testing.
4. **Release v1.0** — Open Testing → Production.

### Branching

- `main` — stabilne, każdy push to potencjalny release.
- `feature/*` — pojedyncze zadania ze speca.
- Tagujemy `v0.2.0`, `v0.3.0`... `v1.0.0`.

## Otwarte pytania (do potwierdzenia)

Spec zostawia te decyzje otwarte — proponuję defaulty:

- **Cena IAP:** 19,99 zł (default) lub 14,99 zł (entry).
- **Sentry vs Crashlytics:** Sentry (lepszy free tier, prostszy
  onboarding, bez konieczności Firebase).
- **Play Games achievements:** TAK, ale opcjonalnie — gracz nie musi
  się logować do gry.
- **Audio:** placeholder z `generate_audio.py` zostaje na czas
  developmentu. Finalne assety pozyskujemy z freesound.org +
  ewentualnie własne nagrania pod koniec Fazy 3.
- **Grafika zdjęć:** stockowe na licencji (Unsplash CC0 lub Pexels)
  dobierane tak, żeby pasowały do polskich realiów. Lista konkretnych
  zdjęć w `assets/images/photos/README.md`.
