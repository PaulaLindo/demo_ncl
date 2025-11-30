// lib/models/scheduler_models.dart
import 'package:flutter/material.dart';

// Transport Request Model (ITC 5.2)
class TransportRequest {
  final String id;
  final String jobAssignmentId;
  final String staffId;
  final String pickupLocation;
  final String destinationLocation;
  final DateTime pickupTime;
  final TransportStatus status;
  final DateTime requestedAt;
  final String? uberDriverId;
  final String? uberVehicleInfo;
  final DateTime? estimatedArrival;
  final Duration? estimatedDuration;
  final double? cost;
  final String? trackingUrl;

  TransportRequest({
    required this.id,
    required this.jobAssignmentId,
    required this.staffId,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.pickupTime,
    required this.status,
    required this.requestedAt,
    this.uberDriverId,
    this.uberVehicleInfo,
    this.estimatedArrival,
    this.estimatedDuration,
    this.cost,
    this.trackingUrl,
  });

  TransportRequest copyWith({
    String? id,
    String? jobAssignmentId,
    String? staffId,
    String? pickupLocation,
    String? destinationLocation,
    DateTime? pickupTime,
    TransportStatus? status,
    DateTime? requestedAt,
    String? uberDriverId,
    String? uberVehicleInfo,
    DateTime? estimatedArrival,
    Duration? estimatedDuration,
    double? cost,
    String? trackingUrl,
  }) {
    return TransportRequest(
      id: id ?? this.id,
      jobAssignmentId: jobAssignmentId ?? this.jobAssignmentId,
      staffId: staffId ?? this.staffId,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      pickupTime: pickupTime ?? this.pickupTime,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      uberDriverId: uberDriverId ?? this.uberDriverId,
      uberVehicleInfo: uberVehicleInfo ?? this.uberVehicleInfo,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      cost: cost ?? this.cost,
      trackingUrl: trackingUrl ?? this.trackingUrl,
    );
  }
}

enum TransportStatus { requested, confirmed, inTransit, completed, cancelled }

// Quality Flag Model (ITC 5.3)
class QualityFlag {
  final String id;
  final String jobAssignmentId;
  final String staffId;
  final List<QualityChecklistItem> checklistItems;
  final int customerRating;
  final String? customerNotes;
  final List<String> issues;
  final QualityStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  QualityFlag({
    required this.id,
    required this.jobAssignmentId,
    required this.staffId,
    required this.checklistItems,
    required this.customerRating,
    this.customerNotes,
    required this.issues,
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  QualityFlag copyWith({
    String? id,
    String? jobAssignmentId,
    String? staffId,
    List<QualityChecklistItem>? checklistItems,
    int? customerRating,
    String? customerNotes,
    List<String>? issues,
    QualityStatus? status,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) {
    return QualityFlag(
      id: id ?? this.id,
      jobAssignmentId: jobAssignmentId ?? this.jobAssignmentId,
      staffId: staffId ?? this.staffId,
      checklistItems: checklistItems ?? this.checklistItems,
      customerRating: customerRating ?? this.customerRating,
      customerNotes: customerNotes ?? this.customerNotes,
      issues: issues ?? this.issues,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }
}

class QualityChecklistItem {
  final String id;
  final String description;
  final bool completed;
  final String? notes;

  QualityChecklistItem({
    required this.id,
    required this.description,
    required this.completed,
    this.notes,
  });

  QualityChecklistItem copyWith({
    String? id,
    String? description,
    bool? completed,
    String? notes,
  }) {
    return QualityChecklistItem(
      id: id ?? this.id,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
    );
  }
}

enum QualityStatus { pendingReview, approved, rejected, needsImprovement }

// Training Record Model (ITC 5.6)
class TrainingRecord {
  final String id;
  final String staffId;
  final String trainingId;
  final TrainingStatus status;
  final DateTime completionDate;
  final String? certificateUrl;
  final DateTime createdAt;
  final DateTime? expiresAt;

  TrainingRecord({
    required this.id,
    required this.staffId,
    required this.trainingId,
    required this.status,
    required this.completionDate,
    this.certificateUrl,
    required this.createdAt,
    this.expiresAt,
  });

  TrainingRecord copyWith({
    String? id,
    String? staffId,
    String? trainingId,
    TrainingStatus? status,
    DateTime? completionDate,
    String? certificateUrl,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return TrainingRecord(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      trainingId: trainingId ?? this.trainingId,
      status: status ?? this.status,
      completionDate: completionDate ?? this.completionDate,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

enum TrainingStatus { notStarted, inProgress, completed, expired }

// Service Quote Model (ITC 5.4)
class ServiceQuote {
  final String id;
  final String serviceId;
  final String customerId;
  final double basePrice;
  final double customizationPrice;
  final double totalPrice;
  final DateTime validUntil;
  final Map<String, dynamic> customizations;
  final QuoteStatus status;
  final DateTime createdAt;
  final DateTime? acceptedAt;

  ServiceQuote({
    required this.id,
    required this.serviceId,
    required this.customerId,
    required this.basePrice,
    required this.customizationPrice,
    required this.totalPrice,
    required this.validUntil,
    required this.customizations,
    required this.status,
    required this.createdAt,
    this.acceptedAt,
  });

  ServiceQuote copyWith({
    String? id,
    String? serviceId,
    String? customerId,
    double? basePrice,
    double? customizationPrice,
    double? totalPrice,
    DateTime? validUntil,
    Map<String, dynamic>? customizations,
    QuoteStatus? status,
    DateTime? createdAt,
    DateTime? acceptedAt,
  }) {
    return ServiceQuote(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      customerId: customerId ?? this.customerId,
      basePrice: basePrice ?? this.basePrice,
      customizationPrice: customizationPrice ?? this.customizationPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      validUntil: validUntil ?? this.validUntil,
      customizations: customizations ?? this.customizations,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
    );
  }
}

enum QuoteStatus { draft, sent, accepted, rejected, expired }

// Temp Card Entry Model (ITC 5.5)
class TempCardEntry {
  final String id;
  final String staffId;
  final DateTime workDate;
  final double hoursWorked;
  final String workType;
  final String? approvedBy;
  final String? notes;
  final TempCardStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;

  TempCardEntry({
    required this.id,
    required this.staffId,
    required this.workDate,
    required this.hoursWorked,
    required this.workType,
    this.approvedBy,
    this.notes,
    required this.status,
    required this.createdAt,
    this.approvedAt,
  });

  TempCardEntry copyWith({
    String? id,
    String? staffId,
    DateTime? workDate,
    double? hoursWorked,
    String? workType,
    String? approvedBy,
    String? notes,
    TempCardStatus? status,
    DateTime? createdAt,
    DateTime? approvedAt,
  }) {
    return TempCardEntry(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      workDate: workDate ?? this.workDate,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      workType: workType ?? this.workType,
      approvedBy: approvedBy ?? this.approvedBy,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}

enum TempCardStatus { pendingApproval, approved, rejected, processed }

// Staff Availability Model
class StaffAvailability {
  final String id;
  final String staffId;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isAvailable;
  final String? reason;
  final DateTime createdAt;

  StaffAvailability({
    required this.id,
    required this.staffId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.reason,
    required this.createdAt,
  });

  StaffAvailability copyWith({
    String? id,
    String? staffId,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isAvailable,
    String? reason,
    DateTime? createdAt,
  }) {
    return StaffAvailability(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Enhanced Booking Model for Integration
class EnhancedBooking {
  final String id;
  final String customerId;
  final String? staffId;
  final String serviceId;
  final DateTime scheduledDate;
  final BookingStatus status;
  final double totalPrice;
  final Map<String, dynamic> customizations;
  final String? quoteId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? qualityFlagId;

  EnhancedBooking({
    required this.id,
    required this.customerId,
    this.staffId,
    required this.serviceId,
    required this.scheduledDate,
    required this.status,
    required this.totalPrice,
    required this.customizations,
    this.quoteId,
    required this.createdAt,
    this.completedAt,
    this.qualityFlagId,
  });

  EnhancedBooking copyWith({
    String? id,
    String? customerId,
    String? staffId,
    String? serviceId,
    DateTime? scheduledDate,
    BookingStatus? status,
    double? totalPrice,
    Map<String, dynamic>? customizations,
    String? quoteId,
    DateTime? createdAt,
    DateTime? completedAt,
    String? qualityFlagId,
  }) {
    return EnhancedBooking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      staffId: staffId ?? this.staffId,
      serviceId: serviceId ?? this.serviceId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      customizations: customizations ?? this.customizations,
      quoteId: quoteId ?? this.quoteId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      qualityFlagId: qualityFlagId ?? this.qualityFlagId,
    );
  }
}

enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

// Payroll Entry Model
class PayrollEntry {
  final String id;
  final String staffId;
  final DateTime workDate;
  final double hoursWorked;
  final double hourlyRate;
  final double basePay;
  final double qualityMultiplier;
  final double bonusAmount;
  final double finalPay;
  final String qualityStatus;
  final PayrollStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final DateTime? paidAt;

  PayrollEntry({
    required this.id,
    required this.staffId,
    required this.workDate,
    required this.hoursWorked,
    required this.hourlyRate,
    required this.basePay,
    required this.qualityMultiplier,
    required this.bonusAmount,
    required this.finalPay,
    required this.qualityStatus,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.paidAt,
  });

  PayrollEntry copyWith({
    String? id,
    String? staffId,
    DateTime? workDate,
    double? hoursWorked,
    double? hourlyRate,
    double? basePay,
    double? qualityMultiplier,
    double? bonusAmount,
    double? finalPay,
    String? qualityStatus,
    PayrollStatus? status,
    DateTime? createdAt,
    DateTime? processedAt,
    DateTime? paidAt,
  }) {
    return PayrollEntry(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      workDate: workDate ?? this.workDate,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      basePay: basePay ?? this.basePay,
      qualityMultiplier: qualityMultiplier ?? this.qualityMultiplier,
      bonusAmount: bonusAmount ?? this.bonusAmount,
      finalPay: finalPay ?? this.finalPay,
      qualityStatus: qualityStatus ?? this.qualityStatus,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}

enum PayrollStatus { pending, approved, processed, paid }

// Training Template Model
class TrainingTemplate {
  final String id;
  final String name;
  final String description;
  final Duration estimatedDuration;
  final List<String> prerequisites;
  final bool isRequired;
  final DateTime? validUntil;

  TrainingTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.estimatedDuration,
    required this.prerequisites,
    required this.isRequired,
    this.validUntil,
  });
}
