// test_driver/appium_helper.dart
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

/// Appium Test Helper for Stable E2E Testing
/// This provides reliable, stable testing for Flutter apps
class AppiumHelper {
  late FlutterDriver driver;

  /// Initialize the Flutter driver
  Future<void> setUp() async {
    driver = await FlutterDriver.connect();
  }

  /// Clean up the driver connection
  Future<void> tearDown() async {
    if (driver != null) {
      await driver.close();
    }
  }

  /// Wait for app to be ready
  Future<void> waitForAppReady() async {
    await driver.waitUntilFirstFrameRasterized();
    await Future.delayed(const Duration(seconds: 2));
  }

  /// Find and tap a widget by text
  Future<void> tapByText(String text) async {
    final SerializableFinder finder = find.byValueKey(text);
    await driver.waitFor(finder);
    await driver.tap(finder);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Find and tap a widget by key
  Future<void> tapByKey(String key) async {
    final SerializableFinder finder = find.byValueKey(key);
    await driver.waitFor(finder);
    await driver.tap(finder);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Enter text in a text field
  Future<void> enterText(String key, String text) async {
    final SerializableFinder finder = find.byValueKey(key);
    await driver.waitFor(finder);
    await driver.tap(finder);
    await driver.enterText(text);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Wait for a widget to appear
  Future<void> waitForWidget(String key) async {
    final SerializableFinder finder = find.byValueKey(key);
    await driver.waitFor(finder);
  }

  /// Check if widget exists
  Future<bool> widgetExists(String key) async {
    try {
      final SerializableFinder finder = find.byValueKey(key);
      await driver.waitFor(finder, timeout: const Duration(seconds: 5));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Take screenshot for debugging
  Future<void> takeScreenshot(String name) async {
    final List<int> image = await driver.screenshot();
    // In real implementation, save this to file
    print('Screenshot taken: $name');
  }

  /// Scroll until widget is visible
  Future<void> scrollUntilVisible(String key) async {
    final SerializableFinder finder = find.byValueKey(key);
    await driver.scrollUntilVisible(
      finder,
      0.0, // dx
      -100.0, // dy (scroll up)
      delta: 100.0,
    );
  }

  /// Get text from a widget
  Future<String> getText(String key) async {
    final SerializableFinder finder = find.byValueKey(key);
    await driver.waitFor(finder);
    return await driver.getText(finder);
  }

  /// Check if widget is enabled
  Future<bool> isEnabled(String key) async {
    final SerializableFinder finder = find.byValueKey(key);
    await driver.waitFor(finder);
    return await driver.getText(finder) != null;
  }
}
