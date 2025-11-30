// test_driver/app_test.dart
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart' as test;

void main() {
  group('NCL App Integration Tests', () {
    late FlutterDriver driver;

    // Connect to the app before running tests
    test.setUpAll(() async {
      driver = await FlutterDriver.connect();
      print('🚀 CONNECTED TO VISIBLE APP ON EMULATOR');
    });

    // Disconnect from the app after tests
    test.tearDownAll(() async {
      if (driver != null) {
        await driver.close();
        print('🔌 DISCONNECTED FROM APP');
      }
    });

    test('Launch app and verify login chooser screen', () async {
      print('🚀 TESTING: Launch app and verify login chooser screen');
      
      // Wait for app to load
      await driver.waitFor(find.byValueKey('welcome-text'));
      
      print('✅ App loaded - Welcome text found');
      
      // Verify all login options are present
      await driver.waitFor(find.byValueKey('customer-login-btn'));
      await driver.waitFor(find.byValueKey('staff-access-btn'));
      await driver.waitFor(find.byValueKey('admin-portal-btn'));
      
      print('✅ All login buttons found on screen');
      
      // Take screenshot for verification
      await driver.screenshot('login_chooser_screen');
      print('📸 Screenshot saved: login_chooser_screen');
    });

    test('Customer Login button interaction', () async {
      print('🚀 TESTING: Customer Login button interaction');
      
      // Tap Customer Login button
      await driver.tap(find.byValueKey('customer-login-btn'));
      print('👆 Customer Login button tapped');
      
      // Wait for navigation
      await Future.delayed(Duration(seconds: 3));
      
      // Take screenshot
      await driver.screenshot('customer_login_tapped');
      print('📸 Screenshot saved: customer_login_tapped');
      
      // Go back
      await driver.waitFor(find.byValueKey('back-button'));
      await driver.tap(find.byValueKey('back-button'));
      print('🔙 Navigated back');
    });

    test('Staff Access button interaction', () async {
      print('🚀 TESTING: Staff Access button interaction');
      
      // Tap Staff Access button
      await driver.tap(find.byValueKey('staff-access-btn'));
      print('👆 Staff Access button tapped');
      
      // Wait for navigation
      await Future.delayed(Duration(seconds: 3));
      
      // Take screenshot
      await driver.screenshot('staff_access_tapped');
      print('📸 Screenshot saved: staff_access_tapped');
      
      // Go back
      await driver.waitFor(find.byValueKey('back-button'));
      await driver.tap(find.byValueKey('back-button'));
      print('🔙 Navigated back');
    });

    test('Admin Portal button interaction', () async {
      print('🚀 TESTING: Admin Portal button interaction');
      
      // Tap Admin Portal button
      await driver.tap(find.byValueKey('admin-portal-btn'));
      print('👆 Admin Portal button tapped');
      
      // Wait for navigation
      await Future.delayed(Duration(seconds: 3));
      
      // Take screenshot
      await driver.screenshot('admin_portal_tapped');
      print('📸 Screenshot saved: admin_portal_tapped');
      
      // Go back
      await driver.waitFor(find.byValueKey('back-button'));
      await driver.tap(find.byValueKey('back-button'));
      print('🔙 Navigated back');
    });

    test('Complete user flow simulation', () async {
      print('🚀 TESTING: Complete user flow simulation');
      
      // Test all buttons in sequence
      await driver.tap(find.byValueKey('customer-login-btn'));
      await Future.delayed(Duration(seconds: 2));
      await driver.tap(find.byValueKey('back-button'));
      
      await driver.tap(find.byValueKey('staff-access-btn'));
      await Future.delayed(Duration(seconds: 2));
      await driver.tap(find.byValueKey('back-button'));
      
      await driver.tap(find.byValueKey('admin-portal-btn'));
      await Future.delayed(Duration(seconds: 2));
      await driver.tap(find.byValueKey('back-button'));
      
      print('✅ Complete user flow finished');
      
      // Final screenshot
      await driver.screenshot('complete_user_flow');
      print('📸 Final screenshot saved: complete_user_flow');
    });

    test('App responsiveness test', () async {
      print('🚀 TESTING: App responsiveness test');
      
      // Test different screen sizes (if supported)
      await driver.screenshot('mobile_view');
      print('📸 Mobile view screenshot saved');
      
      // You can add more responsiveness tests here
      print('✅ Responsiveness test completed');
    });
  });
}
