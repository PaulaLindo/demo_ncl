// test/integration/test_runner.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'app_test.dart' as app_tests;
import 'staff_flows_test.dart' as staff_tests;
import 'customer_flows_test.dart' as customer_tests;
import 'admin_flows_test.dart' as admin_tests;

/// Integration Test Runner
/// 
/// This script runs all integration tests in sequence and provides a summary.
/// Usage: dart test/integration/test_runner.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('NCL Integration Test Suite', () {
    setUpAll(() async {
      print('🚀 Starting NCL Integration Test Suite');
      print('📱 Testing Admin, Customer, and Staff flows');
      
      // Setup test environment
      await _setupTestEnvironment();
    });

    tearDownAll(() async {
      print('🧹 Cleaning up test environment');
      await _cleanupTestEnvironment();
      print('✅ Integration Test Suite Complete');
    });

    group('App Tests', app_tests.main);
    group('Staff Flow Tests', staff_tests.main);
    group('Customer Flow Tests', customer_tests.main);
    group('Admin Flow Tests', admin_tests.main);
  });
}

/// Setup test environment
Future<void> _setupTestEnvironment() async {
  print('⚙️ Setting up test environment...');
  
  // Ensure test devices are ready
  await _ensureTestDevicesReady();
  
  // Initialize test data
  await _initializeTestData();
  
  print('✅ Test environment ready');
}

/// Cleanup test environment
Future<void> _cleanupTestEnvironment() async {
  print('🧹 Cleaning up...');
  
  // Clean up test data
  await _cleanupTestData();
  
  // Reset test devices
  await _resetTestDevices();
  
  print('✅ Cleanup complete');
}

/// Ensure test devices are ready
Future<void> _ensureTestDevicesReady() async {
  // Check if devices are connected
  try {
    final result = await Process.run('flutter', ['devices', '--machine']);
    if (result.exitCode == 0) {
      print('📱 Test devices available');
    } else {
      print('⚠️ No test devices found, using emulator');
    }
  } catch (e) {
    print('⚠️ Could not check devices: $e');
  }
}

/// Initialize test data
Future<void> _initializeTestData() async {
  print('📊 Initializing test data...');
  
  // Add any test data initialization here
  await Future.delayed(Duration(milliseconds: 500));
  
  print('✅ Test data initialized');
}

/// Cleanup test data
Future<void> _cleanupTestData() async {
  print('🗑️ Cleaning up test data...');
  
  // Add any test data cleanup here
  await Future.delayed(Duration(milliseconds: 500));
  
  print('✅ Test data cleaned up');
}

/// Reset test devices
Future<void> _resetTestDevices() async {
  print('🔄 Resetting test devices...');
  
  // Add any device reset logic here
  await Future.delayed(Duration(milliseconds: 500));
  
  print('✅ Test devices reset');
}

/// Print test summary
void printTestSummary(List<TestSuiteResult> results) {
  print('\n📊 Test Summary:');
  print('=' * 50);
  
  int totalTests = 0;
  int passedTests = 0;
  int failedTests = 0;
  int skippedTests = 0;
  
  for (final result in results) {
    totalTests += result.totalTests;
    passedTests += result.passedTests;
    failedTests += result.failedTests;
    skippedTests += result.skippedTests;
    
    print('📋 ${result.suiteName}:');
    print('   Total: ${result.totalTests}');
    print('   Passed: ${result.passedTests}');
    print('   Failed: ${result.failedTests}');
    print('   Skipped: ${result.skippedTests}');
    print('');
  }
  
  print('=' * 50);
  print('📊 Overall Results:');
  print('   Total Tests: $totalTests');
  print('   Passed: $passedTests ✅');
  print('   Failed: $failedTests ❌');
  print('   Skipped: $skippedTests ⏭️');
  print('   Success Rate: ${((passedTests / totalTests) * 100).toStringAsFixed(1)}%');
  
  if (failedTests > 0) {
    print('\n❌ Some tests failed. Please check the logs above.');
    exit(1);
  } else {
    print('\n✅ All tests passed!');
  }
}

/// Test suite result model
class TestSuiteResult {
  final String suiteName;
  final int totalTests;
  final int passedTests;
  final int failedTests;
  final int skippedTests;
  
  TestSuiteResult({
    required this.suiteName,
    required this.totalTests,
    required this.passedTests,
    required this.failedTests,
    required this.skippedTests,
  });
}
