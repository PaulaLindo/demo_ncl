import 'package:flutter/material.dart';

/// Extension on [Color] to provide custom opacity with simplified API.
/// 
/// This extension adds a [withCustomOpacity] method that handles the conversion
/// from 0.0-1.0 opacity range to the 0-255 alpha channel range internally.
extension ColorExtension on Color {
  /// Returns a new color with the given opacity.
  ///
  /// The [opacity] must be between 0.0 (invisible) and 1.0 (fully opaque).
  /// Values will be clamped to this range.
  Color withCustomOpacity(double opacity) {
    return withValues(
      alpha: opacity.clamp(0.0, 1.0),
    );
  }
}

/// Extension on [MaterialColor] to provide custom opacity with simplified API.
extension MaterialColorExtension on MaterialColor {
  /// Returns a new color with the given opacity.
  ///
  /// The [opacity] must be between 0.0 (invisible) and 1.0 (fully opaque).
  /// Values will be clamped to this range.
  Color withCustomOpacity(double opacity) {
    return withValues(
      alpha: opacity.clamp(0.0, 1.0),
    );
  }
}