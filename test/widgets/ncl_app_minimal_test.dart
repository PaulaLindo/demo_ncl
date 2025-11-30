// test/widgets/ncl_app_minimal_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/main.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/screens/auth/login_chooser_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('NCL App - Minimal Tests', () {
    testWidgets('NCLApp renders with minimal providers', (WidgetTester tester) async {
      // Build the app with just the essential providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<MockDataService>.value(value: MockDataService()),
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(MockDataService()),
            ),
          ],
          child: const MaterialApp(
            home: LoginChooserScreen(),
          ),
        ),
      );

      // Wait for the app to load
      await tester.pumpAndSettle();

      // Verify that the login chooser screen appears
      expect(find.text('Welcome to NCL'), findsOneWidget);
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.text('Staff Access'), findsOneWidget);
      expect(find.text('Admin Portal'), findsOneWidget);
    });

    testWidgets('NCLApp renders with GoRouter', (WidgetTester tester) async {
      // Build the app with GoRouter
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<MockDataService>.value(value: MockDataService()),
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(MockDataService()),
            ),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const LoginChooserScreen(),
                ),
              ],
            ),
          ),
        ),
      );

      // Wait for the app to load
      await tester.pumpAndSettle();

      // Verify that the login chooser screen appears
      expect(find.text('Welcome to NCL'), findsOneWidget);
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.text('Staff Access'), findsOneWidget);
      expect(find.text('Admin Portal'), findsOneWidget);
    });

    testWidgets('NCLApp widget renders correctly', (WidgetTester tester) async {
      // Build the actual NCLApp widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<SharedPreferences>(
              create: (_) => MockSharedPreferences(),
            ),
            Provider<MockDataService>.value(value: MockDataService()),
            ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(MockDataService()),
            ),
          ],
          child: const NCLApp(),
        ),
      );

      // Wait for the app to load
      await tester.pumpAndSettle();

      // Verify that the login chooser screen appears
      expect(find.text('Welcome to NCL'), findsOneWidget);
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.text('Staff Access'), findsOneWidget);
      expect(find.text('Admin Portal'), findsOneWidget);
    });
  });
}

// Mock SharedPreferences for testing
class MockSharedPreferences implements SharedPreferences {
  final Map<String, dynamic> _data = {};

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<bool> commit() async => true;

  @override
  bool containsKey(String key) => _data.containsKey(key);

  @override
  dynamic get(String key) => _data[key];

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return true;
  }

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  int? getInt(String key) => _data[key] as int?;

  @override
  double? getDouble(String key) => _data[key] as double?;

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  List<String>? getStringList(String key) => _data[key] as List<String>?;

  @override
  Future<void> reload() async {}

  @override
  Set<String> getKeys() => _data.keys.toSet();
}
