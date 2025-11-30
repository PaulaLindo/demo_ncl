// lib/models/staff_model.dart
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'review_model.dart';

/// Represents a staff member/cleaning professional
class StaffMember extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String bio;
  final String? profileImageUrl;
  final List<String> specialties;
  final int experienceYears;
  final int completedJobs;
  final int responseRate;
  final List<Review> reviews;
  final bool isVerified;
  final bool isInsured;
  final bool hasOwnSupplies;
  final bool isEcoFriendly;
  final bool isPetFriendly;
  final bool isFlexibleSchedule;
  final DateTime? lastActive;
  final double? averageRating;

  const StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    this.profileImageUrl,
    required this.specialties,
    required this.experienceYears,
    required this.completedJobs,
    required this.responseRate,
    required this.reviews,
    required this.isVerified,
    required this.isInsured,
    required this.hasOwnSupplies,
    required this.isEcoFriendly,
    required this.isPetFriendly,
    required this.isFlexibleSchedule,
    this.lastActive,
    this.averageRating,
  });

  /// Creates a StaffMember from JSON data
  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      bio: json['bio'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      specialties: (json['specialties'] as List<dynamic>?)?.cast<String>() ?? [],
      experienceYears: json['experienceYears'] as int? ?? 0,
      completedJobs: json['completedJobs'] as int? ?? 0,
      responseRate: json['responseRate'] as int? ?? 0,
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((review) => Review.fromJson(review))
          .toList() ?? [],
      isVerified: json['isVerified'] as bool? ?? false,
      isInsured: json['isInsured'] as bool? ?? false,
      hasOwnSupplies: json['hasOwnSupplies'] as bool? ?? false,
      isEcoFriendly: json['isEcoFriendly'] as bool? ?? false,
      isPetFriendly: json['isPetFriendly'] as bool? ?? false,
      isFlexibleSchedule: json['isFlexibleSchedule'] as bool? ?? false,
      lastActive: json['lastActive'] != null 
          ? DateTime.parse(json['lastActive'] as String)
          : null,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'specialties': specialties,
      'experienceYears': experienceYears,
      'completedJobs': completedJobs,
      'responseRate': responseRate,
      'reviews': reviews.map((review) => review.toJson()).toList(),
      'isVerified': isVerified,
      'isInsured': isInsured,
      'hasOwnSupplies': hasOwnSupplies,
      'isEcoFriendly': isEcoFriendly,
      'isPetFriendly': isPetFriendly,
      'isFlexibleSchedule': isFlexibleSchedule,
      'lastActive': lastActive?.toIso8601String(),
      'averageRating': averageRating,
    };
  }

  /// Creates a copy with updated values
  StaffMember copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? bio,
    String? profileImageUrl,
    List<String>? specialties,
    int? experienceYears,
    int? completedJobs,
    int? responseRate,
    List<Review>? reviews,
    bool? isVerified,
    bool? isInsured,
    bool? hasOwnSupplies,
    bool? isEcoFriendly,
    bool? isPetFriendly,
    bool? isFlexibleSchedule,
    DateTime? lastActive,
    double? averageRating,
  }) {
    return StaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      specialties: specialties ?? this.specialties,
      experienceYears: experienceYears ?? this.experienceYears,
      completedJobs: completedJobs ?? this.completedJobs,
      responseRate: responseRate ?? this.responseRate,
      reviews: reviews ?? this.reviews,
      isVerified: isVerified ?? this.isVerified,
      isInsured: isInsured ?? this.isInsured,
      hasOwnSupplies: hasOwnSupplies ?? this.hasOwnSupplies,
      isEcoFriendly: isEcoFriendly ?? this.isEcoFriendly,
      isPetFriendly: isPetFriendly ?? this.isPetFriendly,
      isFlexibleSchedule: isFlexibleSchedule ?? this.isFlexibleSchedule,
      lastActive: lastActive ?? this.lastActive,
      averageRating: averageRating ?? this.averageRating,
    );
  }

  /// Gets the display name for experience
  String get experienceDisplay {
    if (experienceYears == 0) return 'New Professional';
    if (experienceYears == 1) return '1 Year Experience';
    return '$experienceYears Years Experience';
  }

  /// Gets the display name for completed jobs
  String get completedJobsDisplay {
    if (completedJobs == 0) return 'No Jobs Yet';
    if (completedJobs == 1) return '1 Job Completed';
    return '$completedJobs Jobs Completed';
  }

  /// Gets the display name for response rate
  String get responseRateDisplay {
    return '$responseRate% Response Rate';
  }

  /// Gets the rating display
  String get ratingDisplay {
    if (reviews.isEmpty) return 'No Reviews Yet';
    final rating = averageRating ?? 0.0;
    return '${rating.toStringAsFixed(1)} (${reviews.length} reviews)';
  }

  /// Gets the status based on last active time
  String get status {
    if (lastActive == null) return 'Offline';
    
    final now = DateTime.now();
    final difference = now.difference(lastActive!);
    
    if (difference.inMinutes < 5) return 'Online';
    if (difference.inHours < 1) return 'Recently Active';
    if (difference.inDays < 1) return 'Active Today';
    if (difference.inDays < 7) return 'Active This Week';
    return 'Inactive';
  }

  /// Gets status color
  Color get statusColor {
    switch (status) {
      case 'Online':
        return Colors.green;
      case 'Recently Active':
        return Colors.lightGreen;
      case 'Active Today':
        return Colors.blue;
      case 'Active This Week':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        bio,
        profileImageUrl,
        specialties,
        experienceYears,
        completedJobs,
        responseRate,
        reviews,
        isVerified,
        isInsured,
        hasOwnSupplies,
        isEcoFriendly,
        isPetFriendly,
        isFlexibleSchedule,
        lastActive,
        averageRating,
      ];

  @override
  String toString() {
    return 'StaffMember(id: $id, name: $name, experienceYears: $experienceYears)';
  }
}

/// Represents staff availability
class StaffAvailability extends Equatable {
  final String staffId;
  final DateTime date;
  final List<TimeSlot> availableSlots;
  final List<TimeSlot> bookedSlots;

  const StaffAvailability({
    required this.staffId,
    required this.date,
    required this.availableSlots,
    required this.bookedSlots,
  });

  /// Creates a StaffAvailability from JSON data
  factory StaffAvailability.fromJson(Map<String, dynamic> json) {
    return StaffAvailability(
      staffId: json['staffId'] as String,
      date: DateTime.parse(json['date'] as String),
      availableSlots: (json['availableSlots'] as List<dynamic>?)
          ?.map((slot) => TimeSlot.fromJson(slot))
          .toList() ?? [],
      bookedSlots: (json['bookedSlots'] as List<dynamic>?)
          ?.map((slot) => TimeSlot.fromJson(slot))
          .toList() ?? [],
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'date': date.toIso8601String(),
      'availableSlots': availableSlots.map((slot) => slot.toJson()).toList(),
      'bookedSlots': bookedSlots.map((slot) => slot.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [staffId, date, availableSlots, bookedSlots];
}

/// Represents a time slot for availability
class TimeSlot extends Equatable {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isAvailable;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  /// Creates a TimeSlot from JSON data
  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: TimeOfDay(
        hour: json['startTime']['hour'] as int,
        minute: json['startTime']['minute'] as int,
      ),
      endTime: TimeOfDay(
        hour: json['endTime']['hour'] as int,
        minute: json['endTime']['minute'] as int,
      ),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'startTime': {
        'hour': startTime.hour,
        'minute': startTime.minute,
      },
      'endTime': {
        'hour': endTime.hour,
        'minute': endTime.minute,
      },
      'isAvailable': isAvailable,
    };
  }

  /// Gets the display text for the time slot
  String get displayText {
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [startTime, endTime, isAvailable];
}
