// lib/models/timekeeping_models.dart

class TimeRecord {
  final String id;
  final String jobId;
  final String jobName;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String type; // 'Self' or 'Proxy'
  final String? proxyCardId;
  final bool isCompleted;

  TimeRecord({
    required this.id,
    required this.jobId,
    required this.jobName,
    required this.checkInTime,
    this.checkOutTime,
    this.type = 'Self',
    this.proxyCardId,
    this.isCompleted = false,
  });

  Duration get duration {
    final endTime = checkOutTime ?? DateTime.now();
    return endTime.difference(checkInTime);
  }

  String get formattedDuration {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  TimeRecord copyWith({
    String? id,
    String? jobId,
    String? jobName,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? type,
    String? proxyCardId,
    bool? isCompleted,
  }) {
    return TimeRecord(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobName: jobName ?? this.jobName,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      type: type ?? this.type,
      proxyCardId: proxyCardId ?? this.proxyCardId,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TempCard {
  final String cardNumber;
  final String staffId;
  final String staffName;
  final String role;
  final bool isInUse;

  TempCard({
    required this.cardNumber,
    required this.staffId,
    required this.staffName,
    required this.role,
    this.isInUse = false,
  });

  TempCard copyWith({
    String? cardNumber,
    String? staffId,
    String? staffName,
    String? role,
    bool? isInUse,
  }) {
    return TempCard(
      cardNumber: cardNumber ?? this.cardNumber,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      role: role ?? this.role,
      isInUse: isInUse ?? this.isInUse,
    );
  }
}

class WorkShift {
  final String id;
  final DateTime date;
  final String type; // 'External', 'NCL Shift', 'Available'
  final String? name;
  final String? hours;
  final String? location;
  final bool isBooked;

  WorkShift({
    required this.id,
    required this.date,
    required this.type,
    this.name,
    this.hours,
    this.location,
    this.isBooked = false,
  });

  bool get isAvailable => type == 'Available' && !isBooked;
  bool get isExternal => type == 'External';
  bool get isNCL => type == 'NCL Shift';
}

class TimekeepingStats {
  final double hoursToday;
  final int activeJobs;
  final String status; // 'Off-Duty', 'On-Duty', 'Proxy Check-In'
  final double totalEarningsToday;
  final int completedJobsThisMonth;

  TimekeepingStats({
    this.hoursToday = 0.0,
    this.activeJobs = 0,
    this.status = 'Off-Duty',
    this.totalEarningsToday = 0.0,
    this.completedJobsThisMonth = 0,
  });

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
}