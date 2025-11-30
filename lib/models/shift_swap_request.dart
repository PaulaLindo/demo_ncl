// lib/models/shift_swap_request.dart
import 'package:equatable/equatable.dart';

enum ShiftSwapStatus {
  pending,
  approved,
  rejected,
  cancelled,
  expired,
}

class ShiftSwapRequest extends Equatable {
  final String id;
  final String requesterId;
  final String? recipientId; // null if open to all staff
  final String gigId;
  final String reason;
  final ShiftSwapStatus status;
  final DateTime requestDate;
  final DateTime? responseDate;
  final String? responseNote;

  const ShiftSwapRequest({
    required this.id,
    required this.requesterId,
    this.recipientId,
    required this.gigId,
    required this.reason,
    this.status = ShiftSwapStatus.pending,
    required this.requestDate,
    this.responseDate,
    this.responseNote,
  });

  // Copy with method for immutability
  ShiftSwapRequest copyWith({
    String? id,
    String? requesterId,
    String? recipientId,
    String? gigId,
    String? reason,
    ShiftSwapStatus? status,
    DateTime? requestDate,
    DateTime? responseDate,
    String? responseNote,
  }) {
    return ShiftSwapRequest(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      recipientId: recipientId ?? this.recipientId,
      gigId: gigId ?? this.gigId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      requestDate: requestDate ?? this.requestDate,
      responseDate: responseDate ?? this.responseDate,
      responseNote: responseNote ?? this.responseNote,
    );
  }

  // Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requesterId': requesterId,
      'recipientId': recipientId,
      'gigId': gigId,
      'reason': reason,
      'status': status.toString().split('.').last,
      'requestDate': requestDate.toIso8601String(),
      'responseDate': responseDate?.toIso8601String(),
      'responseNote': responseNote,
    };
  }

  // Create from map for deserialization
  factory ShiftSwapRequest.fromMap(Map<String, dynamic> map) {
    return ShiftSwapRequest(
      id: map['id'] as String,
      requesterId: map['requesterId'] as String,
      recipientId: map['recipientId'] as String?,
      gigId: map['gigId'] as String,
      reason: map['reason'] as String,
      status: (map['status'] as String).toShiftSwapStatus(),
      requestDate: DateTime.parse(map['requestDate'] as String),
      responseDate: map['responseDate'] != null 
          ? DateTime.parse(map['responseDate'] as String) 
          : null,
      responseNote: map['responseNote'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    requesterId,
    recipientId,
    gigId,
    reason,
    status,
    requestDate,
    responseDate,
    responseNote,
  ];
}

// Extension to convert string to ShiftSwapStatus
extension StringExtension on String {
  ShiftSwapStatus toShiftSwapStatus() {
    return ShiftSwapStatus.values.firstWhere(
      (e) => e.toString() == 'ShiftSwapStatus.$this',
      orElse: () => ShiftSwapStatus.pending,
    );
  }
}