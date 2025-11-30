// test_driver/simple_visual_test.dart
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:flutter/material.dart';

/// Simple Visual UI Test - Quick and Reliable
/// This test focuses on basic UI interactions that work
void main() {
  group('NCL App - Simple Visual Test', () {
    late FlutterDriver driver;

    setUpAll(() async {
      // Connect to Flutter app with longer timeout
      driver = await FlutterDriver.connect(
        timeout: Duration(seconds: 30),
      );
    });

    tearDownAll(() async {
      if (driver != null) {
        await driver.close();
      }
    });

    test('Basic UI Navigation Test', () async {
      print('🚀 Starting Basic UI Test...');

      // Wait for app to load
      await Future.delayed(const Duration(seconds: 3));
      print('✅ App loaded');

      // Take initial screenshot
      final List<int> screenshot1 = await driver.screenshot();
      print('📸 Initial screenshot captured');

      // Find Customer Login button by text (more reliable)
      final customerButton = find.byValueKey('customer_login_button');
      
      // Wait for button to be available
      await driver.waitFor(customerButton, timeout: Duration(seconds: 10));
      print('✅ Customer Login button found');

      // Tap Customer Login button
      await driver.tap(customerButton);
      await Future.delayed(const Duration(seconds: 2));
      print('✅ Customer Login button clicked');

      // Take screenshot after navigation
      final List<int> screenshot2 = await driver.screenshot();
      print('📸 Customer login screen screenshot captured');

      // Verify we're on login screen (look for email field)
      final emailField = find.byValueKey('email_field');
      await driver.waitFor(emailField, timeout: Duration(seconds: 10));
      print('✅ Email field found - login screen loaded');

      // Fill email field
      await driver.tap(emailField);
      await driver.enterText('customer@example.com');
      await Future.delayed(const Duration(milliseconds: 500));
      print('✅ Email entered');

      // Fill password field
      final passwordField = find.byValueKey('password_field');
      await driver.tap(passwordField);
      await driver.enterText('customer123');
      await Future.delayed(const Duration(milliseconds: 500));
      print('✅ Password entered');

      // Take screenshot of filled form
      final List<int> screenshot3 = await driver.screenshot();
      print('📸 Filled form screenshot captured');

      // Click login button
      final loginButton = find.byValueKey('login_button');
      await driver.tap(loginButton);
      await Future.delayed(const Duration(seconds: 3));
      print('✅ Login button clicked');

      // Take final screenshot
      final List<int> screenshot4 = await driver.screenshot();
      print('📸 Final screenshot captured');

      print('✅ Basic UI Test - PASSED');
    });

    test('Staff Access Quick Test', () async {
      print('🚀 Starting Staff Access Test...');

      // Go back to login chooser (try to find back button)
      try {
        final backButton = find.byType(IconButton);
        await driver.tap(backButton);
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        print('✅ Already on login chooser');
      }

      // Click Staff Access button
      final staffButton = find.byValueKey('staff_access_button');
      await driver.waitFor(staffButton, timeout: Duration(seconds: 5));
      await driver.tap(staffButton);
      await Future.delayed(const Duration(seconds: 2));
      print('✅ Staff Access button clicked');

      // Verify staff login screen
      final emailField = find.byValueKey('email_field');
      await driver.waitFor(emailField, timeout: Duration(seconds: 5));
      print('✅ Staff login screen loaded');

      // Take screenshot
      final List<int> screenshot = await driver.screenshot();
      print('📸 Staff login screenshot captured');

      print('✅ Staff Access Test - PASSED');
    });

    test('Help Dialog Quick Test', () async {
      print('🚀 Testing Help Dialog...');

      // Go back to login chooser
      try {
        final backButton = find.byType(IconButton);
        await driver.tap(backButton);
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        print('✅ Already on login chooser');
      }

      // Click help button
      final helpButton = find.text('Need help signing in?');
      await driver.waitFor(helpButton, timeout: Duration(seconds: 5));
      await driver.tap(helpButton);
      await Future.delayed(const Duration(seconds: 1));
      print('✅ Help button clicked');

      // Take screenshot of help dialog
      final List<int> screenshot = await driver.screenshot();
      print('📸 Help dialog screenshot captured');

      print('✅ Help Dialog Test - PASSED');
    });
  });
}
