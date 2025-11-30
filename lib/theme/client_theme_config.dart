/// Client Theme Configuration
/// 
/// This file allows easy theme customization for different clients
/// Simply modify the colors below to change the entire app theme
/// 
/// Example: Client wants green/orange instead of purple/gold
/// Just replace the colors in the selected theme set
import 'package:flutter/material.dart';

class ClientThemeConfig {
  
  // CURRENT CLIENT THEME - Purple & Gold (Your current theme)
  static const Map<String, Color> currentTheme = {
    'primary': Color(0xFF5D3F6A),      // Purple (main brand color)
    'secondary': Color(0xFFEECB05),    // Gold (accent color)
    'background': Color(0xFFF5F5F5),   // Light background
    'card': Color(0xFFFFFFFF),         // White cards
    'text': Color(0xFF333333),         // Dark text
    'subtleText': Color(0xFF868686),   // Grey subtle text
    'success': Color(0xFF4CAF50),       // Green success
    'error': Color(0xFFF44336),        // Red error
    'border': Color(0xFFE0E0E0),       // Light borders
  };
  
  // ALTERNATE CLIENT THEME - Navy & Gold
  static const Map<String, Color> navyGoldTheme = {
    'primary': Color(0xFF1E3A8A),      // Navy blue (main brand color)
    'secondary': Color(0xFFEECB05),    // Gold (accent color)
    'background': Color(0xFFF8FAFC),   // Light grey background
    'card': Color(0xFFFFFFFF),         // White cards
    'text': Color(0xFF1F2937),         // Dark grey text
    'subtleText': Color(0xFF6B7280),   // Medium grey subtle text
    'success': Color(0xFF10B981),       // Emerald green success
    'error': Color(0xFFEF4444),        // Red error
    'border': Color(0xFFE5E7EB),       // Light grey borders
  };
  
  // FUTURE CLIENT THEME - Green & Orange (Example for new clients)
  static const Map<String, Color> greenOrangeTheme = {
    'primary': Color(0xFF059669),      // Green (main brand color)
    'secondary': Color(0xFFEA580C),    // Orange (accent color)
    'background': Color(0xFFF0FDF4),   // Very light green background
    'card': Color(0xFFFFFFFF),         // White cards
    'text': Color(0xFF064E3B),         // Dark green text
    'subtleText': Color(0xFF6B7280),   // Medium grey subtle text
    'success': Color(0xFF059669),       // Green success
    'error': Color(0xFFDC2626),        // Red error
    'border': Color(0xFFD1FAE5),       // Light green borders
  };
  
  // ACTIVE THEME SELECTION
  // Change this line to switch between client themes:
  // - currentTheme (Purple & Gold - Your current theme)
  // - navyGoldTheme (Navy & Gold - Alternative option)
  // - greenOrangeTheme (Green & Orange - Example for new clients)
  static const Map<String, Color> activeTheme = currentTheme;
  
  // Convenience getters for the active theme
  static Color get primary => activeTheme['primary']!;
  static Color get secondary => activeTheme['secondary']!;
  static Color get background => activeTheme['background']!;
  static Color get card => activeTheme['card']!;
  static Color get text => activeTheme['text']!;
  static Color get subtleText => activeTheme['subtleText']!;
  static Color get success => activeTheme['success']!;
  static Color get error => activeTheme['error']!;
  static Color get border => activeTheme['border']!;
  
  // Theme display names for the switcher
  static String getThemeDisplayName(Map<String, Color> theme) {
    if (theme == currentTheme) return 'Purple & Gold (Current)';
    if (theme == navyGoldTheme) return 'Navy & Gold';
    if (theme == greenOrangeTheme) return 'Green & Orange';
    return 'Unknown Theme';
  }
  
  // Get all available themes for the switcher
  static List<Map<String, Color>> get availableThemes => [
    currentTheme,
    navyGoldTheme,
    greenOrangeTheme,
  ];
}
