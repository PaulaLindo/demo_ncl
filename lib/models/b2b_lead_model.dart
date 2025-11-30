// lib/models/b2b_lead_model.dart
import 'package:equatable/equatable.dart';

enum LeadStatus {
  newLead,
  contacted,
  qualified,
  proposal,
  negotiation,
  won,
  lost,
}

extension LeadStatusExtension on LeadStatus {
  String get displayName {
    switch (this) {
      case LeadStatus.newLead:
        return 'New';
      case LeadStatus.contacted:
        return 'Contacted';
      case LeadStatus.qualified:
        return 'Qualified';
      case LeadStatus.proposal:
        return 'Proposal';
      case LeadStatus.negotiation:
        return 'Negotiation';
      case LeadStatus.won:
        return 'Won';
      case LeadStatus.lost:
        return 'Lost';
    }
  }
}

/// Represents a B2B sales lead
class B2BLead extends Equatable {
  final String id;
  final String companyName;
  final String contactName;
  final String email;
  final String phone;
  final String serviceInterest;
  final String? notes;
  final DateTime createdAt;
  final LeadStatus status;
  final DateTime? statusUpdatedAt;

  const B2BLead({
    required this.id,
    required this.companyName,
    required this.contactName,
    required this.email,
    required this.phone,
    required this.serviceInterest,
    this.notes,
    required this.createdAt,
    required this.status,
    this.statusUpdatedAt,
  });

  factory B2BLead.fromJson(Map<String, dynamic> json) {
    return B2BLead(
      id: json['id'] as String,
      companyName: json['companyName'] as String,
      contactName: json['contactName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      serviceInterest: json['serviceInterest'] as String,
      notes: json['notes'] as String?,
      createdAt: (json['createdAt'] as dynamic).toDate(),
      status: LeadStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => LeadStatus.newLead,
      ),
      statusUpdatedAt: json['statusUpdatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'contactName': contactName,
      'email': email,
      'phone': phone,
      'serviceInterest': serviceInterest,
      'notes': notes,
      'createdAt': createdAt,
      'status': status.toString(),
      'statusUpdatedAt': statusUpdatedAt,
    };
  }

  B2BLead copyWith({
    String? id,
    String? companyName,
    String? contactName,
    String? email,
    String? phone,
    String? serviceInterest,
    String? notes,
    DateTime? createdAt,
    LeadStatus? status,
    DateTime? statusUpdatedAt,
  }) {
    return B2BLead(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      contactName: contactName ?? this.contactName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      serviceInterest: serviceInterest ?? this.serviceInterest,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        companyName,
        contactName,
        email,
        phone,
        serviceInterest,
        notes,
        createdAt,
        status,
        statusUpdatedAt,
      ];
}
