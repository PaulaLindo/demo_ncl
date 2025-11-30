import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

enum AvailabilityStatus {
  available,
  unavailable,
  booked,
  requestedTimeOff,
}

class StaffAvailability extends Equatable {
  final String id;
  final String staffId;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final AvailabilityStatus status;
  final String? notes;
  final DateTime? updatedAt;

  const StaffAvailability({
    required this.id,
    required this.staffId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = AvailabilityStatus.available,
    this.notes,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        staffId,
        date,
        startTime,
        endTime,
        status,
        notes,
        updatedAt,
      ];

  StaffAvailability copyWith({
    String? id,
    String? staffId,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    AvailabilityStatus? status,
    String? notes,
    DateTime? updatedAt,
  }) {
    return StaffAvailability(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'startTime': '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}',
      'endTime': '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}',
      'status': status.toString().split('.').last,
      'notes': notes,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory StaffAvailability.fromJson(Map<String, dynamic> json) {
    final startTimeParts = (json['startTime'] as String).split(':');
    final endTimeParts = (json['endTime'] as String).split(':');
    
    return StaffAvailability(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      status: _statusFromString(json['status'] as String? ?? 'available'),
      notes: json['notes'] as String?,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  static AvailabilityStatus _statusFromString(String status) {
    return AvailabilityStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => AvailabilityStatus.available,
    );
  }
}
