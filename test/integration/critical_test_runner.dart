// test/integration/critical_test_runner.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Test runner for critical integration test cases
/// 
/// This runner executes the 6 critical ITC test cases that validate
/// the most important end-to-end workflows in the NCL system.
/// 
/// Usage:
/// dart test/integration/critical_test_runner.dart
void main() {
  print('🚀 Starting Critical Integration Test Runner...');
  print('');
  print('📋 Critical Integration Test Cases (ITC):');
  print('   ITC 5.1: Schedule-to-Job Assignment Flow');
  print('   ITC 5.2: Managed Logistics to Punctuality');
  print('   ITC 5.3: Quality-Gated Payroll Integration');
  print('   ITC 5.4: Fixed-Price Quote to Billing');
  print('   ITC 5.5: Proxy Shift to Payroll Audit Trail');
  print('   ITC 5.6: Training Completion to Job Eligibility');
  print('');

  group('Critical Integration Tests Execution', () {
    test('Run ITC 5.1: Schedule-to-Job Assignment Flow', () async {
      print('🧪 Running ITC 5.1: Schedule-to-Job Assignment Flow...');
      
      final result = await Process.run('flutter', [
        'test',
        'test/integration/critical_integration_tests.dart',
        '--name',
        'ITC 5.1: Schedule-to-Job Assignment Flow'
      ]);
      
      if (result.exitCode == 0) {
        print('✅ ITC 5.1 PASSED');
      } else {
        print('❌ ITC 5.1 FAILED');
        print('Error: ${result.stderr}');
      }
      
      expect(result.exitCode, equals(0), reason: 'ITC 5.1 should pass');
    });

    test('Run ITC 5.2: Managed Logistics to Punctuality', () async {
      print('🧪 Running ITC 5.2: Managed Logistics to Punctuality...');
      
      final result = await Process.run('flutter', [
        'test',
        'test/integration/critical_integration_tests.dart',
        '--name',
        'ITC 5.2: Managed Logistics to Punctuality'
      ]);
      
      if (result.exitCode == 0) {
        print('✅ ITC 5.2 PASSED');
      } else {
        print('❌ ITC 5.2 FAILED');
        print('Error: ${result.stderr}');
      }
      
      expect(result.exitCode, equals(0), reason: 'ITC 5.2 should pass');
    });

    test('Run ITC 5.3: Quality-Gated Payroll Integration', () async {
      print('🧪 Running ITC 5.3: Quality-Gated Payroll Integration...');
      
      final result = await Process.run('flutter', [
        'test',
        'test/integration/critical_integration_tests.dart',
        '--name',
        'ITC 5.3: Quality-Gated Payroll Integration'
      ]);
      
      if (result.exitCode == 0) {
        print('✅ ITC 5.3 PASSED');
      } else {
        print('❌ ITC 5.3 FAILED');
        print('Error: ${result.stderr}');
      }
      
      expect(result.exitCode, equals(0), reason: 'ITC 5.3 should pass');
    });

    test('Run ITC 5.4: Fixed-Price Quote to Billing', () async {
      print('🧪 Running ITC 5.4: Fixed-Price Quote to Billing...');
      
      final result = await Process.run('flutter', [
        'test',
        'test/integration/critical_integration_tests.dart',
        '--name',
        'ITC 5.4: Fixed-Price Quote to Billing'
      ]);
      
      if (result.exitCode == 0) {
        print('✅ ITC 5.4 PASSED');
      } else {
        print('❌ ITC 5.4 FAILED');
        print('Error: ${result.stderr}');
      }
      
      expect(result.exitCode, equals(0), reason: 'ITC 5.4 should pass');
    });

    test('Run ITC 5.5: Proxy Shift to Payroll Audit Trail', () async {
      print('🧪 Running ITC 5.5: Proxy Shift to Payroll Audit Trail...');
      
      final result = await Process.run('flutter', [
        'test',
        'test/integration/critical_integration_tests.dart',
        '--name',
        'ITC 5.5: Proxy Shift to Payroll Audit Trail'
      ]);
      
      if (result.exitCode == 0) {
        print('✅ ITC 5.5 PASSED');
      } else {
        print('❌ ITC 5.5 FAILED');
        print('Error: ${result.stderr}');
      }
      
      expect(result.exitCode, equals(0), reason: 'ITC 5.5 should pass');
    });

    test('Run ITC 5.6: Training Completion to Job Eligibility', () async {
      print('🧪 Running ITC 5.6: Training Completion to Job Eligibility...');
      
      final result = await Process.run('flutter', [
        'test',
        'test/integration/critical_integration_tests.dart',
        '--name',
        'ITC 5.6: Training Completion to Job Eligibility'
      ]);
      
      if (result.exitCode == 0) {
        print('✅ ITC 5.6 PASSED');
      } else {
        print('❌ ITC 5.6 FAILED');
        print('Error: ${result.stderr}');
      }
      
      expect(result.exitCode, equals(0), reason: 'ITC 5.6 should pass');
    });
  });
}

/// Helper function to run all critical tests at once
Future<void> runAllCriticalTests() async {
  print('🚀 Running All Critical Integration Tests...');
  print('');
  
  final tests = [
    'ITC 5.1: Schedule-to-Job Assignment Flow',
    'ITC 5.2: Managed Logistics to Punctuality',
    'ITC 5.3: Quality-Gated Payroll Integration',
    'ITC 5.4: Fixed-Price Quote to Billing',
    'ITC 5.5: Proxy Shift to Payroll Audit Trail',
    'ITC 5.6: Training Completion to Job Eligibility',
  ];
  
  int passed = 0;
  int failed = 0;
  
  for (final testName in tests) {
    print('🧪 Running $testName...');
    
    final result = await Process.run('flutter', [
      'test',
      'test/integration/critical_integration_tests.dart',
      '--name',
      testName
    ]);
    
    if (result.exitCode == 0) {
      print('✅ $testName PASSED');
      passed++;
    } else {
      print('❌ $testName FAILED');
      print('Error: ${result.stderr}');
      failed++;
    }
    print('');
  }
  
  print('📊 Final Results:');
  print('   Passed: $passed');
  print('   Failed: $failed');
  print('   Total: ${passed + failed}');
  
  if (failed == 0) {
    print('🎉 All Critical Integration Tests PASSED!');
  } else {
    print('⚠️  Some Critical Integration Tests FAILED!');
  }
}
