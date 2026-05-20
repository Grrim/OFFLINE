import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralised theme for the simulated OS.
/// Keeping it here lets every screen feel like the same device.
class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.black,
      colorScheme: base.colorScheme.copyWith(
        primary: Colors.white,
        secondary: const Color(0xFF8E8E93), // iOS-like neutral grey
        surface: const Color(0xFF1C1C1E),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }
}
