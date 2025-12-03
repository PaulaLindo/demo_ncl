// lib/providers/admin_provider_web.dart - Web-compatible AdminProvider
import 'package:flutter/foundation.dart';
import '../models/temp_card_model.dart';

class AdminUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final double rating; // Staff rating (1-5)

  AdminUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    this.rating = 4.5, // Default rating for staff
  });

  String get fullName => '$firstName $lastName';
}

class AdminActivity {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String type;

  AdminActivity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

class AdminStats {
  final int totalUsers;
  final int activeJobs;
  final int pendingApprovals;
  final int totalRevenue;
  final int newUsersThisMonth;

  AdminStats({
    required this.totalUsers,
    required this.activeJobs,
    required this.pendingApprovals,
    required this.totalRevenue,
    required this.newUsersThisMonth,
  });
}

class AdminProviderWeb extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<AdminUser> _users = [];
  List<AdminActivity> _recentActivities = [];
  AdminStats? _stats;
  List<TempCard> _tempCards = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AdminUser> get users => _users;
  List<AdminActivity> get recentActivities => _recentActivities;
  AdminStats? get stats => _stats;
  List<TempCard> get tempCards => _tempCards;

  // Mock data for web compatibility
  // Temp Card Management Methods
  Future<void> loadTempCards() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock data - in a real app, this would come from an API
      _tempCards = [
        TempCard(
          id: '1',
          userId: 'user1',
          userName: 'John Doe',
          cardNumber: 'TEMP-1234-5678',
          issueDate: DateTime.now().subtract(const Duration(days: 2)),
          expiryDate: DateTime.now().add(const Duration(days: 5)),
          isActive: true,
        ),
        TempCard(
          id: '2',
          userId: 'user2',
          userName: 'Jane Smith',
          cardNumber: 'TEMP-8765-4321',
          issueDate: DateTime.now().subtract(const Duration(days: 1)),
          expiryDate: DateTime.now().add(const Duration(days: 6)),
          isActive: true,
        ),
      ];
      
      _error = null;
    } catch (e) {
      _error = 'Failed to load temp cards: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TempCard> issueTempCard({
    required String staffId,
    required String staffName,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Generate a random card number
      final cardNumber = 'TEMP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      
      final newCard = TempCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: staffId,
        userName: staffName,
        cardNumber: cardNumber,
        issueDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 7)), // 7 days expiry
        isActive: true,
        notes: notes,
      );
      
      _tempCards = [..._tempCards, newCard];
      _error = null;
      
      return newCard;
    } catch (e) {
      _error = 'Failed to issue temp card: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deactivateTempCard(String cardId, String reason) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      _tempCards = _tempCards.map((card) {
        if (card.id == cardId) {
          return card.copyWith(
            isActive: false,
            deactivationDate: DateTime.now(),
            deactivationReason: reason,
          );
        }
        return card;
      }).toList();
      
      _error = null;
    } catch (e) {
      _error = 'Failed to deactivate temp card: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadMockData() {
    _users = [
      AdminUser(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        role: 'Staff',
        rating: 4.8,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      AdminUser(
        id: '2',
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane.smith@example.com',
        role: 'Staff',
        rating: 4.6,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      AdminUser(
        id: '3',
        firstName: 'Mike',
        lastName: 'Johnson',
        email: 'mike.johnson@example.com',
        role: 'Customer',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      AdminUser(
        id: '4',
        firstName: 'Sarah',
        lastName: 'Williams',
        email: 'sarah.williams@example.com',
        role: 'Customer',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      AdminUser(
        id: '5',
        firstName: 'David',
        lastName: 'Brown',
        email: 'david.brown@example.com',
        role: 'Admin',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];

    _recentActivities = [
      AdminActivity(
        id: '1',
        title: 'New user registration',
        subtitle: 'John Doe joined as staff',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'user',
      ),
      AdminActivity(
        id: '2',
        title: 'Job completed',
        subtitle: 'Office cleaning at CBD',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        type: 'job',
      ),
      AdminActivity(
        id: '3',
        title: 'Time entry approved',
        subtitle: 'Sarah Smith - 8 hours',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: 'timekeeping',
      ),
      AdminActivity(
        id: '4',
        title: 'Payment processed',
        subtitle: 'R2,500 for cleaning services',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        type: 'payment',
      ),
    ];

    _stats = AdminStats(
      totalUsers: _users.where((user) => user.role != 'Admin').length, // Only Staff + Customer = 4
      activeJobs: 8, // Match actual gigs from calendar
      pendingApprovals: 2, // Match pending time off requests
      totalRevenue: 45000,
      newUsersThisMonth: 2, // Match actual new users this month
    );
  }

  // Load admin data
  Future<void> loadAdminData() async {
    // Prevent multiple concurrent loads
    if (_isLoading) return;
    
    _setLoading(true);
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Update state
      _loadMockData();
      _error = null;
    } catch (e) {
      _error = 'Failed to load admin data: $e';
      // Re-throw to allow error handling in the UI if needed
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get user by ID
  AdminUser? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new activity
  void addActivity({
    required String title,
    required String subtitle,
    required String type,
  }) {
    final activity = AdminActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      subtitle: subtitle,
      timestamp: DateTime.now(),
      type: type,
    );
    
    _recentActivities.insert(0, activity);
    
    // Keep only last 20 activities
    if (_recentActivities.length > 20) {
      _recentActivities = _recentActivities.take(20).toList();
    }
    
    notifyListeners();
  }

  // Update user status
  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      final userIndex = _users.indexWhere((user) => user.id == userId);
      if (userIndex != -1) {
        _users[userIndex] = AdminUser(
          id: _users[userIndex].id,
          firstName: _users[userIndex].firstName,
          lastName: _users[userIndex].lastName,
          email: _users[userIndex].email,
          role: _users[userIndex].role,
          isActive: isActive,
          createdAt: _users[userIndex].createdAt,
        );
        
        addActivity(
          title: 'User status updated',
          subtitle: '${_users[userIndex].fullName} ${isActive ? 'activated' : 'deactivated'}',
          type: 'user',
        );
        
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update user status: $e';
      notifyListeners();
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadAdminData();
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      // Notify listeners directly since this is a ChangeNotifier
      // and we don't need to worry about build context
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
