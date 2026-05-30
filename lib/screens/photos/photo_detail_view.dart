import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/audio_service.dart';
import '../../state/photos_state.dart';
import 'photo_thumbnail.dart';

/// Fullscreen photo viewer with swipe left/right between photos,
/// a top back chevron, and a bottom action bar (Share / Favorite / Info / Delete).
class PhotoDetailView extends StatefulWidget {
  const PhotoDetailView({super.key, required this.photoId});

  final String photoId;

  @override
  State<PhotoDetailView> createState() => _PhotoDetailViewState();
}

class _PhotoDetailViewState extends State<PhotoDetailView> {
  late PageController _pageController;
  late int _currentIndex;
  bool _favorite = false;

  @override
  void initState() {
    super.initState();
    final photos = context.read<PhotosState>().photos;
    _currentIndex = photos.indexWhere((p) => p.id == widget.photoId);
    if (_currentIndex < 0) _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showInfoSheet(BuildContext context, PhotoItem photo) {
    context.read<PhotosState>().markInspected(photo.id);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ExifSheet(photo: photo),
    );
  }

  void _showShareSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text('Udostępnij', style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ShareOption(icon: Icons.message, label: 'Wiadomości', onTap: () {
                    Navigator.pop(context);
                    _showNoConnection(context);
                  }),
                  _ShareOption(icon: Icons.mail, label: 'Mail', onTap: () {
                    Navigator.pop(context);
                    _showNoConnection(context);
                  }),
                  _ShareOption(icon: Icons.copy, label: 'Kopiuj', onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                        content: Text('Skopiowano do schowka'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ));
                  }),
                  _ShareOption(icon: Icons.save_alt, label: 'Zapisz', onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                        content: Text('Zdjęcie jest już zapisane na urządzeniu'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ));
                  }),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Usunąć zdjęcie?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'To zdjęcie może być dowodem. Czy na pewno chcesz je usunąć?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Anuluj',
                style: TextStyle(color: Color(0xFF0A84FF))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              HapticFeedback.heavyImpact();
              // Error message + return to gallery.
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.error_outline, color: Color(0xFFFF453A), size: 18),
                      SizedBox(width: 8),
                      Expanded(child: Text('Błąd: odmowa dostępu. Plik chroniony.')),
                    ],
                  ),
                  duration: Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Color(0xFF1A0A0A),
                ));
              // Return to gallery after a moment.
              Future.delayed(const Duration(seconds: 1), () {
                if (context.mounted) Navigator.of(context).maybePop();
              });
            },
            child: const Text('Usuń',
                style: TextStyle(color: Color(0xFFFF453A))),
          ),
        ],
      ),
    );
  }

  void _showNoConnection(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white70, size: 18),
            SizedBox(width: 8),
            Text('Brak połączenia — nie można wysłać'),
          ],
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF2C2C2E),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final photos = context.watch<PhotosState>().photos;
    final photo = photos[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ---- Top bar ----
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF0A84FF), size: 22),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          photo.dateString.split(',').first,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          photo.dateString.contains(',')
                              ? photo.dateString.split(',').sublist(1).join(',').trim()
                              : '',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Photo counter.
                  Text(
                    '${_currentIndex + 1}/${photos.length}',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),

            // ---- Swipeable photos with pinch-to-zoom ----
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: photos.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, i) {
                  final p = photos[i];
                  return InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: PhotoThumbnail(
                      photo: p,
                      fit: BoxFit.contain,
                      iconSize: 96,
                    ),
                  );
                },
              ),
            ),

            // ---- Bottom action bar ----
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF1C1C1E))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ActionIcon(
                    icon: Icons.ios_share,
                    color: const Color(0xFF0A84FF),
                    onTap: () => _showShareSheet(context),
                  ),
                  _ActionIcon(
                    icon: _favorite ? Icons.favorite : Icons.favorite_border,
                    color: _favorite
                        ? const Color(0xFFFF453A)
                        : const Color(0xFF0A84FF),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _favorite = !_favorite);
                    },
                  ),
                  _ActionIcon(
                    icon: Icons.info_outline,
                    color: const Color(0xFF0A84FF),
                    onTap: () => _showInfoSheet(context, photo),
                  ),
                  _ActionIcon(
                    icon: Icons.delete_outline,
                    color: const Color(0xFF0A84FF),
                    onTap: () => _showDeleteConfirm(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Share option ----

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(
            color: Colors.white70, fontSize: 11,
          )),
        ],
      ),
    );
  }
}

// ---- Action icon ----

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}

// ---- EXIF sheet ----

class _ExifSheet extends StatelessWidget {
  const _ExifSheet({required this.photo});
  final PhotoItem photo;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text('Informacje', style: TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700,
                )),
                const SizedBox(height: 14),
                _ExifRow(icon: Icons.calendar_today, label: 'Data', value: photo.dateString),
                _ExifRow(icon: Icons.location_on_outlined, label: 'Lokalizacja', value: photo.location),
                _ExifRow(icon: Icons.camera_alt_outlined, label: 'Aparat', value: photo.camera),
                if (photo.isCluePhoto && photo.hiddenNote != null) ...[
                  const SizedBox(height: 18),
                  const Text('Komentarz pliku', style: TextStyle(
                    color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500,
                  )),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF453A).withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      photo.hiddenNote!,
                      style: const TextStyle(
                        color: Color(0xFFFFB1AC),
                        fontSize: 14,
                        height: 1.35,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExifRow extends StatelessWidget {
  const _ExifRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0A84FF), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
