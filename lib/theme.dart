import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChessTheme {
  static const Color midnight = Color(0xFF121212);
  static const Color coal = Color(0xFF1E1E1E);
  static const Color gold = Color(0xFFD4AF37);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color accentGold = Color(0xFFFFD700);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: gold,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      cardColor: coal,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: silver,
        surface: coal,
        background: Color(0xFF0A0A0A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static BoxDecoration glassmorphism = BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withOpacity(0.1)),
  );
}
