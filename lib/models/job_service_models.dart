// lib/models/job_service_models.dart
import 'package:flutter/material.dart';

/// Represents a user in the system (customer or staff)
class User {
  final String id;
  final String name;
  final bool isStaff;
  final String? email;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.name,
    this.isStaff = false,
    this.email,
    this.avatarUrl,
  });

  /// Convert User to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isStaff': isStaff,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      isStaff: json['isStaff'] as bool? ?? false,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  User copyWith({
    String? id,
    String? name,
    bool? isStaff,
    String? email,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      isStaff: isStaff ?? this.isStaff,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents a cleaning/service job
class Job {
  final String id;
  final String customerName;
  final String address;
  final DateTime startTime;
  final DateTime endTime;
  final String serviceType;
  final JobStatus status;
  final bool isActive;

  const Job({
    required this.id,
    required this.customerName,
    required this.address,
    required this.startTime,
    required this.endTime,
    required this.serviceType,
    this.status = JobStatus.scheduled,
    this.isActive = false,
  });

  /// Duration of the job
  Duration get duration => endTime.difference(startTime);

  /// Check if job is happening today
  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  /// Check if job is upcoming (not started yet)
  bool get isUpcoming => startTime.isAfter(DateTime.now());

  Job copyWith({
    String? id,
    String? serviceType,
    String? customerName,
    String? address,
    DateTime? startTime,
    DateTime? endTime,
    JobStatus? status,
    bool? isActive,
  }) {
    return Job(
      id: id ?? this.id,
      serviceType: serviceType ?? this.serviceType,
      customerName: customerName ?? this.customerName,
      address: address ?? this.address,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Job && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Job status enumeration
enum JobStatus {
  scheduled('Scheduled'),
  inProgress('In Progress'),
  completed('Completed'),
  cancelled('Cancelled');

  final String displayName;
  const JobStatus(this.displayName);

  /// Get color associated with status
  Color getColor() {
    switch (this) {
      case JobStatus.scheduled:
        return Colors.orange;
      case JobStatus.inProgress:
        return Colors.blue;
      case JobStatus.completed:
        return Colors.green;
      case JobStatus.cancelled:
        return Colors.red;
    }
  }

  /// Parse from string (for backwards compatibility)
  static JobStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
        return JobStatus.inProgress;
      case 'completed':
        return JobStatus.completed;
      case 'cancelled':
        return JobStatus.cancelled;
      default:
        return JobStatus.scheduled;
    }
  }
}

/// Staff statistics for dashboard
class StaffStats {
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
}

/// Service offering
class Service {
  final String id;
  final String name;
  final double basePrice;
  final String duration;
  final String description;
  final bool isHourly;
  final String? iconName;

  const Service({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.duration,
    required this.description,
    this.isHourly = false,
    this.iconName,
  });

  Service copyWith({
    String? id,
    String? name,
    double? basePrice,
    String? duration,
    String? description,
    bool? isHourly,
    String? iconName,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      basePrice: basePrice ?? this.basePrice,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      isHourly: isHourly ?? this.isHourly,
      iconName: iconName ?? this.iconName,
    );
  }
}

/// Navigation item for bottom navigation bar
class NavigationItem {
  final String label;
  final IconData icon;
  final String route;
  final int? badgeCount;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
    this.badgeCount,
  });

  NavigationItem copyWith({
    String? label,
    IconData? icon,
    String? route,
    int? badgeCount,
  }) {
    return NavigationItem(
      label: label ?? this.label,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      badgeCount: badgeCount ?? this.badgeCount,
    );
  }
}