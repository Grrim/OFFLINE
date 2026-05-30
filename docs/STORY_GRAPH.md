# Story Graph — OFFLINE

Single source of truth dla scenariusza. Każda zmiana w dialogach,
warunkach zakończeń i zaufaniu NPCów zaczyna się tutaj — kod jest
implementacją tego dokumentu.

## Postacie

| ID         | Imię                      | Rola                                            |
|------------|---------------------------|-------------------------------------------------|
| `mama`     | Mama (Halina K.)          | Matka N. — emocjonalny anker                    |
| `nieznany` | Nieznany                  | Tajemniczy informator — przewodnik gracza       |
| `dziennikarka` | Anita Z. (Gazeta)     | Dziennikarka śledcza — ścieżka PRAWDA           |
| `tomasz`   | T.W. (sąsiad)             | Były pracownik HB — ścieżka ŚWIT                |
| `szeryf`   | Komendant K. ("Szeryf")   | Antagonista — driver konfliktu                  |
| `stalker`  | Anonimowy stalker         | Klimatyczny — nie ma ścieżki dialogowej         |
| `n_scheduled` | N. (zaplanowana)       | Wiadomość-ego N. — emocjonalny dramat           |

## Stan trust (-100..+100)

Inicjalizowany na 0 dla każdej postaci. Wpływa na:
- dostępność ukrytych choices (np. Anita ujawnia szczegóły dopiero
  gdy `trust >= 30`).
- ton odpowiedzi NPC (krótsze/cieplejsze wiadomości).
- możliwość uzyskania niektórych zakończeń.

## Stan evidenceScore

Punkty za zebrane materiały dowodowe. Progi:
- `>= 80` → ścieżka PRAWDA dostępna.
- `>= 120` → ścieżka ŚWIT dostępna.
- `< 50` → soft-blokada Anity (nie wierzy bez dowodów).

## Wagi evidence

| ID                       | Waga | Skąd                          |
|--------------------------|------|-------------------------------|
| `photo_forest_night`     | 20   | Zdjęcia → Info                |
| `photo_parking`          | 15   | Zdjęcia → Info                |
| `photo_document`         | 25   | Zdjęcia → Info                |
| `file_invoice_05`        | 10   | Pliki                         |
| `file_invoice_04`        | 5    | Pliki                         |
| `file_transcript`        | 30   | Pliki                         |
| `file_envelopes`         | 15   | Pliki                         |
| `file_map`               | 10   | Pliki                         |
| `recording_001`          | 15   | Dyktafon                      |
| `recording_002`          | 15   | Dyktafon                      |
| `recording_003`          | 25   | Dyktafon                      |
| `voicemail_threat`       | 10   | Telefon (poczta głosowa)      |
| `email_anita`            | 10   | Poczta                        |
| `email_strazn_lasu`      | 10   | Poczta                        |
| `browser_krs`            | 5    | Przeglądarka                  |
| `browser_centralna`      | 15   | Przeglądarka                  |
| `email_recovered`        | 25   | Po rozwiązaniu puzzla "trash" |
| `route_reconstructed`    | 20   | Po ułożeniu trasy w Mapach    |

## Drzewo dialogowe — Nieznany (rozdział 1, intro)

```
intro
├── "Kim jesteś?"          → branch_a → convergence → hint_files (END)
└── "Idę z tym na policję." → branch_b → convergence → hint_files (END)
```

Convergence jest jeden — gracz dochodzi do tego samego stanu wiedzy
niezależnie od wyboru.

## Drzewo dialogowe — Szeryf (po unlock secret note)

```
opener (NPC: "Wiem, że grzebiesz...")
├── "Nie wiem o czym mówisz..."           → choice_dumb  → ENDING_CAUGHT
├── "Wiem wszystko o Helion-Budzie..."    → choice_defy  → ENDING_ESCAPE
├── "Już za późno..."                     → choice_truth → triggers Anita
└── (nowy v1.0) "Ile zapłacisz za ciszę?" → choice_corrupt → ENDING_KORUPCJA
                                              [requires evidence >= 50]
```

8-min countdown: brak odpowiedzi → auto-CAUGHT.

## Drzewo dialogowe — Anita (po choice_truth)

```
opener
├── "Anita, to ja. Mam dowody."          → confirm
└── "Anita, jesteś tam?"                 → confirm
                                            ↓
                                        send → ENDING_TRUTH
                                        [requires evidence >= 80]
```

## Drzewo dialogowe — Tomasz (po unlock plan_b note)

```
opener (NPC: "Wiem że masz jej telefon...")
├── "Drzewo, które padło na dachu."     → recognise → commit → ENDING_DAWN
└── "Nie znam żadnego hasła."           → cold_open
                                          ├── "Drzewo..."   → recognise
                                          └── "Po prostu pomóż" → reject (brak ending, soft fail)
```

## Zakończenia v1.0 (9)

### ZŁAPANY (`caught`)
- Trigger: `choice_dumb` w Sheriff dialogue
- Trigger: 8-min countdown bez odpowiedzi Szeryfowi
- Trust impact: irrelevant
- Evidence: irrelevant

### UCIECZKA (`escape`)
- Trigger: `choice_defy` w Sheriff dialogue
- Trust impact: bez wymogu
- Evidence: irrelevant

### PRAWDA (`truth`)
- Trigger: `choice_truth` → Anita opener → confirm → send
- **Wymaga:** `evidenceScore >= 80`
- Trust Anita +30 wymagane do osiągnięcia choice_truth (ukryty bez)

### ŚWIT (`dawn`)
- Trigger: Tomasz dialogue → commit
- **Wymaga:** unlock plan_b note (PIN 1422)
- **Wymaga:** `evidenceScore >= 120`
- Trust Tomasz: rozpoznanie hasłem (`recognise` ścieżka)

### SAMOTNIA (`solitude`) — NOWE v1.0
- Trigger: gracz odrzucił wszystkie ścieżki współpracy:
  - `trust_mama < -50`
  - `trust_anita < -50`
  - `trust_tomasz < -50`
  - czas rozgrywki >= 25 min bez aktywnego dialogu
- Epilog: "Nikt cię nie wysłuchał. Telefon umiera w twojej dłoni."

### KORUPCJA (`corruption`) — NOWE v1.0
- Trigger: nowy choice w Sheriff dialogue: "Ile zapłacisz za ciszę?"
- **Wymaga:** `evidenceScore >= 50` (Sheriff musi widzieć że masz dowody)
- Epilog: "Dostałeś kopertę. N. nigdy nie wraca. Nikt nie pyta."

### CYKL (`cycle`) — UKRYTE w NG+
- Trigger: drugie przejście, dotarcie do dowolnego ending'a
- Nieznany ujawnia że gra to symulacja
- Epilog meta-narracyjny

### ŚWIADEK (`witness`) — Rozdział 3 (NG+ tylko)
- Trigger: w NG+ po dotarciu do TRUTH lub DAWN otwiera się Chapter 3.
  Prokurator dialogue → wybór "Mam dowody, chcę zeznawać oficjalnie"
- Konsekwencje: publiczne zeznanie, 4 zatrzymania, Grand Press dla Anity
- N. wciąż nie odnaleziona ale szuka ją cały kraj

### CIEŃ (`shadow`) — Rozdział 3 (NG+ tylko)
- Trigger: w NG+ Chapter 3, prokurator dialogue → "Wolę depozyt anonimowy"
- Konsekwencje: sprawa idzie wolniej (sierpień), bez konferencji,
  ale gracz pozostaje niewidzialny
- Helion-Bud przejmowany powoli, przeniesienia służbowe

## Rozdział 3 — Po świcie (NG+ only)

Otwiera się gdy gracz w NG+ runie dochodzi do TRUTH lub DAWN endingu
po raz pierwszy. Zamiast terminal ending pokazuje się
`triggerProsecutorDialog`. Nowy thread "Prokurator R. (centralna)"
z 4 nodes:

- **opener** — gracz wybiera ścieżkę: publiczne zeznanie / depozyt /
  zapytanie o ochronę
- **protection_q** — gated przez `puzzle.signal_decoded`. Sukces
  prowadzi do witness_path; odrzucenie do shadow_path
- **witness_path** → ENDING_WITNESS
- **shadow_path** → ENDING_SHADOW

Nowa app **Signal** widoczna w Chapter 3 na home grid. Mini-puzzle
to dekodowanie hasła `koperta1422` z dwóch istniejących wskazówek:
- "koperta" — kodowe słowo dla łapówek (z notatek N. + nagrań)
- "1422" — godzina pierwszego nagrania (28.03.2026, 14:22)

## Hooki narracyjne (timery)

| Czas po unlock | Zdarzenie                                    |
|----------------|----------------------------------------------|
| 2s             | Banner Nieznanego (intro)                    |
| 10s            | Wi-Fi auto-connect (HB_Guest_5G)             |
| 60s            | Reminder: zajrzyj do Zdjęć (jeśli nie EXIF)  |
| 1:00           | Stalker: "Widzę cię."                        |
| 1:30           | System: aparat włączony                      |
| 2:00           | Ghost notification (1.5s flash)              |
| 2:30           | Stalker: time-of-day comment                 |
| 3:00           | Stalker: "Ładne zdjęcie" + camera notif      |
| 3:00           | Low battery alert                            |
| 3:30           | N. (scheduled): "Jeśli to czytasz..."        |
| 4:00           | Stalker: real location                       |
| 4:00           | System: mikrofon aktywny                     |
| 5:30           | Stalker: escalation                          |
| 5:30           | Security: failed remote unlock + glitch SFX  |
| 7:00           | Stalker: final warning                       |

Po unlock secret note (PIN 7309):
- Sheriff +20s threat message
- Mama panic +1s po Sheriffie
- Nieznany hint o czytaniu plików +4s
- Nieznany hint o plan_b notatce +6s
- Sheriff countdown 8 min → auto-CAUGHT
- Sheriff warning "Minuta" 7 min in

## Szyfry i kody

| Kod    | Gdzie znaleźć                                       | Co odblokowuje              |
|--------|-----------------------------------------------------|------------------------------|
| `1984` | Lock screen — startowy                              | Cały telefon                 |
| `7309` | Zdjęcie `forest_night` → przycisk Info → komentarz  | Notatka "PRZECZYTAJ W RAZIE..." |
| `1422` | Pliki → transkrypcja → "14:22"                       | Notatka "PLAN B"             |
| `mruczek2019` | Notatka "Hasła Wi-Fi" + hint Nieznanego      | Tryb prywatny przeglądarki   |
| `drzewo` (hasło) | Notatka "PLAN B"                              | Wątek z Tomaszem             |
| `koperta1422` | Notatki + transkrypcja (Chapter 3)             | Signal channel — wymaga decoding dla "ochrona świadka" choice |
