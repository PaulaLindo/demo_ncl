import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/client_theme_config.dart';

enum ClientThemeMode {
  currentTheme,    // Purple & Gold (Current)
  navyGold,        // Navy & Gold
  greenOrange,     // Green & Orange (Example for new clients)
}

class ThemeProvider extends ChangeNotifier {
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;
  ThemeProvider._internal();

  ClientThemeMode _currentTheme = ClientThemeMode.currentTheme;
  ClientThemeMode get currentTheme => _currentTheme;

  static const String _themeKey = 'client_theme_mode';

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _currentTheme = ClientThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> setTheme(ClientThemeMode theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
    notifyListeners();
  }

  ThemeData get currentThemeData {
    switch (_currentTheme) {
      case ClientThemeMode.currentTheme:
        return _buildClientTheme(ClientThemeConfig.currentTheme);
      case ClientThemeMode.navyGold:
        return _buildClientTheme(ClientThemeConfig.navyGoldTheme);
      case ClientThemeMode.greenOrange:
        return _buildClientTheme(ClientThemeConfig.greenOrangeTheme);
    }
  }

  String get currentThemeName {
    switch (_currentTheme) {
      case ClientThemeMode.currentTheme:
        return 'Purple & Gold (Current)';
      case ClientThemeMode.navyGold:
        return 'Navy & Gold';
      case ClientThemeMode.greenOrange:
        return 'Green & Orange';
    }
  }

  Color get primaryColor {
    switch (_currentTheme) {
      case ClientThemeMode.currentTheme:
        return ClientThemeConfig.currentTheme['primary']!;
      case ClientThemeMode.navyGold:
        return ClientThemeConfig.navyGoldTheme['primary']!;
      case ClientThemeMode.greenOrange:
        return ClientThemeConfig.greenOrangeTheme['primary']!;
    }
  }

  Color get secondaryColor {
    switch (_currentTheme) {
      case ClientThemeMode.currentTheme:
        return ClientThemeConfig.currentTheme['secondary']!;
      case ClientThemeMode.navyGold:
        return ClientThemeConfig.navyGoldTheme['secondary']!;
      case ClientThemeMode.greenOrange:
        return ClientThemeConfig.greenOrangeTheme['secondary']!;
    }
  }

  Color get backgroundColor {
    switch (_currentTheme) {
      case ClientThemeMode.currentTheme:
        return ClientThemeConfig.currentTheme['background']!;
      case ClientThemeMode.navyGold:
        return ClientThemeConfig.navyGoldTheme['background']!;
      case ClientThemeMode.greenOrange:
        return ClientThemeConfig.greenOrangeTheme['background']!;
    }
  }

  Color get cardColor {
    switch (_currentTheme) {
      case ClientThemeMode.currentTheme:
        return ClientThemeConfig.currentTheme['card']!;
      case ClientThemeMode.navyGold:
        return ClientThemeConfig.navyGoldTheme['card']!;
      case ClientThemeMode.greenOrange:
        return ClientThemeConfig.greenOrangeTheme['card']!;
    }
  }

  Color get textColor {
    switch (_currentTheme) {
      case ClientThemeMode.currentTheme:
        return ClientThemeConfig.currentTheme['text']!;
      case ClientThemeMode.navyGold:
        return ClientThemeConfig.navyGoldTheme['text']!;
      case ClientThemeMode.greenOrange:
        return ClientThemeConfig.greenOrangeTheme['text']!;
    }
  }

  ThemeData _buildClientTheme(Map<String, Color> themeColors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeColors['primary']!,
        primary: themeColors['primary']!,
        secondary: themeColors['secondary']!,
        surface: themeColors['card']!,
        background: themeColors['background']!,
        error: themeColors['error']!,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: themeColors['primary']!,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: themeColors['card']!,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColors['primary']!,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
