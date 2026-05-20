import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/photos_state.dart';
import 'photo_thumbnail.dart';

/// Fullscreen photo viewer with a top back chevron and a bottom action bar
/// (Share / Favorite / Info). The Info button slides up an OS-style EXIF
/// bottom sheet that, for the clue photo, also reveals the hidden note.
class PhotoDetailView extends StatefulWidget {
  const PhotoDetailView({super.key, required this.photoId});

  final String photoId;

  @override
  State<PhotoDetailView> createState() => _PhotoDetailViewState();
}

class _PhotoDetailViewState extends State<PhotoDetailView> {
  bool _favorite = false;

  void _showInfoSheet(BuildContext context, PhotoItem photo) {
    // Mark the clue photo as inspected the moment the player opens Info.
    context.read<PhotosState>().markInspected(photo.id);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ExifSheet(photo: photo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = context
        .watch<PhotosState>()
        .photos
        .firstWhere(
          (p) => p.id == widget.photoId,
          orElse: () => context.read<PhotosState>().photos.first,
        );

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
                  const SizedBox(width: 36), // visual balance
                ],
              ),
            ),

            // ---- Photo ----
            Expanded(
              child: Hero(
                tag: 'photo_${photo.id}',
                child: PhotoThumbnail(
                  photo: photo,
                  fit: BoxFit.contain,
                  iconSize: 96,
                ),
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
                    onTap: () => _comingSoon(context, 'Udostępnianie'),
                  ),
                  _ActionIcon(
                    icon: _favorite ? Icons.favorite : Icons.favorite_border,
                    color: _favorite
                        ? const Color(0xFFFF453A)
                        : const Color(0xFF0A84FF),
                    onTap: () => setState(() => _favorite = !_favorite),
                  ),
                  _ActionIcon(
                    icon: Icons.info_outline,
                    color: const Color(0xFF0A84FF),
                    onTap: () => _showInfoSheet(context, photo),
                  ),
                  _ActionIcon(
                    icon: Icons.delete_outline,
                    color: const Color(0xFF0A84FF),
                    onTap: () => _comingSoon(context, 'Usuwanie'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label - niedostępne'),
          duration: const Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

// ----------------- Action icon -----------------

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

// ----------------- EXIF sheet -----------------

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
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Informacje',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _ExifGroup(rows: [
                  _ExifRow(
                    icon: Icons.calendar_today,
                    label: 'Data wykonania',
                    value: photo.dateString,
                  ),
                  _ExifRow(
                    icon: Icons.location_on_outlined,
                    label: 'Lokalizacja',
                    value: photo.location,
                  ),
                  _ExifRow(
                    icon: Icons.camera_alt_outlined,
                    label: 'Aparat',
                    value: photo.camera,
                  ),
                ]),
                if (photo.isCluePhoto && photo.hiddenNote != null) ...[
                  const SizedBox(height: 18),
                  const Text(
                    'Komentarz pliku',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFF453A).withValues(alpha: 0.45),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      photo.hiddenNote!,
                      style: const TextStyle(
                        color: Color(0xFFFFB1AC),
                        fontSize: 14,
                        height: 1.35,
                        fontFamily: 'Courier', // monospace gives it a "raw EXIF" feel
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

class _ExifGroup extends StatelessWidget {
  const _ExifGroup({required this.rows});
  final List<_ExifRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 52),
                child: Divider(height: 1, color: Color(0xFF3A3A3C)),
              ),
          ],
        ],
      ),
    );
  }
}

class _ExifRow extends StatelessWidget {
  const _ExifRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0A84FF), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
