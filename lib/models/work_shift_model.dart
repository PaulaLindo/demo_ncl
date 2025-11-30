// lib/models/work_shift_model.dart
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

enum WorkShiftType {
  regular,
  overtime,
  holiday,
  sick,
  vacation,
}

enum WorkShiftStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
}

/// Represents a break period during a work shift
class Break extends Equatable {
  final DateTime startTime;
  final DateTime endTime;
  final String reason;

  const Break({
    required this.startTime,
    required this.endTime,
    required this.reason,
  });

  /// Creates a copy of this break with the given fields replaced
  Break copyWith({
    DateTime? startTime,
    DateTime? endTime,
    String? reason,
  }) {
    return Break(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reason: reason ?? this.reason,
    );
  }

  /// Calculates the duration of the break in minutes
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  @override
  List<Object> get props => [startTime, endTime, reason];

  @override
  bool? get stringify => true;
}

/// Represents a work shift with start/end times and breaks
class WorkShift extends Equatable {
  final String id;
  final String? jobId;
  final String? userId;
  final String name;
  final String? notes;
  final WorkShiftType type;
  final DateTime startTime;
  final DateTime endTime;
  final double? hours;
  final String? location;
  final WorkShiftStatus? status;
  final DateTime? updatedAt;
  final List<Break> breaks;

  const WorkShift({
    required this.id,
    required this.name,
    required this.type,
    this.jobId,
    this.status,
    this.hours,
    this.location,
    required this.startTime,
    required this.endTime,
    this.userId,
    this.notes,
    this.updatedAt,
    this.breaks = const [],
  });

  /// Creates a copy of this work shift with the given fields replaced
  WorkShift copyWith({
    String? id,
    String? name,
    WorkShiftType? type,
    String? jobId,
    String? userId,
    WorkShiftStatus? status,
    double? hours,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    List<Break>? breaks,
  }) {
    return WorkShift(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      jobId: jobId ?? this.jobId,
      status: status ?? this.status,
      hours: hours ?? this.hours,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      userId: userId ?? this.userId,
      notes: notes ?? this.notes,
      breaks: breaks ?? this.breaks,
    );
  }

  /// Calculates the total duration of the shift in minutes (excluding breaks)
  int get totalShiftMinutes {
    int breakTime = breaks.fold(
      0,
      (sum, breakItem) => sum + breakItem.durationMinutes,
    );
    return endTime.difference(startTime).inMinutes - breakTime;
  }

  /// Returns true if the shift is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Returns true if the shift is in the future
  bool get isUpcoming => DateTime.now().isBefore(startTime);

  /// Returns true if the shift is in the past
  bool get isCompleted => DateTime.now().isAfter(endTime);

  /// Returns a formatted date string (e.g., "Mon, Jan 1")
  String get formattedDate => DateFormat('E, MMM d').format(startTime);

  /// Returns a formatted time range string (e.g., "9:00 AM - 5:00 PM")
  String get formattedTimeRange =>
      '${DateFormat.jm().format(startTime)} - ${DateFormat.jm().format(endTime)}';

  /// Returns a formatted duration string (e.g., "8h 0m")
  String get formattedDuration {
    final hours = totalShiftMinutes ~/ 60;
    final minutes = totalShiftMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  bool get isExternal => type == WorkShiftType.overtime;
  bool get isNCL => type == WorkShiftType.regular;

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        jobId,
        userId,
        status,
        hours,
        location,
        startTime,
        endTime,
        notes,
        breaks,
      ];

  @override
  bool? get stringify => true;
}