import 'package:flutter/material.dart';

class CosmosTheme {
  CosmosTheme._();

  // Backgrounds
  static const Color background   = Color(0xFF0A0C12);
  static const Color panelBg      = Color(0xFF0E1018);
  static const Color cardBg       = Color(0xFF13151F);
  static const Color historyBg    = Color(0xFF0C0E16);
  static const Color spaceBg      = Color(0xFF040509);

  // Button backgrounds
  static const Color buttonBg     = Color(0xFF1C1E2C);
  static const Color operatorBg   = Color(0xFF1A2840);
  static const Color functionBg   = Color(0xFF151A2A);
  static const Color constBg      = Color(0xFF0F1A2E);
  static const Color op2Bg        = Color(0xFF151C2E);
  static const Color modeBg       = Color(0xFF162030);

  // Equals button gradient
  static const Color equalStart   = Color(0xFF2E5AFF);
  static const Color equalEnd     = Color(0xFF1A3ACC);

  // Text / accent
  static const Color textPrimary     = Color(0xFFE8EEFF);
  static const Color textSecondary   = Color(0xFF7A8BA8);
  static const Color accent          = Color(0xFF4A9EFF);
  static const Color success         = Color(0xFF3EFFB4);
  static const Color danger          = Color(0xFFFF4466);

  // Borders
  static const Color borderTop    = Color(0xFF3D4B64);
  static const Color borderBottom = Color(0xFF1C2333);

  // Spacing
  static const double buttonGap      = 7.0;
  static const double keypadPadding  = 12.0;
  static const double displayPaddingH = 18.0;
  static const double displayPaddingV = 14.0;
  static const double buttonRadius   = 12.0;
  static const double cardRadius     = 10.0;

  // Panel widths
  static const double scientificWidth = 200.0;
  static const double historyWidth    = 220.0;

  // Window
  static const double windowMinW = 320.0;
  static const double windowMinH = 480.0;
  static const double windowDefW = 380.0;
  static const double windowDefH = 600.0;

  static TextStyle monoStyle({
    double size = 16,
    FontWeight weight = FontWeight.normal,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: 'Courier New',
      fontSize: size,
      fontWeight: weight,
      color: color ?? textPrimary,
      letterSpacing: 0,
    );
  }

  static ThemeData get materialTheme => ThemeData.dark().copyWith(
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      surface: cardBg,
    ),
  );
}
