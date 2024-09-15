import 'package:flutter/material.dart';
import 'app_color.dart';

ThemeData appTheme() => ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.scaffoldBackgroundColor,
      ),
      useMaterial3: true,
      textTheme:  const TextTheme(
        titleMedium: TextStyle(
            fontFamily: 'hiragino',
            fontSize: 32,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'hiragino',
          fontSize: 24,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'hiragino',
          fontSize: 20,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(showCloseIcon: true),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Colors.black),
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
        labelStyle: const TextStyle(
          fontSize: 14,
        ),
      hintStyle: const TextStyle(
          fontSize: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style:
              ElevatedButton.styleFrom(foregroundColor: AppColors.themeColor)),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
          foregroundColor: Colors.black,
        ),
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
      colorScheme:
          ColorScheme.fromSwatch(primarySwatch: AppColors.themeColorPrimary)
              .copyWith(secondary: AppColors.accentColor),
    );
