// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

/// Centralized theme configuration matching your CSS variables
class AppTheme {
  // Brand Colors - From your CSS
  static const Color primaryPurple = Color(0xFF5D3F6A);  // --primary-color
  static const Color goldAccent = Color(0xFFEECB05);     // --gold-accent
  static const Color secondaryColor = Color(0xFF2C2C2C); // --secondary-color
  
  // Background Colors
  static const Color lightBackground = Color(0xFFF5F5F5);      // --light-background
  static const Color backgroundLight = Color(0xFFF5F5F5);      // Alias for consistency
  static const Color containerBackground = Color(0xFFE9E7E7);  // --container-background
  static const Color cardBackground = Color(0xFFFFFFFF);       // --card-background
  static const Color cardWhite = Color(0xFFFFFFFF);            // Alias
  
  // Border and Text Colors
  static const Color borderColor = Color(0xFFE0E0E0);    // --border-color
  static const Color borderGrey = Color(0xFFE0E0E0);     // Alias
  static const Color textColor = Color(0xFF333333);      // --text-color
  static const Color textDark = Color(0xFF333333);       // Alias
  static const Color subtleText = Color(0xFF868686);     // --subtle-text
  static const Color textGrey = Color(0xFF868686);       // Alias
  static const Color fadedText = Color(0xFFCFD0D1);      // --faded-text
  
  // Status Colors
  static const Color greenStatus = Color(0xFF4CAF50);    // --green-status
  static const Color successGreen = Color(0xFF4CAF50);   // Alias
  static const Color redStatus = Color(0xFFF44336);      // --red-status
  static const Color errorRed = Color(0xFFF44336);       // Alias
  
  // Additional Utility Colors
  static const Color secondaryTeal = Color(0xFF4ECDC4);
  static const Color warningOrange = Color(0xFFf59e0b);
  static const Color infoBlue = Color(0xFF3b82f6);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        primary: primaryPurple,
        secondary: goldAccent,
        error: redStatus,
        surface: cardBackground,
        background: lightBackground,
      ),
      
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: lightBackground,
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: cardBackground,
        foregroundColor: primaryPurple,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryPurple,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: primaryPurple),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        color: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontFamily: 'Inter',
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPurple,
          side: const BorderSide(color: primaryPurple, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryPurple,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: redStatus),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: redStatus, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        hintStyle: const TextStyle(color: subtleText, fontFamily: 'Inter'),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: containerBackground,
        selectedColor: primaryPurple,
        labelStyle: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: primaryPurple,
        unselectedItemColor: subtleText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontFamily: 'Inter'),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        // Headlines
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: secondaryColor,
          letterSpacing: -0.5,
          fontFamily: 'Inter',
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: secondaryColor,
          letterSpacing: -0.5,
          fontFamily: 'Inter',
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: secondaryColor,
          fontFamily: 'Inter',
        ),
        
        // Titles
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'Inter',
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'Inter',
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'Inter',
        ),
        
        // Body
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textColor,
          height: 1.5,
          fontFamily: 'Inter',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textColor,
          height: 1.5,
          fontFamily: 'Inter',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: subtleText,
          height: 1.4,
          fontFamily: 'Inter',
        ),
        
        // Labels
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'Inter',
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
          fontFamily: 'Inter',
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: subtleText,
          fontFamily: 'Inter',
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: subtleText,
        size: 24,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryPurple,
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: secondaryColor,
        contentTextStyle: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: cardBackground,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
      ),
      
      // Font Family
      fontFamily: 'Inter',
    );
  }
  
  // Custom Text Styles
  static const TextStyle badgeText = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    fontFamily: 'Inter',
  );
  
  static const TextStyle priceText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryPurple,
    fontFamily: 'Inter',
  );
  
  // Box Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];
}

// Extension for convenient access
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}