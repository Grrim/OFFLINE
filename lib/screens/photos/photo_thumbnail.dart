import 'package:flutter/material.dart';

import '../../state/photos_state.dart';

/// Renders the photo's real asset if present, otherwise a themed
/// gradient + icon placeholder. Used by both the grid and the detail view
/// so the fallback styling stays consistent.
class PhotoThumbnail extends StatelessWidget {
  const PhotoThumbnail({
    super.key,
    required this.photo,
    this.fit = BoxFit.cover,
    this.iconSize = 36,
    this.darken = 0.0,
  });

  final PhotoItem photo;
  final BoxFit fit;
  final double iconSize;

  /// Extra darkening overlay [0..1]. Useful for the clue photo so the
  /// "ominous night" feel comes through even on the placeholder.
  final double darken;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          photo.assetPath,
          fit: fit,
          errorBuilder: (_, __, ___) => _Placeholder(
            colors: photo.placeholderColors,
            icon: photo.placeholderIcon,
            iconSize: iconSize,
          ),
        ),
        if (darken > 0)
          Container(color: Colors.black.withValues(alpha: darken)),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.colors,
    required this.icon,
    required this.iconSize,
  });

  final List<Color> colors;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: Colors.white.withValues(alpha: 0.85),
        size: iconSize,
      ),
    );
  }
}
