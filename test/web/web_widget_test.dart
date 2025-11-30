// test/web/web_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/screens/auth/login_chooser_screen.dart';
import 'package:demo_ncl/main.dart';

void main() {
  group('Web Widget Tests', () {
    testWidgets('Login chooser screen renders on web', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginChooserScreen(),
        ),
      );

      // Test that all elements are present
      expect(find.text('Welcome to NCL'), findsOneWidget);
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.text('Staff Access'), findsOneWidget);
      expect(find.text('Admin Portal'), findsOneWidget);
    });

    testWidgets('Web navigation works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginChooserScreen(),
        ),
      );

      // Test customer login navigation
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Should show customer login content
      expect(find.text('Customer Login'), findsWidgets);
    });

    testWidgets('Web responsive layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginChooserScreen(),
        ),
      );

      // Test mobile size
      await tester.binding.setSurfaceSize(Size(375, 667));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to NCL'), findsOneWidget);

      // Test desktop size
      await tester.binding.setSurfaceSize(Size(1200, 800));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to NCL'), findsOneWidget);

      // Reset
      await tester.binding.setSurfaceSize(null);
    });
  });
}
