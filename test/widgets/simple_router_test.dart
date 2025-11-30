// test/widgets/simple_router_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:demo_ncl/screens/auth/login_chooser_screen.dart';

void main() {
  group('Simple Router Tests', () {
    testWidgets('Simple MaterialApp.router works', (WidgetTester tester) async {
      print('🚀 Testing simple router');
      
      // Build a simple MaterialApp.router with just the login chooser
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const LoginChooserScreen(),
              ),
            ],
          ),
        ),
      );

      print('🔍 Pumped simple router');
      await tester.pumpAndSettle();
      print('🔍 Pumped and settled');

      // Check if the login chooser screen appears
      expect(find.text('Welcome to NCL'), findsOneWidget);
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.text('Staff Access'), findsOneWidget);
      expect(find.text('Admin Portal'), findsOneWidget);
      print('🔍 Found all login chooser elements');
    });
  });
}
