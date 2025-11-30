// test/widgets/simplified_ncl_app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:demo_ncl/screens/auth/login_chooser_screen.dart';
import 'package:demo_ncl/theme/app_theme.dart';

// Simplified version of NCLApp for testing
class SimplifiedNCLApp extends StatefulWidget {
  const SimplifiedNCLApp({super.key});

  @override
  State<SimplifiedNCLApp> createState() => _SimplifiedNCLAppState();
}

class _SimplifiedNCLAppState extends State<SimplifiedNCLApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    print('🔍 SimplifiedNCLApp.initState() called');
    
    // Create a simple router without auth dependencies
    _router = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginChooserScreen(),
        ),
      ],
    );
    print('🔍 Simplified router created: ${_router != null}');
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 SimplifiedNCLApp.build() called');
    print('🔍 Router is null: ${_router == null}');
    
    return MaterialApp.router(
      routerConfig: _router,
      title: 'NCL - Simplified',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}

void main() {
  group('Simplified NCL App Tests', () {
    testWidgets('Simplified NCLApp works', (WidgetTester tester) async {
      print('🚀 Testing simplified NCLApp');
      
      try {
        // Build the simplified app
        await tester.pumpWidget(
          const SimplifiedNCLApp(),
        );

        print('🔍 Pumped simplified NCLApp');
        await tester.pumpAndSettle();
        print('🔍 Pumped and settled');

        // Check if the login chooser screen appears
        expect(find.text('Welcome to NCL'), findsOneWidget);
        expect(find.text('Customer Login'), findsOneWidget);
        expect(find.text('Staff Access'), findsOneWidget);
        expect(find.text('Admin Portal'), findsOneWidget);
        print('🔍 Found all login chooser elements');
        
      } catch (e, stackTrace) {
        print('🔥 Exception caught: $e');
        print('🔥 Stack trace: $stackTrace');
        rethrow;
      }
    });
  });
}
