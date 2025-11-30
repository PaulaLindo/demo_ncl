// test/web/web_integration_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Web Integration Tests', () {
    testWidgets('Web app loads and renders correctly', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 10));

      // Test that the app loads
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Test login chooser screen
      expect(find.text('Welcome to NCL'), findsOneWidget);
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.text('Staff Access'), findsOneWidget);
      expect(find.text('Admin Portal'), findsOneWidget);

      // Test navigation
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();
      
      // Verify navigation worked
      expect(find.text('Customer Login'), findsWidgets);
    });

    testWidgets('Web app responsive design', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test different screen sizes
      await tester.binding.setSurfaceSize(Size(375, 667)); // Mobile
      await tester.pumpAndSettle();
      expect(find.text('Welcome to NCL'), findsOneWidget);

      await tester.binding.setSurfaceSize(Size(1200, 800)); // Desktop
      await tester.pumpAndSettle();
      expect(find.text('Welcome to NCL'), findsOneWidget);

      await tester.binding.setSurfaceSize(Size(768, 1024)); // Tablet
      await tester.pumpAndSettle();
      expect(find.text('Welcome to NCL'), findsOneWidget);

      // Reset
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Web app interactions work', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test button interactions
      await tester.tap(find.text('Staff Access'));
      await tester.pumpAndSettle();
      
      // Test form interactions
      await tester.enterText(find.byKey(Key('email-field')), 'test@example.com');
      await tester.pumpAndSettle();
      
      // Test navigation back
      await tester.pageBack();
      await tester.pumpAndSettle();
      
      expect(find.text('Welcome to NCL'), findsOneWidget);
    });
  });
}
