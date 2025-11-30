// lib/models/loyalty_model.dart
import 'package:equatable/equatable.dart';

/// Represents a customer's loyalty status and points
class LoyaltyAccount extends Equatable {
  final String customerId;
  final int totalPoints;
  final int availablePoints;
  final int pointsEarned;
  final int pointsRedeemed;
  final LoyaltyTier currentTier;
  final DateTime? lastActivity;
  final List<LoyaltyTransaction> transactions;
  final List<LoyaltyReward> availableRewards;

  const LoyaltyAccount({
    required this.customerId,
    required this.totalPoints,
    required this.availablePoints,
    required this.pointsEarned,
    required this.pointsRedeemed,
    required this.currentTier,
    this.lastActivity,
    required this.transactions,
    required this.availableRewards,
  });

  /// Creates a LoyaltyAccount from JSON data
  factory LoyaltyAccount.fromJson(Map<String, dynamic> json) {
    return LoyaltyAccount(
      customerId: json['customerId'] as String,
      totalPoints: json['totalPoints'] as int,
      availablePoints: json['availablePoints'] as int,
      pointsEarned: json['pointsEarned'] as int,
      pointsRedeemed: json['pointsRedeemed'] as int,
      currentTier: LoyaltyTier.values.firstWhere(
        (tier) => tier.name == json['currentTier'],
        orElse: () => LoyaltyTier.bronze,
      ),
      lastActivity: json['lastActivity'] != null
          ? DateTime.parse(json['lastActivity'] as String)
          : null,
      transactions: (json['transactions'] as List<dynamic>?)
          ?.map((t) => LoyaltyTransaction.fromJson(t))
          .toList() ?? [],
      availableRewards: (json['availableRewards'] as List<dynamic>?)
          ?.map((r) => LoyaltyReward.fromJson(r))
          .toList() ?? [],
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'totalPoints': totalPoints,
      'availablePoints': availablePoints,
      'pointsEarned': pointsEarned,
      'pointsRedeemed': pointsRedeemed,
      'currentTier': currentTier.name,
      'lastActivity': lastActivity?.toIso8601String(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'availableRewards': availableRewards.map((r) => r.toJson()).toList(),
    };
  }

  /// Gets points needed for next tier
  int get pointsToNextTier {
    switch (currentTier) {
      case LoyaltyTier.bronze:
        return 1000 - totalPoints;
      case LoyaltyTier.silver:
        return 2500 - totalPoints;
      case LoyaltyTier.gold:
        return 5000 - totalPoints;
      case LoyaltyTier.platinum:
        return 0; // Already at highest tier
    }
  }

  /// Gets progress to next tier (0.0 to 1.0)
  double get progressToNextTier {
    switch (currentTier) {
      case LoyaltyTier.bronze:
        return (totalPoints / 1000).clamp(0.0, 1.0);
      case LoyaltyTier.silver:
        return ((totalPoints - 1000) / 1500).clamp(0.0, 1.0);
      case LoyaltyTier.gold:
        return ((totalPoints - 2500) / 2500).clamp(0.0, 1.0);
      case LoyaltyTier.platinum:
        return 1.0;
    }
  }

  @override
  List<Object?> get props => [
        customerId,
        totalPoints,
        availablePoints,
        pointsEarned,
        pointsRedeemed,
        currentTier,
        lastActivity,
        transactions,
        availableRewards,
      ];
}

/// Represents loyalty tiers
enum LoyaltyTier {
  bronze('Bronze', 0, 1.0),
  silver('Silver', 1000, 1.1),
  gold('Gold', 2500, 1.15),
  platinum('Platinum', 5000, 1.2);

  const LoyaltyTier(this.displayName, this.requiredPoints, this.pointsMultiplier);
  final String displayName;
  final int requiredPoints;
  final double pointsMultiplier;
}

/// Represents a loyalty transaction
class LoyaltyTransaction extends Equatable {
  final String id;
  final String customerId;
  final int points;
  final LoyaltyTransactionType type;
  final String? source;
  final String? bookingId;
  final String? description;
  final DateTime createdAt;

  const LoyaltyTransaction({
    required this.id,
    required this.customerId,
    required this.points,
    required this.type,
    this.source,
    this.bookingId,
    this.description,
    required this.createdAt,
  });

  /// Creates a LoyaltyTransaction from JSON data
  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      points: json['points'] as int,
      type: LoyaltyTransactionType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => LoyaltyTransactionType.earned,
      ),
      source: json['source'] as String?,
      bookingId: json['bookingId'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'points': points,
      'type': type.name,
      'source': source,
      'bookingId': bookingId,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Gets the display text for points
  String get pointsDisplay {
    final prefix = type == LoyaltyTransactionType.earned ? '+' : '-';
    return '$prefix${points.abs()} points';
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        points,
        type,
        source,
        bookingId,
        description,
        createdAt,
      ];
}

/// Represents types of loyalty transactions
enum LoyaltyTransactionType {
  earned,
  redeemed,
  expired,
  adjusted,
}

/// Represents a loyalty reward
class LoyaltyReward extends Equatable {
  final String id;
  final String name;
  final String description;
  final int pointsCost;
  final String type;
  final bool isAvailable;
  final DateTime? validUntil;
  final Map<String, dynamic> rewardData;

  const LoyaltyReward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsCost,
    required this.type,
    required this.isAvailable,
    this.validUntil,
    required this.rewardData,
  });

  /// Creates a LoyaltyReward from JSON data
  factory LoyaltyReward.fromJson(Map<String, dynamic> json) {
    return LoyaltyReward(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      pointsCost: json['pointsCost'] as int,
      type: json['type'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
      validUntil: json['validUntil'] != null
          ? DateTime.parse(json['validUntil'] as String)
          : null,
      rewardData: Map<String, dynamic>.from(json['rewardData'] as Map? ?? {}),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pointsCost': pointsCost,
      'type': type,
      'isAvailable': isAvailable,
      'validUntil': validUntil?.toIso8601String(),
      'rewardData': rewardData,
    };
  }

  /// Gets the display text for points cost
  String get pointsCostDisplay {
    return '$pointsCost points';
  }

  /// Checks if the reward is expired
  bool get isExpired {
    if (validUntil == null) return false;
    return DateTime.now().isAfter(validUntil!);
  }

  /// Checks if the reward can be redeemed
  bool get canRedeem {
    return isAvailable && !isExpired;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        pointsCost,
        type,
        isAvailable,
        validUntil,
        rewardData,
      ];
}

/// Represents a loyalty redemption
class LoyaltyRedemption extends Equatable {
  final String id;
  final String customerId;
  final String rewardId;
  final int pointsUsed;
  final DateTime redeemedAt;
  final String? bookingId;
  final Map<String, dynamic> redemptionData;

  const LoyaltyRedemption({
    required this.id,
    required this.customerId,
    required this.rewardId,
    required this.pointsUsed,
    required this.redeemedAt,
    this.bookingId,
    required this.redemptionData,
  });

  /// Creates a LoyaltyRedemption from JSON data
  factory LoyaltyRedemption.fromJson(Map<String, dynamic> json) {
    return LoyaltyRedemption(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      rewardId: json['rewardId'] as String,
      pointsUsed: json['pointsUsed'] as int,
      redeemedAt: DateTime.parse(json['redeemedAt'] as String),
      bookingId: json['bookingId'] as String?,
      redemptionData: Map<String, dynamic>.from(json['redemptionData'] as Map? ?? {}),
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'rewardId': rewardId,
      'pointsUsed': pointsUsed,
      'redeemedAt': redeemedAt.toIso8601String(),
      'bookingId': bookingId,
      'redemptionData': redemptionData,
    };
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        rewardId,
        pointsUsed,
        redeemedAt,
        bookingId,
        redemptionData,
      ];
}
