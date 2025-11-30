// lib/utils/web_color_utils.dart - Web-compatible color utilities
import 'package:flutter/material.dart';

/// Web-compatible color extensions that replace withCustomOpacity
/// Uses Flutter's built-in withOpacity() which works reliably in web
extension WebColorExtension on Color {
  /// Web-compatible opacity method - uses Flutter's built-in withOpacity()
  Color withWebOpacity(double opacity) {
    return withOpacity(opacity.clamp(0.0, 1.0));
  }
  
  /// Create a lighter version of the color for web
  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
  
  /// Create a darker version of the color for web
  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

/// Web-compatible theme colors with better CanvasKit support
class WebThemeColors {
  // Primary colors - Material 3 compatible
  static const Color primary = Color(0xFF6750A4); // Material 3 Purple
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFEADDFF);
  static const Color onPrimaryContainer = Color(0xFF21005D);
  
  // Secondary colors
  static const Color secondary = Color(0xFF625B71);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE8DEF8);
  static const Color onSecondaryContainer = Color(0xFF1D192B);
  
  // Surface colors - better for web rendering
  static const Color surface = Color(0xFFFFFBFE);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  
  // Background colors
  static const Color background = Color(0xFFFFFBFE);
  static const Color onBackground = Color(0xFF1C1B1F);
  
  // Error colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  
  // Success colors
  static const Color success = Color(0xFF006C3C);
  static const Color onSuccess = Color(0xFFFFFFFF);
  
  // Warning colors
  static const Color warning = Color(0xFF7D5700);
  static const Color onWarning = Color(0xFFFFFFFF);
  
  // Text colors - Material 3 compatible
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color textTertiary = Color(0xFF79747E);
  static const Color textDisabled = Color(0xFFCAC4D0);
  
  // Border colors
  static const Color border = Color(0xFF79747E);
  static const Color borderLight = Color(0xFFE7E0EC);
  
  // Shadow colors
  static const Color shadow = Color(0x1F000000);
  static const Color shadowLight = Color(0x0F000000);
}

/// Web-compatible elevation/shadow utilities
class WebShadows {
  static List<BoxShadow> get elevation1 => [
    BoxShadow(
      color: WebThemeColors.shadow,
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get elevation2 => [
    BoxShadow(
      color: WebThemeColors.shadow,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get elevation3 => [
    BoxShadow(
      color: WebThemeColors.shadow,
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get elevation4 => [
    BoxShadow(
      color: WebThemeColors.shadow,
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get elevation6 => [
    BoxShadow(
      color: WebThemeColors.shadow,
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
  
  static List<BoxShadow> get elevation8 => [
    BoxShadow(
      color: WebThemeColors.shadow,
      blurRadius: 32,
      offset: const Offset(0, 16),
    ),
  ];
  
  // Card shadow - optimized for web
  static List<BoxShadow> get card => [
    BoxShadow(
      color: WebThemeColors.shadowLight,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  // Button shadow - optimized for web
  static List<BoxShadow> get button => [
    BoxShadow(
      color: WebThemeColors.shadowLight,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
}

/// Web-compatible gradient utilities
class WebGradients {
  /// Safe gradient for web rendering
  static LinearGradient primaryGradient({
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      colors: [
        WebThemeColors.primary.withWebOpacity(0.1),
        WebThemeColors.surface,
      ],
      begin: begin,
      end: end,
    );
  }
  
  /// Safe gradient for buttons
  static LinearGradient buttonGradient(Color color) {
    return LinearGradient(
      colors: [
        color,
        color.darken(0.1),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
  
  /// Safe gradient for containers
  static LinearGradient containerGradient({
    Color? color,
    double opacity = 0.1,
  }) {
    final baseColor = color ?? WebThemeColors.primary;
    return LinearGradient(
      colors: [
        baseColor.withWebOpacity(opacity),
        baseColor.withWebOpacity(opacity * 0.5),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

/// Web-compatible border radius utilities
class WebBorderRadius {
  static const BorderRadius xs = BorderRadius.all(Radius.circular(4));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius md = BorderRadius.all(Radius.circular(12));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(16));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(20));
  static const BorderRadius xxl = BorderRadius.all(Radius.circular(24));
  static const BorderRadius full = BorderRadius.all(Radius.circular(999));
}

/// Web-compatible spacing utilities
class WebSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// Web-compatible text styles
class WebTextStyles {
  static TextStyle get headlineLarge => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: WebThemeColors.textPrimary,
    height: 1.2,
  );
  
  static TextStyle get headlineMedium => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: WebThemeColors.textPrimary,
    height: 1.2,
  );
  
  static TextStyle get headlineSmall => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: WebThemeColors.textPrimary,
    height: 1.2,
  );
  
  static TextStyle get titleLarge => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: WebThemeColors.textPrimary,
    height: 1.3,
  );
  
  static TextStyle get titleMedium => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: WebThemeColors.textPrimary,
    height: 1.3,
  );
  
  static TextStyle get titleSmall => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: WebThemeColors.textPrimary,
    height: 1.3,
  );
  
  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: WebThemeColors.textPrimary,
    height: 1.5,
  );
  
  static TextStyle get bodyMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: WebThemeColors.textPrimary,
    height: 1.5,
  );
  
  static TextStyle get bodySmall => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: WebThemeColors.textPrimary,
    height: 1.5,
  );
  
  static TextStyle get labelLarge => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: WebThemeColors.textPrimary,
    height: 1.3,
  );
  
  static TextStyle get labelMedium => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: WebThemeColors.textPrimary,
    height: 1.3,
  );
  
  static TextStyle get labelSmall => const TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: WebThemeColors.textPrimary,
    height: 1.3,
  );
}
