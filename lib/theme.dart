import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChessTheme {
  // EP-133 K.O. II Physical Palette
  static const Color vintageCase = Color(0xFFD4D6D5); // Warm retro grey
  static const Color darkSensor = Color(0xFF2B2B2D);  // Dark display surround
  static const Color padWhite = Color(0xFFF0F2F0);    // Light pad color
  static const Color trafficOrange = Color(0xFFFF421F); // Signature TE orange
  static const Color lcdBlack = Color(0xFF111111);    // Digital segments
  static const Color coal = Color(0xFF151515);        // Dark charcoal
  
  static const Color boardLight = padWhite;
  static const Color boardDark = Color(0xFFB0B2B0);   // Darker grey for contrast

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      brightness: Brightness.light,
      primaryColor: trafficOrange,
      scaffoldBackgroundColor: vintageCase,
      cardColor: padWhite,
      dividerColor: lcdBlack,
      textTheme: GoogleFonts.orbitronTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.orbitron(color: lcdBlack, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.orbitron(color: lcdBlack, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.orbitron(color: lcdBlack, fontSize: 12),
        bodyMedium: GoogleFonts.orbitron(color: lcdBlack, fontSize: 10),
      ),
      colorScheme: ColorScheme.light(
        primary: trafficOrange,
        secondary: trafficOrange,
        surface: padWhite,
        onSurface: lcdBlack,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: lcdBlack, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      brightness: Brightness.dark,
      primaryColor: trafficOrange,
      scaffoldBackgroundColor: darkSensor,
      cardColor: lcdBlack,
      dividerColor: vintageCase.withOpacity(0.3),
      textTheme: GoogleFonts.orbitronTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.orbitron(color: padWhite, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.orbitron(color: padWhite, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.orbitron(color: padWhite, fontSize: 12),
        bodyMedium: GoogleFonts.orbitron(color: padWhite, fontSize: 10),
      ),
      colorScheme: ColorScheme.dark(
        primary: trafficOrange,
        secondary: trafficOrange,
        surface: lcdBlack,
        onSurface: padWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: padWhite, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  // "Printed" logic: No shadows, outlined boxes
  static BoxDecoration koStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      border: Border.all(
        color: isDark ? vintageCase.withOpacity(0.3) : lcdBlack,
        width: 1,
      ),
    );
  }
}
