// lib/models/quality_audit_model.dart
import 'package:equatable/equatable.dart';

/// Represents a quality flag for audit purposes
class QualityFlag extends Equatable {
  final String id;
  final String bookingId;
  final String staffId;
  final String? jobId;
  final FlagType flagType;
  final FlagSeverity severity;
  final FlagStatus status;
  final DateTime createdAt;
  final String triggeredBy;
  final Map<String, dynamic> details;
  final String? reviewedBy;
  final String? reviewNotes;
  final DateTime? reviewedAt;
  final FlagResolution? resolution;
  final DateTime? resolvedAt;
  final List<QualityAuditEvent> auditTrail;

  const QualityFlag({
    required this.id,
    required this.bookingId,
    required this.staffId,
    this.jobId,
    required this.flagType,
    required this.severity,
    this.status = FlagStatus.open,
    required this.createdAt,
    required this.triggeredBy,
    required this.details,
    this.reviewedBy,
    this.reviewNotes,
    this.reviewedAt,
    this.resolution,
    this.resolvedAt,
    this.auditTrail = const [],
  });

  /// Creates QualityFlag from JSON
  factory QualityFlag.fromJson(Map<String, dynamic> json) {
    return QualityFlag(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      staffId: json['staffId'] as String,
      jobId: json['jobId'] as String?,
      flagType: FlagType.values.firstWhere(
        (type) => type.name == json['flagType'],
        orElse: () => FlagType.lowRating,
      ),
      severity: FlagSeverity.values.firstWhere(
        (severity) => severity.name == json['severity'],
        orElse: () => FlagSeverity.medium,
      ),
      status: FlagStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => FlagStatus.open,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      triggeredBy: json['triggeredBy'] as String,
      details: Map<String, dynamic>.from(json['details'] as Map),
      reviewedBy: json['reviewedBy'] as String?,
      reviewNotes: json['reviewNotes'] as String?,
      reviewedAt: json['reviewedAt'] != null 
          ? DateTime.parse(json['reviewedAt'] as String) 
          : null,
      resolution: json['resolution'] != null
          ? FlagResolution.fromJson(json['resolution'] as Map<String, dynamic>)
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      auditTrail: (json['auditTrail'] as List<dynamic>?)
          ?.map((event) => QualityAuditEvent.fromJson(event as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'staffId': staffId,
      'jobId': jobId,
      'flagType': flagType.name,
      'severity': severity.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'triggeredBy': triggeredBy,
      'details': details,
      'reviewedBy': reviewedBy,
      'reviewNotes': reviewNotes,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'resolution': resolution?.toJson(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'auditTrail': auditTrail.map((event) => event.toJson()).toList(),
    };
  }

  /// Gets age of flag
  Duration get age => DateTime.now().difference(createdAt);

  /// Checks if flag is overdue for review
  bool get isOverdue {
    if (status == FlagStatus.resolved || status == FlagStatus.closed) return false;
    
    final overdueThreshold = switch (severity) {
      FlagSeverity.critical => const Duration(hours: 4),
      FlagSeverity.high => const Duration(hours: 24),
      FlagSeverity.medium => const Duration(days: 3),
      FlagSeverity.low => const Duration(days: 7),
    };
    
    return age > overdueThreshold;
  }

  @override
  List<Object?> get props => [
        id,
        bookingId,
        staffId,
        jobId,
        flagType,
        severity,
        status,
        createdAt,
        triggeredBy,
        details,
        reviewedBy,
        reviewNotes,
        reviewedAt,
        resolution,
        resolvedAt,
        auditTrail,
      ];
}

/// Flag resolution details
class FlagResolution extends Equatable {
  final ResolutionAction actionType;
  final String description;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final bool followUpRequired;
  final DateTime? followUpDate;
  final String? followUpNotes;
  final Map<String, dynamic>? actionDetails;

  const FlagResolution({
    required this.actionType,
    required this.description,
    this.resolvedBy,
    this.resolvedAt,
    required this.followUpRequired,
    this.followUpDate,
    this.followUpNotes,
    this.actionDetails,
  });

  /// Creates FlagResolution from JSON
  factory FlagResolution.fromJson(Map<String, dynamic> json) {
    return FlagResolution(
      actionType: ResolutionAction.values.firstWhere(
        (action) => action.name == json['actionType'],
        orElse: () => ResolutionAction.noAction,
      ),
      description: json['description'] as String,
      resolvedBy: json['resolvedBy'] as String?,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      followUpRequired: json['followUpRequired'] as bool? ?? false,
      followUpDate: json['followUpDate'] != null
          ? DateTime.parse(json['followUpDate'] as String)
          : null,
      followUpNotes: json['followUpNotes'] as String?,
      actionDetails: json['actionDetails'] != null
          ? Map<String, dynamic>.from(json['actionDetails'] as Map)
          : null,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'actionType': actionType.name,
      'description': description,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'followUpRequired': followUpRequired,
      'followUpDate': followUpDate?.toIso8601String(),
      'followUpNotes': followUpNotes,
      'actionDetails': actionDetails,
    };
  }

  @override
  List<Object?> get props => [
        actionType,
        description,
        resolvedBy,
        resolvedAt,
        followUpRequired,
        followUpDate,
        followUpNotes,
        actionDetails,
      ];
}

/// Quality audit event
class QualityAuditEvent extends Equatable {
  final String id;
  final String flagId;
  final AuditEventType eventType;
  final String? performedBy;
  final DateTime timestamp;
  final String? description;
  final Map<String, dynamic>? eventDetails;

  const QualityAuditEvent({
    required this.id,
    required this.flagId,
    required this.eventType,
    this.performedBy,
    required this.timestamp,
    this.description,
    this.eventDetails,
  });

  /// Creates QualityAuditEvent from JSON
  factory QualityAuditEvent.fromJson(Map<String, dynamic> json) {
    return QualityAuditEvent(
      id: json['id'] as String,
      flagId: json['flagId'] as String,
      eventType: AuditEventType.values.firstWhere(
        (type) => type.name == json['eventType'],
        orElse: () => AuditEventType.flagCreated,
      ),
      performedBy: json['performedBy'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String?,
      eventDetails: json['eventDetails'] != null
          ? Map<String, dynamic>.from(json['eventDetails'] as Map)
          : null,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flagId': flagId,
      'eventType': eventType.name,
      'performedBy': performedBy,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'eventDetails': eventDetails,
    };
  }

  @override
  List<Object?> get props => [
        id,
        flagId,
        eventType,
        performedBy,
        timestamp,
        description,
        eventDetails,
      ];
}

/// Quality audit report
class QualityAuditReport extends Equatable {
  final ReportPeriod reportPeriod;
  final int totalJobs;
  final int flaggedJobs;
  final double averageRating;
  final double averageCompletion;
  final Map<FlagType, int> flagsByType;
  final Map<FlagSeverity, int> flagsBySeverity;
  final List<String> topIssues;
  final List<StaffQualitySummary> staffSummaries;
  final QualityTrend overallTrend;
  final DateTime generatedAt;

  const QualityAuditReport({
    required this.reportPeriod,
    required this.totalJobs,
    required this.flaggedJobs,
    required this.averageRating,
    required this.averageCompletion,
    required this.flagsByType,
    required this.flagsBySeverity,
    required this.topIssues,
    required this.staffSummaries,
    required this.overallTrend,
    required this.generatedAt,
  });

  /// Gets flag rate percentage
  double get flagRate => totalJobs > 0 ? (flaggedJobs / totalJobs) * 100 : 0.0;

  /// Gets quality score (0-100)
  double get qualityScore {
    double score = 100.0;
    
    // Deduct for low ratings
    if (averageRating < 4.0) {
      score -= (4.0 - averageRating) * 20;
    }
    
    // Deduct for low completion
    if (averageCompletion < 90.0) {
      score -= (90.0 - averageCompletion) * 0.5;
    }
    
    // Deduct for flag rate
    score -= flagRate * 0.5;
    
    return score.clamp(0.0, 100.0);
  }

  @override
  List<Object?> get props => [
        reportPeriod,
        totalJobs,
        flaggedJobs,
        averageRating,
        averageCompletion,
        flagsByType,
        flagsBySeverity,
        topIssues,
        staffSummaries,
        overallTrend,
        generatedAt,
      ];
}

/// Staff quality summary
class StaffQualitySummary extends Equatable {
  final String staffId;
  final String staffName;
  final int totalJobs;
  final double averageRating;
  final double averageCompletion;
  final int flaggedJobs;
  final List<QualityFlag> recentFlags;
  final QualityTrend trend;
  final DateTime lastAssessment;

  const StaffQualitySummary({
    required this.staffId,
    required this.staffName,
    required this.totalJobs,
    required this.averageRating,
    required this.averageCompletion,
    required this.flaggedJobs,
    required this.recentFlags,
    required this.trend,
    required this.lastAssessment,
  });

  /// Gets flag rate for this staff
  double get flagRate => totalJobs > 0 ? (flaggedJobs / totalJobs) * 100 : 0.0;

  /// Gets performance score
  double get performanceScore {
    double score = 100.0;
    
    // Rating component (40% weight)
    score -= (4.0 - averageRating.clamp(0.0, 5.0)) * 10;
    
    // Completion component (30% weight)
    score -= (100.0 - averageCompletion) * 0.3;
    
    // Flag rate component (30% weight)
    score -= flagRate * 0.3;
    
    return score.clamp(0.0, 100.0);
  }

  @override
  List<Object?> get props => [
        staffId,
        staffName,
        totalJobs,
        averageRating,
        averageCompletion,
        flaggedJobs,
        recentFlags,
        trend,
        lastAssessment,
      ];
}

/// Quality thresholds configuration
class QualityThresholds extends Equatable {
  final double minimumRating;
  final double minimumCompletion;
  final double criticalRatingThreshold;
  final double criticalCompletionThreshold;
  final Map<FlagType, int> flagLimits;
  final Duration reviewTimeouts;

  const QualityThresholds({
    required this.minimumRating,
    required this.minimumCompletion,
    required this.criticalRatingThreshold,
    required this.criticalCompletionThreshold,
    required this.flagLimits,
    required this.reviewTimeouts,
  });

  @override
  List<Object?> get props => [
        minimumRating,
        minimumCompletion,
        criticalRatingThreshold,
        criticalCompletionThreshold,
        flagLimits,
        reviewTimeouts,
      ];
}

/// Quality metrics for monitoring
class QualityMetrics extends Equatable {
  final DateTime timestamp;
  final double averageRating;
  final double averageCompletion;
  final int totalFlags;
  final int criticalFlags;
  final int resolvedFlags;
  final double averageResolutionTime;
  final Map<FlagType, int> flagsByType;
  final Map<FlagSeverity, int> flagsBySeverity;

  const QualityMetrics({
    required this.timestamp,
    required this.averageRating,
    required this.averageCompletion,
    required this.totalFlags,
    required this.criticalFlags,
    required this.resolvedFlags,
    required this.averageResolutionTime,
    required this.flagsByType,
    required this.flagsBySeverity,
  });

  /// Gets resolution rate
  double get resolutionRate => totalFlags > 0 ? (resolvedFlags / totalFlags) * 100 : 0.0;

  /// Gets critical flag rate
  double get criticalFlagRate => totalFlags > 0 ? (criticalFlags / totalFlags) * 100 : 0.0;

  @override
  List<Object?> get props => [
        timestamp,
        averageRating,
        averageCompletion,
        totalFlags,
        criticalFlags,
        resolvedFlags,
        averageResolutionTime,
        flagsByType,
        flagsBySeverity,
      ];
}

/// Quality alert notification
class QualityAlert extends Equatable {
  final String id;
  final String flagId;
  final AlertType alertType;
  final AlertSeverity severity;
  final String title;
  final String message;
  final String? staffId;
  final String? bookingId;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;
  final Map<String, dynamic>? alertData;

  const QualityAlert({
    required this.id,
    required this.flagId,
    required this.alertType,
    required this.severity,
    required this.title,
    required this.message,
    this.staffId,
    this.bookingId,
    required this.createdAt,
    this.isRead = false,
    this.readAt,
    this.alertData,
  });

  @override
  List<Object?> get props => [
        id,
        flagId,
        alertType,
        severity,
        title,
        message,
        staffId,
        bookingId,
        createdAt,
        isRead,
        readAt,
        alertData,
      ];
}

/// Report period for audits
class ReportPeriod extends Equatable {
  final DateTime start;
  final DateTime end;
  final String label;

  ReportPeriod(this.start, this.end, [this.label = '']);

  @override
  List<Object?> get props => [start, end, label];
}

/// Enums
enum FlagType {
  lowRating('Low Rating'),
  incompleteChecklist('Incomplete Checklist'),
  multipleIssues('Multiple Issues'),
  customerComplaint('Customer Complaint'),
  staffIssue('Staff Issue'),
  delayIssue('Delay Issue'),
  qualityIssue('Quality Issue');

  const FlagType(this.displayName);
  final String displayName;
}

enum FlagSeverity {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  const FlagSeverity(this.displayName);
  final String displayName;
}

enum FlagStatus {
  open('Open'),
  underReview('Under Review'),
  resolved('Resolved'),
  closed('Closed');

  const FlagStatus(this.displayName);
  final String displayName;
}

enum ResolutionAction {
  staffRetraining('Staff Retraining'),
  customerFollowUp('Customer Follow-up'),
  processImprovement('Process Improvement'),
  noAction('No Action Required'),
  disciplinaryAction('Disciplinary Action'),
  additionalTraining('Additional Training');

  const ResolutionAction(this.displayName);
  final String displayName;
}

enum AuditEventType {
  flagCreated('Flag Created'),
  flagReviewed('Flag Reviewed'),
  flagResolved('Flag Resolved'),
  flagReopened('Flag Reopened'),
  followUpScheduled('Follow-up Scheduled'),
  followUpCompleted('Follow-up Completed');

  const AuditEventType(this.displayName);
  final String displayName;
}

enum QualityTrend {
  improving('Improving'),
  stable('Stable'),
  declining('Declining');

  const QualityTrend(this.displayName);
  final String displayName;
}

enum AlertType {
  newFlag('New Quality Flag'),
  criticalFlag('Critical Quality Issue'),
  overdueReview('Overdue Review'),
  followUpDue('Follow-up Due'),
  trendAlert('Quality Trend Alert');

  const AlertType(this.displayName);
  final String displayName;
}

enum AlertSeverity {
  info('Info'),
  warning('Warning'),
  error('Error'),
  critical('Critical');

  const AlertSeverity(this.displayName);
  final String displayName;
}
