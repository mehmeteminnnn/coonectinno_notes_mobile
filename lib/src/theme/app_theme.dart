import 'package:flutter/material.dart';

class AppTheme {
  // Renkler
  static const primaryColor = Color(0xFF6750A4);
  static const onPrimaryColor = Colors.white;
  static const backgroundColor = Color(0xFFFFFBFE);
  static const onBackgroundColor = Color(0xFF1C1B1F);
  static const surfaceColor = Color(0xFFFFFBFE);
  static const onSurfaceColor = Color(0xFF1C1B1F);
  static const errorColor = Color(0xFFB3261E);
  static const onErrorColor = Colors.white;
  static const outlineColor = Color(0xFF79747E);
  static const surfaceVariantColor = Color(0xFFE7E0EC);
  static const onSurfaceVariantColor = Color(0xFF49454F);

  // Metin Stilleri
  static TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57.0, color: onBackgroundColor),
    displayMedium: TextStyle(fontSize: 45.0, color: onBackgroundColor),
    displaySmall: TextStyle(fontSize: 36.0, color: onBackgroundColor),
    headlineLarge: TextStyle(fontSize: 32.0, color: onBackgroundColor),
    headlineMedium: TextStyle(fontSize: 28.0, color: onBackgroundColor),
    headlineSmall: TextStyle(fontSize: 24.0, color: onBackgroundColor),
    titleLarge: TextStyle(
        fontSize: 22.0, fontWeight: FontWeight.bold, color: onBackgroundColor),
    titleMedium: TextStyle(
        fontSize: 16.0, fontWeight: FontWeight.w500, color: onBackgroundColor),
    titleSmall: TextStyle(
        fontSize: 14.0, fontWeight: FontWeight.w500, color: onBackgroundColor),
    bodyLarge: TextStyle(fontSize: 16.0, color: onBackgroundColor),
    bodyMedium: TextStyle(fontSize: 14.0, color: onBackgroundColor),
    bodySmall: TextStyle(fontSize: 12.0, color: onBackgroundColor),
    labelLarge: TextStyle(
        fontSize: 14.0, fontWeight: FontWeight.w500, color: onBackgroundColor),
    labelMedium: TextStyle(
        fontSize: 12.0, fontWeight: FontWeight.w500, color: onBackgroundColor),
    labelSmall: TextStyle(
        fontSize: 11.0, fontWeight: FontWeight.w500, color: onBackgroundColor),
  );

  // Tema Verisi
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: onPrimaryColor,
        background: backgroundColor,
        onBackground: onBackgroundColor,
        error: errorColor,
        onError: onErrorColor,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        surfaceVariant: surfaceVariantColor,
        onSurfaceVariant: onSurfaceVariantColor,
        outline: outlineColor,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: onPrimaryColor),
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: primaryColor, width: 2.0),
        ),
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
      ),
    );
  }
}
