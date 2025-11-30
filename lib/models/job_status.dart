// lib/models/job_status.dart
import 'package:flutter/material.dart';

/// Represents the status of a job
enum JobStatus {
  scheduled('Scheduled', Colors.orange),
  inProgress('In Progress', Colors.blue),
  completed('Completed', Colors.green),
  cancelled('Cancelled', Colors.red);

  final String displayName;
  final Color color;

  const JobStatus(this.displayName, this.color);

  /// Get status from string value
  static JobStatus fromString(String? value) {
    if (value == null) return JobStatus.scheduled;
    
    return JobStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => JobStatus.scheduled,
    );
  }

  /// Get color associated with status
  Color getColor() => color;

  @override
  String toString() => displayName;
}