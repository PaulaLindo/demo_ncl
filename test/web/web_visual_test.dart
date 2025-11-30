// test/web/web_visual_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/main.dart' as app;

void main() {
  group('Web Visual Tests', () {
    testWidgets('Web app visual regression test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Take screenshot of login chooser
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/web_login_chooser.png'),
      );
    });

    testWidgets('Web app responsive test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test mobile view
      await tester.binding.setSurfaceSize(Size(375, 667));
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/web_mobile.png'),
      );

      // Test desktop view
      await tester.binding.setSurfaceSize(Size(1200, 800));
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/web_desktop.png'),
      );

      // Reset
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Web app renders all UI elements', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Test that all key elements are present
      expect(find.text('Welcome to NCL'), findsOneWidget);
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.text('Staff Access'), findsOneWidget);
      expect(find.text('Admin Portal'), findsOneWidget);
    });
  });
}
