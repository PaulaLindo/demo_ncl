// lib/providers/loyalty_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loyalty_model.dart';

class LoyaltyProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  LoyaltyAccount? _loyaltyAccount;
  List<LoyaltyReward> _availableRewards = [];
  bool _isLoading = false;
  String? _error;

  LoyaltyAccount? get loyaltyAccount => _loyaltyAccount;
  List<LoyaltyReward> get availableRewards => _availableRewards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load customer's loyalty account
  Future<void> loadLoyaltyAccount(String customerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final doc = await _firestore.collection('loyalty_accounts').doc(customerId).get();
      
      if (doc.exists) {
        _loyaltyAccount = LoyaltyAccount.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        // Create new loyalty account
        _loyaltyAccount = LoyaltyAccount(
          customerId: customerId,
          totalPoints: 0,
          availablePoints: 0,
          pointsEarned: 0,
          pointsRedeemed: 0,
          currentTier: LoyaltyTier.bronze,
          transactions: [],
          availableRewards: [],
        );
        await _saveLoyaltyAccount();
      }

      await _loadAvailableRewards();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load loyalty account: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add loyalty points to customer account
  Future<void> addLoyaltyPoints({
    required String customerId,
    required int points,
    required String source,
    String? bookingId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Create transaction
      final transaction = LoyaltyTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: customerId,
        points: points,
        type: LoyaltyTransactionType.earned,
        source: source,
        bookingId: bookingId,
        description: 'Earned $points points from $source',
        createdAt: DateTime.now(),
      );

      // Update account
      if (_loyaltyAccount != null) {
        final updatedAccount = _loyaltyAccount!.copyWith(
          totalPoints: _loyaltyAccount!.totalPoints + points,
          availablePoints: _loyaltyAccount!.availablePoints + points,
          pointsEarned: _loyaltyAccount!.pointsEarned + points,
          transactions: [..._loyaltyAccount!.transactions, transaction],
          lastActivity: DateTime.now(),
        );

        // Check for tier upgrade
        updatedAccount.currentTier = _calculateTier(updatedAccount.totalPoints);

        _loyaltyAccount = updatedAccount;
        await _saveLoyaltyAccount();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add loyalty points: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Redeem loyalty points for a reward
  Future<bool> redeemReward(String customerId, String rewardId) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (_loyaltyAccount == null) {
        _error = 'No loyalty account found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final reward = _availableRewards.firstWhere((r) => r.id == rewardId);
      
      if (_loyaltyAccount!.availablePoints < reward.pointsCost) {
        _error = 'Insufficient points';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create redemption
      final redemption = LoyaltyRedemption(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: customerId,
        rewardId: rewardId,
        pointsUsed: reward.pointsCost,
        redeemedAt: DateTime.now(),
        redemptionData: {'rewardName': reward.name},
      );

      // Create transaction
      final transaction = LoyaltyTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: customerId,
        points: reward.pointsCost,
        type: LoyaltyTransactionType.redeemed,
        source: 'reward_redemption',
        description: 'Redeemed ${reward.name} for ${reward.pointsCost} points',
        createdAt: DateTime.now(),
      );

      // Update account
      final updatedAccount = _loyaltyAccount!.copyWith(
        availablePoints: _loyaltyAccount!.availablePoints - reward.pointsCost,
        pointsRedeemed: _loyaltyAccount!.pointsRedeemed + reward.pointsCost,
        transactions: [..._loyaltyAccount!.transactions, transaction],
        lastActivity: DateTime.now(),
      );

      _loyaltyAccount = updatedAccount;
      await _saveLoyaltyAccount();

      // Save redemption
      await _firestore.collection('loyalty_redemptions').doc(redemption.id).set(redemption.toJson());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to redeem reward: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Calculate loyalty tier based on total points
  LoyaltyTier _calculateTier(int totalPoints) {
    if (totalPoints >= 5000) return LoyaltyTier.platinum;
    if (totalPoints >= 2500) return LoyaltyTier.gold;
    if (totalPoints >= 1000) return LoyaltyTier.silver;
    return LoyaltyTier.bronze;
  }

  /// Load available rewards
  Future<void> _loadAvailableRewards() async {
    try {
      final snapshot = await _firestore
          .collection('loyalty_rewards')
          .where('isActive', isEqualTo: true)
          .get();

      _availableRewards = snapshot.docs
          .map((doc) => LoyaltyReward.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading available rewards: $e');
    }
  }

  /// Save loyalty account to Firestore
  Future<void> _saveLoyaltyAccount() async {
    if (_loyaltyAccount == null) return;
    
    await _firestore
        .collection('loyalty_accounts')
        .doc(_loyaltyAccount!.customerId)
        .set(_loyaltyAccount!.toJson());
  }

  /// Get points multiplier for current tier
  double get pointsMultiplier {
    if (_loyaltyAccount == null) return 1.0;
    return _loyaltyAccount!.currentTier.pointsMultiplier;
  }

  /// Get tier benefits
  Map<String, List<String>> getTierBenefits() {
    return {
      'Bronze': [
        '1 point per dollar spent',
        'Birthday bonus points',
        'Standard customer support',
      ],
      'Silver': [
        '1.1 points per dollar spent',
        'Birthday bonus points (+10%)',
        'Priority customer support',
        'Early access to promotions',
      ],
      'Gold': [
        '1.15 points per dollar spent',
        'Birthday bonus points (+25%)',
        'Dedicated customer support',
        'Exclusive promotions',
        'Free service upgrades',
      ],
      'Platinum': [
        '1.2 points per dollar spent',
        'Birthday bonus points (+50%)',
        'VIP customer support',
        'Exclusive promotions',
        'Free service upgrades',
        'Annual bonus points',
        'Invitation to special events',
      ],
    };
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
