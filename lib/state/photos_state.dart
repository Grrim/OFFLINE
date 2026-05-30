import 'package:flutter/material.dart';

import '../services/persistence_service.dart';

/// One item shown in the gallery.
class PhotoItem {
  const PhotoItem({
    required this.id,
    required this.assetPath,
    required this.dateString,
    required this.location,
    required this.camera,
    required this.placeholderIcon,
    required this.placeholderColors,
    this.isCluePhoto = false,
    this.hiddenNote,
  });

  final String id;
  final String assetPath;
  final String dateString;
  final String location;
  final String camera;
  final IconData placeholderIcon;
  final List<Color> placeholderColors;
  final bool isCluePhoto;
  final String? hiddenNote;
}

/// State for the gallery app. Persists which clue photos the player has
/// inspected via the EXIF sheet.
class PhotosState extends ChangeNotifier {
  PhotosState({PersistenceService? persistence})
      : _persistence = persistence {
    _seed();
    _load();
  }

  static const String _kInspectedIds = 'game.photos.inspected';

  final PersistenceService? _persistence;
  final List<PhotoItem> _photos = [];
  final Set<String> _inspectedClueIds = {};
  String? _selectedPhotoId;

  List<PhotoItem> get photos => List.unmodifiable(_photos);

  PhotoItem? get selectedPhoto {
    if (_selectedPhotoId == null) return null;
    for (final p in _photos) {
      if (p.id == _selectedPhotoId) return p;
    }
    return null;
  }

  bool hasInspected(String photoId) => _inspectedClueIds.contains(photoId);

  void selectPhoto(String id) {
    _selectedPhotoId = id;
    notifyListeners();
  }

  void clearSelection() {
    _selectedPhotoId = null;
    notifyListeners();
  }

  void markInspected(String id) {
    final p = _photos.firstWhere(
      (e) => e.id == id,
      orElse: () => const PhotoItem(
        id: '',
        assetPath: '',
        dateString: '',
        location: '',
        camera: '',
        placeholderIcon: Icons.image,
        placeholderColors: [Colors.black, Colors.black],
      ),
    );
    if (p.id.isEmpty || !p.isCluePhoto) return;
    if (_inspectedClueIds.add(p.id)) {
      _saveInspected();
      notifyListeners();
      onClueInspected?.call(p.id);
    }
  }

  /// Wired from main.dart. Called when a clue photo is inspected for
  /// the first time. Used to trigger reactive NPC messages.
  void Function(String photoId)? onClueInspected;

  void _load() {
    final p = _persistence;
    if (p == null) return;
    _inspectedClueIds.addAll(p.getStringList(_kInspectedIds));
  }

  void _saveInspected() {
    _persistence?.setStringList(_kInspectedIds, _inspectedClueIds.toList());
  }

  /// Wipe progression. Photo list itself is kept (it's seed data).
  void reset() {
    _inspectedClueIds.clear();
    _selectedPhotoId = null;
    notifyListeners();
  }

  // ---------- Seed ----------

  void _seed() {
    _photos.addAll([
      const PhotoItem(
        id: 'forest_night',
        assetPath: 'assets/images/photos/forest_night.jpg',
        dateString: '17 maja 2026, 23:45',
        location: 'Las Kabacki, Warszawa',
        camera: 'iPhone - Tylny aparat 26 mm f/1.8',
        placeholderIcon: Icons.dark_mode,
        placeholderColors: [Color(0xFF0B1014), Color(0xFF1A2530)],
        isCluePhoto: true,
        hiddenNote: 'KOD DO NOTATNIKA: 7309. Nie ufaj szeryfowi.',
      ),
      const PhotoItem(
        id: 'selfie',
        assetPath: 'assets/images/photos/selfie.jpg',
        dateString: '14 maja 2026, 17:22',
        location: 'Plac Zbawiciela, Warszawa',
        camera: 'iPhone - Przedni aparat 23 mm f/1.9',
        placeholderIcon: Icons.sentiment_satisfied_alt,
        placeholderColors: [Color(0xFFE08AB0), Color(0xFFB05A85)],
      ),
      const PhotoItem(
        id: 'coffee',
        assetPath: 'assets/images/photos/coffee.jpg',
        dateString: '12 maja 2026, 09:08',
        location: 'Cafe Relaks, Warszawa',
        camera: 'iPhone - Tylny aparat 26 mm f/1.8',
        placeholderIcon: Icons.local_cafe,
        placeholderColors: [Color(0xFF8C5A3C), Color(0xFF4A2C1A)],
      ),
      const PhotoItem(
        id: 'cat',
        assetPath: 'assets/images/photos/cat.jpg',
        dateString: '9 maja 2026, 19:41',
        location: 'Dom',
        camera: 'iPhone - Tylny aparat 26 mm f/1.8',
        placeholderIcon: Icons.pets,
        placeholderColors: [Color(0xFFFFB870), Color(0xFF8C5A2E)],
      ),
      const PhotoItem(
        id: 'parking',
        assetPath: 'assets/images/photos/parking.jpg',
        dateString: '10 maja 2026, 22:18',
        location: 'Parking, ul. Wołoska, Warszawa',
        camera: 'iPhone - Tylny aparat 26 mm f/1.8',
        placeholderIcon: Icons.local_parking,
        placeholderColors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
        isCluePhoto: true,
        hiddenNote: 'Czarny SUV BMW. Rejestracja: WI 38274. To auto Helion-Bud.',
      ),
      const PhotoItem(
        id: 'document',
        assetPath: 'assets/images/photos/document.jpg',
        dateString: '11 maja 2026, 16:33',
        location: 'Cafe Relaks, Warszawa',
        camera: 'iPhone - Tylny aparat 26 mm f/1.8',
        placeholderIcon: Icons.description,
        placeholderColors: [Color(0xFFE8E0D4), Color(0xFF8C7A5E)],
        isCluePhoto: true,
        hiddenNote: 'Skan koperty z pieniędzmi. Widać palce K. i logo gazety.',
      ),
      const PhotoItem(
        id: 'window',
        assetPath: 'assets/images/photos/window.jpg',
        dateString: '15 maja 2026, 22:47',
        location: 'Dom',
        camera: 'iPhone - Tylny aparat 26 mm f/1.8',
        placeholderIcon: Icons.visibility,
        placeholderColors: [Color(0xFF0A0A14), Color(0xFF1A1A2E)],
        isCluePhoto: false,
        hiddenNote: null,
      ),
      const PhotoItem(
        id: 'dawn',
        assetPath: 'assets/images/photos/dawn.jpg',
        dateString: '17 maja 2026, 05:48',
        location: 'Most Łazienkowski, Warszawa',
        camera: 'iPhone - Tylny aparat 26 mm f/1.8',
        placeholderIcon: Icons.wb_twilight,
        placeholderColors: [Color(0xFFFF9F7A), Color(0xFF6E2A4F)],
        isCluePhoto: false,
      ),
    ]);
  }
}
