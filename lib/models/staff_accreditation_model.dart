// lib/models/staff_accreditation_model.dart
import 'package:equatable/equatable.dart';

/// Represents staff member's professional certifications and accreditations
class StaffAccreditation extends Equatable {
  final String id;
  final String staffId;
  final AccreditationType type;
  final CertificationLevel level;
  final DateTime issuedDate;
  final DateTime expiryDate;
  final String? issuingOrganization;
  final String? certificateNumber;
  final String? verificationUrl;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StaffAccreditation({
    required this.id,
    required this.staffId,
    required this.type,
    required this.level,
    required this.issuedDate,
    required this.expiryDate,
    this.issuingOrganization,
    this.certificateNumber,
    this.verificationUrl,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates StaffAccreditation from JSON
  factory StaffAccreditation.fromJson(Map<String, dynamic> json) {
    return StaffAccreditation(
      id: json['id'] as String,
      staffId: json['staffId'] as String,
      type: AccreditationType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => AccreditationType.regularCleaning,
      ),
      level: CertificationLevel.values.firstWhere(
        (level) => level.name == json['level'],
        orElse: () => CertificationLevel.basic,
      ),
      issuedDate: DateTime.parse(json['issuedDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      issuingOrganization: json['issuingOrganization'] as String?,
      certificateNumber: json['certificateNumber'] as String?,
      verificationUrl: json['verificationUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'type': type.name,
      'level': level.name,
      'issuedDate': issuedDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'issuingOrganization': issuingOrganization,
      'certificateNumber': certificateNumber,
      'verificationUrl': verificationUrl,
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Checks if accreditation is currently valid
  bool get isValid {
    final now = DateTime.now();
    return isActive && now.isAfter(issuedDate) && now.isBefore(expiryDate);
  }

  /// Checks if accreditation is expiring soon (within 30 days)
  bool get isExpiringSoon {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    return isValid && expiryDate.isBefore(thirtyDaysFromNow);
  }

  /// Gets days until expiry
  int get daysUntilExpiry {
    final now = DateTime.now();
    return expiryDate.difference(now).inDays;
  }

  /// Gets accreditation display name
  String get displayName => '${type.displayName} - ${level.displayName}';

  @override
  List<Object?> get props => [
        id,
        staffId,
        type,
        level,
        issuedDate,
        expiryDate,
        issuingOrganization,
        certificateNumber,
        verificationUrl,
        isActive,
        notes,
        createdAt,
        updatedAt,
      ];
}

/// Types of accreditations available
enum AccreditationType {
  regularCleaning('Regular Cleaning'),
  deepCleaning('Deep Cleaning'),
  ecoFriendly('Eco-Friendly Cleaning'),
  postConstruction('Post-Construction'),
  carpetCare('Carpet Care'),
  windowCleaning('Window Cleaning'),
  pressureWashing('Pressure Washing'),
  disinfection('Disinfection & Sanitization'),
  kitchenDeepClean('Kitchen Deep Clean'),
  bathroomSpecialist('Bathroom Specialist');

  const AccreditationType(this.displayName);
  final String displayName;
}

/// Certification levels
enum CertificationLevel {
  basic('Basic'),
  intermediate('Intermediate'),
  advanced('Advanced'),
  expert('Expert'),
  master('Master');

  const CertificationLevel(this.displayName);
  final String displayName;
}

/// Accreditation validation result
class AccreditationValidationResult extends Equatable {
  final String staffId;
  final AccreditationType type;
  final bool isValid;
  final String? accreditationId;
  final DateTime validatedAt;
  final String? errorMessage;
  final List<String> warnings;

  const AccreditationValidationResult({
    required this.staffId,
    required this.type,
    required this.isValid,
    this.accreditationId,
    required this.validatedAt,
    this.errorMessage,
    this.warnings = const [],
  });

  @override
  List<Object?> get props => [
        staffId,
        type,
        isValid,
        accreditationId,
        validatedAt,
        errorMessage,
        warnings,
      ];
}

/// Accreditation warning for expiring or missing certifications
class AccreditationWarning extends Equatable {
  final String staffId;
  final AccreditationType type;
  final WarningType warningType;
  final DateTime warningDate;
  final int? daysUntilExpiry;
  final String? message;
  final String? recommendedAction;

  const AccreditationWarning({
    required this.staffId,
    required this.type,
    required this.warningType,
    required this.warningDate,
    this.daysUntilExpiry,
    this.message,
    this.recommendedAction,
  });

  @override
  List<Object?> get props => [
        staffId,
        type,
        warningType,
        warningDate,
        daysUntilExpiry,
        message,
        recommendedAction,
      ];
}

/// Types of accreditation warnings
enum WarningType {
  expiry('Expiring Soon'),
  expired('Expired'),
  missing('Missing'),
  inactive('Inactive'),
  renewalRequired('Renewal Required');

  const WarningType(this.displayName);
  final String displayName;
}

/// Summary of staff accreditations
class AccreditationSummary extends Equatable {
  final String staffId;
  final int totalAccreditations;
  final int activeAccreditations;
  final int expiredAccreditations;
  final int expiringSoonCount;
  final List<AccreditationWarning> warnings;
  final DateTime lastUpdated;

  const AccreditationSummary({
    required this.staffId,
    required this.totalAccreditations,
    required this.activeAccreditations,
    required this.expiredAccreditations,
    required this.expiringSoonCount,
    required this.warnings,
    required this.lastUpdated,
  });

  /// Gets compliance percentage
  double get compliancePercentage {
    if (totalAccreditations == 0) return 0.0;
    return (activeAccreditations / totalAccreditations) * 100;
  }

  /// Gets overall status
  AccreditationStatus get overallStatus {
    if (expiredAccreditations > 0) return AccreditationStatus.nonCompliant;
    if (expiringSoonCount > 0) return AccreditationStatus.warning;
    if (activeAccreditations == totalAccreditations) return AccreditationStatus.compliant;
    return AccreditationStatus.partial;
  }

  @override
  List<Object?> get props => [
        staffId,
        totalAccreditations,
        activeAccreditations,
        expiredAccreditations,
        expiringSoonCount,
        warnings,
        lastUpdated,
      ];
}

/// Overall accreditation status
enum AccreditationStatus {
  compliant('Compliant'),
  nonCompliant('Non-Compliant'),
  warning('Warning'),
  partial('Partial');

  const AccreditationStatus(this.displayName);
  final String displayName;
}

/// Training suggestion for missing accreditations
class TrainingSuggestion extends Equatable {
  final String staffId;
  final AccreditationType requiredType;
  final CertificationLevel targetLevel;
  final String trainingCourse;
  final String? provider;
  final Duration? estimatedDuration;
  final double? estimatedCost;
  final String? enrollmentUrl;

  const TrainingSuggestion({
    required this.staffId,
    required this.requiredType,
    required this.targetLevel,
    required this.trainingCourse,
    this.provider,
    this.estimatedDuration,
    this.estimatedCost,
    this.enrollmentUrl,
  });

  @override
  List<Object?> get props => [
        staffId,
        requiredType,
        targetLevel,
        trainingCourse,
        provider,
        estimatedDuration,
        estimatedCost,
        enrollmentUrl,
      ];
}

/// Accreditation renewal request
class AccreditationRenewal extends Equatable {
  final String id;
  final String staffId;
  final String accreditationId;
  final RenewalType renewalType;
  final DateTime requestedAt;
  final DateTime? requestedExpiryDate;
  final String? notes;
  final RenewalStatus status;
  final String? processedBy;
  final DateTime? processedAt;
  final String? rejectionReason;

  const AccreditationRenewal({
    required this.id,
    required this.staffId,
    required this.accreditationId,
    required this.renewalType,
    required this.requestedAt,
    this.requestedExpiryDate,
    this.notes,
    required this.status,
    this.processedBy,
    this.processedAt,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [
        id,
        staffId,
        accreditationId,
        renewalType,
        requestedAt,
        requestedExpiryDate,
        notes,
        status,
        processedBy,
        processedAt,
        rejectionReason,
      ];
}

/// Types of renewal
enum RenewalType {
  standard('Standard Renewal'),
  expedited('Expedited Renewal'),
  upgrade('Level Upgrade'),
  reissue('Certificate Reissue');

  const RenewalType(this.displayName);
  final String displayName;
}

/// Renewal status
enum RenewalStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected'),
  processed('Processed');

  const RenewalStatus(this.displayName);
  final String displayName;
}

/// Service requirement mapping
class ServiceRequirement extends Equatable {
  final AccreditationType requiredAccreditation;
  final CertificationLevel minimumLevel;
  final bool isRequired;
  final String? alternativeOptions;

  const ServiceRequirement({
    required this.requiredAccreditation,
    required this.minimumLevel,
    required this.isRequired,
    this.alternativeOptions,
  });

  @override
  List<Object?> get props => [
        requiredAccreditation,
        minimumLevel,
        isRequired,
        alternativeOptions,
      ];
}
