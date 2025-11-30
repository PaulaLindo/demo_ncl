// lib/models/service_model.dart
import 'package:equatable/equatable.dart';

/// Represents a service add-on option
class ServiceAddon extends Equatable {
  final String id;
  final String name;
  final double price;
  final String? description;

  const ServiceAddon({
    required this.id,
    required this.name,
    required this.price,
    this.description,
  });

  /// Creates a ServiceAddon from JSON data
  factory ServiceAddon.fromJson(Map<String, dynamic> json) {
    return ServiceAddon(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [id, name, price, description];
}

/// Represents a service offered by the company
class Service extends Equatable {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final String pricingUnit;
  final String? duration;
  final String category;
  final String? imageUrl;
  final bool allowQuantity;
  final bool isPopular;
  final bool isFeatured;
  final double rating;
  final int reviewCount;
  final List<String> features;
  final List<ServiceAddon> availableAddons;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    this.pricingUnit = 'service',
    this.duration,
    required this.category,
    this.imageUrl,
    this.allowQuantity = false,
    this.isPopular = false,
    this.isFeatured = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.features = const [],
    this.availableAddons = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  })  : assert(basePrice >= 0, 'Price cannot be negative'),
        assert(rating >= 0 && rating <= 5, 'Rating must be between 0 and 5'),
        assert(reviewCount >= 0, 'Review count cannot be negative');

  /// Creates a Service from JSON data
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      pricingUnit: json['pricingUnit'] as String? ?? 'service',
      duration: json['duration'] as String?,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      allowQuantity: json['allowQuantity'] as bool? ?? false,
      isPopular: json['isPopular'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      features: (json['features'] as List<dynamic>?)?.cast<String>() ?? [],
      availableAddons: (json['availableAddons'] as List<dynamic>?)
          ?.map((addon) => ServiceAddon.fromJson(addon))
          .toList() ?? [],
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'pricingUnit': pricingUnit,
      'duration': duration,
      'category': category,
      'imageUrl': imageUrl,
      'allowQuantity': allowQuantity,
      'isPopular': isPopular,
      'isFeatured': isFeatured,
      'rating': rating,
      'reviewCount': reviewCount,
      'features': features,
      'availableAddons': availableAddons.map((addon) => addon.toJson()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy with updated values
  Service copyWith({
    String? id,
    String? name,
    String? description,
    double? basePrice,
    String? pricingUnit,
    String? duration,
    String? category,
    String? imageUrl,
    bool? allowQuantity,
    bool? isPopular,
    bool? isFeatured,
    double? rating,
    int? reviewCount,
    List<String>? features,
    List<ServiceAddon>? availableAddons,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      pricingUnit: pricingUnit ?? this.pricingUnit,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      allowQuantity: allowQuantity ?? this.allowQuantity,
      isPopular: isPopular ?? this.isPopular,
      isFeatured: isFeatured ?? this.isFeatured,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      features: features ?? this.features,
      availableAddons: availableAddons ?? this.availableAddons,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted price display
  String get priceDisplay {
    if (pricingUnit == 'hour') {
      return '\$${basePrice.toStringAsFixed(0)}/hr';
    }
    return 'From \$${basePrice.toStringAsFixed(0)}';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        basePrice,
        pricingUnit,
        duration,
        category,
        imageUrl,
        allowQuantity,
        isPopular,
        isFeatured,
        rating,
        reviewCount,
        features,
        availableAddons,
        isActive,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Service(id: $id, name: $name, basePrice: $basePrice)';
  }
}