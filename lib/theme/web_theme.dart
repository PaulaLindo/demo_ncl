// lib/theme/web_theme.dart - Web-compatible Material 3 theme
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/web_color_utils.dart';

/// Web-compatible Material 3 theme for better CanvasKit compatibility
class WebTheme {
  WebTheme._(); // Private constructor
  
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true, // Force Material 3 for better web compatibility
    colorScheme: ColorScheme.fromSeed(
      seedColor: WebThemeColors.primary,
      brightness: Brightness.light,
      // Override specific colors for better web rendering
      primary: WebThemeColors.primary,
      onPrimary: WebThemeColors.onPrimary,
      primaryContainer: WebThemeColors.primaryContainer,
      onPrimaryContainer: WebThemeColors.onPrimaryContainer,
      secondary: WebThemeColors.secondary,
      onSecondary: WebThemeColors.onSecondary,
      secondaryContainer: WebThemeColors.secondaryContainer,
      onSecondaryContainer: WebThemeColors.onSecondaryContainer,
      surface: WebThemeColors.surface,
      onSurface: WebThemeColors.onSurface,
      surfaceVariant: WebThemeColors.surfaceVariant,
      onSurfaceVariant: WebThemeColors.onSurfaceVariant,
      background: WebThemeColors.background,
      onBackground: WebThemeColors.onBackground,
      error: WebThemeColors.error,
      onError: WebThemeColors.onError,
    ),
    
    // Text theme - Material 3 compatible
    textTheme: TextTheme(
      displayLarge: WebTextStyles.headlineLarge,
      displayMedium: WebTextStyles.headlineMedium,
      displaySmall: WebTextStyles.headlineSmall,
      headlineLarge: WebTextStyles.headlineLarge,
      headlineMedium: WebTextStyles.headlineMedium,
      headlineSmall: WebTextStyles.headlineSmall,
      titleLarge: WebTextStyles.titleLarge,
      titleMedium: WebTextStyles.titleMedium,
      titleSmall: WebTextStyles.titleSmall,
      bodyLarge: WebTextStyles.bodyLarge,
      bodyMedium: WebTextStyles.bodyMedium,
      bodySmall: WebTextStyles.bodySmall,
      labelLarge: WebTextStyles.labelLarge,
      labelMedium: WebTextStyles.labelMedium,
      labelSmall: WebTextStyles.labelSmall,
    ),
    
    // App bar theme - Material 3 compatible
    appBarTheme: AppBarTheme(
      backgroundColor: WebThemeColors.surface,
      foregroundColor: WebThemeColors.onSurface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: WebTextStyles.titleLarge,
      iconTheme: const IconThemeData(
        color: WebThemeColors.textPrimary,
        size: 24,
      ),
    ),
    
    // Card theme - optimized for web
    cardTheme: CardThemeData(
      color: WebThemeColors.surface,
      elevation: 2,
      shadowColor: WebThemeColors.shadow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: WebBorderRadius.md,
      ),
      margin: const EdgeInsets.all(8),
    ),
    
    // Elevated button theme - Material 3 compatible
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: WebThemeColors.primary,
        foregroundColor: WebThemeColors.onPrimary,
        elevation: 1,
        shadowColor: WebThemeColors.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: WebBorderRadius.md,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: WebTextStyles.labelLarge,
      ),
    ),
    
    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: WebThemeColors.primary,
        side: const BorderSide(color: WebThemeColors.primary, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: WebBorderRadius.md,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: WebTextStyles.labelLarge,
      ),
    ),
    
    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: WebThemeColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: WebBorderRadius.md,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: WebTextStyles.labelLarge,
      ),
    ),
    
    // Input decoration theme - Material 3 compatible
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WebThemeColors.surfaceVariant.withWebOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: WebBorderRadius.md,
        borderSide: const BorderSide(color: WebThemeColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: WebBorderRadius.md,
        borderSide: const BorderSide(color: WebThemeColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: WebBorderRadius.md,
        borderSide: const BorderSide(color: WebThemeColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: WebBorderRadius.md,
        borderSide: const BorderSide(color: WebThemeColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: WebBorderRadius.md,
        borderSide: const BorderSide(color: WebThemeColors.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: WebBorderRadius.md,
        borderSide: BorderSide(color: WebThemeColors.border.withWebOpacity(0.5)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: WebTextStyles.bodyMedium.copyWith(
        color: WebThemeColors.textSecondary,
      ),
      hintStyle: WebTextStyles.bodyMedium.copyWith(
        color: WebThemeColors.textTertiary,
      ),
      prefixStyle: WebTextStyles.bodyMedium.copyWith(
        color: WebThemeColors.textSecondary,
      ),
      suffixStyle: WebTextStyles.bodyMedium.copyWith(
        color: WebThemeColors.textSecondary,
      ),
      floatingLabelStyle: WebTextStyles.bodyMedium.copyWith(
        color: WebThemeColors.primary,
      ),
    ),
    
    // Container decoration theme
    scaffoldBackgroundColor: WebThemeColors.background,
    
    // Divider theme
    dividerTheme: const DividerThemeData(
      color: WebThemeColors.borderLight,
      thickness: 1,
      space: 1,
    ),
    
    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return WebThemeColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(WebThemeColors.onPrimary),
      side: const BorderSide(color: WebThemeColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: WebBorderRadius.xs,
      ),
    ),
    
    // Radio button theme
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return WebThemeColors.primary;
        }
        return WebThemeColors.border;
      }),
    ),
    
    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return WebThemeColors.primary;
        }
        return WebThemeColors.surface;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return WebThemeColors.primary.withWebOpacity(0.5);
        }
        return WebThemeColors.border.withWebOpacity(0.5);
      }),
    ),
    
    // Progress indicator theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: WebThemeColors.primary,
      linearTrackColor: WebThemeColors.surfaceVariant,
      circularTrackColor: WebThemeColors.surfaceVariant,
    ),
    
    // Snack bar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: WebThemeColors.surface,
      contentTextStyle: WebTextStyles.bodyMedium.copyWith(
        color: WebThemeColors.onSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: WebBorderRadius.md,
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),
    
    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: WebThemeColors.surface,
      elevation: 6,
      shadowColor: WebThemeColors.shadow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: WebBorderRadius.lg,
      ),
      titleTextStyle: WebTextStyles.titleLarge,
      contentTextStyle: WebTextStyles.bodyMedium,
    ),
    
    // Bottom sheet theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: WebThemeColors.surface,
      elevation: 6,
      shadowColor: WebThemeColors.shadow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(WebBorderRadius.lg.topLeft.x),
        ),
      ),
    ),
    
    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: WebThemeColors.surfaceVariant,
      selectedColor: WebThemeColors.primaryContainer,
      disabledColor: WebThemeColors.surfaceVariant.withWebOpacity(0.5),
      labelStyle: WebTextStyles.labelMedium,
      secondaryLabelStyle: WebTextStyles.labelMedium.copyWith(
        color: WebThemeColors.onPrimaryContainer,
      ),
      brightness: Brightness.light,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: WebBorderRadius.sm,
      ),
    ),
    
    // List tile theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      titleTextStyle: WebTextStyles.titleMedium,
      subtitleTextStyle: WebTextStyles.bodyMedium.copyWith(
        color: WebThemeColors.textSecondary,
      ),
      leadingAndTrailingTextStyle: WebTextStyles.bodyMedium,
      tileColor: Colors.transparent,
      selectedTileColor: WebThemeColors.primaryContainer.withWebOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: WebBorderRadius.md,
      ),
    ),
  );
  
  /// Get role-specific color for web compatibility
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'staff':
        return WebThemeColors.secondary;
      case 'admin':
        return const Color(0xFF1E293B);
      case 'customer':
      default:
        return WebThemeColors.primary;
    }
  }
  
  /// Get role-specific gradient for web compatibility
  static LinearGradient getRoleGradient(String role) {
    final color = getRoleColor(role);
    return LinearGradient(
      colors: [
        color.withWebOpacity(0.1),
        WebThemeColors.surface,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}
