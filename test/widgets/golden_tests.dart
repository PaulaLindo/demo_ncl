// test/widgets/golden_tests.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/screens/auth/login_chooser_screen.dart';
import 'package:demo_ncl/main.dart';

void main() {
  group('Golden Tests', () {
    testWidgets('Login chooser screen golden test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginChooserScreen(),
        ),
      );

      await expectLater(
        find.byType(LoginChooserScreen),
        matchesGoldenFile('goldens/login_chooser_screen.png'),
      );
    });

    testWidgets('App golden test - different sizes', (WidgetTester tester) async {
      // Mobile size
      await tester.pumpWidget(NCLApp());
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(NCLApp),
        matchesGoldenFile('goldens/app_mobile.png'),
      );

      // Desktop size
      await tester.binding.setSurfaceSize(Size(1200, 800));
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(NCLApp),
        matchesGoldenFile('goldens/app_desktop.png'),
      );

      // Tablet size
      await tester.binding.setSurfaceSize(Size(800, 600));
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(NCLApp),
        matchesGoldenFile('goldens/app_tablet.png'),
      );

      // Reset
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Login chooser interactions golden test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginChooserScreen(),
        ),
      );

      // Test initial state
      await expectLater(
        find.byType(LoginChooserScreen),
        matchesGoldenFile('goldens/login_chooser_initial.png'),
      );

      // Test pressed state
      await tester.press(find.text('Customer Login'));
      await tester.pumpAndSettle();
      
      await expectLater(
        find.byType(LoginChooserScreen),
        matchesGoldenFile('goldens/login_chooser_pressed.png'),
      );
    });
  });
}
