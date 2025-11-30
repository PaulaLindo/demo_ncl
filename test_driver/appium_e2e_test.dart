// test_driver/appium_e2e_test.dart
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'appium_helper.dart';

/// Stable Appium E2E Tests for Flutter App
/// These tests focus on critical user journeys with reliable selectors
void main() {
  group('NCL App - Stable E2E Tests', () {
    late AppiumHelper helper;

    setUpAll(() async {
      helper = AppiumHelper();
      await helper.setUp();
    });

    tearDownAll(() async {
      await helper.tearDown();
    });

    setUp(() async {
      await helper.waitForAppReady();
    });

    test('Critical Journey 1: Customer Registration Flow', () async {
      print('🚀 Starting Customer Registration Flow...');
      
      // Step 1: Verify login chooser is visible
      expect(await helper.widgetExists('customer_login_button'), isTrue,
          reason: 'Customer login button should be visible');
      
      // Step 2: Click Customer Login
      await helper.tapByKey('customer_login_button');
      await helper.waitForAppReady();
      
      // Step 3: Verify customer login screen
      expect(await helper.widgetExists('email_field'), isTrue,
          reason: 'Email field should be visible on customer login');
      
      // Step 4: Fill registration form
      await helper.enterText('email_field', 'customer@example.com');
      await helper.enterText('password_field', 'customer123');
      
      // Step 5: Submit form
      await helper.tapByKey('login_button');
      await helper.waitForAppReady();
      
      // Step 6: Verify successful login (dashboard appears)
      expect(await helper.widgetExists('customer_dashboard'), isTrue,
          reason: 'Customer dashboard should appear after successful login');
      
      print('✅ Customer Registration Flow - PASSED');
    });

    test('Critical Journey 2: Staff Login Flow', () async {
      print('🚀 Starting Staff Login Flow...');
      
      // Step 1: Go back to login chooser (if needed)
      if (await helper.widgetExists('back_button')) {
        await helper.tapByKey('back_button');
        await helper.waitForAppReady();
      }
      
      // Step 2: Click Staff Access
      await helper.tapByKey('staff_access_button');
      await helper.waitForAppReady();
      
      // Step 3: Verify staff login screen
      expect(await helper.widgetExists('email_field'), isTrue,
          reason: 'Email field should be visible on staff login');
      
      // Step 4: Fill login form
      await helper.enterText('email_field', 'staff@example.com');
      await helper.enterText('password_field', 'staff123');
      
      // Step 5: Submit form
      await helper.tapByKey('login_button');
      await helper.waitForAppReady();
      
      // Step 6: Verify successful login
      expect(await helper.widgetExists('staff_dashboard'), isTrue,
          reason: 'Staff dashboard should appear after successful login');
      
      print('✅ Staff Login Flow - PASSED');
    });

    test('Critical Journey 3: Admin Login Flow', () async {
      print('🚀 Starting Admin Login Flow...');
      
      // Step 1: Go back to login chooser
      if (await helper.widgetExists('back_button')) {
        await helper.tapByKey('back_button');
        await helper.waitForAppReady();
      }
      
      // Step 2: Click Admin Portal
      await helper.tapByKey('admin_portal_button');
      await helper.waitForAppReady();
      
      // Step 3: Verify admin login screen
      expect(await helper.widgetExists('email_field'), isTrue,
          reason: 'Email field should be visible on admin login');
      
      // Step 4: Fill login form
      await helper.enterText('email_field', 'admin@example.com');
      await helper.enterText('password_field', 'admin123');
      
      // Step 5: Submit form
      await helper.tapByKey('login_button');
      await helper.waitForAppReady();
      
      // Step 6: Verify successful login
      expect(await helper.widgetExists('admin_dashboard'), isTrue,
          reason: 'Admin dashboard should appear after successful login');
      
      print('✅ Admin Login Flow - PASSED');
    });

    test('Critical Journey 4: Help Dialog Functionality', () async {
      print('🚀 Testing Help Dialog...');
      
      // Step 1: Go back to login chooser
      if (await helper.widgetExists('back_button')) {
        await helper.tapByKey('back_button');
        await helper.waitForAppReady();
      }
      
      // Step 2: Click help button
      await helper.tapByText('Need help signing in?');
      await helper.waitForAppReady();
      
      // Step 3: Verify help dialog appears
      expect(await helper.widgetExists('help_dialog'), isTrue,
          reason: 'Help dialog should appear');
      
      // Step 4: Close help dialog
      await helper.tapByKey('close_dialog_button');
      await helper.waitForAppReady();
      
      // Step 5: Verify we're back to login chooser
      expect(await helper.widgetExists('customer_login_button'), isTrue,
          reason: 'Should be back to login chooser');
      
      print('✅ Help Dialog Functionality - PASSED');
    });

    test('Critical Journey 5: Form Validation', () async {
      print('🚀 Testing Form Validation...');
      
      // Step 1: Navigate to customer login
      await helper.tapByText('Customer Login');
      await helper.waitForAppReady();
      
      // Step 2: Try to submit empty form
      await helper.tapByKey('login_button');
      await helper.waitForAppReady();
      
      // Step 3: Check for validation errors
      // Note: This depends on your validation implementation
      expect(await helper.widgetExists('validation_error'), isTrue,
          reason: 'Validation error should appear for empty form');
      
      print('✅ Form Validation - PASSED');
    });

    test('Critical Journey 6: Credentials Display', () async {
      print('🚀 Testing Credentials Display...');
      
      // Step 1: Navigate to each login screen and verify credentials
      final loginTypes = ['Customer Login', 'Staff Access', 'Admin Portal'];
      
      for (final loginType in loginTypes) {
        // Go back to chooser if needed
        if (await helper.widgetExists('back_button')) {
          await helper.tapByKey('back_button');
          await helper.waitForAppReady();
        }
        
        // Navigate to login screen
        await helper.tapByText(loginType);
        await helper.waitForAppReady();
        
        // Verify credentials are visible
        expect(await helper.widgetExists('credentials_display'), isTrue,
            reason: 'Credentials should be visible for $loginType');
        
        print('✅ Credentials verified for $loginType');
      }
      
      print('✅ Credentials Display - PASSED');
    });

    test('App Stability Test: Multiple Navigation', () async {
      print('🚀 Testing App Stability with Multiple Navigation...');
      
      // Test multiple navigation cycles
      for (int i = 0; i < 3; i++) {
        print('Navigation cycle ${i + 1}/3');
        
        // Navigate through all login screens
        await helper.tapByText('Customer Login');
        await helper.waitForAppReady();
        await helper.tapByKey('back_button');
        await helper.waitForAppReady();
        
        await helper.tapByText('Staff Access');
        await helper.waitForAppReady();
        await helper.tapByKey('back_button');
        await helper.waitForAppReady();
        
        await helper.tapByText('Admin Portal');
        await helper.waitForAppReady();
        await helper.tapByKey('back_button');
        await helper.waitForAppReady();
      }
      
      // Verify app is still responsive
      expect(await helper.widgetExists('customer_login_button'), isTrue,
          reason: 'App should still be responsive after multiple navigation cycles');
      
      print('✅ App Stability Test - PASSED');
    });
  });
}
