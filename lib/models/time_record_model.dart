// lib/models/time_record_model.dart
import 'package:equatable/equatable.dart';

/// The type of time record
enum TimeRecordType { 
  self, 
  proxy,
  manual,
}

/// The status of a time record
enum TimeRecordStatus { 
  inProgress, 
  completed, 
  cancelled,
  rejected,
  pendingApproval,
}

/// Represents a time record for tracking work hours
class TimeRecord extends Equatable {
  final String id;
  final String jobId;
  final String staffId;
  final String? jobName;
  final String? proxyStaffId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String? checkInPhoto;
  final String? checkOutPhoto;
  final TimeRecordType type;
  final TimeRecordStatus status;
  final bool isBreak;
  final DateTime startTime;
  final DateTime? endTime;
  final String? notes;
  final String? checkInLocation;
  final String? checkOutLocation;
  final String? proxyCardId;
  final Map<String, dynamic>? qualityData;
  final List<String>? issues;
  final int? customerRating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TimeRecord({
    required this.id,
    required this.staffId,
    required this.jobId,
    this.jobName,
    required this.checkInTime,
    this.checkOutTime,
    required this.startTime,
    this.endTime,
    this.checkInLocation,
    this.checkOutLocation,
    required this.type,
    this.status = TimeRecordStatus.pendingApproval,
    this.proxyCardId,
    this.proxyStaffId,
    this.notes,
    this.checkInPhoto,
    this.checkOutPhoto,
    this.isBreak = false,
    this.qualityData,
    this.issues,
    this.customerRating,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a copy of this time record with the given fields replaced
  TimeRecord copyWith({
    String? id,
    String? staffId,
    String? jobId,
    String? jobName,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    DateTime? startTime,
    DateTime? endTime,
    String? checkInLocation,
    String? checkOutLocation,
    TimeRecordType? type,
    TimeRecordStatus? status,
    String? proxyCardId,
    String? proxyStaffId,
    String? notes,
    String? checkInPhoto,
    String? checkOutPhoto,
    bool? isBreak,
    Map<String, dynamic>? qualityData,
    List<String>? issues,
    int? customerRating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimeRecord(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      jobId: jobId ?? this.jobId,
      jobName: jobName ?? this.jobName,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      checkInLocation: checkInLocation ?? this.checkInLocation,
      checkOutLocation: checkOutLocation ?? this.checkOutLocation,
      type: type ?? this.type,
      status: status ?? this.status,
      proxyCardId: proxyCardId ?? this.proxyCardId,
      proxyStaffId: proxyStaffId ?? this.proxyStaffId,
      notes: notes ?? this.notes,
      checkInPhoto: checkInPhoto ?? this.checkInPhoto,
      checkOutPhoto: checkOutPhoto ?? this.checkOutPhoto,
      isBreak: isBreak ?? this.isBreak,
      qualityData: qualityData ?? this.qualityData,
      issues: issues ?? this.issues,
      customerRating: customerRating ?? this.customerRating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculates the duration in minutes between check-in and check-out
  int? get calculatedDuration {
    if (checkOutTime == null) return null;
    return checkOutTime!.difference(checkInTime).inMinutes;
  }

  /// Returns true if the time record is currently active (checked in)
  bool get isActive => status == TimeRecordStatus.inProgress;

  @override
  List<Object?> get props => [
        id,
        staffId,
        jobId,
        jobName,
        checkInTime,
        checkOutTime,
        startTime,
        endTime,
        checkInLocation,
        checkOutLocation,
        type,
        status,
        proxyCardId,
        proxyStaffId,
        notes,
        checkInPhoto,
        checkOutPhoto,
        isBreak,
        qualityData,
        issues,
        customerRating,
        createdAt,
        updatedAt,
      ];

  @override
  bool? get stringify => true;
}