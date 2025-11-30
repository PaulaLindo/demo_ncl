// lib/models/timekeeping_stats_model.dart
import 'package:equatable/equatable.dart';

/// Represents timekeeping statistics
class TimekeepingStats extends Equatable {
  final double hoursToday;
  final int activeJobs;
  final String status;
  final double totalEarningsToday;
  final int completedJobsThisMonth;

  const TimekeepingStats({
    this.hoursToday = 0.0,
    this.activeJobs = 0,
    this.status = 'Active',
    this.totalEarningsToday = 0.0,
    this.completedJobsThisMonth = 0,
  });

  /// Creates TimekeepingStats from JSON
  factory TimekeepingStats.fromJson(Map<String, dynamic> json) {
    return TimekeepingStats(
      hoursToday: (json['hoursToday'] as num?)?.toDouble() ?? 0.0,
      activeJobs: (json['activeJobs'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?) ?? 'Active',
      totalEarningsToday: (json['totalEarningsToday'] as num?)?.toDouble() ?? 0.0,
      completedJobsThisMonth: (json['completedJobsThisMonth'] as num?)?.toInt() ?? 0,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'hoursToday': hoursToday,
      'activeJobs': activeJobs,
      'status': status,
      'totalEarningsToday': totalEarningsToday,
      'completedJobsThisMonth': completedJobsThisMonth,
    };
  }

  /// Creates a copy with updated fields
  TimekeepingStats copyWith({
    double? hoursToday,
    int? activeJobs,
    String? status,
    double? totalEarningsToday,
    int? completedJobsThisMonth,
  }) {
    return TimekeepingStats(
      hoursToday: hoursToday ?? this.hoursToday,
      activeJobs: activeJobs ?? this.activeJobs,
      status: status ?? this.status,
      totalEarningsToday: totalEarningsToday ?? this.totalEarningsToday,
      completedJobsThisMonth: completedJobsThisMonth ?? this.completedJobsThisMonth,
    );
  }

  @override
  List<Object> get props => [
        hoursToday,
        activeJobs,
        status,
        totalEarningsToday,
        completedJobsThisMonth,
      ];

  @override
  String toString() =>
      'TimekeepingStats(hoursToday: $hoursToday, activeJobs: $activeJobs)';
}