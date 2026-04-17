import 'package:flutter/material.dart';

import '../widgets/glass.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GlassPalette.primary,
        primary: GlassPalette.primary,
        secondary: GlassPalette.secondary,
        surface: GlassPalette.surface,
        onSurface: GlassPalette.onSurface,
      ),
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: GlassPalette.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: GlassPalette.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      inputDecorationTheme: _inputTheme(),
      textTheme: base.textTheme.apply(
        bodyColor: GlassPalette.onSurface,
        displayColor: GlassPalette.onSurface,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: GlassPalette.primary,
        selectionColor: Color(0x336C9FFF),
        selectionHandleColor: GlassPalette.primary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: GlassPalette.primary,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: GlassPalette.primary,
        unselectedLabelColor: GlassPalette.onSurfaceVariant,
        indicatorColor: GlassPalette.primary,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;

  static InputDecorationTheme _inputTheme() {
    const fillColor = Color(0xF2FFFFFF);
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      labelStyle: const TextStyle(
        color: GlassPalette.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        color: GlassPalette.outlineVariant.withValues(alpha: 0.9),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: GlassPalette.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: GlassPalette.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: GlassPalette.primaryContainer,
          width: 1.6,
        ),
      ),
    );
  }
}
