// test/widgets/ncl_app_debug_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/main.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('NCL App Debug Tests', () {
    testWidgets('Debug NCLApp initialization', (WidgetTester tester) async {
      print('🚀 Starting debug test');
      
      try {
        // Build the app with minimal providers
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

        print('🔍 Pumped widget');
        await tester.pumpAndSettle();
        print('🔍 Pumped and settled');

        // Just check if any widget exists
        expect(find.byType(Container), findsWidgets);
        print('🔍 Found Container widgets');
        
      } catch (e, stackTrace) {
        print('🔥 Exception caught: $e');
        print('🔥 Stack trace: $stackTrace');
        rethrow;
      }
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
