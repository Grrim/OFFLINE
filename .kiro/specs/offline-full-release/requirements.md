# Wymagania — OFFLINE 1.0 (wersja komercyjna)

## Wprowadzenie

OFFLINE to mobilna gra "found phone / fake OS" osadzona w polskich realiach,
zbudowana w Flutterze. Aktualny stan to grywalne demo (~20–30 min, 4
zakończenia, 1 prawdziwa zagadka). Celem tego speca jest rozwinięcie
projektu do **pełnej, komercyjnej wersji 1.0** publikowanej na **Google
Play Store**, z polską premierą i przygotowaną lokalizacją EN do
późniejszego przełączenia.

### Cele biznesowe

- Komercyjny tytuł single-player z monetyzacją premium (płatna gra
  z opcjonalnym darmowym demo) lub freemium z odblokowaniem epizodów.
- Czas rozgrywki przy pierwszym przejściu: **2–4 godziny** (vs. obecne
  20–30 min).
- Powtarzalność: ≥ 3 sensowne przejścia, łącznie 4–6 godzin treści.
- Wartość sprzedażowa: trzymające się gry typu *Sara Is Missing* /
  *Simulacra* (cena 15–30 PLN, oczekiwana ocena ≥ 4.2 na Play).
- 0 mechanik dark-pattern, 0 reklam, 0 trackingu poza Google Play
  standard.

### Zakres ogólny

Spec obejmuje cztery równoległe ścieżki rozwoju:

1. **Treść narracyjna** — rozszerzenie fabuły, dodanie nowych zakończeń,
   prawdziwych zagadek w aplikacjach, systemu konsekwencji.
2. **Polish techniczny** — testy, linty, refaktor `BuildContext`-async,
   poprawne obsługi permission flow, asset pipeline.
3. **Komercjalizacja** — lokalizacja, monetyzacja, GDPR/prywatność,
   Play Console, signing, store listing.
4. **Game feel & assets** — finalne audio (lektor, ambient, SFX),
   grafiki, ikona launchera, animacje przejść.

### Założenia

- Język premiery: **polski** (wszystkie obecne treści są PL).
- Lokalizacja **angielska** ma być przygotowana strukturalnie (system
  i18n, wszystkie stringi w plikach `.arb`), ale tłumaczenie zostanie
  uzupełnione później — tu definiujemy fundament i kryteria gotowości.
- Platforma premiery: **Google Play Store** (Android). iOS poza zakresem
  v1.0, ale architektura nie ma zamykać tej drogi.
- Stack pozostaje Flutter + Dart, Provider, SharedPreferences. Dochodzą
  zależności na lokalizację, IAP i logging błędów.

---

## Wymagania

### 1. Rozszerzenie zawartości narracyjnej

**User story:** Jako gracz chcę dłuższej, głębszej historii z wieloma
ścieżkami i prawdziwymi konsekwencjami moich wyborów, żebym miał powód
zagrać więcej niż raz i polecić grę znajomym.

#### Kryteria akceptacji

1. WHEN gracz uruchamia nową rozgrywkę THEN system SHALL zapewnić co
   najmniej **3 rozdziały** narracyjne (obecne 2 + nowy rozdział 3
   "Po świcie").
2. WHEN gracz ukończy grę THEN system SHALL prezentować jedno z co
   najmniej **6 unikalnych zakończeń** (obecne 4 + 2 nowe: np. SAMOTNIA
   i KORUPCJA).
3. WHEN gracz dokonuje wyboru dialogowego THEN system SHALL aktualizować
   wewnętrzny stan zaufania (`TrustState`) co najmniej dla 4 postaci
   (Mama, Anita, Tomasz, Nieznany), a poziom zaufania SHALL wpływać na
   dostępność opcji dialogowych w późniejszych scenach.
4. WHEN gracz przegląda dowody (Pliki, Zdjęcia, Dyktafon, Poczta) THEN
   system SHALL akumulować punkty `evidenceScore`. IF `evidenceScore` <
   wymaganego progu THEN ścieżka PRAWDA / ŚWIT SHALL nie być dostępna.
5. WHEN gracz zaczyna nową rozgrywkę po ukończeniu pierwszego przejścia
   THEN system SHALL aktywować tryb **New Game+** odblokowujący
   dodatkowe sceny, co najmniej 1 ukryte zakończenie i komentarze
   meta-narracyjne od postaci "Nieznany".
6. WHEN gracz odblokuje którekolwiek zakończenie THEN system SHALL
   dodać je do "Galerii zakończeń" dostępnej z ekranu głównego po
   pierwszym ukończeniu gry.
7. The system SHALL utrzymać tonację narracyjną i poziom merytoryczny
   obecnego dema (osadzenie w polskich realiach, mocne dialogi,
   antykorupcyjny temat).

### 2. Prawdziwe zagadki w aplikacjach telefonu

**User story:** Jako gracz chcę odkrywać tajemnice rozwiązując
łamigłówki w aplikacjach telefonu, a nie tylko klikając "kontynuuj"
w dialogach.

#### Kryteria akceptacji

1. The system SHALL zawierać co najmniej **6 niezależnych puzzli**
   rozłożonych w aplikacjach telefonu, w tym minimum jeden w każdej
   z aplikacji: Zdjęcia, Notatki, Pliki, Poczta, Dyktafon, Mapy.
2. WHEN gracz otwiera Pocztę THEN system SHALL prezentować mechanikę
   "odzyskiwania usuniętej wiadomości" wymagającą połączenia 3+
   fragmentów rozsianych po innych aplikacjach.
3. WHEN gracz otwiera Mapy THEN system SHALL umożliwić rekonstrukcję
   trasy N. z timestampów Kalendarza, Zdjęć i Dyktafonu, a poprawna
   rekonstrukcja SHALL odblokować dodatkową opcję dialogową w Anitą.
4. WHEN gracz otwiera Dyktafon THEN system SHALL wymagać dopasowania
   3 anonimowych głosów do osób z Kontaktów (na podstawie tekstowych
   wskazówek w transkrypcjach), przy czym poprawne dopasowanie wszystkich
   SHALL odblokować dodatkową scenę.
5. WHEN gracz otwiera przeglądarkę w trybie prywatnym THEN system SHALL
   wymagać hasła znalezionego w innej notatce, a wpisanie hasła SHALL
   odsłonić ukryte historie i materiały dowodowe.
6. The system SHALL zapewnić wbudowany system podpowiedzi: po **5
   minutach bezczynności w danym puzzlu**, postać "Nieznany" SHALL
   wysłać hint adekwatny do aktualnego progresu.
7. WHEN gracz rozwiąże każdą łamigłówkę THEN system SHALL przyznawać
   `evidenceScore` adekwatny do trudności.
8. IF gracz całkowicie utknie THEN gracz SHALL móc opcjonalnie włączyć
   "tryb prowadzony" w ustawieniach, który automatycznie wysyła hinty
   Nieznanego co 90 sekund — dostępny z menu, nie domyślny.

### 3. System zaufania i moralnych konsekwencji

**User story:** Jako gracz chcę, żeby moje wybory miały sens i widoczne
konsekwencje, a nie żeby zakończenie zależało od jednego klika pod
koniec gry.

#### Kryteria akceptacji

1. The system SHALL śledzić zmienną `trust` w zakresie -100..+100 dla
   każdej z 4 postaci kluczowych: Mama, Anita Z., Tomasz W., Nieznany.
2. WHEN gracz wybiera odpowiedź dialogową THEN system SHALL modyfikować
   `trust` wybranej postaci o wartość zdefiniowaną w grafie dialogowym
   (od -20 do +20 punktów na decyzję).
3. WHEN postać NPC chce ujawnić informację krytyczną (kod, hasło, lokację)
   THEN system SHALL zezwolić na to wyłącznie IF `trust` ≥ progu
   zdefiniowanego dla danej kwestii.
4. WHEN gracz dociera do finałowych dialogów THEN system SHALL
   determinować dostępne zakończenia na podstawie wektora
   `(trust_mama, trust_anita, trust_tomasz, evidenceScore)`, a nie
   pojedynczego wyboru.
5. The system SHALL pokazywać aktualny stan zaufania **niejawnie** —
   przez zmiany w tonie odpowiedzi NPC, nie przez liczby na ekranie.
6. WHEN gracz ukończy grę THEN ekran zakończenia SHALL podsumować
   kluczowe wybory i ich wpływ na finał ("Mama ci zaufała, ale Anita
   przestała", itp.).

### 4. Polish techniczny i jakość kodu

**User story:** Jako developer i wydawca, chcę żeby kod był testowalny,
stabilny i nadawał się do długiego utrzymania komercyjnego.

#### Kryteria akceptacji

1. The system SHALL przejść `flutter analyze` z **0 ostrzeżeniami**
   (obecnie: 14).
2. The system SHALL mieć pokrycie testami **≥ 70%** dla modułów
   krytycznych: `MessagesState`, `EndingState`, `NotesState`,
   `FilesState`, `ChapterState`, `PhotosState`, `TrustState` (nowy),
   `EvidenceState` (nowy).
3. WHEN aplikacja przechodzi przez async gap THEN system SHALL nigdzie
   nie używać `BuildContext` bez sprawdzenia `mounted` (obecnie 2
   takie miejsca w `main.dart`).
4. The system SHALL używać `intl` dla wszystkich stringów wyświetlanych
   użytkownikowi — żaden hardcoded string PL nie SHALL pozostać poza
   plikami `.arb`.
5. WHEN aplikacja zgłasza wyjątek krytyczny w produkcji THEN system
   SHALL przesyłać raport błędu (Crashlytics lub Sentry) **bez danych
   osobowych gracza** i **z opt-in z poziomu ustawień**.
6. The system SHALL przechowywać save w `SharedPreferences` z wersją
   schematu (obecnie nie ma wersjonowania), z migracją między wersjami
   schematu.
7. WHEN użytkownik resetuje rozgrywkę THEN system SHALL kasować
   wszystkie persystowane klucze gry, ale zachować ustawienia
   (język, dźwięk, tryb prowadzony, zgody).

### 5. Lokalizacja i internacjonalizacja

**User story:** Jako wydawca chcę wypuścić grę najpierw po polsku, ale
mieć fundament gotowy na angielski rynek bez refaktoru.

#### Kryteria akceptacji

1. The system SHALL używać `flutter_localizations` + ARB jako mechanizm
   tłumaczeń.
2. The system SHALL zawierać **kompletny plik `intl_pl.arb`** dla
   wszystkich stringów wyświetlanych w grze.
3. The system SHALL zawierać **plik `intl_en.arb` ze szkieletem** —
   wszystkie klucze są obecne, wartości to tymczasowe `[EN: ...]` lub
   wstępne tłumaczenia (bez wymogu finalnej jakości EN dla v1.0).
4. WHEN użytkownik zmieni język w Ustawieniach THEN system SHALL
   przeładować całą warstwę UI bez restartu aplikacji.
5. IF język urządzenia to angielski AND brak finalnego EN tłumaczenia
   THEN system SHALL **fallbackować do polskiego**, nie do kluczy ARB.
6. The system SHALL formatować daty, godziny i liczby zgodnie z
   wybranym `Locale`.
7. The system SHALL mieć "tryb developera języka" za 5 tapnięć w numer
   wersji (Ustawienia → O grze) odsłaniający przełącznik między PL i
   EN — do testów lokalizacji.

### 6. Monetyzacja i model dystrybucji

**User story:** Jako wydawca chcę modelu monetyzacji, który jest
szczery wobec gracza i wpisuje się w gatunek narrative-puzzle.

#### Kryteria akceptacji

1. The system SHALL wspierać model **"darmowe demo + płatna pełna gra"**
   przez Google Play In-App Purchase:
   - Darmowe: Rozdział 1 (~30 min, 2 zakończenia: ZŁAPANY, UCIECZKA).
   - Płatna pełna gra (jednorazowy IAP): Rozdziały 2 i 3, pozostałe
     zakończenia, New Game+, Galeria.
2. WHEN gracz dotrze do końca darmowej zawartości THEN system SHALL
   prezentować ekran "Kontynuuj historię" z czytelnym opisem co dostaje
   za zakup, **bez ciemnych wzorców** (timer, fałszywe zniżki).
3. WHEN gracz dokona zakupu THEN system SHALL natychmiast odblokować
   pełną zawartość bez konieczności pobierania dodatkowych assetów.
4. WHEN gracz odinstaluje i ponownie zainstaluje grę z tego samego
   konta Google THEN system SHALL automatycznie przywrócić zakup.
5. The system SHALL nie zawierać reklam, mikrotransakcji kosmetycznych,
   loot boxów ani żadnej formy "energii" / "życia" odnawialnego za $.
6. The system SHALL zawierać przycisk "Przywróć zakup" w Ustawieniach.
7. WHEN gracz uruchamia grę po raz pierwszy THEN system SHALL **NIE**
   wymuszać logowania do Google Play Games / żadnego konta.

### 7. Prywatność, GDPR, zgodność z Play Store

**User story:** Jako wydawca chcę przejść Play Store review za pierwszym
podejściem i być zgodny z RODO.

#### Kryteria akceptacji

1. WHEN aplikacja po raz pierwszy potrzebuje uprawnienia (lokalizacja)
   THEN system SHALL pokazać **rationale screen** wyjaśniający dlaczego
   gra prosi o lokalizację (immersja stalker-threadu) i SHALL pozwolić
   na odmowę bez wpływu na działanie gry.
2. The system SHALL działać **w pełni** bez uprawnień lokalizacji —
   stalker thread SHALL wtedy używać generycznych komunikatów.
3. The system SHALL zawierać ekran **Polityki Prywatności** dostępny
   z poziomu Ustawień i z lock screena, w PL i EN.
4. The system SHALL zawierać ekran **"O grze"** z wersją, autorami,
   licencjami third-party (przez `package_info_plus` +
   `flutter_oss_licenses` lub równoważne).
5. The system SHALL deklarować w Play Console **target audience: 13+**
   ze względu na motywy korupcji, stalkingu i przemocy psychicznej.
6. The system SHALL zawierać ostrzeżenie wstępne (przed lock screenem
   przy pierwszym uruchomieniu) o tematyce gry: stalking, korupcja,
   tematyka osoby zaginionej.
7. The system SHALL **nie zbierać** żadnych danych identyfikujących
   gracza (brak analityki użytkowania, IP, ID urządzenia poza tym co
   robi Play Services automatycznie).
8. WHEN gracz włączy raporty błędów (opt-in) THEN system SHALL wysyłać
   wyłącznie stack trace, wersję gry, model urządzenia i Android API
   level — nigdy: lokalizacji, treści save'a, ID Play.

### 8. Onboarding, dostępność i UX

**User story:** Jako gracz, który nigdy wcześniej nie grał w found-phone
games, chcę zrozumieć co mam robić bez nudnego tutoriala.

#### Kryteria akceptacji

1. WHEN gracz uruchamia grę po raz pierwszy THEN system SHALL pokazać
   **kontekstowe podpowiedzi** (subtelne hinty w tooltipach, max 3
   w pierwszych 5 minutach), nigdy modalne tutoriale.
2. The system SHALL wspierać **dynamic font scaling** Androida — wszystkie
   teksty SHALL skalować się gdy gracz ma powiększone czcionki.
3. The system SHALL spełniać kontrast tekstu **WCAG AA** dla wszystkich
   ekranów gry.
4. The system SHALL zapewniać **alternatywny tryb dla osób
   z fotosensytywnością** wyłączający glitch overlay i flash effects
   (przełącznik w Ustawieniach: "Zmniejsz efekty wizualne").
5. The system SHALL zapewniać **przełącznik haptyki** (wibracje) w
   Ustawieniach, domyślnie WŁĄCZONY ale łatwy do wyłączenia.
6. The system SHALL zapewniać **przycisk pauzy** dostępny z każdego
   ekranu gry — pauza zatrzymuje countdown Szeryfa i wszystkie timery
   narracyjne.
7. WHEN gracz wraca do gry po przerwie ≥ 24h THEN system SHALL pokazać
   **streszczenie "co się dotąd wydarzyło"** zamiast wrzucać go w sam
   środek aktualnego stanu.

### 9. Audio i grafika produkcyjna

**User story:** Jako gracz chcę immersyjnego klimatu z dobrze
nagranymi dźwiękami i prawdziwymi zdjęciami, a nie placeholderami.

#### Kryteria akceptacji

1. The system SHALL zawierać **finalne assety audio** (nie placeholder
   z `generate_audio.py`):
   - Ambient drone (60s loop, ≥ 192 kbps)
   - Tension loop (60s loop, ≥ 192 kbps)
   - 6 SFX: keypad tap, keypad error, message in, notification, unlock,
     ending reveal, glitch burst
   - Wszystkie z poprawnymi licencjami (CC0, CC-BY z atrybucją w O grze,
     lub własne nagrania).
2. The system SHALL zawierać **finalne zdjęcia** w `assets/images/photos/`
   — fotorealistyczne lub stockowe na licencji, nie placeholdery.
3. The system SHALL zawierać **2 tapety** (lock screen + home screen)
   spójne stylistycznie.
4. The system SHALL zawierać **ikonę launchera** w wymaganiach Play
   (adaptive icon: foreground + background, 432×432 dp źródło).
5. The system SHALL zawierać **feature graphic** (1024×500 px) i
   **screenshoty Play Store** (min. 4 zrzuty, 16:9 lub 9:16) w PL i EN.
6. WHEN gracz wycisza dźwięki w Ustawieniach THEN system SHALL natychmiast
   wyciszyć ambient/tension/SFX bez zauważalnego opóźnienia.
7. The system SHALL **graceful-fallback** do gradientu z ikoną gdy plik
   graficzny brakuje (zachowane z aktualnego zachowania).

### 10. Powtarzalność i meta-zawartość

**User story:** Jako gracz chcę mieć powód wracać do gry po pierwszym
ukończeniu.

#### Kryteria akceptacji

1. The system SHALL zawierać **system osiągnięć** integrowany z Google
   Play Games Services (opcjonalnie, jeśli gracz się zaloguje):
   - Min. 12 osiągnięć pokrywających różne style gry (Speedrun,
     Pacyfista, Detektyw — odkryj wszystkie wskazówki, Paranoik —
     przeczytaj wszystkie wiadomości, itd.)
2. The system SHALL zawierać **Galerię zakończeń** odblokowywaną po
   pierwszym ukończeniu, pokazującą stan 6/6 (zakończenia odkryte,
   nieodkryte zaczernione).
3. The system SHALL zawierać **statystyki rozgrywki** na ekranie końca:
   czas przejścia, % przeczytanego contentu, ilość rozwiązanych puzzli,
   kluczowe wybory.
4. WHEN gracz ukończy grę po raz drugi z innym zakończeniem THEN system
   SHALL ujawnić dodatkową scenę meta-narracyjną od Nieznanego.
5. The system SHALL zachować backwards compatibility savów między
   patchami w obrębie minor versions (1.0.x, 1.1.x).

### 11. Build, signing i Play Store readiness

**User story:** Jako wydawca chcę móc wypchnąć grę na produkcję bez
ostatniej chwili szukania ikon i tekstów.

#### Kryteria akceptacji

1. The system SHALL być zbudowany jako **Android App Bundle (.aab)**,
   nie APK, z target SDK ≥ 34 (Android 14, wymóg Play 2025).
2. The system SHALL używać **upload key** + **app signing by Google
   Play** (Play App Signing).
3. The system SHALL przejść skanowanie Play Protect i pre-launch
   report (test na min. 5 wirtualnych urządzeniach Android).
4. The system SHALL mieć skonfigurowane **R8/ProGuard** bez naruszania
   działania reflection (audioplayers, geolocator).
5. The system SHALL mieć **build flavor "free"** i **"full"** (lub
   jeden flavor + IAP gating) wybrany na etapie designu.
6. The system SHALL zawierać **Play Store listing**:
   - Tytuł (≤ 30 zn), krótki opis (≤ 80 zn), długi opis (≤ 4000 zn) — PL i EN.
   - Min. 4 screenshoty + feature graphic + ikona.
   - Trailer w formacie YouTube (opcjonalne, ale zalecane).
7. The system SHALL mieć **wersjonowanie semantyczne**: `versionName`
   (X.Y.Z) i `versionCode` (auto-inkrementowany w CI).

### 12. Pipeline rozwojowy i CI

**User story:** Jako solo-developer chcę móc szybko i bezpiecznie
wydawać patche.

#### Kryteria akceptacji

1. The system SHALL mieć GitHub Actions (lub równoważne) workflow:
   - Push na main: `flutter analyze`, `flutter test`, build aab
     (debug-signed do artefaktu).
   - Tag `v*`: build aab z release signing (klucze z secrets) +
     publish do Play Internal Track.
2. The system SHALL mieć aktualny `README.md` zgodny ze stanem kodu
   (obecny pomija połowę aplikacji).
3. The system SHALL mieć `CHANGELOG.md` w formacie Keep-a-Changelog.
4. The system SHALL mieć dokument `docs/STORY_GRAPH.md` opisujący
   wszystkie ścieżki narracyjne, postaci, stany trust i warunki
   zakończeń (single source of truth dla scenariusza).

---

## Poza zakresem v1.0 (przyszłe wersje)

- Wersja iOS (przygotujemy fundament, ale nie publikujemy w v1.0).
- Wersja desktop (Windows / Linux / macOS).
- Episodyczność (drugi telefon = Episode 2) — przygotujemy hub-pattern,
  ale wypuszczamy tylko Episode 1.
- Pełne tłumaczenie EN — fundament tak, finalna jakość: po polskiej
  premierze.
- Lektor głosowy NPC (voice-over) — opcjonalnie post-launch DLC.
- Cloud save między urządzeniami — Google Play Save Games dopiero w 1.1.
- Sterowanie głosowe / accessibility services Android.

---

## Definicje gotowości v1.0

Gra jest **gotowa do wypuszczenia na Google Play** gdy:

- [ ] Wszystkie kryteria akceptacji wymagań 1–12 są spełnione.
- [ ] `flutter analyze` zwraca 0 issues.
- [ ] Pokrycie testów ≥ 70% dla modułów state.
- [ ] Min. 5 osób przeszło grę testowo (track Closed Testing) bez
      crashy w sesji 30+ minut.
- [ ] Pre-launch report Google: 0 stability errors.
- [ ] Polityka prywatności opublikowana pod stabilnym URL.
- [ ] Klucz signingu zabezpieczony w 2 lokalizacjach (lokalnie + zaszyfr.
      backup).
- [ ] Trailer (≥ 30s) wgrany na YouTube.
