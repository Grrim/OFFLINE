import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/photos_state.dart';
import '../../widgets/status_bar.dart';
import 'photo_detail_view.dart';
import 'photo_thumbnail.dart';

/// Native-looking gallery: status bar, big "Zdjęcia" title, 3-column
/// square thumbnail grid. Tapping a thumbnail opens the detail view.
class PhotosGridView extends StatelessWidget {
  const PhotosGridView({super.key});

  @override
  Widget build(BuildContext context) {
    final photos = context.watch<PhotosState>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const StatusBar(),
            // ---- App header ----
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF0A84FF), size: 22),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Zdjęcia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.more_horiz,
                      color: Color(0xFF0A84FF), size: 26),
                ],
              ),
            ),
            // ---- Section label ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Wszystkie zdjęcia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${photos.photos.length} elementów',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // ---- Grid ----
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemCount: photos.photos.length,
                itemBuilder: (context, i) {
                  final photo = photos.photos[i];
                  return _GridTile(
                    photo: photo,
                    onTap: () {
                      photos.selectPhoto(photo.id);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PhotoDetailView(photoId: photo.id),
                        ),
                      ).then((_) => photos.clearSelection());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile({required this.photo, required this.onTap});

  final PhotoItem photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Slight darkening on the clue photo gives the grid a subtle "wrong note"
    // without spoiling that it's the one to investigate.
    final darken = photo.isCluePhoto ? 0.25 : 0.0;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AspectRatio(
        aspectRatio: 1,
        child: Hero(
          tag: 'photo_${photo.id}',
          child: PhotoThumbnail(photo: photo, darken: darken, iconSize: 28),
        ),
      ),
    );
  }
}
