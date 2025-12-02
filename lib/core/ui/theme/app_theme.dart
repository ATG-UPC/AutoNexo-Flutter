import 'package:flutter/material.dart';

/// Tema de la aplicación AutoNexo Owner
/// Colores extraídos del diseño Figma: https://www.figma.com/design/eiNkdEp9PnXWGA5jPEThG1/APP-MOVIL-ATG
class AppTheme {
  // === Primary Colors (Figma) ===
  static const Color primaryBlue = Color(0xFF202D36); // Primary Blue
  static const Color primaryWhite = Color(0xFFFFFFFF); // Primary White

  // === Secondary Colors (Figma) ===
  static const Color secondaryCrimson = Color(0xFF800C1F); // Secondary Crimson
  static const Color secondaryDarkRed = Color(0xFF3C0007); // Secondary Dark Red
  static const Color secondarySteelBlue = Color(0xFF5C7896); // Secondary Steel Blue
  static const Color secondaryLightBlueGray = Color(0xFF7598B9); // Secondary Light Blue-Gray

  // === Wireframe Colors (Figma) ===
  static const Color gray1 = Color(0xFFD9D9D9); // Gray 1
  static const Color gray2 = Color(0xFF8E8E8E); // Gray 2
  static const Color black = Color(0xFF282828); // Black
  static const Color white = Color(0xFFFFFFFF); // White

  // === Text Colors (Figma) ===
  static const Color textBlack = Color(0xFF000000); // Text Black
  static const Color textWhite = Color(0xFFFFFFFF); // Text White

  // === Semantic Colors (Derivados del diseño) ===
  static const Color backgroundColor = Color(0xFFF8F9FA); // Fondo claro
  static const Color cardColor = white; // Color de tarjetas
  static const Color textPrimary = black; // Texto principal
  static const Color textSecondary = gray2; // Texto secundario
  static const Color textHint = gray1; // Texto de hint

  // Colores semánticos usando la paleta del diseño
  static const Color errorColor = secondaryCrimson; // Error (Crimson)
  static const Color successColor = Color(0xFF06D6A0); // Success (mantener verde)
  static const Color warningColor = Color(0xFFFFB800); // Warning (amarillo)

  // Aliases para compatibilidad con código existente
  static const Color darkBlue = secondarySteelBlue;
  static const Color lightBlue = secondaryLightBlueGray;
  static const Color accentRed = secondaryCrimson;

  /// Tema claro
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Colores
      colorScheme: const ColorScheme.light(
        primary: primaryBlue, // #202D36
        secondary: secondarySteelBlue, // #5C7896
        tertiary: secondaryLightBlueGray, // #7598B9
        surface: cardColor, // White
        error: errorColor, // Secondary Crimson #800C1F
        onPrimary: textWhite, // White
        onSecondary: textWhite, // White
        onTertiary: textWhite, // White
        onSurface: textPrimary, // Black #000000
        onError: textWhite, // White
      ),

      scaffoldBackgroundColor: backgroundColor,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Texto
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textPrimary),
        bodySmall: TextStyle(fontSize: 12, color: textSecondary),
        labelSmall: TextStyle(fontSize: 12, color: textHint),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gray1), // #D9D9D9
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: const TextStyle(color: textHint, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue, // #202D36
          foregroundColor: textWhite, // White
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue, // #202D36
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue, // #202D36
          side: const BorderSide(color: primaryBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
