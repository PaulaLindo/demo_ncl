// lib/models/hotel_sync_model.dart
import 'package:equatable/equatable.dart';

/// Represents hotel partner sync data and operations
class HotelSyncData extends Equatable {
  final String id;
  final String hotelId;
  final String employeeId;
  final String name;
  final String department;
  final OnDutyStatus onDutyStatus;
  final DateTime shiftStart;
  final DateTime shiftEnd;
  final DateTime lastSync;
  final bool isActive;

  const HotelSyncData({
    required this.id,
    required this.hotelId,
    required this.employeeId,
    required this.name,
    required this.department,
    required this.onDutyStatus,
    required this.shiftStart,
    required this.shiftEnd,
    required this.lastSync,
    required this.isActive,
  });

  /// Creates HotelSyncData from JSON
  factory HotelSyncData.fromJson(Map<String, dynamic> json) {
    return HotelSyncData(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String,
      employeeId: json['employeeId'] as String,
      name: json['name'] as String,
      department: json['department'] as String,
      onDutyStatus: OnDutyStatus.values.firstWhere(
        (status) => status.name == json['onDutyStatus'],
        orElse: () => OnDutyStatus.offDuty,
      ),
      shiftStart: DateTime.parse(json['shiftStart'] as String),
      shiftEnd: DateTime.parse(json['shiftEnd'] as String),
      lastSync: DateTime.parse(json['lastSync'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotelId': hotelId,
      'employeeId': employeeId,
      'name': name,
      'department': department,
      'onDutyStatus': onDutyStatus.name,
      'shiftStart': shiftStart.toIso8601String(),
      'shiftEnd': shiftEnd.toIso8601String(),
      'lastSync': lastSync.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Checks if employee is currently on duty
  bool get isCurrentlyOnDuty {
    final now = DateTime.now();
    return onDutyStatus == OnDutyStatus.onDuty &&
           now.isAfter(shiftStart) &&
           now.isBefore(shiftEnd);
  }

  /// Gets shift duration
  Duration get shiftDuration => shiftEnd.difference(shiftStart);

  @override
  List<Object?> get props => [
        id,
        hotelId,
        employeeId,
        name,
        department,
        onDutyStatus,
        shiftStart,
        shiftEnd,
        lastSync,
        isActive,
      ];
}

/// On duty status from hotel system
enum OnDutyStatus {
  onDuty('On Duty'),
  offDuty('Off Duty'),
  onBreak('On Break'),
  sickLeave('Sick Leave'),
  vacation('Vacation');

  const OnDutyStatus(this.displayName);
  final String displayName;
}

/// Sync operation result
class SyncResult extends Equatable {
  final bool success;
  final int importedCount;
  final List<String> errors;
  final List<String> warnings;
  final DateTime syncTime;

  const SyncResult({
    required this.success,
    required this.importedCount,
    this.errors = const [],
    this.warnings = const [],
    required this.syncTime,
  });

  @override
  List<Object?> get props => [success, importedCount, errors, warnings, syncTime];
}

/// Staff availability based on hotel sync
class StaffAvailability extends Equatable {
  final String staffId;
  final bool isAvailable;
  final DateTime? availableUntil;
  final String? currentAssignment;
  final OnDutyStatus syncStatus;

  const StaffAvailability({
    required this.staffId,
    required this.isAvailable,
    this.availableUntil,
    this.currentAssignment,
    required this.syncStatus,
  });

  @override
  List<Object?> get props => [
        staffId,
        isAvailable,
        availableUntil,
        currentAssignment,
        syncStatus,
      ];
}

/// Assignment conflict detection
class AssignmentConflict extends Equatable {
  final String staffId;
  final ConflictType conflictType;
  final DateTime detectedAt;
  final String? description;
  final Map<String, dynamic>? conflictDetails;

  const AssignmentConflict({
    required this.staffId,
    required this.conflictType,
    required this.detectedAt,
    this.description,
    this.conflictDetails,
  });

  bool get hasConflict => true;

  @override
  List<Object?> get props => [
        staffId,
        conflictType,
        detectedAt,
        description,
        conflictDetails,
      ];
}

/// Types of conflicts
enum ConflictType {
  onDuty('On Duty Conflict'),
  schedulingOverlap('Scheduling Overlap'),
  accreditationMismatch('Accreditation Mismatch'),
  locationConflict('Location Conflict');

  const ConflictType(this.displayName);
  final String displayName;
}

/// Conflict alert for admin notification
class ConflictAlert extends Equatable {
  final String id;
  final String staffId;
  final ConflictType conflictType;
  final AlertSeverity severity;
  final DateTime createdAt;
  final String? description;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  const ConflictAlert({
    required this.id,
    required this.staffId,
    required this.conflictType,
    required this.severity,
    required this.createdAt,
    this.description,
    this.isResolved = false,
    this.resolvedAt,
    this.resolvedBy,
  });

  @override
  List<Object?> get props => [
        id,
        staffId,
        conflictType,
        severity,
        createdAt,
        description,
        isResolved,
        resolvedAt,
        resolvedBy,
      ];
}

/// Alert severity levels
enum AlertSeverity {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  const AlertSeverity(this.displayName);
  final String displayName;
}

/// Sync history entry for audit trail
class SyncHistoryEntry extends Equatable {
  final String id;
  final String type;
  final String status;
  final DateTime timestamp;
  final int? recordCount;
  final String? errorMessage;
  final String? performedBy;

  const SyncHistoryEntry({
    required this.id,
    required this.type,
    required this.status,
    required this.timestamp,
    this.recordCount,
    this.errorMessage,
    this.performedBy,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        status,
        timestamp,
        recordCount,
        errorMessage,
        performedBy,
      ];
}

/// Hotel partner configuration
class HotelPartnerConfig extends Equatable {
  final String id;
  final String hotelName;
  final String apiKey;
  final String syncEndpoint;
  final Duration syncInterval;
  final bool isActive;
  final DateTime? lastSync;
  final Map<String, dynamic> syncSettings;

  const HotelPartnerConfig({
    required this.id,
    required this.hotelName,
    required this.apiKey,
    required this.syncEndpoint,
    required this.syncInterval,
    required this.isActive,
    this.lastSync,
    required this.syncSettings,
  });

  @override
  List<Object?> get props => [
        id,
        hotelName,
        apiKey,
        syncEndpoint,
        syncInterval,
        isActive,
        lastSync,
        syncSettings,
      ];
}
