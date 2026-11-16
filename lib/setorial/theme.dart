import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta central do GestaoOS Setorial.
abstract final class SColors {
  static const primary = Color(0xFF2D3BB0);
  static const dark = Color(0xFF1A237E);
  static const background = Color(0xFFF5F6FA);
  static const ink = Color(0xFF12153A);
  static const muted = Color(0xFF7B7F9E);
  static const border = Color(0xFFE3E6F5);
  static const blue = Color(0xFF3B6CF6);
  static const amber = Color(0xFFF59E0B);
  static const green = Color(0xFF16A34A);
  static const red = Color(0xFFEF4444);
  static const soft = Color(0xFFF2F3FB);
  static const shadow = BoxShadow(
    color: Color(0x130E1249),
    blurRadius: 24,
    offset: Offset(0, 10),
  );
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, dark],
  );
}

/// Alterne para false quando os dados vierem da API real.
const bool kModoDemo = true;

ThemeData buildSetorialTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(seedColor: SColors.primary);
  final poppins = GoogleFonts.poppinsTextTheme(
    base.textTheme,
  ).apply(bodyColor: SColors.ink, displayColor: SColors.ink);

  return base
      .copyWith(
        colorScheme: scheme,
        scaffoldBackgroundColor: SColors.background,
        // Fonte global: Text, TextField, botões e demais widgets herdam Poppins.
        textTheme: poppins,
        primaryTextTheme: GoogleFonts.poppinsTextTheme(base.primaryTextTheme),
        cardTheme: const CardThemeData(color: Colors.white),
        splashFactory: InkRipple.splashFactory,
      )
      .applyPoppinsToComponents();
}

/// Força Poppins também nos componentes com temas próprios.
extension _SetorialPoppinsTheme on ThemeData {
  ThemeData applyPoppinsToComponents() {
    return copyWith(
      appBarTheme: appBarTheme.copyWith(
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: SColors.ink,
        ),
      ),
    );
  }
}
