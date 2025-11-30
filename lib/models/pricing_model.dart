// lib/models/pricing_model.dart
import 'package:equatable/equatable.dart';

/// Represents different service types with their base pricing
enum ServiceType {
  regularCleaning('Regular Cleaning', 80.0),
  deepCleaning('Deep Cleaning', 150.0),
  windowCleaning('Window Cleaning', 120.0),
  carpetCleaning('Carpet Cleaning', 100.0),
  kitchenCleaning('Kitchen Cleaning', 90.0),
  bathroomCleaning('Bathroom Cleaning', 70.0),
  moveInOutCleaning('Move In/Out Cleaning', 200.0),
  postConstruction('Post-Construction', 250.0);

  const ServiceType(this.displayName, this.basePrice);
  final String displayName;
  final double basePrice;
}

/// Represents property size with pricing multipliers
enum PropertySize {
  small('Small (1-2 rooms)', 1.0),
  medium('Medium (3-4 rooms)', 1.5),
  large('Large (5-6 rooms)', 2.0),
  extraLarge('Extra Large (7+ rooms)', 2.5);

  const PropertySize(this.displayName, this.multiplier);
  final String displayName;
  final double multiplier;
}

/// Represents booking frequency with discount multipliers
enum BookingFrequency {
  oneTime('One-time', 1.0),
  weekly('Weekly', 0.9), // 10% discount
  biWeekly('Bi-weekly', 0.85), // 15% discount
  monthly('Monthly', 0.8); // 20% discount

  const BookingFrequency(this.displayName, this.discountMultiplier);
  final String displayName;
  final double discountMultiplier;
}

/// Represents additional services with their pricing
enum AddOnService {
  fridgeCleaning('Fridge Cleaning', 25.0),
  ovenCleaning('Oven Cleaning', 40.0),
  cabinetCleaning('Cabinet Cleaning', 35.0),
  balconyCleaning('Balcony Cleaning', 30.0),
  garageCleaning('Garage Cleaning', 50.0),
  basementCleaning('Basement Cleaning', 60.0),
  wallWashing('Wall Washing', 45.0),
  furnitureCleaning('Furniture Cleaning', 20.0);

  const AddOnService(this.displayName, this.price);
  final String displayName;
  final double price;
}

/// Represents a complete pricing calculation
class PriceQuote extends Equatable {
  final ServiceType serviceType;
  final PropertySize propertySize;
  final BookingFrequency frequency;
  final List<AddOnService> addOns;
  final double basePrice;
  final double sizeMultiplier;
  final double frequencyDiscount;
  final double addOnsTotal;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double totalPrice;
  final DateTime estimatedDuration;
  final DateTime createdAt;

  const PriceQuote({
    required this.serviceType,
    required this.propertySize,
    required this.frequency,
    required this.addOns,
    required this.basePrice,
    required this.sizeMultiplier,
    required this.frequencyDiscount,
    required this.addOnsTotal,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.totalPrice,
    required this.estimatedDuration,
    required this.createdAt,
  });

  /// Creates a price quote from service selections
  factory PriceQuote.calculate({
    required ServiceType serviceType,
    required PropertySize propertySize,
    required BookingFrequency frequency,
    List<AddOnService> addOns = const [],
    DateTime? estimatedDuration,
  }) {
    final basePrice = serviceType.basePrice;
    final sizeMultiplier = propertySize.multiplier;
    final frequencyDiscount = frequency.discountMultiplier;
    
    // Calculate add-ons total
    final addOnsTotal = addOns.fold<double>(0.0, (sum, addOn) => sum + addOn.price);
    
    // Calculate subtotal: (base price * size multiplier) + add-ons
    final subtotal = (basePrice * sizeMultiplier) + addOnsTotal;
    
    // Apply frequency discount
    final discountedSubtotal = subtotal * frequencyDiscount;
    
    // Calculate tax (8.5% tax rate)
    const taxRate = 0.085;
    final taxAmount = discountedSubtotal * taxRate;
    
    // Calculate final total
    final totalPrice = discountedSubtotal + taxAmount;
    
    // Estimate duration (2 hours for small, +30min per size level, +15min per add-on)
    final baseDuration = Duration(hours: 2);
    final sizeExtraDuration = Duration(minutes: 30 * (propertySize.index));
    final addOnsDuration = Duration(minutes: 15 * addOns.length);
    final totalDuration = baseDuration + sizeExtraDuration + addOnsDuration;
    
    final now = DateTime.now();
    final estimatedServiceDuration = now.add(totalDuration);

    return PriceQuote(
      serviceType: serviceType,
      propertySize: propertySize,
      frequency: frequency,
      addOns: addOns,
      basePrice: basePrice,
      sizeMultiplier: sizeMultiplier,
      frequencyDiscount: frequencyDiscount,
      addOnsTotal: addOnsTotal,
      subtotal: subtotal,
      taxRate: taxRate,
      taxAmount: taxAmount,
      totalPrice: totalPrice,
      estimatedDuration: estimatedServiceDuration,
      createdAt: now,
    );
  }

  /// Creates a price quote from JSON
  factory PriceQuote.fromJson(Map<String, dynamic> json) {
    return PriceQuote(
      serviceType: ServiceType.values.firstWhere(
        (e) => e.name == json['serviceType'],
        orElse: () => ServiceType.regularCleaning,
      ),
      propertySize: PropertySize.values.firstWhere(
        (e) => e.name == json['propertySize'],
        orElse: () => PropertySize.medium,
      ),
      frequency: BookingFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => BookingFrequency.oneTime,
      ),
      addOns: (json['addOns'] as List<dynamic>?)
          ?.map((e) => AddOnService.values.firstWhere(
                (service) => service.name == e,
                orElse: () => AddOnService.fridgeCleaning,
              ))
          .toList() ?? [],
      basePrice: (json['basePrice'] as num).toDouble(),
      sizeMultiplier: (json['sizeMultiplier'] as num).toDouble(),
      frequencyDiscount: (json['frequencyDiscount'] as num).toDouble(),
      addOnsTotal: (json['addOnsTotal'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxRate: (json['taxRate'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      estimatedDuration: DateTime.parse(json['estimatedDuration'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts price quote to JSON
  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType.name,
      'propertySize': propertySize.name,
      'frequency': frequency.name,
      'addOns': addOns.map((e) => e.name).toList(),
      'basePrice': basePrice,
      'sizeMultiplier': sizeMultiplier,
      'frequencyDiscount': frequencyDiscount,
      'addOnsTotal': addOnsTotal,
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'totalPrice': totalPrice,
      'estimatedDuration': estimatedDuration.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Gets the estimated duration in hours
  double get estimatedHours => estimatedDuration.difference(createdAt).inMinutes / 60.0;

  /// Gets the discount amount
  double get discountAmount => (subtotal * (1 - frequencyDiscount));

  /// Gets the formatted price strings
  String get formattedBasePrice => '\$${basePrice.toStringAsFixed(2)}';
  String get formattedSubtotal => '\$${subtotal.toStringAsFixed(2)}';
  String get formattedTaxAmount => '\$${taxAmount.toStringAsFixed(2)}';
  String get formattedTotalPrice => '\$${totalPrice.toStringAsFixed(2)}';
  String get formattedDiscount => '\$${discountAmount.toStringAsFixed(2)}';
  String get formattedAddOnsTotal => '\$${addOnsTotal.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
        serviceType,
        propertySize,
        frequency,
        addOns,
        basePrice,
        sizeMultiplier,
        frequencyDiscount,
        addOnsTotal,
        subtotal,
        taxRate,
        taxAmount,
        totalPrice,
        estimatedDuration,
        createdAt,
      ];
}

/// Represents a fixed-price quote for a booking request
class Quote extends Equatable {
  final String id;
  final double basePrice;
  final List<QuoteOption> availableOptions;
  final DateTime validUntil;
  final Map<String, dynamic> breakdown;
  final String? notes;

  const Quote({
    required this.id,
    required this.basePrice,
    required this.availableOptions,
    required this.validUntil,
    required this.breakdown,
    this.notes,
  });

  /// Creates a Quote from JSON data
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      availableOptions: (json['availableOptions'] as List<dynamic>?)
          ?.map((option) => QuoteOption.fromJson(option))
          .toList() ?? [],
      validUntil: DateTime.parse(json['validUntil'] as String),
      breakdown: Map<String, dynamic>.from(json['breakdown'] as Map? ?? {}),
      notes: json['notes'] as String?,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'basePrice': basePrice,
      'availableOptions': availableOptions.map((option) => option.toJson()).toList(),
      'validUntil': validUntil.toIso8601String(),
      'breakdown': breakdown,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [id, basePrice, availableOptions, validUntil, breakdown, notes];
}

/// Represents an optional quote variant
class QuoteOption extends Equatable {
  final String id;
  final String name;
  final String description;
  final double totalPrice;
  final List<String> features;
  final String? savingsText;

  const QuoteOption({
    required this.id,
    required this.name,
    required this.description,
    required this.totalPrice,
    required this.features,
    this.savingsText,
  });

  /// Creates a QuoteOption from JSON data
  factory QuoteOption.fromJson(Map<String, dynamic> json) {
    return QuoteOption(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      features: (json['features'] as List<dynamic>?)?.cast<String>() ?? [],
      savingsText: json['savingsText'] as String?,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'totalPrice': totalPrice,
      'features': features,
      'savingsText': savingsText,
    };
  }

  @override
  List<Object?> get props => [id, name, description, totalPrice, features, savingsText];
}
