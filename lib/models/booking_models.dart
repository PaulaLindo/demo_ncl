// lib/models/booking_models.dart

/// Booking status enum
enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

/// Extension for BookingStatus display name
extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Booking model - matches bookings_screen requirements
class Booking {
  final String id;
  final String serviceId;
  final String serviceName;
  final DateTime bookingDate;
  final String preferredTime; // 'morning', 'afternoon', 'flexible'
  final String address;
  final BookingStatus status;
  final double estimatedPrice;
  final String propertySize; // 'small', 'medium', 'large'
  final String frequency; // 'one-time', 'weekly', 'bi-weekly', 'monthly'
  final String? specialInstructions;
  final String? assignedStaffName;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.bookingDate,
    required this.preferredTime,
    required this.address,
    required this.status,
    required this.estimatedPrice,
    required this.propertySize,
    required this.frequency,
    this.specialInstructions,
    this.assignedStaffName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if booking is upcoming
  bool get isUpcoming {
    return status == BookingStatus.confirmed || status == BookingStatus.pending;
  }

  /// Check if booking is completed
  bool get isCompleted {
    return status == BookingStatus.completed;
  }

  // Copy with method for updates
  Booking copyWith({
    String? id,
    String? serviceId,
    String? serviceName,
    DateTime? bookingDate,
    String? preferredTime,
    String? address,
    BookingStatus? status,
    double? estimatedPrice,
    String? propertySize,
    String? frequency,
    String? specialInstructions,
    String? assignedStaffName,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      bookingDate: bookingDate ?? this.bookingDate,
      preferredTime: preferredTime ?? this.preferredTime,
      address: address ?? this.address,
      status: status ?? this.status,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      propertySize: propertySize ?? this.propertySize,
      frequency: frequency ?? this.frequency,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Service Detail model for services screen
class ServiceDetail {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final String duration;
  final List<String> features;
  final String category; // 'cleaning', 'garden', 'care'
  final String? imageUrl;
  final bool isHourly;
  final bool isPopular;
  final bool isFeatured;
  final double rating;
  final int reviewCount;

  ServiceDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.duration,
    required this.features,
    required this.category,
    this.imageUrl,
    this.isHourly = false,
    this.isPopular = false,
    this.isFeatured = false,
    this.rating = 4.5,
    this.reviewCount = 0,
  });

  /// Get formatted price display
  String get priceDisplay {
    if (isHourly) {
      return 'R${basePrice.toStringAsFixed(0)}/hr';
    }
    return 'From R${basePrice.toStringAsFixed(0)}';
  }
}

/// Mock service data
final List<ServiceDetail> mockServices = [
  ServiceDetail(
    id: 'S01',
    name: 'Standard Cleaning',
    description: 'Weekly maintenance cleaning for your home',
    basePrice: 280,
    duration: '2-3 hours',
    category: 'cleaning',
    features: [
      'Dusting and wiping surfaces',
      'Vacuum and mop floors',
      'Bathroom cleaning',
      'Kitchen cleaning',
    ],
    isHourly: false,
    isPopular: true,
    isFeatured: false,
    rating: 4.7,
    reviewCount: 143,
  ),
  ServiceDetail(
    id: 'S02',
    name: 'Deep Cleaning',
    description: 'Comprehensive seasonal deep cleaning service',
    basePrice: 600,
    duration: '4-6 hours',
    category: 'cleaning',
    features: [
      'Complete home sanitization',
      'Behind furniture cleaning',
      'Window cleaning',
      'Appliance cleaning',
      'Detailed bathroom scrubbing',
    ],
    isHourly: false,
    isPopular: false,
    isFeatured: true,
    rating: 4.9,
    reviewCount: 87,
  ),
  ServiceDetail(
    id: 'S03',
    name: 'Elderly Care Support',
    description: 'Non-medical home assistance and companionship',
    basePrice: 150,
    duration: 'Flexible',
    category: 'care',
    features: [
      'Light housekeeping',
      'Meal preparation',
      'Companionship',
      'Shopping assistance',
    ],
    isHourly: true,
    isPopular: true,
    isFeatured: false,
    rating: 4.8,
    reviewCount: 56,
  ),
  ServiceDetail(
    id: 'S04',
    name: 'Garden Maintenance',
    description: 'Professional garden care and landscaping',
    basePrice: 350,
    duration: '3-4 hours',
    category: 'garden',
    features: [
      'Lawn mowing',
      'Hedge trimming',
      'Weeding',
      'Garden cleanup',
    ],
    isHourly: false,
    isPopular: false,
    isFeatured: false,
    rating: 4.6,
    reviewCount: 34,
  ),
];