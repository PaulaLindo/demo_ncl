// lib/models/service_customization_model.dart
import 'package:equatable/equatable.dart';

/// Represents optional service that can be added to base service
class OptionalService extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final OptionalServiceCategory category;
  final bool isQuantityBased;
  final int maxQuantity;
  final Duration additionalDuration;
  final List<String>? incompatibleServices;
  final List<String>? prerequisites;

  const OptionalService({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.category,
    this.isQuantityBased = false,
    this.maxQuantity = 1,
    this.additionalDuration = Duration.zero,
    this.incompatibleServices,
    this.prerequisites,
  });

  /// Creates OptionalService from JSON
  factory OptionalService.fromJson(Map<String, dynamic> json) {
    return OptionalService(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      category: OptionalServiceCategory.values.firstWhere(
        (cat) => cat.name == json['category'],
        orElse: () => OptionalServiceCategory.window,
      ),
      isQuantityBased: json['isQuantityBased'] as bool? ?? false,
      maxQuantity: json['maxQuantity'] as int? ?? 1,
      additionalDuration: Duration(
        milliseconds: json['additionalDuration'] as int? ?? 0,
      ),
      incompatibleServices: (json['incompatibleServices'] as List<dynamic>?)
          ?.map((s) => s as String).toList(),
      prerequisites: (json['prerequisites'] as List<dynamic>?)
          ?.map((p) => p as String).toList(),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category.name,
      'isQuantityBased': isQuantityBased,
      'maxQuantity': maxQuantity,
      'additionalDuration': additionalDuration.inMilliseconds,
      'incompatibleServices': incompatibleServices,
      'prerequisites': prerequisites,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        category,
        isQuantityBased,
        maxQuantity,
        additionalDuration,
        incompatibleServices,
        prerequisites,
      ];
}

/// Service customization configuration
class ServiceCustomization extends Equatable {
  final String id;
  final String baseServiceId;
  final List<SelectedOptionalService> selectedOptionalServices;
  final ServiceTier? selectedTier;
  final PropertySize propertySize;
  final ServiceFrequency frequency;
  final DateTime bookingDate;
  final Map<String, int> serviceQuantities;
  final List<AppliedDiscount> appliedDiscounts;
  final double totalPrice;
  final Duration totalDuration;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceCustomization({
    required this.id,
    required this.baseServiceId,
    this.selectedOptionalServices = const [],
    this.selectedTier,
    required this.propertySize,
    required this.frequency,
    required this.bookingDate,
    this.serviceQuantities = const {},
    this.appliedDiscounts = const [],
    required this.totalPrice,
    required this.totalDuration,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates ServiceCustomization from JSON
  factory ServiceCustomization.fromJson(Map<String, dynamic> json) {
    return ServiceCustomization(
      id: json['id'] as String,
      baseServiceId: json['baseServiceId'] as String,
      selectedOptionalServices: (json['selectedOptionalServices'] as List<dynamic>?)
          ?.map((service) => SelectedOptionalService.fromJson(service as Map<String, dynamic>))
          .toList() ?? [],
      selectedTier: json['selectedTier'] != null
          ? ServiceTier.fromJson(json['selectedTier'] as Map<String, dynamic>)
          : null,
      propertySize: PropertySize.values.firstWhere(
        (size) => size.name == json['propertySize'],
        orElse: () => PropertySize.oneBedroom,
      ),
      frequency: ServiceFrequency.values.firstWhere(
        (freq) => freq.name == json['frequency'],
        orElse: () => ServiceFrequency.oneTime,
      ),
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      serviceQuantities: Map<String, int>.from(json['serviceQuantities'] as Map? ?? {}),
      appliedDiscounts: (json['appliedDiscounts'] as List<dynamic>?)
          ?.map((discount) => AppliedDiscount.fromJson(discount as Map<String, dynamic>))
          .toList() ?? [],
      totalPrice: (json['totalPrice'] as num).toDouble(),
      totalDuration: Duration(milliseconds: json['totalDuration'] as int),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'baseServiceId': baseServiceId,
      'selectedOptionalServices': selectedOptionalServices.map((s) => s.toJson()).toList(),
      'selectedTier': selectedTier?.toJson(),
      'propertySize': propertySize.name,
      'frequency': frequency.name,
      'bookingDate': bookingDate.toIso8601String(),
      'serviceQuantities': serviceQuantities,
      'appliedDiscounts': appliedDiscounts.map((d) => d.toJson()).toList(),
      'totalPrice': totalPrice,
      'totalDuration': totalDuration.inMilliseconds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Gets total optional services price
  double get optionalServicesPrice => selectedOptionalServices
      .fold(0.0, (total, service) => total + service.totalPrice);

  /// Gets total discount amount
  double get totalDiscountAmount => appliedDiscounts
      .fold(0.0, (total, discount) => total + discount.discountAmount);

  @override
  List<Object?> get props => [
        id,
        baseServiceId,
        selectedOptionalServices,
        selectedTier,
        propertySize,
        frequency,
        bookingDate,
        serviceQuantities,
        appliedDiscounts,
        totalPrice,
        totalDuration,
        createdAt,
        updatedAt,
      ];
}

/// Selected optional service with quantity
class SelectedOptionalService extends Equatable {
  final String optionalServiceId;
  final OptionalService optionalService;
  final int quantity;
  final DateTime selectedAt;

  const SelectedOptionalService({
    required this.optionalServiceId,
    required this.optionalService,
    required this.quantity,
    required this.selectedAt,
  });

  /// Creates SelectedOptionalService from JSON
  factory SelectedOptionalService.fromJson(Map<String, dynamic> json) {
    return SelectedOptionalService(
      optionalServiceId: json['optionalServiceId'] as String,
      optionalService: OptionalService.fromJson(json['optionalService'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      selectedAt: DateTime.parse(json['selectedAt'] as String),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'optionalServiceId': optionalServiceId,
      'optionalService': optionalService.toJson(),
      'quantity': quantity,
      'selectedAt': selectedAt.toIso8601String(),
    };
  }

  /// Gets total price for this selection
  double get totalPrice => optionalService.price * quantity;

  /// Gets total duration for this selection
  Duration get totalDuration => optionalService.additionalDuration * quantity;

  @override
  List<Object?> get props => [
        optionalServiceId,
        optionalService,
        quantity,
        selectedAt,
      ];
}

/// Service tier model
class ServiceTier extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> features;
  final List<String> includedOptionalServices;
  final bool isActive;

  const ServiceTier({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.features,
    this.includedOptionalServices = const [],
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
      includedOptionalServices: (json['includedOptionalServices'] as List<dynamic>?)
          ?.map((s) => s as String).toList() ?? [],
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
      'includedOptionalServices': includedOptionalServices,
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
        includedOptionalServices,
        isActive,
      ];
}

/// Applied discount model
class AppliedDiscount extends Equatable {
  final String discountId;
  final DiscountType type;
  final double discountAmount;
  final String description;
  final DateTime appliedAt;

  const AppliedDiscount({
    required this.discountId,
    required this.type,
    required this.discountAmount,
    required this.description,
    required this.appliedAt,
  });

  /// Creates AppliedDiscount from JSON
  factory AppliedDiscount.fromJson(Map<String, dynamic> json) {
    return AppliedDiscount(
      discountId: json['discountId'] as String,
      type: DiscountType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => DiscountType.percentage,
      ),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      description: json['description'] as String,
      appliedAt: DateTime.parse(json['appliedAt'] as String),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'discountId': discountId,
      'type': type.name,
      'discountAmount': discountAmount,
      'description': description,
      'appliedAt': appliedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        discountId,
        type,
        discountAmount,
        description,
        appliedAt,
      ];
}

/// Price breakdown for customization
class PriceBreakdown extends Equatable {
  final double basePrice;
  final double optionalServicesTotal;
  final double tierPrice;
  final double propertySizeMultiplier;
  final double frequencyDiscount;
  final double seasonalAdjustment;
  final double discountsTotal;
  final double finalPrice;
  final List<OptionalServiceBreakdown> optionalServiceBreakdown;
  final List<AppliedDiscount> appliedDiscounts;

  const PriceBreakdown({
    required this.basePrice,
    required this.optionalServicesTotal,
    required this.tierPrice,
    required this.propertySizeMultiplier,
    required this.frequencyDiscount,
    required this.seasonalAdjustment,
    required this.discountsTotal,
    required this.finalPrice,
    required this.optionalServiceBreakdown,
    this.appliedDiscounts = const [],
  });

  /// Gets subtotal before discounts
  double get subtotal => basePrice + optionalServicesTotal + tierPrice + propertySizeMultiplier + seasonalAdjustment;

  @override
  List<Object?> get props => [
        basePrice,
        optionalServicesTotal,
        tierPrice,
        propertySizeMultiplier,
        frequencyDiscount,
        seasonalAdjustment,
        discountsTotal,
        finalPrice,
        optionalServiceBreakdown,
        appliedDiscounts,
      ];
}

/// Optional service price breakdown
class OptionalServiceBreakdown extends Equatable {
  final SelectedOptionalService selectedService;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final double discountAmount;

  const OptionalServiceBreakdown({
    required this.selectedService,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.discountAmount = 0.0,
  });

  @override
  List<Object?> get props => [
        selectedService,
        unitPrice,
        quantity,
        totalPrice,
        discountAmount,
      ];
}

/// Price change notification
class PriceChangeNotification extends Equatable {
  final double oldPrice;
  final double newPrice;
  final double priceDifference;
  final String? changeReason;
  final DateTime timestamp;

  const PriceChangeNotification({
    required this.oldPrice,
    required this.newPrice,
    required this.priceDifference,
    this.changeReason,
    required this.timestamp,
  });

  /// Gets price change percentage
  double get percentageChange => oldPrice != 0 ? (priceDifference / oldPrice) * 100 : 0.0;

  @override
  List<Object?> get props => [
        oldPrice,
        newPrice,
        priceDifference,
        changeReason,
        timestamp,
      ];
}

/// Customization validation result
class CustomizationValidation extends Equatable {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final List<ValidationIssue> issues;

  const CustomizationValidation({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    this.issues = const [],
  });

  @override
  List<Object?> get props => [isValid, errors, warnings, issues];
}

/// Individual validation issue
class ValidationIssue extends Equatable {
  final String field;
  final String message;
  final ValidationSeverity severity;

  const ValidationIssue({
    required this.field,
    required this.message,
    required this.severity,
  });

  @override
  List<Object?> get props => [field, message, severity];
}

/// Required customization field
class RequiredCustomization extends Equatable {
  final String id;
  final String name;
  final CustomizationType type;
  final bool isRequired;
  final String? description;
  final List<String>? options;

  const RequiredCustomization({
    required this.id,
    required this.name,
    required this.type,
    required this.isRequired,
    this.description,
    this.options,
  });

  @override
  List<Object?> get props => [id, name, type, isRequired, description, options];
}

/// Booking summary with customization details
class BookingSummary extends Equatable {
  final Service baseService;
  final List<SelectedOptionalService> selectedOptionalServices;
  final ServiceTier? selectedTier;
  final PropertySize propertySize;
  final ServiceFrequency frequency;
  final DateTime bookingDate;
  final double totalPrice;
  final Duration totalDuration;
  final List<AppliedDiscount> appliedDiscounts;

  const BookingSummary({
    required this.baseService,
    required this.selectedOptionalServices,
    this.selectedTier,
    required this.propertySize,
    required this.frequency,
    required this.bookingDate,
    required this.totalPrice,
    required this.totalDuration,
    this.appliedDiscounts = const [],
  });

  @override
  List<Object?> get props => [
        baseService,
        selectedOptionalServices,
        selectedTier,
        propertySize,
        frequency,
        bookingDate,
        totalPrice,
        totalDuration,
        appliedDiscounts,
      ];
}

/// Enums
enum OptionalServiceCategory {
  window('Window Services'),
  kitchen('Kitchen Services'),
  flooring('Flooring Services'),
  room('Room Services'),
  bathroom('Bathroom Services'),
  outdoor('Outdoor Services'),
  specialty('Specialty Services');

  const OptionalServiceCategory(this.displayName);
  final String displayName;
}

enum DiscountType {
  percentage('Percentage'),
  fixed('Fixed Amount'),
  bundle('Bundle Discount'),
  quantity('Quantity Discount');

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

enum CustomizationType {
  propertySize('Property Size'),
  frequency('Service Frequency'),
  tier('Service Tier'),
  quantity('Service Quantity');

  const CustomizationType(this.displayName);
  final String displayName;
}

enum ValidationSeverity {
  error('Error'),
  warning('Warning'),
  info('Info');

  const ValidationSeverity(this.displayName);
  final String displayName;
}
