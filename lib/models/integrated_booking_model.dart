// lib/models/integrated_booking_model.dart
import 'package:equatable/equatable.dart';

/// Represents an integrated booking with multiple service types
class IntegratedBooking extends Equatable {
  final String id;
  final String customerId;
  final List<Service> services;
  final List<ServiceAddon> selectedAddOns;
  final ServiceBundle? selectedBundle;
  final DateTime preferredDate;
  final TimeOfDay preferredTime;
  final PropertySize propertySize;
  final ServiceFrequency frequency;
  final double totalPrice;
  final Duration totalDuration;
  final BookingStatus status;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IntegratedBooking({
    required this.id,
    required this.customerId,
    required this.services,
    this.selectedAddOns = const [],
    this.selectedBundle,
    required this.preferredDate,
    required this.preferredTime,
    required this.propertySize,
    required this.frequency,
    required this.totalPrice,
    required this.totalDuration,
    required this.status,
    this.transactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates IntegratedBooking from JSON
  factory IntegratedBooking.fromJson(Map<String, dynamic> json) {
    return IntegratedBooking(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      services: (json['services'] as List<dynamic>?)
          ?.map((service) => Service.fromJson(service as Map<String, dynamic>))
          .toList() ?? [],
      selectedAddOns: (json['selectedAddOns'] as List<dynamic>?)
          ?.map((addon) => ServiceAddon.fromJson(addon as Map<String, dynamic>))
          .toList() ?? [],
      selectedBundle: json['selectedBundle'] != null
          ? ServiceBundle.fromJson(json['selectedBundle'] as Map<String, dynamic>)
          : null,
      preferredDate: DateTime.parse(json['preferredDate'] as String),
      preferredTime: TimeOfDay.fromJson(json['preferredTime'] as Map<String, dynamic>),
      propertySize: PropertySize.values.firstWhere(
        (size) => size.name == json['propertySize'],
        orElse: () => PropertySize.oneBedroom,
      ),
      frequency: ServiceFrequency.values.firstWhere(
        (freq) => freq.name == json['frequency'],
        orElse: () => ServiceFrequency.oneTime,
      ),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      totalDuration: Duration(milliseconds: json['totalDuration'] as int),
      status: BookingStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      transactionId: json['transactionId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'services': services.map((service) => service.toJson()).toList(),
      'selectedAddOns': selectedAddOns.map((addon) => addon.toJson()).toList(),
      'selectedBundle': selectedBundle?.toJson(),
      'preferredDate': preferredDate.toIso8601String(),
      'preferredTime': preferredTime.toJson(),
      'propertySize': propertySize.name,
      'frequency': frequency.name,
      'totalPrice': totalPrice,
      'totalDuration': totalDuration.inMilliseconds,
      'status': status.name,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Gets core services
  List<Service> get coreServices => 
      services.where((service) => service.category == ServiceCategory.core).toList();

  /// Gets expansion services
  List<Service> get expansionServices => 
      services.where((service) => service.category == ServiceCategory.homeCare).toList();

  /// Gets specialty services
  List<Service> get specialtyServices => 
      services.where((service) => service.category == ServiceCategory.specialty).toList();

  /// Checks if booking has multiple service categories
  bool get hasMultipleCategories {
    final categories = services.map((s) => s.category).toSet();
    return categories.length > 1;
  }

  /// Gets service category breakdown
  Map<ServiceCategory, List<Service>> get servicesByCategory {
    final Map<ServiceCategory, List<Service>> categorized = {};
    for (final service in services) {
      categorized.putIfAbsent(service.category, () => []).add(service);
    }
    return categorized;
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        services,
        selectedAddOns,
        selectedBundle,
        preferredDate,
        preferredTime,
        propertySize,
        frequency,
        totalPrice,
        totalDuration,
        status,
        transactionId,
        createdAt,
        updatedAt,
      ];
}

/// Service model for integrated booking
class Service extends Equatable {
  final String id;
  final String name;
  final String description;
  final ServiceCategory category;
  final double basePrice;
  final Duration duration;
  final bool isRequired;
  final int maxQuantity;
  final bool isAvailable;
  final List<String>? incompatibleServices;
  final List<ServiceAddon>? availableAddOns;
  final List<ServiceDiscount>? availableDiscounts;
  final List<ServiceTier>? availableTiers;
  final Map<ServiceFrequency, double>? frequencyDiscounts;
  final Map<PropertySize, double>? propertySizeMultipliers;
  final Map<Season, double>? seasonalAdjustments;

  const Service({
    required this.id,
    required this.name,
    this.description = '',
    required this.category,
    required this.basePrice,
    required this.duration,
    this.isRequired = false,
    this.maxQuantity = 1,
    this.isAvailable = true,
    this.incompatibleServices,
    this.availableAddOns,
    this.availableDiscounts,
    this.availableTiers,
    this.frequencyDiscounts,
    this.propertySizeMultipliers,
    this.seasonalAdjustments,
  });

  /// Creates Service from JSON
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: ServiceCategory.values.firstWhere(
        (cat) => cat.name == json['category'],
        orElse: () => ServiceCategory.core,
      ),
      basePrice: (json['basePrice'] as num).toDouble(),
      duration: Duration(milliseconds: json['duration'] as int? ?? 7200000), // Default 2 hours
      isRequired: json['isRequired'] as bool? ?? false,
      maxQuantity: json['maxQuantity'] as int? ?? 1,
      isAvailable: json['isAvailable'] as bool? ?? true,
      incompatibleServices: (json['incompatibleServices'] as List<dynamic>?)
          ?.map((s) => s as String).toList(),
      availableAddOns: (json['availableAddOns'] as List<dynamic>?)
          ?.map((addon) => ServiceAddon.fromJson(addon as Map<String, dynamic>))
          .toList(),
      availableDiscounts: (json['availableDiscounts'] as List<dynamic>?)
          ?.map((discount) => ServiceDiscount.fromJson(discount as Map<String, dynamic>))
          .toList(),
      availableTiers: (json['availableTiers'] as List<dynamic>?)
          ?.map((tier) => ServiceTier.fromJson(tier as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'basePrice': basePrice,
      'duration': duration.inMilliseconds,
      'isRequired': isRequired,
      'maxQuantity': maxQuantity,
      'isAvailable': isAvailable,
      'incompatibleServices': incompatibleServices,
      'availableAddOns': availableAddOns?.map((addon) => addon.toJson()).toList(),
      'availableDiscounts': availableDiscounts?.map((discount) => discount.toJson()).toList(),
      'availableTiers': availableTiers?.map((tier) => tier.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        basePrice,
        duration,
        isRequired,
        maxQuantity,
        isAvailable,
        incompatibleServices,
        availableAddOns,
        availableDiscounts,
        availableTiers,
      ];
}

/// Service addon model
class ServiceAddon extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> applicableServices;
  final bool isQuantityBased;
  final int maxQuantity;
  final Duration additionalDuration;

  const ServiceAddon({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.applicableServices,
    this.isQuantityBased = false,
    this.maxQuantity = 1,
    this.additionalDuration = Duration.zero,
  });

  /// Creates ServiceAddon from JSON
  factory ServiceAddon.fromJson(Map<String, dynamic> json) {
    return ServiceAddon(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      applicableServices: (json['applicableServices'] as List<dynamic>)
          .map((s) => s as String).toList(),
      isQuantityBased: json['isQuantityBased'] as bool? ?? false,
      maxQuantity: json['maxQuantity'] as int? ?? 1,
      additionalDuration: Duration(
        milliseconds: json['additionalDuration'] as int? ?? 0,
      ),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'applicableServices': applicableServices,
      'isQuantityBased': isQuantityBased,
      'maxQuantity': maxQuantity,
      'additionalDuration': additionalDuration.inMilliseconds,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        applicableServices,
        isQuantityBased,
        maxQuantity,
        additionalDuration,
      ];
}

/// Service bundle model
class ServiceBundle extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<String> services;
  final double bundlePrice;
  final double savings;
  final bool isActive;

  const ServiceBundle({
    required this.id,
    required this.name,
    this.description = '',
    required this.services,
    required this.bundlePrice,
    this.savings = 0.0,
    this.isActive = true,
  });

  /// Creates ServiceBundle from JSON
  factory ServiceBundle.fromJson(Map<String, dynamic> json) {
    return ServiceBundle(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      services: (json['services'] as List<dynamic>)
          .map((s) => s as String).toList(),
      bundlePrice: (json['bundlePrice'] as num).toDouble(),
      savings: (json['savings'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'services': services,
      'bundlePrice': bundlePrice,
      'savings': savings,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        services,
        bundlePrice,
        savings,
        isActive,
      ];
}

/// Service discount model
class ServiceDiscount extends Equatable {
  final String id;
  final String name;
  final String description;
  final DiscountType type;
  final double discountAmount;
  final List<String> conditions;
  final bool isActive;

  const ServiceDiscount({
    required this.id,
    required this.name,
    this.description = '',
    required this.type,
    required this.discountAmount,
    required this.conditions,
    this.isActive = true,
  });

  /// Creates ServiceDiscount from JSON
  factory ServiceDiscount.fromJson(Map<String, dynamic> json) {
    return ServiceDiscount(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      type: DiscountType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => DiscountType.percentage,
      ),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      conditions: (json['conditions'] as List<dynamic>)
          .map((c) => c as String).toList(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'discountAmount': discountAmount,
      'conditions': conditions,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        discountAmount,
        conditions,
        isActive,
      ];
}

/// Service tier model
class ServiceTier extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> features;
  final bool isActive;

  const ServiceTier({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.features,
    this.isActive = true,
  });

  /// Creates ServiceTier from JSON
  factory ServiceTier.fromJson(Map<String, dynamic> json) {
    return ServiceTier(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      features: (json['features'] as List<dynamic>)
          .map((f) => f as String).toList(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'features': features,
      'isActive': isActive,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        features,
        isActive,
      ];
}

/// Time of day model
class TimeOfDay extends Equatable {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  /// Creates TimeOfDay from JSON
  factory TimeOfDay.fromJson(Map<String, dynamic> json) {
    return TimeOfDay(
      hour: json['hour'] as int,
      minute: json['minute'] as int,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  @override
  List<Object?> get props => [hour, minute];
}

/// Enums
enum ServiceCategory {
  core('Core Cleaning'),
  homeCare('Home Care Expansion'),
  specialty('Specialty Services');

  const ServiceCategory(this.displayName);
  final String displayName;
}

enum BookingStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  completed('Completed'),
  cancelled('Cancelled');

  const BookingStatus(this.displayName);
  final String displayName;
}

enum DiscountType {
  percentage('Percentage'),
  fixed('Fixed Amount'),
  bundle('Bundle Discount');

  const DiscountType(this.displayName);
  final String displayName;
}

enum ServiceFrequency {
  oneTime('One Time'),
  weekly('Weekly'),
  biWeekly('Bi-Weekly'),
  monthly('Monthly');

  const ServiceFrequency(this.displayName);
  final String displayName;
}

enum PropertySize {
  studio('Studio'),
  oneBedroom('1 Bedroom'),
  twoBedroom('2 Bedrooms'),
  threeBedroom('3 Bedrooms'),
  fourPlusBedroom('4+ Bedrooms');

  const PropertySize(this.displayName);
  final String displayName;
}

enum Season {
  winter('Winter'),
  spring('Spring'),
  summer('Summer'),
  fall('Fall');

  const Season(this.displayName);
  final String displayName;
}
