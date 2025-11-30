// lib/providers/review_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Review> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Submit a new review
  Future<void> submitReview(Review review) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Save review to Firestore
      await _firestore.collection('reviews').doc(review.id).set(review.toJson());

      // Update staff member's rating
      await _updateStaffRating(review.staffId);

      // Update booking status to reviewed
      await _firestore
          .collection('bookings')
          .doc(review.bookingId)
          .update({'status': 'reviewed', 'reviewId': review.id});

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to submit review: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Get reviews for a staff member
  Future<List<Review>> getStaffReviews(String staffId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('staffId', isEqualTo: staffId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Review.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching staff reviews: $e');
      return [];
    }
  }

  /// Get reviews for a customer
  Future<List<Review>> getCustomerReviews(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Review.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching customer reviews: $e');
      return [];
    }
  }

  /// Update staff member's average rating
  Future<void> _updateStaffRating(String staffId) async {
    try {
      final reviews = await getStaffReviews(staffId);
      
      if (reviews.isEmpty) return;

      final averageRating = reviews
          .map((r) => r.rating)
          .reduce((a, b) => a + b) / reviews.length;

      await _firestore
          .collection('staff')
          .doc(staffId)
          .update({
            'averageRating': averageRating,
            'reviewCount': reviews.length,
          });
    } catch (e) {
      debugPrint('Error updating staff rating: $e');
    }
  }

  /// Get overall review statistics
  Map<String, dynamic> getReviewStatistics(List<Review> reviews) {
    if (reviews.isEmpty) {
      return {
        'totalReviews': 0,
        'averageRating': 0.0,
        'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        'wouldRecommendPercentage': 0.0,
        'wouldRebookPercentage': 0.0,
      };
    }

    final averageRating = reviews
        .map((r) => r.rating)
        .reduce((a, b) => a + b) / reviews.length;

    final ratingDistribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      ratingDistribution[i] = reviews.where((r) => r.rating == i).length;
    }

    final wouldRecommendCount = reviews
        .where((r) => r.wouldRecommend == true)
        .length;
    final wouldRebookCount = reviews
        .where((r) => r.wouldRebook == true)
        .length;

    return {
      'totalReviews': reviews.length,
      'averageRating': averageRating,
      'ratingDistribution': ratingDistribution,
      'wouldRecommendPercentage': (wouldRecommendCount / reviews.length) * 100,
      'wouldRebookPercentage': (wouldRebookCount / reviews.length) * 100,
    };
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
