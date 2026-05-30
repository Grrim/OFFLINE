# Changelog

Format zgodny z [Keep a Changelog](https://keepachangelog.com/pl/1.1.0/),
projekt używa [SemVer](https://semver.org/lang/pl/).

## [Unreleased]

### Added
- Spec wersji komercyjnej w `.kiro/specs/offline-full-release/`
  (requirements / design / tasks).
- Wersjonowanie schematu `SharedPreferences` z migracją z legacy
  (kluczy bez prefiksu) do `game.*` / `settings.*`.
- `clearGameState()` — reset rozgrywki bez kasowania ustawień.
- `SettingsState` — central toggle dla mute, reduced motion, haptics,
  guided mode, telemetry opt-in, privacy consent, hasCompletedOnce,
  lastPlayedAt + helpers (touchLastPlayed, hasBeenAwayLong).
- `L10nService` + `flutter_localizations` — szkielet i18n PL/EN z
  fallbackiem EN→PL dla nieprzełożonych kluczy (sentinel `[EN] `).
- 183 testów jednostkowych dla state, services, l10n.
- Sekcje "Gra", "Język", "Prywatność", "O grze" w Ustawieniach.
- **`TrustState`** — śledzenie zaufania 4 NPCów (-100..+100).
- **`EvidenceState`** — system 22 dowodów z wagami, 3 progi (TRUTH 80,
  DAWN 120, Anita soft-block 50), automatyczne zbieranie przez
  PhotosState/FilesState/BrowserState/RecorderState/EmailState/MapsState
  (`EvidenceMapping`).
- **`FlagsState`** — boolean flags dla puzzli i stanu fabularnego.
- **`NewGamePlusState`** — meta-progresja krzyżowa (runCount,
  previousEndings, isPlusActive, cycleHinted), persistencja pod
  `meta.*` (przeżywa "Resetuj rozgrywkę").
- **`NewGamePlusChoiceScreen`** — boot-time wybór "Nowa gra" vs
  "Kontynuuj NG+" gdy gracz ma już ≥1 ukończenie.
- **`EmailState`** + **puzzle "Odzyskaj usuniętą wiadomość"** — 5
  fragmentów rozsianych po 5 ekranach (Notatki/Zakupy, Kalendarz/14:00,
  Mapy/Las Kabacki, Browser/Sygnal, Settings/footer). Long-press
  recovery, snackbar feedback, _RecoveredEmailTile w inbox.
- **`RecorderState`** + **puzzle "Voice match"** — 3 anonimowe głosy
  w nagraniach, BottomSheet z listy kontaktów, walidacja, hook
  `onVoicePuzzleSolved`.
- **`MapsState`** + **puzzle "Route reconstruction"** — 5 lokalizacji
  z timestampami, ReorderableListView z drag-handle, tap-to-add /
  tap-to-remove, hook `onPuzzleSolved`.
- **`AchievementsState`** — 12 osiągnięć (12 katalogowych, 1 secret).
  Hookowanie w shell przy każdym ending, NotificationsState toast
  przy unlock, ekran `AchievementsView` z secret-rendering.
- **`DialogueChoice`** rozszerzone o `trustDeltas`, `requiresMinTrust`,
  `requiresMinEvidence`, `requiresFlag`, `hidden`, `lockedReasonKey`.
- **Gating UI**: locked choices pokazane wyszarzone z ikoną kłódki.
- **2 nowe zakończenia**: KORUPCJA, SAMOTNIA.
- **7. ukryte zakończenie CYKL** — meta-narracyjne. Choice
  "Ile razy mieliśmy już tę samą rozmowę?" w Sheriff dialogue,
  dostępny wyłącznie w aktywnym NG+ run gdy `runCount >= 2 && cycleHinted`.
- **Rozdział 3 "Po świcie"** — odpalany w NG+ runach gdy gracz
  doszedłby do TRUTH/DAWN; zamiast terminal endingu otwiera się
  prokurator thread.
- **2 zakończenia rozdziału 3**: **ŚWIADEK** (publiczne zeznanie pod
  własnym nazwiskiem, status świadka koronnego, Anita dostaje
  Grand Press) i **CIEŃ** (depozyt anonimowy, sprawa idzie wolniej
  ale nie ma śladu po graczu).
- **Signal puzzle** — mini-dekodowanie hasła `koperta1422` z dwóch
  istniejących wskazówek (notatki + transkrypcja 14:22). Nowa app
  Signal na home gridzie w Chapter 3, gated choice "ochrona świadka"
  w prokurator dialogue wymaga `puzzle.signal_decoded`.
- **Meta-narracja Nieznanego w NG+** — 7 wariantów openerów
  zależnych od ostatniego ukończenia + cycle hint po 3 min
  (`Słuchaj, zauważyłeś że za każdym razem to ten sam piątek?`).
- **Browser private mode** — `mruczek2019`, hint w dialogu po 5 min.
- **Galeria zakończeń** — 6 kafelków, niedostępne zaczernione.
- **Pauza globalna** — long-press na home indicator.
- **Welcome-back overlay** — recap "Co się dotąd wydarzyło" po >24h
  przerwy. Linie generowane dynamicznie ze stanu (rozdział, notatki,
  dowody, trust, puzzle).
- **Hint system** — co 30s sprawdzamy idle; po 5 min (lub 90s w guided
  mode) Nieznany wysyła kontekstowy hint dynamicznie wybrany na
  podstawie aktualnego stanu progresu.
- **Statystyki na ending overlay** — Pliki przeczytane, Wskazówki
  odkryte, Dowody, Łamigłówki, Zakończenie.
- **`ContentWarningScreen`** — pierwszy ekran przy świeżej instalacji
  z opisem tematyki 13+, opcją opt-in dla lokalizacji i info o
  efektach wizualnych.
- **`AboutView`** — ekran "O grze" w Ustawieniach z wersją,
  polityką prywatności, atrybucjami audio i `showLicensePage`.
- **Toggle "Używaj lokalizacji"** w Ustawieniach → Prywatność.
- **`reducedMotion` honored** — GlitchOverlay i ScareOverlay nie
  mountują się gdy gracz włączył w Ustawieniach.
- **`haptics` honored** — Sheriff ringer respektuje toggle wibracji.
- `FragmentHotspot` widget — niewidoczny long-press wrapper dla
  fragmentów email puzzla.
- `PhoneShellEvents` (InheritedWidget) — cross-tree dispatcher dla
  pause request.

### Changed
- Cały projekt przeszedł `dart fix --apply`.
- Naprawiono 2 ostrzeżenia `use_build_context_synchronously` w
  `main.dart` (capture state references przed async gap).
- `Resetuj rozgrywkę` — używa `clearGameState()` zamiast `clearAll()`.
- README zaktualizowany do faktycznego stanu projektu.

### Fixed
- `flutter analyze` zwraca 0 issues (z 14 wcześniej).

## [0.1.0] - 2026-05 (demo)

Pierwsza wersja grywalnego dema.

### Added
- 12 aplikacji telefonu (Wiadomości, Zdjęcia, Notatki, Pliki, Poczta,
  Kalendarz, Kontakty, Mapy, Dyktafon, Telefon, Przeglądarka,
  Ustawienia).
- 2 rozdziały, 4 zakończenia (ZŁAPANY, UCIECZKA, PRAWDA, ŚWIT).
- Stalker thread z opcjonalną integracją lokalizacji.
- Boot screen, intro screen, glitch overlay, scare overlay.
- Persystencja postępu w `SharedPreferences`.
