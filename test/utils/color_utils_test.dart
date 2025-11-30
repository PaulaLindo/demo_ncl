import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/utils/color_utils.dart';

void main() {
  group('ColorExtension', () {
    const testColor = Color(0xFF4285F4); // A sample color (blue-ish)
    
    test('withCustomOpacity applies correct opacity', () {
      // Test with 50% opacity
      final result = testColor.withCustomOpacity(0.5);
      expect(result.alpha, 128); // 255 * 0.5 = 127.5, rounded to 128

      // Test with 0% opacity (fully transparent)
      final transparent = testColor.withCustomOpacity(0);
      expect(transparent.alpha, 0);

      // Test with 100% opacity (fully opaque)
      final opaque = testColor.withCustomOpacity(1);
      expect(opaque.alpha, 255);
    });

    test('withCustomOpacity clamps values outside 0-1 range', () {
      // Test with opacity > 1.0
      final overOne = testColor.withCustomOpacity(1.5);
      expect(overOne.alpha, 255);

      // Test with opacity < 0.0
      final underZero = testColor.withCustomOpacity(-0.5);
      expect(underZero.alpha, 0);
    });

    test('withCustomOpacity preserves RGB values', () {
      final result = testColor.withCustomOpacity(0.5);
      expect(result.red, testColor.red);
      expect(result.green, testColor.green);
      expect(result.blue, testColor.blue);
    });

    test('withCustomOpacity with extreme values', () {
      // Test with very small opacity
      final tinyOpacity = testColor.withCustomOpacity(0.001);
      expect(tinyOpacity.alpha, 0); // Should be 0 due to rounding
      
      // Test with very large opacity
      final hugeOpacity = testColor.withCustomOpacity(999);
      expect(hugeOpacity.alpha, 255);
    });
  });

  group('MaterialColorExtension', () {
    test('withCustomOpacity works on MaterialColor', () {
      // Test with Colors.blue (which is a MaterialColor)
      final result = Colors.blue.withCustomOpacity(0.5);
      expect(result.alpha, 128); // 255 * 0.5 = 127.5, rounded to 128

      // Test with 0% opacity (fully transparent)
      final transparent = Colors.red.withCustomOpacity(0);
      expect(transparent.alpha, 0);

      // Test with 100% opacity (fully opaque)
      final opaque = Colors.green.withCustomOpacity(1);
      expect(opaque.alpha, 255);
    });
  });
}
