# Zaginiona

Mobilna gra tekstowa z gatunku "Found Phone / Fake OS". Gracz trzyma w
rękach telefon zaginionej osoby N. i przez kolejne aplikacje (Wiadomości,
Zdjęcia, Notatki, Pliki, Safari, Ustawienia) odkrywa, co się jej
przytrafiło. Dwa rozdziały, cztery zakończenia.

Stack: **Flutter + Dart**, `provider`, `shared_preferences`, `google_fonts`, `audioplayers`.

## Struktura projektu

```
lib/
  main.dart                       # bootstrap, MultiProvider, fabuła hooków
  services/
    persistence_service.dart      # cienka warstwa nad SharedPreferences
    audio_service.dart            # ambient/tension loops + SFX
  state/
    phone_state.dart              # status blokady urządzenia
    photos_state.dart             # galeria + ślad o obejrzeniu EXIF
    notes_state.dart              # notatki + dwie zablokowane (7309, 1422)
    messages_state.dart           # wątki, drzewo dialogów, doręczenia NPC
    notifications_state.dart      # systemowe banery push
    ending_state.dart             # 4 finałowe nakładki
    files_state.dart              # dokumenty Helion-Bud (faktury, transkrypty)
    browser_state.dart            # historia przeglądarki
    chapter_state.dart            # rozdział 1/2 + transition flag
  theme/app_theme.dart
  widgets/
    status_bar.dart
    numeric_keypad.dart           # współdzielony keypad lock + notatki
    notification_banner.dart
    ending_overlay.dart
    glitch_overlay.dart           # cyfrowe zakłócenia gdy Szeryf aktywny
    chapter_transition_overlay.dart  # "8 godzin później" overlay
  screens/
    lock_screen.dart
    home_screen.dart
    messages/{messages_list_view,chat_view}.dart
    photos/{photos_grid_view,photo_detail_view,photo_thumbnail}.dart
    notes/notes_view.dart
    settings/settings_view.dart
    files/files_view.dart
    browser/browser_view.dart
assets/
  images/                         # tapety urządzenia
    photos/                       # zdjęcia z galerii
  audio/                          # ambient, tension loop, SFX
tools/
  generate_audio.py               # proceduralny generator placeholder audio
```

## Uruchomienie

```bash
flutter pub get
flutter run
```

## Przejście dema

### Rozdział 1 — wieczór

1. PIN telefonu: `1984`
2. Wiadomości → Nieznany → wybierz dowolną gałąź
3. Zdjęcia → ciemne zdjęcie z lasu → przycisk Info → odczytaj komentarz pliku
4. Notatki → notatka "PRZECZYTAJ W RAZIE MOJEGO ZNIKNIĘCIA" → PIN `7309`
5. ~3s później baner od Szeryfa → ~1s później panika od Mamy
6. Tap baner Szeryfa → wybierz odpowiedź:
   - "Nie wiem o czym mówisz..." → ZAKOŃCZENIE 1: ZŁAPANY
   - "Wiem wszystko o Helion-Budzie..." → ZAKOŃCZENIE 2: UCIECZKA
   - "Już za późno. Wszystko jest w drodze do redakcji." →
     wątek z Anitą Z. (Gazeta) → wybierz odpowiedź → wyślij dowody →
     ZAKOŃCZENIE 3: PRAWDA

### Rozdział 2 — świt (po przeczytaniu ≥4 dokumentów w Plikach)

7. Pliki → otwórz wszystkie 5 dokumentów (faktury, transkrypcje, lista koperty, mapa)
8. Po 4. otwartym pliku — overlay "8 GODZIN PÓŹNIEJ"
9. Pojawi się nowy wątek: T.W. (sąsiad)
10. W transkrypcji nagrania znajdź godzinę `14:22` — to PIN do drugiej notatki
11. Notatki → "PLAN B (ostateczny)" → PIN `1422` — wskazuje świadka i hasło
12. T.W. (sąsiad) → wybierz "Drzewo, które padło na dachu" → przejdź dialog →
    ZAKOŃCZENIE 4: ŚWIT

### Reset

13. Reset rozgrywki: Ustawienia → Resetuj rozgrywkę
    (lub przycisk "Zagraj jeszcze raz" na ekranie zakończenia)

## Materiały graficzne

Gra działa bez assetów — w razie braku obrazka renderowany jest
tematyczny gradient z ikoną. Pełna lista oczekiwanych plików jest w
`assets/images/README.md` oraz `assets/images/photos/README.md`.

## Audio

Gra działa bez plików audio (silent fail). Lista oczekiwanych plików
dźwiękowych jest w `assets/audio/README.md`. Dźwięk można wyciszyć
w Ustawienia → Wycisz dźwięki.
