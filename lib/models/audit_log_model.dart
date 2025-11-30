// lib/models/audit_log_model.dart
import 'package:equatable/equatable.dart';

/// Represents an audit log entry for tracking admin actions
class AuditLog extends Equatable {
  final String id;
  final String action;
  final String? targetId;
  final String? targetName;
  final Map<String, dynamic> details;
  final DateTime timestamp;
  final String userId;

  const AuditLog({
    required this.id,
    required this.action,
    this.targetId,
    this.targetName,
    required this.details,
    required this.timestamp,
    required this.userId,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      action: json['action'] as String,
      targetId: json['targetId'] as String?,
      targetName: json['targetName'] as String?,
      details: Map<String, dynamic>.from(json['details'] as Map),
      timestamp: (json['timestamp'] as dynamic).toDate(),
      userId: json['userId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'targetId': targetId,
      'targetName': targetName,
      'details': details,
      'timestamp': timestamp,
      'userId': userId,
    };
  }

  @override
  List<Object?> get props => [
        id,
        action,
        targetId,
        targetName,
        details,
        timestamp,
        userId,
      ];
}
