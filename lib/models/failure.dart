// lib/models/failure.dart
class Failure {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  Failure({
    required this.message,
    this.error,
    this.stackTrace,
  });

  @override
  String toString() => 'Failure(message: $message, error: $error)';
}