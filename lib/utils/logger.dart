import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// A utility class for application-wide logging
class AppLogger {
  static final Logger _logger = Logger('NCLApp');
  static bool _isInitialized = false;

  /// Initializes the logger with default configuration
  static void initialize() {
    if (_isInitialized) return;
    
    // Configure logging
    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
    
    // Add console output for all levels in debug mode
    if (kDebugMode) {
      Logger.root.onRecord.listen((record) {
        // ignore: avoid_print
        print('${record.level.name}: ${record.time}: ${record.message}');
        if (record.error != null) {
          // ignore: avoid_print
          print('Error: ${record.error}');
        }
        if (record.stackTrace != null) {
          // ignore: avoid_print
          print(record.stackTrace);
        }
      });
    }
    
    _isInitialized = true;
  }

  /// Logs a debug message
  static void d(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.fine(message, error, stackTrace);
  }

  /// Logs an info message
  static void i(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.info(message, error, stackTrace);
  }

  /// Logs a warning message
  static void w(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.warning(message, error, stackTrace);
  }

  /// Logs an error message
  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.severe(message, error, stackTrace);
  }

  /// Logs a fatal error message
  static void f(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.shout(message, error, stackTrace);
  }
}

/// Global logger instance for easier access
final logger = AppLogger();
