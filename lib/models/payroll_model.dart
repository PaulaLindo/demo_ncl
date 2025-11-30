// lib/models/payroll_model.dart
import 'package:equatable/equatable.dart';

enum PayrollStatus {
  draft,
  review,
  approved,
  finalized,
  paid,
}

extension PayrollStatusExtension on PayrollStatus {
  String get displayName {
    switch (this) {
      case PayrollStatus.draft:
        return 'Draft';
      case PayrollStatus.review:
        return 'Under Review';
      case PayrollStatus.approved:
        return 'Approved';
      case PayrollStatus.finalized:
        return 'Finalized';
      case PayrollStatus.paid:
        return 'Paid';
    }
  }
}

/// Represents a payroll report for a period
class PayrollReport extends Equatable {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final PayrollStatus status;
  final List<String> timeRecordIds;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? finalizedAt;
  final DateTime? paidAt;

  const PayrollReport({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.timeRecordIds,
    required this.totalAmount,
    required this.createdAt,
    this.finalizedAt,
    this.paidAt,
  });

  factory PayrollReport.fromJson(Map<String, dynamic> json) {
    return PayrollReport(
      id: json['id'] as String,
      startDate: (json['startDate'] as dynamic).toDate(),
      endDate: (json['endDate'] as dynamic).toDate(),
      status: PayrollStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => PayrollStatus.draft,
      ),
      timeRecordIds: List<String>.from(json['timeRecordIds'] as List),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      createdAt: (json['createdAt'] as dynamic).toDate(),
      finalizedAt: json['finalizedAt']?.toDate(),
      paidAt: json['paidAt']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
      'status': status.toString(),
      'timeRecordIds': timeRecordIds,
      'totalAmount': totalAmount,
      'createdAt': createdAt,
      'finalizedAt': finalizedAt,
      'paidAt': paidAt,
    };
  }

  PayrollReport copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    PayrollStatus? status,
    List<String>? timeRecordIds,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? finalizedAt,
    DateTime? paidAt,
  }) {
    return PayrollReport(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      timeRecordIds: timeRecordIds ?? this.timeRecordIds,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      finalizedAt: finalizedAt ?? this.finalizedAt,
      paidAt: paidAt ?? this.paidAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        startDate,
        endDate,
        status,
        timeRecordIds,
        totalAmount,
        createdAt,
        finalizedAt,
        paidAt,
      ];
}
