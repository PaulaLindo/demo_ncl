// lib/models/temp_card_model.dart
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Represents a temporary access card assigned to a user
class TempCard extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String cardNumber;
  final DateTime issueDate;
  final DateTime expiryDate;
  final bool isActive;
  final String? notes;
  final DateTime? deactivationDate;
  final String? deactivationReason;

  const TempCard({
    required this.id,
    required this.userId,
    required this.userName,
    required this.cardNumber,
    required this.issueDate,
    required this.expiryDate,
    this.isActive = true,
    this.notes,
    this.deactivationDate,
    this.deactivationReason,
  });

  /// Creates a copy of this temp card with the given fields replaced
  TempCard copyWith({
    String? id,
    String? userId,
    String? userName,
    String? cardNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    bool? isActive,
    String? notes,
    DateTime? deactivationDate,
    String? deactivationReason,
  }) {
    return TempCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      cardNumber: cardNumber ?? this.cardNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      deactivationDate: deactivationDate ?? this.deactivationDate,
      deactivationReason: deactivationReason ?? this.deactivationReason,
    );
  }

  /// Creates a TempCard from a JSON object
  factory TempCard.fromJson(Map<String, dynamic> json) {
    return TempCard(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      cardNumber: json['cardNumber'] as String,
      issueDate: (json['issueDate'] as dynamic).toDate(),
      expiryDate: (json['expiryDate'] as dynamic).toDate(),
      isActive: json['isActive'] as bool? ?? true,
      notes: json['notes'] as String?,
      deactivationDate: json['deactivationDate']?.toDate(),
      deactivationReason: json['deactivationReason'] as String?,
    );
  }

  /// Deactivates the card with an optional reason
  TempCard deactivate({String? reason}) {
    return copyWith(
      isActive: false,
      deactivationDate: DateTime.now(),
      deactivationReason: reason,
    );
  }

  /// Reactivates the card
  TempCard reactivate() {
    return copyWith(
      isActive: true,
      deactivationDate: null,
      deactivationReason: null,
    );
  }

  /// Returns true if the card is expired
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  /// Returns true if the card is active and not expired
  bool get isValid => isActive && !isExpired;

  /// Returns the number of days until expiration
  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  /// Returns a formatted issue date string (e.g., "Jan 1, 2023")
  String get formattedIssueDate => DateFormat('MMM d, y').format(issueDate);

  /// Returns a formatted expiry date string (e.g., "Jan 1, 2024")
  String get formattedExpiryDate => DateFormat('MMM d, y').format(expiryDate);

  /// Returns a formatted status string
  String get status {
    if (!isActive) return 'Deactivated';
    if (isExpired) return 'Expired';
    return 'Active';
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        cardNumber,
        issueDate,
        expiryDate,
        isActive,
        notes,
        deactivationDate,
        deactivationReason,
      ];

  @override
  bool? get stringify => true;
}