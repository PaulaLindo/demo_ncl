// lib/models/review_model.dart
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String bookingId;
  final String customerId;
  final String customerName;
  final String staffId;
  final String staffName;
  final int rating; // 1-5
  final int? cleanlinessRating;
  final int? professionalismRating;
  final int? communicationRating;
  final int? valueRating;
  final String? comment;
  final List<String>? issues;
  final String? feedback;
  final bool? wouldRecommend;
  final bool? wouldRebook;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.customerName,
    required this.staffId,
    required this.staffName,
    required this.rating,
    this.cleanlinessRating,
    this.professionalismRating,
    this.communicationRating,
    this.valueRating,
    this.comment,
    this.issues,
    this.feedback,
    this.wouldRecommend,
    this.wouldRebook,
    required this.createdAt,
  });

  /// Creates a Review from JSON data
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      rating: json['rating'] as int,
      cleanlinessRating: json['cleanlinessRating'] as int?,
      professionalismRating: json['professionalismRating'] as int?,
      communicationRating: json['communicationRating'] as int?,
      valueRating: json['valueRating'] as int?,
      comment: json['comment'] as String?,
      issues: (json['issues'] as List<dynamic>?)?.cast<String>(),
      feedback: json['feedback'] as String?,
      wouldRecommend: json['wouldRecommend'] as bool?,
      wouldRebook: json['wouldRebook'] as bool?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'customerId': customerId,
      'customerName': customerName,
      'staffId': staffId,
      'staffName': staffName,
      'rating': rating,
      'cleanlinessRating': cleanlinessRating,
      'professionalismRating': professionalismRating,
      'communicationRating': communicationRating,
      'valueRating': valueRating,
      'comment': comment,
      'issues': issues,
      'feedback': feedback,
      'wouldRecommend': wouldRecommend,
      'wouldRebook': wouldRebook,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy with updated values
  Review copyWith({
    String? id,
    String? bookingId,
    String? customerId,
    String? customerName,
    String? staffId,
    String? staffName,
    int? rating,
    int? cleanlinessRating,
    int? professionalismRating,
    int? communicationRating,
    int? valueRating,
    String? comment,
    List<String>? issues,
    String? feedback,
    bool? wouldRecommend,
    bool? wouldRebook,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      rating: rating ?? this.rating,
      cleanlinessRating: cleanlinessRating ?? this.cleanlinessRating,
      professionalismRating: professionalismRating ?? this.professionalismRating,
      communicationRating: communicationRating ?? this.communicationRating,
      valueRating: valueRating ?? this.valueRating,
      comment: comment ?? this.comment,
      issues: issues ?? this.issues,
      feedback: feedback ?? this.feedback,
      wouldRecommend: wouldRecommend ?? this.wouldRecommend,
      wouldRebook: wouldRebook ?? this.wouldRebook,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Gets the rating display text
  String get ratingDisplay {
    switch (rating) {
      case 5:
        return 'Excellent';
      case 4:
        return 'Very Good';
      case 3:
        return 'Good';
      case 2:
        return 'Fair';
      case 1:
        return 'Poor';
      default:
        return 'No Rating';
    }
  }

  /// Gets the rating color
  Color get ratingColor {
    switch (rating) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.amber;
      case 2:
        return Colors.orange;
      case 1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  List<Object?> get props => [
        id,
        bookingId,
        customerId,
        customerName,
        staffId,
        staffName,
        rating,
        cleanlinessRating,
        professionalismRating,
        communicationRating,
        valueRating,
        comment,
        issues,
        feedback,
        wouldRecommend,
        wouldRebook,
        createdAt,
      ];
}