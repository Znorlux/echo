import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Tema claro (limpio, tipografía PT Mono)
  static ThemeData lightTheme = FlexThemeData.light(
    useMaterial3: true,
    scheme: FlexScheme.indigo,
    surfaceTint: Colors.transparent,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    textTheme: GoogleFonts.ptMonoTextTheme().apply(
      bodyColor: Colors.black87,
      displayColor: Colors.black87,
    ),
  ).copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[200],
      foregroundColor: Colors.black87,
      titleTextStyle: GoogleFonts.ptMono(
        fontSize: 20,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // Tema oscuro estilo "hacker" (verde neón)
  static ThemeData darkTheme = FlexThemeData.dark(
    useMaterial3: true,
    scheme: FlexScheme.indigo,
    surfaceTint: Colors.transparent,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    textTheme: GoogleFonts.ptMonoTextTheme().apply(
      bodyColor: Colors.greenAccent,
      displayColor: Colors.greenAccent,
    ),
  ).copyWith(
    scaffoldBackgroundColor: const Color(0xFF0B0B0B),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF101010),
      foregroundColor: Colors.greenAccent, // íconos y texto
      titleTextStyle: GoogleFonts.ptMono(
        fontSize: 20,
        color: Colors.greenAccent,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
