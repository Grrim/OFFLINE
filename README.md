# Zaginiona

Mobilna gra tekstowa z gatunku "Found Phone / Fake OS". Gracz trzyma w
rękach telefon zaginionej osoby i przez kolejne aplikacje (Wiadomości,
Zdjęcia, Notatki, Ustawienia) odkrywa, co się jej przytrafiło.

Stack: **Flutter + Dart**, `provider`, `shared_preferences`, `google_fonts`.

## Struktura projektu

```
lib/
  main.dart                       # bootstrap, MultiProvider, fabuła hooków
  services/
    persistence_service.dart      # cienka warstwa nad SharedPreferences
  state/
    phone_state.dart              # status blokady urządzenia
    photos_state.dart             # galeria + ślad o obejrzeniu EXIF
    notes_state.dart              # notatki + zablokowana notatka 7309
    messages_state.dart           # wątki, drzewo dialogów, doręczenia NPC
    notifications_state.dart      # systemowe banery push
    ending_state.dart             # finałowe nakładki
  theme/app_theme.dart
  widgets/
    status_bar.dart
    numeric_keypad.dart           # współdzielony keypad lock + notatki
    notification_banner.dart
    ending_overlay.dart
  screens/
    lock_screen.dart
    home_screen.dart
    messages/{messages_list_view,chat_view}.dart
    photos/{photos_grid_view,photo_detail_view,photo_thumbnail}.dart
    notes/notes_view.dart
    settings/settings_view.dart
assets/
  images/                         # tapety urządzenia
    photos/                       # placeholdery zdjęć z galerii
```

## Uruchomienie

```bash
flutter pub get
flutter run
```

## Przejście dema

1. PIN telefonu: `1984`
2. Wiadomości → Nieznany → wybierz dowolną gałąź
3. Zdjęcia → ciemne zdjęcie z lasu → przycisk Info → odczytaj komentarz pliku
4. Notatki → notatka "PRZECZYTAJ W RAZIE MOJEGO ZNIKNIĘCIA" → PIN `7309`
5. ~3s później baner od Szeryfa → ~1s później panika od Mamy
6. Tap baner Szeryfa → wybierz odpowiedź → finał (ZŁAPANY / UCIECZKA)
7. Reset rozgrywki: Ustawienia → Resetuj rozgrywkę
   (lub przycisk "Zagraj jeszcze raz" na ekranie zakończenia)

## Materiały graficzne

Gra działa bez assetów — w razie braku obrazka renderowany jest
tematyczny gradient z ikoną. Pełna lista oczekiwanych plików jest w
`assets/images/README.md` oraz `assets/images/photos/README.md`.
