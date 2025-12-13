import 'package:flutter/material.dart';

class AppTheme {

  static const gsuBlue = Color(0xFF0039A6); // primary
  static const gsuRed = Color(0xFFE03A3E);  // accent
  static const background = Color(0xFFF5F7FB); // light blue
  static const card = Colors.white;

  static const primary = gsuBlue;
  static const field = Color(0xFFE6EDF8); 
  static const panel = background;

  static const accent = gsuRed;
  static ThemeData get lightTheme {
    final base = ThemeData(useMaterial3: true);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: gsuBlue,
        primary: gsuBlue,
        secondary: gsuRed,
        background: background,
      ),
      scaffoldBackgroundColor: background,

   
      appBarTheme: const AppBarTheme(
        backgroundColor: gsuBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Red
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: gsuRed,
        foregroundColor: Colors.white,
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gsuBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),


      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: gsuBlue,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),


      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: gsuBlue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),

     
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCAD4E4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCAD4E4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gsuBlue, width: 1.6),
        ),
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
      ),

      // Cards & general surfaces
      cardColor: card,
    );
  }
}
