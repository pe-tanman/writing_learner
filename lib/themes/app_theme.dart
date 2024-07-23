import 'package:flutter/material.dart';
import 'app_color.dart';

ThemeData appTheme() => ThemeData(
      appBarTheme:  AppBarTheme(
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      useMaterial3: true,
      fontFamily: "NotoSansJP",
      snackBarTheme: const SnackBarThemeData(showCloseIcon: true),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: DividerThemeData(color: Colors.black),
      dividerColor: Colors.brown.shade100,
      dialogTheme: const DialogTheme(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 22,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.themeColor
      )),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
          foregroundColor: Colors.black,
        ),
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: AppColors.themeColorPrimary).copyWith(secondary: AppColors.accentColor),
    );
