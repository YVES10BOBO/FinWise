import 'package:flutter/material.dart';

class AppTheme {
  // Brand palette, taken from the FinWise app icon: a shield that runs from
  // deep teal into a natural green, with a yellow/amber arrow.
  //
  // `secondaryColor` used to be a neon cyan (#14FFEC) which appeared nowhere
  // in the icon and made every gradient look harsh. It's now the icon's green
  // end, so the greeting header, This Month card, goals header and onboarding
  // all match the brand automatically.
  static const Color primaryColor = Color(0xFF0D7377);
  static const Color secondaryColor = Color(0xFF2FA84F);
  static const Color accentColor = Color(0xFFFFB700);
  static const Color accentDark = Color(0xFFFFA000);
  
  // Background colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  
  // Text colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  
  // Status colors
  static const Color incomeColor = Color(0xFF4CAF50);
  static const Color expenseColor = Color(0xFFF44336);
  
  // Gradient
  static LinearGradient primaryGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, secondaryColor],
  );
  
  static LinearGradient accentGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentColor, accentDark],
  );
  
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
