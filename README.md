# OFFLINE

Mobilna gra typu **found phone / fake OS** osadzona w polskich
realiach. Gracz trzyma w rękach telefon zaginionej dziennikarki N.
i przez kolejne aplikacje (13 łącznie) odkrywa, kto stoi za jej
zniknięciem.

> **Status:** wersja `0.2.0+1`. Faza 1 (foundation) + Faza 2 (content
> & mechaniki) zamknięte. Faza 3 (release polish — IAP, finalne
> assety, build/signing, Play Store, lokalizacja EN) — TBD.
> Pełny plan w `.kiro/specs/offline-full-release/`.

## Skala obecnej zawartości

- **3 rozdziały** (wieczór → świt → po świcie)
- **9 zakończeń** (ZŁAPANY, UCIECZKA, PRAWDA, ŚWIT, KORUPCJA, SAMOTNIA,
  CYKL [secret w NG+], ŚWIADEK [Chapter 3], CIEŃ [Chapter 3])
- **5 prawdziwych łamigłówek** (browser private mode, voice match
  w dyktafonie, route reconstruction w mapach, email recovery
  z fragmentami w 5 ekranach, Signal puzzle w Chapter 3)
- **System trust dla 4 NPCów** (-100..+100) z choice gating
- **System evidence** (22 dowody, 3 progi: TRUTH 80, DAWN 120,
  Anita 50)
- **14 osiągnięć** (1 secret)
- **New Game+** z meta-narracją Nieznanego (7 wariantów openerów)
- **5 hooków narracyjnych** (Sheriff countdown 8 min, solitude
  watchdog 25 min, hint system 5 min idle / 90s w guided mode,
  welcome-back po 24h, scheduled stalker messages)

## Stack

- **Flutter** 3.19+ / **Dart** 3.3+
- **provider** — zarządzanie stanem (każdy moduł = `ChangeNotifier`)
- **shared_preferences** — wersjonowana persystencja (schema v1)
- **flutter_localizations + intl** — i18n PL/EN (PL kompletne,
  EN szkielet z `[EN]` sentinelem)
- **audioplayers** — ambient/tension loops + SFX
- **geolocator + geocoding** — opt-in, opcjonalna lokalizacja
  dla immersji stalker-threadu
- **google_fonts** — typografia
- **fake_async** (dev) — testy z timerami

## Struktura projektu

```
lib/
  main.dart                        # bootstrap, MultiProvider, hooków fabuły
  l10n/
    arb/{app_pl.arb, app_en.arb}   # tłumaczenia
    gen/                           # AppLocalizations (generowane)
    l10n_extensions.dart           # context.l10n, fallbackToPl
  services/
    persistence_service.dart       # versioned SharedPreferences (game.* / settings.* / meta.*)
    audio_service.dart             # ambient/tension loops + SFX
    location_service.dart          # opt-in only
    l10n_service.dart              # runtime locale switch
  state/                           # 14 ChangeNotifier-ów
    phone_state.dart
    photos_state.dart
    notes_state.dart
    messages_state.dart            # threads + dialogue graph + gating
    notifications_state.dart
    ending_state.dart              # 9 zakończeń + discoveredEndings
    files_state.dart
    browser_state.dart             # public + private mode unlock
    chapter_state.dart             # Chapter.one/two/three
    settings_state.dart            # toggles + lastPlayedAt + currentRunStartedAt
    trust_state.dart               # NEW
    evidence_state.dart            # NEW
    flags_state.dart               # NEW
    email_state.dart               # NEW + email puzzle
    recorder_state.dart            # NEW + voice match puzzle
    maps_state.dart                # NEW + route puzzle
    achievements_state.dart        # NEW (14 entries)
    new_game_plus_state.dart       # NEW (meta progression)
    signal_puzzle_state.dart       # NEW (Chapter 3 mini-puzzle)
    evidence_mapping.dart          # content-id → evidence-id mapping
  widgets/
    status_bar.dart
    numeric_keypad.dart
    notification_banner.dart
    ending_overlay.dart            # statystyki + epilog
    glitch_overlay.dart            # respect reducedMotion
    chapter_transition_overlay.dart
    scare_overlay.dart             # respect reducedMotion
    pause_overlay.dart             # NEW
    welcome_back_overlay.dart      # NEW (po 24h)
    fragment_hotspot.dart          # NEW (email puzzle)
    phone_shell_events.dart        # NEW (InheritedWidget event bus)
  screens/
    boot_screen.dart
    intro_screen.dart
    lock_screen.dart
    home_screen.dart               # 12 apps + Signal w Chapter 3
    content_warning_screen.dart    # NEW (first launch)
    new_game_plus_choice_screen.dart  # NEW (NG+ boot picker)
    signal_puzzle_screen.dart      # NEW (Chapter 3)
    messages/{messages_list_view,chat_view}.dart
    photos/{photos_grid_view,photo_detail_view,photo_thumbnail}.dart
    notes/notes_view.dart
    settings/{settings_view,about_view}.dart
    files/files_view.dart
    browser/browser_view.dart
    calendar/calendar_view.dart
    contacts/contacts_view.dart
    email/email_view.dart
    maps/maps_view.dart
    recorder/recorder_view.dart
    phone/phone_view.dart
    endings/endings_gallery_view.dart  # NEW (9 kafelków)
    achievements/achievements_view.dart # NEW (14 kafelków)
assets/
  images/, images/photos/          # tapety + zdjęcia (placeholdery)
  audio/                           # ambient, tension, SFX (placeholdery)
  icon.png                         # ikona launchera
test/                              # 183 testy
  services/persistence_service_test.dart
  state/*_test.dart                # 14 plików testowych
  l10n/l10n_test.dart
.kiro/specs/offline-full-release/  # spec dla wersji 1.0
docs/
  STORY_GRAPH.md                   # graf fabularny + zakończenia + szyfry
  PRIVACY.md                       # szkic polityki prywatności
tools/
  generate_audio.py                # placeholder audio generator
```

## Uruchomienie

```bash
flutter pub get
flutter gen-l10n              # generuje AppLocalizations
flutter run
```

## Testy i jakość kodu

```bash
flutter analyze               # 0 issues policy
flutter test                  # 183 unit testy
flutter test --coverage       # raport pokrycia (≥70% dla state)
```

## Persystencja — namespace'y

Save w `SharedPreferences` z trzema namespace'ami:

- `game.*` — postęp rozgrywki. Czyszczone przy "Resetuj rozgrywkę".
- `settings.*` — preferencje użytkownika (język, mute, motion,
  haptics, telemetry, locationOptIn). Zachowane przy reset.
- `meta.*` — progresja krzyżowa (NG+ runCount, previousEndings,
  cycleHinted, achievements, discoveredEndings). Zachowane
  przy reset.

Schema versioning umożliwia bezpieczną migrację schematu między
buildami. Aktualna wersja: `currentSchemaVersion = 1`.

## Lokalizacja

Plik źródłowy: `lib/l10n/arb/app_pl.arb`. Plik EN
(`lib/l10n/arb/app_en.arb`) zawiera klucze z prefixem `[EN] `;
helper `fallbackToPl()` rozpoznaje go i wraca do polskiego.

Aby dodać klucz:
1. Dopisz w `app_pl.arb` i `app_en.arb` (z prefixem `[EN] `).
2. `flutter gen-l10n`.
3. Użyj jako `context.l10n.mojKlucz`.

## Przejście dema

### Pierwsze uruchomienie

1. **Content warning** — toggle "Używaj lokalizacji", info o tematyce 13+
2. **Intro + boot screen**
3. **Lock screen** — PIN: `1984`

### Rozdział 1 — wieczór

1. Wiadomości → Nieznany → wybierz dowolną gałąź
2. Zdjęcia → ciemne zdjęcie z lasu → Info → kod `7309`
3. Notatki → "PRZECZYTAJ W RAZIE..." → PIN `7309`
4. ~20s później: Sheriff banner → ~1s później: panika Mamy
5. Sheriff dialogue (4 choices): ZŁAPANY / UCIECZKA / PRAWDA-ścieżka
   / KORUPCJA (wymaga evidence ≥ 50)

### Rozdział 2 — świt (po ≥4 plikach w Plikach)

6. Pliki → otwórz wszystkie 5 dokumentów (overlay "8 GODZIN PÓŹNIEJ"
   po 4. pliku)
7. Pojawia się T.W. (sąsiad)
8. W transkrypcji znajdź `14:22` → notatka "PLAN B" → PIN `1422`
9. Tomasz dialogue → ŚWIT (wymaga evidence ≥ 120)

### Łamigłówki (zwiększają evidence)

- **Browser private mode** — hasło `mruczek2019` z notatki "Hasła Wi-Fi"
- **Voice match w Dyktafonie** — 3 anonimowe głosy → kontakty
- **Route reconstruction w Mapach** — 5 lokacji w kolejności
- **Email recovery** — 5 fragmentów long-press w 5 ekranach

### Rozdział 3 — po świcie (NG+ tylko)

Otwiera się gdy gracz w aktywnym NG+ runie dotrze do TRUTH lub DAWN.
Zamiast terminal endingu pojawia się prokurator R. Player wybiera:

- **Mam dowody, chcę zeznawać oficjalnie** → ŚWIADEK
- **Wolę depozyt anonimowy** → CIEŃ
- **Czy mogę liczyć na ochronę świadka?** (wymaga Signal puzzle)
  → ŚWIADEK z lepszą ochroną

**Signal puzzle:** hasło `koperta1422` z notatek + transkrypcji.

### NG+ i CYKL

Po pierwszym ukończeniu, przy następnym uruchomieniu app pokazuje
choice screen "Nowa gra" / "Kontynuuj NG+". W NG+:
- Nieznany ma 7 wariantów openerów zależnych od poprzedniego endingu
- Po 3 min Nieznany wspomina o pętli → unlock CYKL choice w Sheriff
  dialogue (wymaga `runCount >= 2`)

### Reset

Ustawienia → "Resetuj rozgrywkę" — kasuje `game.*`, zachowuje
`settings.*` i `meta.*`. Gracz wraca do lock screen, NG+ pozostaje
opcją na następny launch.

## Pauza i nawigacja meta

- **Long-press na home indicator** → pause overlay
  (Wznów / Ustawienia / Zakończenia / Osiągnięcia)
- **Welcome back** po >24h przerwy — recap "Co się dotąd wydarzyło"
- **Hint system** — co 30s sprawdzamy idle; po 5 min (lub 90s
  w guided mode) Nieznany wysyła kontekstowy hint

## Roadmapa do v1.0

Co zostało do release na Google Play:

### Faza 3 — Release polish

- [ ] Finalne assety audio (loops + 7 SFX z atrybucjami CC0/CC-BY)
- [ ] Finalne zdjęcia (8 fotorealistycznych z Unsplash/Pexels)
- [ ] 2 tapety (lock + home) + adaptive launcher icon (432×432 dp)
- [ ] In-App Purchase: `offline_full_unlock` (Free chapter 1, paid 2+3)
- [ ] Telemetria opt-in (Sentry, beforeSend strip PII)
- [ ] WCAG AA audyt kontrastu + dynamic font scaling test
- [ ] Build config: `app_bundle`, signing, R8/ProGuard rules
  dla audioplayers/geolocator
- [ ] Play App Signing setup
- [ ] Pre-launch report — 0 stability errors na 5 wirtualnych Android
- [ ] Closed Testing track — min. 5 testerów × 30+ min sesja
- [ ] Polityka prywatności na GitHub Pages
- [ ] Play Store listing: tytuł, krótki/długi opis, 4 screenshoty,
  feature graphic 1024×500, opcjonalny trailer
- [ ] CI/CD — GitHub Actions: analyze + test on push, build aab
  + upload do Play Internal Track na tag

### Lokalizacja EN

PL jest kompletne. EN ma szkielet ze wszystkimi kluczami pod
`[EN]` sentinelem. Faktyczne tłumaczenie:
1. Przepisz wartości w `lib/l10n/arb/app_en.arb` (usuń `[EN] ` prefix)
2. Lokalizacja dialogów w MessagesState — wymaga refaktoru content
   layer (rozdzielenie content od state, zad. 4 w spec/tasks.md)
3. `flutter gen-l10n`

### Episodic / Saga (post v1.0)

W spec opisany jako Faza C — pojedyncze epizody jako kolejne
"telefony" w hub-screen, cross-references między episodami.
Architektura już to wspiera (state classes są epizod-agnostyczne).

## Dokumentacja techniczna

- `docs/STORY_GRAPH.md` — pełny graf dialogów, postaci, zakończeń,
  hooków narracyjnych, szyfrów
- `docs/PRIVACY.md` — szkic polityki prywatności
- `CHANGELOG.md` — Keep-a-Changelog
- `.kiro/specs/offline-full-release/` — spec wersji komercyjnej
  (requirements / design / tasks)
