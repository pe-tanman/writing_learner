import 'package:flutter/material.dart';

class AppColors {
  static MaterialColor congressBlueSwatch = const MaterialColor(
    0xFF3174C6,
    const <int, Color>{
      50: const Color(0xFFF2F6FD),
      100: const Color(0xFFE5ECF9),
      200: const Color(0xFFC5D8F2),
      300: const Color(0xFF92B8E7),
      400: const Color(0xFF5792D9),
      500: const Color(0xFF3174C6),
      600: const Color(0xFF225AA7),
      700: const Color(0xFF1F4E93),
      800: const Color(0xFF1B3E71),
      900: const Color(0xFF1C365E),
      950: const Color(0xFF13233E),
    },
  );
  static MaterialColor orangeSwatch = const MaterialColor(
    0xFFF26A26,
    const <int, Color>{
      50: const Color(0xFFFEF6EE),
      100: const Color(0xFFFEEAD6),
      200: const Color(0xFFFBD1AD),
      300: const Color(0xFFF8B079),
      400: const Color(0xFFF58542),
      500: const Color(0xFFF26A26),
      600: const Color(0xFFE34A13),
      700: const Color(0xFFBC3712),
      800: const Color(0xFF962C16),
      900: const Color(0xFF782816),
      950: const Color(0xFF411109),
    },
  );
  static final themeColor = congressBlueSwatch.shade700;
  static final secondaryColor = congressBlueSwatch.shade500;
  static final themeColorPrimary = congressBlueSwatch;
  static const accentTextColor = Color.fromARGB(255, 237, 107, 90);
  static const accentColor = Color.fromARGB(255, 242, 106, 38);
  static final scaffoldBackgroundColor = Colors.white;
  //text color
  static const darkText1 = Colors.black;
  static const lightText1 = Colors.white;
  static final indicatorColorHigh = orangeSwatch.shade400;
  static final indicatorColorMedium = orangeSwatch.shade300;
  static final indicatorColorLow = orangeSwatch.shade200;
  //
}
