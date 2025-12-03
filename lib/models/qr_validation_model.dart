// lib/models/qr_validation_model.dart
import 'package:equatable/equatable.dart';
import 'job_model.dart';

/// Result of QR code validation for check-in
class QRValidationResult extends Equatable {
  final bool isValid;
  final String? error;
  final String? jobId;
  final dynamic job;

  const QRValidationResult({
    required this.isValid,
    this.error = '',
    this.jobId,
    this.job,
  });

  @override
  List<Object?> get props => [isValid, error, jobId, job];

  @override
  String toString() => 'QRValidationResult(isValid: $isValid, error: $error, jobId: $jobId)';
}
