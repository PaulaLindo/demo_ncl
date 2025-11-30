// lib/models/staff_stats_model.dart
import 'package:equatable/equatable.dart';

/// Represents statistics for a staff member
class StaffStats extends Equatable {
  final int jobsToday;
  final double todayEarnings;
  final double hoursScheduled;
  final double averageRating;
  final int jobsCompletedMonth;

  const StaffStats({
    this.jobsToday = 0,
    this.todayEarnings = 0.0,
    this.hoursScheduled = 0.0,
    this.averageRating = 0.0,
    this.jobsCompletedMonth = 0,
  });

  /// Creates StaffStats from JSON data
  factory StaffStats.fromJson(Map<String, dynamic> json) {
    return StaffStats(
      jobsToday: (json['jobsToday'] as num?)?.toInt() ?? 0,
      todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      hoursScheduled: (json['hoursScheduled'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      jobsCompletedMonth: (json['jobsCompletedMonth'] as num?)?.toInt() ?? 0,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'jobsToday': jobsToday,
      'todayEarnings': todayEarnings,
      'hoursScheduled': hoursScheduled,
      'averageRating': averageRating,
      'jobsCompletedMonth': jobsCompletedMonth,
    };
  }

  /// Creates a copy with updated fields
  StaffStats copyWith({
    int? jobsToday,
    double? todayEarnings,
    double? hoursScheduled,
    double? averageRating,
    int? jobsCompletedMonth,
  }) {
    return StaffStats(
      jobsToday: jobsToday ?? this.jobsToday,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      hoursScheduled: hoursScheduled ?? this.hoursScheduled,
      averageRating: averageRating ?? this.averageRating,
      jobsCompletedMonth: jobsCompletedMonth ?? this.jobsCompletedMonth,
    );
  }

  @override
  List<Object> get props => [
        jobsToday,
        todayEarnings,
        hoursScheduled,
        averageRating,
        jobsCompletedMonth,
      ];

  @override
  String toString() => 'StaffStats('
      'jobsToday: $jobsToday, '
      'todayEarnings: $todayEarnings, '
      'hoursScheduled: $hoursScheduled, '
      'averageRating: $averageRating, '
      'jobsCompletedMonth: $jobsCompletedMonth)';
}