// lib/models/logistics_model.dart
import 'package:equatable/equatable.dart';

/// Represents a logistics tracking event
class LogisticsEvent extends Equatable {
  final String id;
  final String staffId;
  final String jobId;
  final String eventType;
  final String description;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  const LogisticsEvent({
    required this.id,
    required this.staffId,
    required this.jobId,
    required this.eventType,
    required this.description,
    required this.metadata,
    required this.timestamp,
  });

  factory LogisticsEvent.fromJson(Map<String, dynamic> json) {
    return LogisticsEvent(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      jobId: json['jobId'] as String,
      eventType: json['eventType'] as String,
      description: json['description'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      timestamp: (json['timestamp'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'jobId': jobId,
      'eventType': eventType,
      'description': description,
      'metadata': metadata,
      'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [
        id,
        staffId,
        jobId,
        eventType,
        description,
        metadata,
        timestamp,
      ];
}

/// Common logistics event types
class LogisticsEventTypes {
  static const String staffCheckedIn = 'STAFF_CHECKED_IN';
  static const String staffCheckedOut = 'STAFF_CHECKED_OUT';
  static const String jobStarted = 'JOB_STARTED';
  static const String jobCompleted = 'JOB_COMPLETED';
  static const String locationVerified = 'LOCATION_VERIFIED';
  static const String qrCodeScanned = 'QR_CODE_SCANNED';
  static const String qualityCheckCompleted = 'QUALITY_CHECK_COMPLETED';
  static const String issueReported = 'ISSUE_REPORTED';
  static const String suppliesRestocked = 'SUPPLIES_RESTOCKED';
  static const String emergencyCalled = 'EMERGENCY_CALLED';
  static const String delayReported = 'DELAY_REPORTED';
}
