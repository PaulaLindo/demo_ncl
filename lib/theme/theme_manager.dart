// lib/theme/theme_manager.dart - Centralized theme management
import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Theme Manager for handling multiple client themes
class ThemeManager {
  static ThemeManager? _instance;
  static ThemeManager get instance => _instance ??= ThemeManager._();
  
  ThemeManager._();

  ThemeType _currentTheme = ThemeType.purpleGold;
  
  /// Current active theme type
  ThemeType get currentTheme => _currentTheme;
  
  /// Set current theme
  void setTheme(ThemeType theme) {
    _currentTheme = theme;
  }

  /// Get theme data for current theme
  ThemeData get currentThemeData {
    switch (_currentTheme) {
      case ThemeType.purpleGold:
        return AppTheme.purpleGoldTheme;
      case ThemeType.navyGold:
        return AppTheme.navyGoldTheme;
      default:
        return AppTheme.purpleGoldTheme; // Fallback
    }
  }

  /// Get theme colors for current theme
  AppThemeColors get currentColors {
    switch (_currentTheme) {
      case ThemeType.purpleGold:
        return AppThemeColors.purpleGold;
      case ThemeType.navyGold:
        return AppThemeColors.navyGold;
      default:
        return AppThemeColors.purpleGold; // Fallback
    }
  }

  /// Get theme name for display
  String get themeName {
    switch (_currentTheme) {
      case ThemeType.purpleGold:
        return 'Purple & Gold';
      case ThemeType.navyGold:
        return 'Navy & Gold';
      default:
        return 'Purple & Gold'; // Fallback
    }
  }
}

/// Available theme types
enum ThemeType {
  purpleGold,
  navyGold,
}

/// Theme-specific color definitions
class AppThemeColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color onPrimary;
  final Color onSecondary;
  final Color onSurface;
  final Color onBackground;
  final Color border;
  final Color text;
  final Color subtleText;
  final Color success;
  final Color warning;
  final Color error;

  const AppThemeColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.onPrimary,
    required this.onSecondary,
    required this.onSurface,
    required this.onBackground,
    required this.border,
    required this.text,
    required this.subtleText,
    required this.success,
    required this.warning,
    required this.error,
  });

  /// Purple & Gold Theme (Current)
  static const AppThemeColors purpleGold = AppThemeColors(
    primary: Color(0xFF5D3F6A),      // Purple
    secondary: Color(0xFF2C2C2C),    // Dark Gray
    accent: Color(0xFFD4AF37),       // Rich Gold (updated)
    background: Color(0xFFF8F9FA),   // Lighter Background (updated)
    surface: Color(0xFFFFFFFF),      // White
    onPrimary: Color(0xFFFFFFFF),     // White
    onSecondary: Color(0xFFFFFFFF),  // White
    onSurface: Color(0xFF333333),    // Dark Text
    onBackground: Color(0xFF333333), // Dark Text
    border: Color(0xFFE0E0E0),       // Light Gray
    text: Color(0xFF333333),         // Dark Text
    subtleText: Color(0xFF868686),   // Gray Text
    success: Color(0xFF4CAF50),     // Green
    warning: Color(0xFFf59e0b),      // Orange
    error: Color(0xFFF44336),        // Red
  );

  /// Navy & Gold Theme (New)
  static const AppThemeColors navyGold = AppThemeColors(
    primary: Color(0xFF1E3A8A),      // Navy Blue
    secondary: Color(0xFF1F2937),    // Dark Gray
    accent: Color(0xFFEAB308),       // Gold
    background: Color(0xFFF8FAFC),   // Very Light Gray
    surface: Color(0xFFFFFFFF),      // White
    onPrimary: Color(0xFFFFFFFF),     // White
    onSecondary: Color(0xFFFFFFFF),  // White
    onSurface: Color(0xFF1F2937),    // Dark Text
    onBackground: Color(0xFF1F2937), // Dark Text
    border: Color(0xFFE5E7EB),       // Light Gray
    text: Color(0xFF1F2937),         // Dark Text
    subtleText: Color(0xFF6B7280),   // Gray Text
    success: Color(0xFF10B981),     // Emerald Green
    warning: Color(0xFFF59E0B),      // Amber
    error: Color(0xFFEF4444),        // Red
  );
}

/// Extension for easy theme access
extension ThemeManagerExtension on BuildContext {
  ThemeManager get themeManager => ThemeManager.instance;
  AppThemeColors get colors => ThemeManager.instance.currentColors;
  ThemeData get appTheme => ThemeManager.instance.currentThemeData;
}
