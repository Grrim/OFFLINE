# Plan zadań — OFFLINE 1.0

Implementacja w trzech fazach. Każda faza kończy się działającą,
testowalną wersją. Numery kryteriów (np. `req 4.1`) odsyłają do
`requirements.md`.

## Faza 1 — Foundation (technika)

- [x] 1. Czyszczenie kodu — 0 lint warnings
  - [x] 1.1 `dart fix --apply` na całym projekcie
  - [x] 1.2 Naprawa 2 `BuildContext` async gaps w `main.dart` (linie ~676, 679)
  - [x] 1.3 Ręczna poprawka pozostałych `prefer_const_constructors` w `email_view.dart`, `home_screen.dart`
  - [x] 1.4 `flutter analyze` musi zwrócić 0 issues
  - _Kryteria: req 4.1, 4.3_

- [x] 2. Wersjonowanie persystencji + helper
  - [x] 2.1 Dodać `PersistenceSchema.migrate()` do `persistence_service.dart`
  - [x] 2.2 Wprowadzić prefiksy kluczy (`game.*`, `settings.*`)
  - [x] 2.3 Wymigrować istniejące klucze pod nowe prefiksy
  - [x] 2.4 `reset()` w state'ach kasuje tylko `game.*`, zachowuje `settings.*`
  - [x] 2.5 Test jednostkowy migracji wersji 0→1
  - _Kryteria: req 4.6, 4.7_

- [x] 3. Testy jednostkowe — moduły istniejące
  - [x] 3.1 `test/state/messages_state_test.dart` — selectChoice, runNode, cold-load
  - [x] 3.2 `test/state/notes_state_test.dart` — tryUnlock, replay
  - [x] 3.3 `test/state/files_state_test.dart` — markOpened, threshold
  - [x] 3.4 `test/state/photos_state_test.dart` — markInspected callback
  - [x] 3.5 `test/state/ending_state_test.dart` — trigger, persist, reset
  - [x] 3.6 `test/state/chapter_state_test.dart` — advance idempotency
  - [x] 3.7 `test/state/browser_state_test.dart` — markVisited
  - [x] 3.8 Pokrycie ≥ 70% dla powyższych
  - _Kryteria: req 4.2_

- [ ] 4. Wydzielenie content layer (odłożone — robię razem z Fazą 2)
  - [ ] 4.1 Utworzyć `lib/content/` (dialogues, photos, files, notes, browser, emails, recordings, maps)
  - [ ] 4.2 Przenieść seed data ze state do content
  - [ ] 4.3 State woła `Content.loadX()` w `_seed()`
  - [ ] 4.4 Test fixtures używają `Content.testFixtures` z mniejszym datasetem
  - _Cel: testowalność, multi-locale w przyszłości_

- [x] 5. Internationalization — szkielet
  - [x] 5.1 Dodać `flutter_localizations`, `intl` do `pubspec.yaml`
  - [x] 5.2 Skonfigurować `l10n.yaml`, generator ARB
  - [x] 5.3 `lib/l10n/intl_pl.arb` — pierwszy zestaw kluczy (UI chrome: lock screen, settings, ending titles)
  - [x] 5.4 `lib/l10n/intl_en.arb` — placeholder `[EN] {pl_value}`
  - [x] 5.5 `L10nService` z `ChangeNotifier`
  - [x] 5.6 `MaterialApp.locale` podpięty przez `ListenableBuilder`
  - [x] 5.7 Helper `fallbackToPl` + extension `context.l10n`
  - [x] 5.8 Migracja `settings_view.dart` jako proof
  - _Kryteria: req 5.1-5.7_

- [x] 6. Settings refaktor
  - [x] 6.1 Utworzyć `SettingsState` (mute, reducedMotion, haptics, guidedMode, telemetry, locale, consents, hasCompletedOnce)
  - [x] 6.2 Dodać `ChangeNotifierProvider<SettingsState>` do `main.dart`
  - [x] 6.3 Przepisać `settings_view.dart` na nowe pola
  - [x] 6.4 Audio mute zsynchronizowane z SettingsState (jednokierunkowo)
  - [ ] 6.5 GlitchOverlay/ScareOverlay/ringer respektujące `reducedMotion`/`haptics` — TODO przed releasem
  - _Kryteria: req 8.4, 8.5, 9.6_

- [x] 7. Dokumentacja techniczna
  - [x] 7.1 Aktualizacja `README.md` do faktycznego stanu (nowe ekrany, geolocator, i18n, schema, settings)
  - [x] 7.2 Utworzenie `CHANGELOG.md` (Keep-a-Changelog)
  - [x] 7.3 Utworzenie `docs/STORY_GRAPH.md` ze schematami dialogów + warunkami zakończeń
  - [x] 7.4 Utworzenie `docs/PRIVACY.md` szkic polityki prywatności
  - _Kryteria: req 12.2, 12.3, 12.4, 7.3_

## Faza 2 — Content & Mechaniki

- [x] 8. TrustState
  - [x] 8.1 Implementacja `state/trust_state.dart` (4 NPC, clamp, persist)
  - [x] 8.2 `DialogueChoice.trustDeltas` + `requiresMinTrust`
  - [x] 8.3 `MessagesState.selectChoice` aplikuje deltas, blokuje hidden choices
  - [x] 8.4 Migracja istniejących dialogów — przypisanie `trustDeltas` do każdego choice
  - [x] 8.5 UI: wyszarzony choice z ikoną kłódki gdy warunek niespełniony
  - [x] 8.6 Testy: apply/clamp/blocking
  - _Kryteria: req 3.1-3.5_

- [x] 9. EvidenceState
  - [x] 9.1 Implementacja `state/evidence_state.dart` z catalog + weights + thresholds
  - [x] 9.2 Hooki w `PhotosState`, `FilesState`, `BrowserState` na collect (przez `EvidenceMapping`)
  - [x] 9.3 Gating w Anita TRUTH dialogue: `requiresMinEvidence: 80`
  - [x] 9.4 Gating w Tomasz DAWN dialogue: `requiresMinEvidence: 120`
  - [x] 9.5 Testy: collect, score, threshold
  - _Kryteria: req 1.4, 2.7_

- [x] 10. EmailState + Email-puzzle "Recover deleted message"
  - [x] 10.1 Implementacja `state/email_state.dart` (inbox + trash fragments)
  - [x] 10.2 Refaktor `email_view.dart` z hardcode na state-driven
  - [x] 10.3 Definicja 5 fragmentów ukrytych w 5 ekranach
        (Notatki/Zakupy, Kalendarz/Pt 16maja, Mapy/Las Kabacki,
        Browser/Sygnal, Settings/footer)
  - [x] 10.4 SFX + snackbar feedback ("Fragment odzyskany. Sprawdź Pocztę.")
  - [x] 10.5 Po 5/5 — _RecoveredEmailTile z assembled body + flag
  - [x] 10.6 Hook do `EvidenceState`: collect `email_recovered`
  - [x] 10.7 Testy (8/8)

- [x] 11. RecorderState + Voice-match-puzzle
  - [x] 11.1 Implementacja `state/recorder_state.dart`
  - [x] 11.2 Refaktor `recorder_view.dart` na state-driven
  - [x] 11.3 BottomSheet "Czyj to głos?" z listy kontaktów
  - [x] 11.4 3 nagrania, 3 dopasowania (Anita, K., Tomasz B.)
  - [x] 11.5 Po complete — flag `puzzle.voices_matched` + Nieznany hint
  - [x] 11.6 Hook do `EvidenceState`: collect `voices_matched` + per-recording
  - [x] 11.7 Testy (12/12)

- [x] 12. MapsState + Route-reconstruction-puzzle
  - [x] 12.1 Implementacja `state/maps_state.dart` z timestampami
  - [x] 12.2 Refaktor `maps_view.dart` z drag-reorder ReorderableListView
  - [x] 12.3 Sprawdzenie poprawności kolejności (chronologicznie)
  - [x] 12.4 Po complete — flag `puzzle.route_reconstructed` + Nieznany
  - [x] 12.5 Hook do `EvidenceState`: collect `route_reconstructed`
  - [x] 12.6 Testy (10/10)

- [x] 13. BrowserState — private mode unlock (zrobione w poprzedniej sesji)

- [x] 14. Dwa nowe zakończenia (zrobione w poprzedniej sesji)

- [x] 15. Rozdział 3 "Po świcie"
  - [x] 15.1 `Chapter.three` w `ChapterState` z `advanceToChapter3()`
        gated od chapter 2 only
  - [x] 15.2 Trigger: TRUTH/DAWN ending w NG+ run → chapter 3 unlock
        zamiast terminal ending
  - [x] 15.3 `MessagesState.triggerProsecutorDialog()` — wątek
        `prokurator` z 4 nodes (opener, protection_q, witness_path, shadow_path)
  - [x] 15.4 `SignalPuzzleState` — mini-puzzle dekodowania (`koperta1422`),
        gated choice "ochrona świadka" wymaga `puzzle.signal_decoded`
  - [x] 15.5 `SignalPuzzleScreen` — Signal-style sign-in z text input
  - [x] 15.6 Signal app na home grid, widoczna tylko w Chapter 3
  - [x] 15.7 2 nowe zakończenia: **ŚWIADEK** (publiczne zeznanie),
        **CIEŃ** (depozyt anonimowy)
  - [x] 15.8 Achievements: `witness_path`, `shadow_path`
  - [x] 15.9 Hint system aktualizuje hint dla Chapter 3
        (Signal puzzle priorytetowy)
  - [x] 15.10 Welcome-back overlay rozpoznaje Chapter 3
  - [x] 15.11 Stats overlay pokazuje czas rozgrywki + 5 puzzli
  - [x] 15.12 Testy (8/8 chapter, 6/6 signal)

- [x] 16. New Game+
  - [x] 16.1 `state/new_game_plus_state.dart` — runCount, isPlusActive,
        previousEndings, cycleHinted, persistencja pod `meta.*`
  - [x] 16.2 `NewGamePlusChoiceScreen` — boot-time wybór "Nowa gra" vs
        "Kontynuuj NG+", pokazany przy każdym launchu gdy canStartPlus
  - [x] 16.3 Meta-narracja Nieznanego — opener + "rób to lepiej tym razem",
        wariant zależny od `previousEndings.last` (7 wariantów)
  - [x] 16.4 7. ukryte zakończenie **CYKL** — ujawnia że gra to pętla,
        choice w Sheriff dialogue gated przez `meta.cycle_available`
        (wymaga isPlusActive + runCount>=2 + cycleHinted)
  - [x] 16.5 Cycle hint dropped 3 min into NG+ run → `markCycleHinted()`
  - [x] 16.6 Achievement `cycle` (secret) unlock przy ending CYKL
  - [x] 16.7 Galeria zakończeń — secret hideContent rendering
  - [x] 16.8 Reset rozgrywki wywołuje `leavePlusRun()` (gracz może
        wrócić do NG+ przy następnym uruchomieniu)
  - [x] 16.9 Testy (8/8)
  - _Kryteria: req 1.5_

- [x] 17. Galeria zakończeń + statystyki
  - [x] 17.1 `EndingsGalleryView` z 6 kafelkami
  - [x] 17.2 Ekran reader dla każdego zakończenia
  - [x] 17.3 Wejście z pause overlay
  - [x] 17.4 Persystencja `discoveredEndings`
  - [x] 17.5 Testy
  - [x] 17.6 Statystyki w ending overlay (Pliki, Wskazówki, Dowody, Łamigłówki, Zakończenie)

- [x] 18. Pauza globalna (zrobione w poprzedniej sesji)

- [x] 19. Streszczenie po przerwie 24h
  - [x] 19.1 Tracking `lastPlayedAt` w SettingsState
  - [x] 19.2 Po >24h — `WelcomeBackOverlay` "Co się dotąd wydarzyło"
  - [x] 19.3 Treść generowana ze stanu (rozdział, notatki, dowody, trust, puzzle)

- [x] 20. Hint system
  - [x] 20.1 `_lastInteractionAt` tracking w shell
  - [x] 20.2 Co 30s sprawdzamy idle; po 5 min → kontekstowy hint Nieznanego
  - [x] 20.3 Tryb prowadzony (toggle w Settings) — hinty co 90s
  - [x] 20.4 Hint dynamicznie wybiera następny krok bazując na stanie

- [x] 21. Achievements
  - [x] 21.1 Implementacja `state/achievements_state.dart`
  - [x] 21.2 Katalog 12 osiągnięć (first_unlock, curious, detective, investigator,
        speedrun, pacifist, truth_teller, dawn_walker, all_endings, paranoid,
        mama_loyal, cycle [secret])
  - [x] 21.3 Hooki w shell na trigger ending → evaluate achievements
  - [x] 21.4 Ekran `AchievementsView` z lockowaniem + secret rendering
  - [x] 21.5 Toast (banner) na unlock przez NotificationsState
  - [x] 21.6 Wejście z pause overlay (gdy `unlockedCount > 0`)
  - [ ] 21.7 (Opcjonalnie) Integracja z Play Games Services — Faza 3

- [ ] 10. EmailState + Email-puzzle "Recover deleted message"
  - [ ] 10.1 Implementacja `state/email_state.dart` (inbox + trash fragments)
  - [ ] 10.2 Refaktor `email_view.dart` z hardcode na state-driven
  - [ ] 10.3 Definicja 5 fragmentów ukrytych w 5 ekranach (Notatki, Kalendarz, Mapy, Browser, Settings)
  - [ ] 10.4 Animacja "fragment found" (krótki flash + sfx)
  - [ ] 10.5 Po 5/5 fragmentach — odsłonięcie 6. wiadomości od Anity z prośbą o miejsce spotkania
  - [ ] 10.6 Hook do `EvidenceState`: collect `email_recovered`
  - [ ] 10.7 Testy
  - _Kryteria: req 2.1, 2.2_

- [ ] 11. RecorderState + Voice-match-puzzle
  - [ ] 11.1 Implementacja `state/recorder_state.dart` (recordings + voiceAssignments)
  - [ ] 11.2 Refaktor `recorder_view.dart`
  - [ ] 11.3 Dropdown "Kto to mówi?" w detail view (lista z Kontaktów)
  - [ ] 11.4 3 nagrania, 3 poprawne dopasowania
  - [ ] 11.5 Po complete — odsłonięcie ukrytej sceny (dodatkowy dialog Tomasza w rozdziale 2)
  - [ ] 11.6 Hook do `EvidenceState`
  - [ ] 11.7 Testy
  - _Kryteria: req 2.1, 2.4_

- [ ] 12. MapsState + Route-reconstruction-puzzle
  - [ ] 12.1 Implementacja `state/maps_state.dart` (locations + ordered route)
  - [ ] 12.2 Refaktor `maps_view.dart` na drag-reorder list
  - [ ] 12.3 Sprawdzenie poprawności kolejności
  - [ ] 12.4 Po complete — nowa opcja w dialogu z Anitą "Wiem dokąd N. szła"
  - [ ] 12.5 Hook do `EvidenceState`
  - [ ] 12.6 Testy
  - _Kryteria: req 2.1, 2.3_

- [ ] 13. BrowserState — private mode unlock
  - [ ] 13.1 Dodanie `_privateUnlocked` do `BrowserState`
  - [ ] 13.2 UI keypad/text-entry dla hasła
  - [ ] 13.3 Hint w dialogu Nieznanego (po inspekcji konkretnej notatki)
  - [ ] 13.4 Po unlock — visible 4 zablokowane wpisy z `isPrivate: true`
  - [ ] 13.5 Testy
  - _Kryteria: req 2.5_

- [ ] 14. Dwa nowe zakończenia (SAMOTNIA, KORUPCJA)
  - [ ] 14.1 Dodanie definicji do `ending_state.dart` catalog
  - [ ] 14.2 Logika triggerów na podstawie `(trust, evidence)`:
    - SAMOTNIA: trust < -50 dla wszystkich + ścieżka choice_dumb
    - KORUPCJA: nowy choice w Sheriff dialogue "Ile zapłacisz za ciszę?"
  - [ ] 14.3 Texty epilogów
  - [ ] 14.4 Tłumaczenie do ARB
  - [ ] 14.5 Testy: ending dispatch
  - _Kryteria: req 1.2, 3.4_

- [ ] 15. Rozdział 3 "Po świcie"
  - [ ] 15.1 Rozszerzenie `ChapterState` o `Chapter.three`
  - [ ] 15.2 Trigger: po zakończeniu DAWN/TRUTH gracz może wybrać "kontynuuj"
  - [ ] 15.3 Nowe wątki: prokurator (interaktywny), redaktor naczelny (non-interactive), nowe NPC
  - [ ] 15.4 2 nowe puzzle: rozszyfrowanie kodu Signal + analiza dat z pełnomocnictwa
  - [ ] 15.5 Finałowa decyzja: zeznawać publicznie czy anonimowo
  - [ ] 15.6 Konsekwencje fabularne (epilog z 2 podściankami)
  - _Kryteria: req 1.1_

- [ ] 16. New Game+
  - [ ] 16.1 Flag `hasCompletedOnce` w `SettingsState`
  - [ ] 16.2 Po pierwszym ukończeniu — przy rozpoczęciu nowej gry pytanie "kontynuuj NG+"
  - [ ] 16.3 W NG+ Nieznany ma dodatkowe linie meta-narracyjne ("Już to widziałeś, prawda?")
  - [ ] 16.4 Odblokowane jedno ukryte zakończenie (CYKL — Nieznany ujawnia że gra to symulacja)
  - _Kryteria: req 1.5_

- [ ] 17. Galeria zakończeń + statystyki
  - [ ] 17.1 Nowy ekran `EndingsGalleryView`, dostępny z home po pierwszym ukończeniu
  - [ ] 17.2 Render 6 kafelków, niedostępne zaczernione
  - [ ] 17.3 Statystyki na ending overlay: czas, % contentu, puzzle solved, kluczowe wybory
  - [ ] 17.4 Test
  - _Kryteria: req 1.6, 10.2, 10.3_

- [ ] 18. Pauza globalna
  - [ ] 18.1 Pause button w `StatusBar`
  - [ ] 18.2 Pause overlay z opcjami: Wznów, Ustawienia, Reset
  - [ ] 18.3 Wstrzymanie wszystkich timerów (sheriff countdown, scheduled NPC messages)
  - [ ] 18.4 Test
  - _Kryteria: req 8.6_

- [ ] 19. Streszczenie po przerwie 24h
  - [ ] 19.1 Tracking `lastPlayedAt` w SettingsState
  - [ ] 19.2 Przy resume po >24h — overlay "Co się dotąd wydarzyło"
  - [ ] 19.3 Treść generowana ze stanu (otwarte notatki, odkryte ścieżki, status NPCów)
  - _Kryteria: req 8.7_

- [ ] 20. Hint system
  - [ ] 20.1 `_lastInteractionAt` tracking w głównym shell
  - [ ] 20.2 Po 5 min idle w danym puzzlu — Nieznany wysyła kontekstowy hint
  - [ ] 20.3 Tryb prowadzony (toggle w Settings) — hinty co 90s
  - [ ] 20.4 Test
  - _Kryteria: req 2.6, 2.8_

- [ ] 21. Achievements
  - [ ] 21.1 Implementacja `state/achievements_state.dart`
  - [ ] 21.2 Definicja katalogu (12 achievementów)
  - [ ] 21.3 Hooki w odpowiednich state (Speedrun=czas, Detektyw=evidence==full, etc.)
  - [ ] 21.4 Ekran Galerii Achievementów
  - [ ] 21.5 (Opcjonalnie) Integracja z Play Games Services
  - _Kryteria: req 10.1_

## Faza 3 — Polish & Release

- [ ] 22. Finalne assety
  - [ ] 22.1 Audio: 2 loopy (ambient, tension) + 7 SFX z freesound.org (CC0/CC-BY)
  - [ ] 22.2 Atrybucje w "O grze"
  - [ ] 22.3 Zdjęcia: 8 fotorealistycznych z Unsplash/Pexels do `assets/images/photos/`
  - [ ] 22.4 2 tapety (lock, home) — spójne ciemne klimatyczne
  - [ ] 22.5 Adaptive icon (foreground + background, 432×432 dp)
  - [ ] 22.6 Lockscreen wallpaper (drobny detal, np. ostatnie zdjęcie z lasu jako tło)
  - _Kryteria: req 9.1-9.5_

- [x] 23. Permission flow lokalizacji
  - [x] 23.1 Rationale screen w `ContentWarningScreen` z toggle przed
        pierwszym `getCurrentPosition`
  - [x] 23.2 Toggle "Używaj lokalizacji" w Ustawieniach (sekcja Prywatność)
  - [x] 23.3 Stalker fallback gdy `!isOptedIn` — generyczne komunikaty
  - [x] 23.4 LocationService.setLocationOptIn() persistuje pod
        `settings.locationOptIn`
  - [ ] 23.5 Aktualizacja `AndroidManifest.xml` z usage description
        (TBD — przed pierwszym buildem release)
  - _Kryteria: req 7.1, 7.2_

- [x] 24. Privacy & Compliance (częściowo)
  - [ ] 24.1 Polityka prywatności w `docs/PRIVACY.md` + publikacja na
        GitHub Pages (TBD — przed Play Console submission)
  - [ ] 24.2 URL polityki w Play Console (TBD)
  - [x] 24.3 Privacy + content warning screen przy 1. uruchomieniu
        (`ContentWarningScreen`)
  - [x] 24.4 Content warning sekcja o tematyce gry
  - [x] 24.5 Ekran "O grze" z wersją, opisami, atrybucjami,
        `showLicensePage` dla pełnych licencji
  - [ ] 24.6 Data Safety form w Play Console (TBD)
  - _Kryteria: req 7.3-7.7_

- [ ] 25. IAP integration
  - [ ] 25.1 Dodać `in_app_purchase` do `pubspec.yaml`
  - [ ] 25.2 Implementacja `IapService`
  - [ ] 25.3 Konfiguracja produktu `offline_full_unlock` w Play Console
  - [ ] 25.4 Paywall screen (czysty, bez dark patterns)
  - [ ] 25.5 Gating: koniec rozdziału 1 → paywall
  - [ ] 25.6 Restore purchase w Settings
  - [ ] 25.7 Test sandbox account
  - _Kryteria: req 6.1-6.7_

- [ ] 26. Telemetria opt-in
  - [ ] 26.1 Sentry projekt + DSN
  - [ ] 26.2 `TelemetryService.init` w main, gated by `settings.telemetryOptIn`
  - [ ] 26.3 `beforeSend` callback strippujący PII
  - [ ] 26.4 Toggle w Settings "Wysyłaj raporty błędów"
  - [ ] 26.5 Test: zmienna włączona/wyłączona
  - _Kryteria: req 4.5, 7.8_

- [ ] 27. WCAG AA + dynamic font scaling
  - [ ] 27.1 Audyt kontrastu wszystkich tekstów (cel: ratio ≥ 4.5:1)
  - [ ] 27.2 Naprawa miejsc z białym 38% (= < 4.5:1)
  - [ ] 27.3 Sprawdzenie skalowania pod accessibility settings (Android textScaleFactor)
  - [ ] 27.4 Naprawa overflow przy skali 1.5x
  - _Kryteria: req 8.2, 8.3_

- [ ] 28. Build configuration
  - [ ] 28.1 `android/app/build.gradle.kts` — minSdk 23, targetSdk 34, ndkVersion
  - [ ] 28.2 ProGuard/R8 rules dla audioplayers, geolocator
  - [ ] 28.3 Generowanie keystore + zabezpieczenie
  - [ ] 28.4 Konfiguracja Play App Signing
  - [ ] 28.5 Wersjonowanie semantyczne (auto bump versionCode)
  - [ ] 28.6 Build aab w trybie release — test instalacji na fizycznym urządzeniu
  - _Kryteria: req 11.1, 11.2, 11.4, 11.7_

- [ ] 29. Play Store listing
  - [ ] 29.1 Tytuł: "OFFLINE — Zaginiona" (PL), TBD (EN)
  - [ ] 29.2 Krótki opis (≤ 80 zn) PL + EN
  - [ ] 29.3 Długi opis (≤ 4000 zn) PL + EN
  - [ ] 29.4 4 screenshoty (lock, chat, ending, app grid) — PL i EN
  - [ ] 29.5 Feature graphic 1024×500
  - [ ] 29.6 Trailer YT (30-60s) — opcjonalnie
  - _Kryteria: req 11.6_

- [ ] 30. CI / CD
  - [ ] 30.1 GitHub Actions workflow `ci.yml`: analyze + test on push
  - [ ] 30.2 GitHub Actions workflow `release.yml`: build aab on tag, upload do Play Internal Track
  - [ ] 30.3 Secrets: keystore base64, key passwords, Play service account JSON
  - _Kryteria: req 12.1_

- [ ] 31. Testy końcowe
  - [ ] 31.1 Closed Testing track w Play Console — min. 5 testerów, sesja 30+ min
  - [ ] 31.2 Pre-launch report — 0 stability errors
  - [ ] 31.3 Test pełnego playthrough wszystkich 6 zakończeń
  - [ ] 31.4 Test cold-load po każdej fazie progresu (notatka unlocked, files opened, chapter 2, ending shown)
  - [ ] 31.5 Test reset rozgrywki — wszystkie state'y wracają do seed
  - _Kryteria: Definition of Done_

- [ ] 32. Release v1.0
  - [ ] 32.1 Tag `v1.0.0`, push, automatyczny build
  - [ ] 32.2 Promote z Closed Testing do Production
  - [ ] 32.3 Update CHANGELOG.md
  - [ ] 32.4 Komunikacja: post o premierze (opcjonalnie)
