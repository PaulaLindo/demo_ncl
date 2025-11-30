// lib/models/quality_flag_model.dart
import 'package:equatable/equatable.dart';

enum QualityFlagStatus {
  pending,
  inProgress,
  resolved,
  dismissed,
}

extension QualityFlagStatusExtension on QualityFlagStatus {
  String get displayName {
    switch (this) {
      case QualityFlagStatus.pending:
        return 'Pending';
      case QualityFlagStatus.inProgress:
        return 'In Progress';
      case QualityFlagStatus.resolved:
        return 'Resolved';
      case QualityFlagStatus.dismissed:
        return 'Dismissed';
    }
  }
}

/// Represents a quality audit flag for a job
class QualityFlag extends Equatable {
  final String id;
  final String jobId;
  final String jobName;
  final String staffId;
  final String staffName;
  final String issueType;
  final String description;
  final int severity; // 1-5 scale
  final DateTime createdAt;
  final QualityFlagStatus status;
  final String? resolution;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  const QualityFlag({
    required this.id,
    required this.jobId,
    required this.jobName,
    required this.staffId,
    required this.staffName,
    required this.issueType,
    required this.description,
    required this.severity,
    required this.createdAt,
    required this.status,
    this.resolution,
    this.resolvedBy,
    this.resolvedAt,
  });

  factory QualityFlag.fromJson(Map<String, dynamic> json) {
    return QualityFlag(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      jobName: json['jobName'] as String,
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      issueType: json['issueType'] as String,
      description: json['description'] as String,
      severity: json['severity'] as int,
      createdAt: (json['createdAt'] as dynamic).toDate(),
      status: QualityFlagStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => QualityFlagStatus.pending,
      ),
      resolution: json['resolution'] as String?,
      resolvedBy: json['resolvedBy'] as String?,
      resolvedAt: json['resolvedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'jobName': jobName,
      'staffId': staffId,
      'staffName': staffName,
      'issueType': issueType,
      'description': description,
      'severity': severity,
      'createdAt': createdAt,
      'status': status.toString(),
      'resolution': resolution,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt,
    };
  }

  QualityFlag copyWith({
    String? id,
    String? jobId,
    String? jobName,
    String? staffId,
    String? staffName,
    String? issueType,
    String? description,
    int? severity,
    DateTime? createdAt,
    QualityFlagStatus? status,
    String? resolution,
    String? resolvedBy,
    DateTime? resolvedAt,
  }) {
    return QualityFlag(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobName: jobName ?? this.jobName,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      issueType: issueType ?? this.issueType,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      resolution: resolution ?? this.resolution,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        jobId,
        jobName,
        staffId,
        staffName,
        issueType,
        description,
        severity,
        createdAt,
        status,
        resolution,
        resolvedBy,
        resolvedAt,
      ];
}
