// lib/models/booking_model.dart
import 'package:equatable/equatable.dart';

/// Represents the possible statuses of a booking
enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rejected,
}

/// Represents the time of day preference for a booking
enum TimeOfDayPreference {
  morning('Morning', '08:00 - 12:00'),
  afternoon('Afternoon', '12:00 - 16:00'),
  evening('Evening', '16:00 - 20:00'),
  flexible('Flexible', 'Anytime');

  final String displayName;
  final String timeRange;

  const TimeOfDayPreference(this.displayName, this.timeRange);
}

/// Represents the size of the property
enum PropertySize {
  small('Small (1-2 rooms)', 1.0),
  medium('Medium (3-4 rooms)', 1.5),
  large('Large (5+ rooms)', 2.0);

  final String displayName;
  final double priceMultiplier;

  const PropertySize(this.displayName, this.priceMultiplier);
}

/// Represents the frequency of recurring bookings
enum BookingFrequency {
  oneTime('One-time', 1.0),
  weekly('Weekly', 0.9), // 10% discount
  biWeekly('Bi-weekly', 0.85), // 15% discount
  monthly('Monthly', 0.8); // 20% discount

  final String displayName;
  final double discountMultiplier;

  const BookingFrequency(this.displayName, this.discountMultiplier);
}

// Add these extensions for better enum serialization
extension BookingStatusExtension on BookingStatus {
  String get value => toString().split('.').last;
}

extension TimeOfDayPreferenceExtension on TimeOfDayPreference {
  String get value => toString().split('.').last;
}

extension PropertySizeExtension on PropertySize {
  String get value => toString().split('.').last;
}

extension BookingFrequencyExtension on BookingFrequency {
  String get value => toString().split('.').last;
}

/// Represents a booking made by a customer
class Booking extends Equatable {
  final String id;
  final String customerId;
  final String serviceId;
  final String serviceName;
  final DateTime bookingDate;
  final TimeOfDayPreference timePreference;
  final String address;
  final BookingStatus status;
  final double basePrice;
  final PropertySize propertySize;
  final BookingFrequency frequency;
  final String? specialInstructions;
  final String? assignedStaffId;
  final String? assignedStaffName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? cancellationReason;
  final double? finalPrice;
  final DateTime startTime;
  final DateTime endTime;
  final String? notes;

  const Booking({
    required this.id,
    required this.customerId,
    required this.serviceId,
    required this.serviceName,
    required this.bookingDate,
    required this.timePreference,
    required this.address,
    required this.status,
    required this.basePrice,
    required this.propertySize,
    required this.frequency,
    required this.startTime,
    required this.endTime,
    this.specialInstructions,
    this.assignedStaffId,
    this.assignedStaffName,
    this.cancellationReason,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.finalPrice,

  });

  /// Creates a booking from JSON data
  factory Booking.fromJson(Map<String, dynamic> json) {
    try {
      return Booking(
        id: json['id'] as String,
        customerId: json['customerId'] as String,
        serviceId: json['serviceId'] as String,
        serviceName: json['serviceName'] as String,
        bookingDate: DateTime.parse(json['bookingDate'] as String),
        timePreference: TimeOfDayPreference.values.firstWhere(
          (e) => e.value == json['timePreference'],
          orElse: () => TimeOfDayPreference.flexible,
        ),
        address: json['address'] as String,
        status: BookingStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => BookingStatus.pending,
        ),
        basePrice: (json['basePrice'] as num).toDouble(),
        propertySize: PropertySize.values.firstWhere(
          (e) => e.value == json['propertySize'],
          orElse: () => PropertySize.medium,
        ),
        frequency: BookingFrequency.values.firstWhere(
          (e) => e.value == json['frequency'],
          orElse: () => BookingFrequency.oneTime,
        ),
        specialInstructions: json['specialInstructions'] as String?,
        assignedStaffId: json['assignedStaffId'] as String?,
        assignedStaffName: json['assignedStaffName'] as String?,
        cancellationReason: json['cancellationReason'] as String?,
        startTime: json['startTime'] != null 
            ? DateTime.parse(json['startTime'] as String)
            : DateTime.parse(json['bookingDate'] as String),
        endTime: json['endTime'] != null 
            ? DateTime.parse(json['endTime'] as String)
            : DateTime.parse(json['bookingDate'] as String).add(const Duration(hours: 2)),
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt'] as String) 
            : null,
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        finalPrice: json['finalPrice'] != null 
            ? (json['finalPrice'] as num).toDouble()
            : calculateFinalPrice(
                (json['basePrice'] as num).toDouble(),
                PropertySize.values.firstWhere(
                  (e) => e.value == json['propertySize'],
                  orElse: () => PropertySize.medium,
                ).priceMultiplier,
                BookingFrequency.values.firstWhere(
                  (e) => e.value == json['frequency'],
                  orElse: () => BookingFrequency.oneTime,
                ).discountMultiplier,
              ),
        notes: json['notes'] as String?,
      );
    } catch (e) {
      throw FormatException('Failed to parse Booking from JSON: $e');
    }
  }

  /// Converts the booking to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'bookingDate': bookingDate.toIso8601String(),
      'timePreference': timePreference.value,
      'address': address,
      'status': status.value,
      'basePrice': basePrice,
      'propertySize': propertySize.value,
      'frequency': frequency.value,
      'specialInstructions': specialInstructions,
      'assignedStaffId': assignedStaffId,
      'assignedStaffName': assignedStaffName,
      'cancellationReason': cancellationReason,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'finalPrice': finalPrice,
    };
  }

  /// Creates a copy of this booking with updated fields
  Booking copyWith({
    String? id,
    String? customerId,
    String? serviceId,
    String? serviceName,
    DateTime? bookingDate,
    TimeOfDayPreference? timePreference,
    String? address,
    BookingStatus? status,
    double? basePrice,
    PropertySize? propertySize,
    BookingFrequency? frequency,
    String? specialInstructions,
    String? assignedStaffId,
    String? assignedStaffName,
    String? cancellationReason,
    DateTime? updatedAt,
    double? finalPrice,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      bookingDate: bookingDate ?? this.bookingDate,
      timePreference: timePreference ?? this.timePreference,
      address: address ?? this.address,
      status: status ?? this.status,
      basePrice: basePrice ?? this.basePrice,
      propertySize: propertySize ?? this.propertySize,
      frequency: frequency ?? this.frequency,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      finalPrice: finalPrice ??
          calculateFinalPrice(
            basePrice ?? this.basePrice,
            (propertySize ?? this.propertySize).priceMultiplier,
            (frequency ?? this.frequency).discountMultiplier,
          ),
    );
  }

  /// Calculates the final price based on base price, property size, and frequency
  static double calculateFinalPrice(
    double basePrice,
    double sizeMultiplier,
    double frequencyMultiplier,
  ) {
    return (basePrice * sizeMultiplier * frequencyMultiplier)
        .roundToDouble();
  }

  /// Checks if the booking is upcoming
  bool get isUpcoming {
    final now = DateTime.now();
    return (status == BookingStatus.confirmed ||
            status == BookingStatus.inProgress) &&
        bookingDate.isAfter(now);
  }

  /// Checks if the booking is in progress
  bool get isInProgress {
    final now = DateTime.now();
    return status == BookingStatus.inProgress ||
        (status == BookingStatus.confirmed &&
            bookingDate.isBefore(now) &&
            bookingDate.add(const Duration(hours: 4)).isAfter(now));
  }

  /// Checks if the booking is completed
  bool get isCompleted => status == BookingStatus.completed;

  /// Checks if the booking is cancelled or rejected
  bool get isCancelledOrRejected =>
      status == BookingStatus.cancelled || status == BookingStatus.rejected;

  @override
  List<Object?> get props => [
        id,
        customerId,
        serviceId,
        bookingDate,
        status,
        createdAt,
      ];

  @override
  String toString() =>
      'Booking(id: $id, service: $serviceName, date: $bookingDate, status: $status)';
}

/// Extension for BookingStatus to get display name
extension BookingStatusDisplayExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.rejected:
        return 'Rejected';
    }
  }
}