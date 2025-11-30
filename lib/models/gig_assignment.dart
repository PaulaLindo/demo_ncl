import 'package:equatable/equatable.dart';

enum GigStatus {
  pending,       // Gig is offered but not yet accepted/declined
  accepted,      // Staff has accepted the gig
  declined,     // Staff has declined the gig
  completed,     // Gig is completed
  cancelled,     // Gig was cancelled (by admin or staff within allowed time)
  inProgress,    // Gig is currently in progress
  autoDeclined,  // Gig was auto-declined due to no response
}

class GigAssignment extends Equatable {
  final String id;
  final String gigId;
  final String title;
  final String location;
  final String staffId;
  final String jobId;
  final String? notes;
  final Duration? duration;
  final DateTime startTime;
  final DateTime endTime;
  final GigStatus status;
  final DateTime? respondedAt;
  final String? declineReason;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  const GigAssignment({
    required this.id,
    required this.gigId,
    required this.title,
    required this.location,
    required this.staffId,
    required this.jobId,
    required this.startTime,
    required this.endTime,
    this.status = GigStatus.pending,
    this.respondedAt,
    this.declineReason,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.acceptedAt,
    this.completedAt,
    this.notes,
    this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

    GigAssignment copyWith({
    String? id,
    String? gigId,
    String? title,
    String? location,
    String? staffId,
    String? jobId,
    DateTime? startTime,
    DateTime? endTime,
    GigStatus? status,
    DateTime? respondedAt,
    String? declineReason,
    DateTime? cancelledAt,
    String? cancelledBy,
    String? cancellationReason,
    DateTime? acceptedAt,
    DateTime? completedAt,
    String? notes,
    Duration? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GigAssignment(
      id: id ?? this.id,
      gigId: gigId ?? this.gigId,
      title: title ?? this.title,
      location: location ?? this.location,
      staffId: staffId ?? this.staffId,
      jobId: jobId ?? this.jobId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      duration: duration ?? this.duration,
      respondedAt: respondedAt ?? this.respondedAt,
      declineReason: declineReason ?? this.declineReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        gigId,
        staffId,
        jobId,
        startTime,
        endTime,
        status,
        respondedAt,
        declineReason,
        cancelledAt,
        cancelledBy,
        cancellationReason,
        createdAt,
        updatedAt,
        acceptedAt,
        completedAt,
        notes,
        duration,
      ];

  bool get isPending => status == GigStatus.pending;
  bool get isAccepted => status == GigStatus.accepted;
  bool get isDeclined => status == GigStatus.declined || status == GigStatus.autoDeclined;
  bool get isActive => status == GigStatus.accepted || status == GigStatus.inProgress;
  bool get isCompleted => status == GigStatus.completed;
  bool get isCancelled => status == GigStatus.cancelled;
  
  // Check if the gig can be cancelled (within 24 hours of start time)
  bool get canBeCancelled {
    if (isCancelled || isCompleted || isDeclined) return false;
    final now = DateTime.now();
    return now.isBefore(startTime.subtract(const Duration(hours: 24)));
  }

  // Check if the gig can be accepted (within the response window)
  bool get canBeAccepted {
    if (!isPending) return false;
    final now = DateTime.now();
    // Allow acceptance up to 1 hour before start time
    return now.isBefore(startTime.subtract(const Duration(hours: 1)));
  }

  Duration get timeUntilResponseDeadline {
    final now = DateTime.now();
    // Default response window: 24 hours from creation or 1 hour before start time, whichever comes first
    final deadline = createdAt.add(const Duration(hours: 24));
    final latestAcceptable = startTime.subtract(const Duration(hours: 1));
    final effectiveDeadline = deadline.isBefore(latestAcceptable) ? deadline : latestAcceptable;
    
    return effectiveDeadline.difference(now);
  }

  // Check if the gig is within the acceptance window
  bool get isWithinAcceptanceWindow {
    if (!isPending) return false;
    final now = DateTime.now();
    // Allow acceptance up to 1 hour before start time
    return now.isBefore(startTime.subtract(const Duration(hours: 1)));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gigId': gigId,
      'staffId': staffId,
      'jobId': jobId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status.toString().split('.').last,
      'respondedAt': respondedAt?.toIso8601String(),
      'declineReason': declineReason,
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancelledBy': cancelledBy,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GigAssignment.fromJson(Map<String, dynamic> json) {
    return GigAssignment(
      id: json['id'] as String,
      gigId: json['gigId'] as String,
      title: json['title'] as String? ?? 'Untitled Gig',
      location: json['location'] as String? ?? 'Unknown Location',
      staffId: json['staffId'] as String,
      jobId: json['jobId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: _statusFromString(json['status'] as String? ?? 'pending'),
      respondedAt: json['respondedAt'] != null 
          ? DateTime.parse(json['respondedAt'] as String) 
          : null,
      declineReason: json['declineReason'] as String?,
      cancelledAt: json['cancelledAt'] != null 
          ? DateTime.parse(json['cancelledAt'] as String) 
          : null,
      cancelledBy: json['cancelledBy'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static GigStatus _statusFromString(String status) {
    return GigStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => GigStatus.pending,
    );
  }
}
