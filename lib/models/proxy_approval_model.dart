// lib/models/proxy_approval_model.dart
import 'package:equatable/equatable.dart';
import 'time_record_model.dart';

/// Represents a proxy time record created by admin
class ProxyTimeRecord extends Equatable {
  final String id;
  final String staffId;
  final String tempCardCode;
  final DateTime clockInTime;
  final DateTime clockOutTime;
  final TimeRecordStatus status;
  final double totalHours;
  final String? adminId;
  final String? adminNotes;
  final DateTime? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final List<ChecklistItem> checklistItems;
  final bool checklistConfirmed;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProxyTimeRecord({
    required this.id,
    required this.staffId,
    required this.tempCardCode,
    required this.clockInTime,
    required this.clockOutTime,
    required this.status,
    required this.totalHours,
    this.adminId,
    this.adminNotes,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.checklistItems = const [],
    this.checklistConfirmed = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates ProxyTimeRecord from JSON
  factory ProxyTimeRecord.fromJson(Map<String, dynamic> json) {
    return ProxyTimeRecord(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      tempCardCode: json['tempCardCode'] as String,
      clockInTime: DateTime.parse(json['clockInTime'] as String),
      clockOutTime: DateTime.parse(json['clockOutTime'] as String),
      status: TimeRecordStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => TimeRecordStatus.pendingApproval,
      ),
      totalHours: (json['totalHours'] as num).toDouble(),
      adminId: json['adminId'] as String?,
      adminNotes: json['adminNotes'] as String?,
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] != null 
          ? DateTime.parse(json['approvedAt'] as String) 
          : null,
      rejectionReason: json['rejectionReason'] as String?,
      checklistItems: (json['checklistItems'] as List<dynamic>?)
          ?.map((item) => ChecklistItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      checklistConfirmed: json['checklistConfirmed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'tempCardCode': tempCardCode,
      'clockInTime': clockInTime.toIso8601String(),
      'clockOutTime': clockOutTime.toIso8601String(),
      'status': status.name,
      'totalHours': totalHours,
      'adminId': adminId,
      'adminNotes': adminNotes,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'checklistItems': checklistItems.map((item) => item.toJson()).toList(),
      'checklistConfirmed': checklistConfirmed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Gets approval status display
  String get statusDisplay {
    switch (status) {
      case TimeRecordStatus.pendingApproval:
        return 'Pending Proxy Approval';
      case TimeRecordStatus.approved:
        return 'Approved';
      case TimeRecordStatus.rejected:
        return 'Rejected';
      default:
        return status.name;
    }
  }

  /// Checks if record can be approved
  bool get canBeApproved => 
      status == TimeRecordStatus.pendingApproval && 
      checklistConfirmed;

  @override
  List<Object?> get props => [
        id,
        staffId,
        tempCardCode,
        clockInTime,
        clockOutTime,
        status,
        totalHours,
        adminId,
        adminNotes,
        approvedBy,
        approvedAt,
        rejectionReason,
        checklistItems,
        checklistConfirmed,
        createdAt,
        updatedAt,
      ];
}

/// Checklist item for proxy confirmation
class ChecklistItem extends Equatable {
  final String id;
  final String description;
  final bool confirmed;
  final String? notes;
  final DateTime? confirmedAt;

  const ChecklistItem({
    required this.id,
    required this.description,
    required this.confirmed,
    this.notes,
    this.confirmedAt,
  });

  /// Creates ChecklistItem from JSON
  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String,
      description: json['description'] as String,
      confirmed: json['confirmed'] as bool? ?? false,
      notes: json['notes'] as String?,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'confirmed': confirmed,
      'notes': notes,
      'confirmedAt': confirmedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, description, confirmed, notes, confirmedAt];
}

/// Proxy approval action
class ProxyApprovalAction extends Equatable {
  final String recordId;
  final String staffId;
  final ApprovalAction action;
  final DateTime actionTime;
  final String? notes;
  final String? performedBy;

  const ProxyApprovalAction({
    required this.recordId,
    required this.staffId,
    required this.action,
    required this.actionTime,
    this.notes,
    this.performedBy,
  });

  @override
  List<Object?> get props => [
        recordId,
        staffId,
        action,
        actionTime,
        notes,
        performedBy,
      ];
}

/// Approval action types
enum ApprovalAction {
  approve('Approve'),
  reject('Reject'),
  requestInfo('Request More Information');

  const ApprovalAction(this.displayName);
  final String displayName;
}

/// Staff login event for detecting restored access
class StaffLoginEvent extends Equatable {
  final String staffId;
  final DateTime loginTime;
  final String deviceInfo;
  final String ipAddress;
  final String? appVersion;
  final String? location;

  const StaffLoginEvent({
    required this.staffId,
    required this.loginTime,
    required this.deviceInfo,
    required this.ipAddress,
    this.appVersion,
    this.location,
  });

  @override
  List<Object?> get props => [
        staffId,
        loginTime,
        deviceInfo,
        ipAddress,
        appVersion,
        location,
      ];
}

/// Blocking information for staff login
class BlockingInfo extends Equatable {
  final bool hasBlockingBanner;
  final int pendingCount;
  final double totalPendingHours;
  final List<ProxyTimeRecord> pendingRecords;
  final DateTime? lastLogin;

  const BlockingInfo({
    required this.hasBlockingBanner,
    required this.pendingCount,
    required this.totalPendingHours,
    this.pendingRecords = const [],
    this.lastLogin,
  });

  @override
  List<Object?> get props => [
        hasBlockingBanner,
        pendingCount,
        totalPendingHours,
        pendingRecords,
        lastLogin,
      ];
}

/// Proxy checklist confirmation
class ProxyChecklistConfirmation extends Equatable {
  final String id;
  final String recordId;
  final String staffId;
  final String adminId;
  final DateTime confirmedAt;
  final List<ChecklistItem> checklistItems;
  final bool overallConfirmation;
  final String? adminNotes;
  final String? verbalConfirmationNotes;
  final ConfirmationMethod confirmationMethod;

  const ProxyChecklistConfirmation({
    required this.id,
    required this.recordId,
    required this.staffId,
    required this.adminId,
    required this.confirmedAt,
    required this.checklistItems,
    required this.overallConfirmation,
    this.adminNotes,
    this.verbalConfirmationNotes,
    required this.confirmationMethod,
  });

  @override
  List<Object?> get props => [
        id,
        recordId,
        staffId,
        adminId,
        confirmedAt,
        checklistItems,
        overallConfirmation,
        adminNotes,
        verbalConfirmationNotes,
        confirmationMethod,
  ];
}

/// Methods of checklist confirmation
enum ConfirmationMethod {
  phone('Phone Call'),
  inPerson('In Person'),
  video('Video Call'),
  text('Text Message');

  const ConfirmationMethod(this.displayName);
  final String displayName;
}

/// Proxy session for admin tracking
class ProxySession extends Equatable {
  final String id;
  final String adminId;
  final String staffId;
  final String tempCardCode;
  final DateTime startTime;
  final DateTime? endTime;
  final ProxySessionStatus status;
  final String? notes;

  const ProxySession({
    required this.id,
    required this.adminId,
    required this.staffId,
    required this.tempCardCode,
    required this.startTime,
    this.endTime,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        adminId,
        staffId,
        tempCardCode,
        startTime,
        endTime,
        status,
        notes,
      ];
}

/// Proxy session status
enum ProxySessionStatus {
  active('Active'),
  completed('Completed'),
  cancelled('Cancelled'),
  expired('Expired');

  const ProxySession(this.displayName);
  final String displayName;
}

/// Audit event for proxy operations
class ProxyAuditEvent extends Equatable {
  final String id;
  final AuditEventType eventType;
  final String staffId;
  final String? adminId;
  final String? recordId;
  final DateTime timestamp;
  final Map<String, dynamic> details;
  final String? ipAddress;
  final String? userAgent;

  const ProxyAuditEvent({
    required this.id,
    required this.eventType,
    required this.staffId,
    this.adminId,
    this.recordId,
    required this.timestamp,
    required this.details,
    this.ipAddress,
    this.userAgent,
  });

  @override
  List<Object?> get props => [
        id,
        eventType,
        staffId,
        adminId,
        recordId,
        timestamp,
        details,
        ipAddress,
        userAgent,
      ];
}

/// Types of audit events
enum AuditEventType {
  proxyInitiation('Proxy Initiation'),
  proxyApproval('Proxy Approval'),
  proxyRejection('Proxy Rejection'),
  checklistConfirmation('Checklist Confirmation'),
  staffLogin('Staff Login'),
  accessBlocked('Access Blocked'),
  recordModified('Record Modified');

  const AuditEventType(this.displayName);
  final String displayName;
}

/// Batch approval action
class BatchApprovalAction extends Equatable {
  final String staffId;
  final List<String> recordIds;
  final ApprovalAction action;
  final DateTime actionTime;
  final String? notes;
  final String? performedBy;

  const BatchApprovalAction({
    required this.staffId,
    required this.recordIds,
    required this.action,
    required this.actionTime,
    this.notes,
    this.performedBy,
  });

  @override
  List<Object?> get props => [
        staffId,
        recordIds,
        action,
        actionTime,
        notes,
        performedBy,
  ];
}

/// Batch approval result
class BatchApprovalResult extends Equatable {
  final int successCount;
  final int failedCount;
  final List<BatchApprovalError> errors;
  final DateTime processedAt;

  const BatchApprovalResult({
    required this.successCount,
    required this.failedCount,
    required this.errors,
    required this.processedAt,
  });

  @override
  List<Object?> get props => [successCount, failedCount, errors, processedAt];
}

/// Batch approval error
class BatchApprovalError extends Equatable {
  final String recordId;
  final String errorMessage;
  final ErrorType errorType;

  const BatchApprovalError({
    required this.recordId,
    required this.errorMessage,
    required this.errorType,
  });

  @override
  List<Object?> get props => [recordId, errorMessage, errorType];
}

/// Error types for batch operations
enum ErrorType {
  validation('Validation Error'),
  permission('Permission Error'),
  concurrency('Concurrency Error'),
  system('System Error');

  const ErrorType(this.displayName);
  final String displayName;
}

/// Proxy compliance report
class ProxyComplianceReport extends Equatable {
  final ReportPeriod reportPeriod;
  final int totalProxySessions;
  final int approvedSessions;
  final int rejectedSessions;
  final int pendingSessions;
  final Duration averageApprovalTime;
  final int flaggedSessions;
  final bool auditTrailComplete;
  final List<ComplianceIssue> issues;

  const ProxyComplianceReport({
    required this.reportPeriod,
    required this.totalProxySessions,
    required this.approvedSessions,
    required this.rejectedSessions,
    required this.pendingSessions,
    required this.averageApprovalTime,
    required this.flaggedSessions,
    required this.auditTrailComplete,
    this.issues = const [],
  });

  /// Gets approval rate percentage
  double get approvalRate {
    if (totalProxySessions == 0) return 0.0;
    return (approvedSessions / totalProxySessions) * 100;
  }

  /// Gets compliance score
  double get complianceScore {
    double score = 100.0;
    
    // Deduct for flagged sessions
    score -= (flaggedSessions / totalProxySessions) * 20;
    
    // Deduct for incomplete audit trail
    if (!auditTrailComplete) score -= 10;
    
    // Deduct for compliance issues
    score -= issues.length * 5;
    
    return score.clamp(0.0, 100.0);
  }

  @override
  List<Object?> get props => [
        reportPeriod,
        totalProxySessions,
        approvedSessions,
        rejectedSessions,
        pendingSessions,
        averageApprovalTime,
        flaggedSessions,
        auditTrailComplete,
        issues,
      ];
}

/// Report period
class ReportPeriod extends Equatable {
  final DateTime start;
  final DateTime end;

  const ReportPeriod(this.start, this.end);

  @override
  List<Object?> get props => [start, end];
}

/// Compliance issue
class ComplianceIssue extends Equatable {
  final String id;
  final IssueType type;
  final String description;
  final Severity severity;
  final String? recordId;
  final String? staffId;
  final DateTime detectedAt;
  final bool isResolved;
  final DateTime? resolvedAt;

  const ComplianceIssue({
    required this.id,
    required this.type,
    required this.description,
    required this.severity,
    this.recordId,
    this.staffId,
    required this.detectedAt,
    this.isResolved = false,
    this.resolvedAt,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        description,
        severity,
        recordId,
        staffId,
        detectedAt,
        isResolved,
        resolvedAt,
      ];
}

/// Issue types
enum IssueType {
  missingChecklist('Missing Checklist'),
  unusualHours('Unusual Hours'),
  rapidApproval('Rapid Approval'),
  adminConflict('Admin Conflict'),
  dataIntegrity('Data Integrity');

  const IssueType(this.displayName);
  final String displayName;
}

/// Issue severity
enum Severity {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  const Severity(this.displayName);
  final String displayName;
}

/// Checklist validation result
class ChecklistValidationResult extends Equatable {
  final bool isComplete;
  final List<String> missingItems;
  final List<String> incompleteItems;
  final DateTime validatedAt;

  const ChecklistValidationResult({
    required this.isComplete,
    required this.missingItems,
    required this.incompleteItems,
    required this.validatedAt,
  });

  @override
  List<Object?> get props => [
        isComplete,
        missingItems,
        incompleteItems,
        validatedAt,
      ];
}
