// lib/providers/admin_provider.dart
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:logging/logging.dart';

import 'base_provider.dart';
import '../models/temp_card_model.dart';
import '../models/time_record_model.dart';
import '../models/staff_availability.dart';
import '../models/audit_log_model.dart';
import '../models/quality_flag_model.dart';
import '../models/b2b_lead_model.dart';
import '../models/logistics_model.dart';
import '../models/payroll_model.dart';

class AdminUser {
  final String id;
  final String name;
  final String role; // 'Customer' or 'Staff'
  bool isBanned;
  final String? email;
  final String? phoneNumber;
  final DateTime? createdAt;

  AdminUser({
    required this.id,
    required this.name,
    required this.role,
    this.isBanned = false,
    this.email,
    this.phoneNumber,
    this.createdAt,
  });

  AdminUser copyWith({
    String? id,
    String? name,
    String? role,
    bool? isBanned,
    String? email,
    String? phoneNumber,
    DateTime? createdAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      isBanned: isBanned ?? this.isBanned,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      isBanned: json['isBanned'] as bool? ?? false,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: json['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'isBanned': isBanned,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}

class AdminBooking {
  final String id;
  final String title;
  final String staffName;
  final String customerName;
  final String status; // 'Pending', 'Confirmed', 'Issue' (No Temp Card)
  final double price;
  final DateTime? startTime;
  final DateTime? endTime;

  AdminBooking({
    required this.id,
    required this.title,
    required this.staffName,
    required this.customerName,
    required this.status,
    required this.price,
    this.startTime,
    this.endTime,
  });

  factory AdminBooking.fromJson(Map<String, dynamic> json) {
    return AdminBooking(
      id: json['id'] as String,
      title: json['title'] as String,
      staffName: json['staffName'] as String,
      customerName: json['customerName'] as String,
      status: json['status'] as String,
      price: (json['price'] as num).toDouble(),
      startTime: json['startTime']?.toDate(),
      endTime: json['endTime']?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'staffName': staffName,
      'customerName': customerName,
      'status': status,
      'price': price,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
  }
}

class AdminActivity {
  final String id;
  final String title;
  final String subtitle;
  final String timeAgo;

  AdminActivity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
  });
}

class AdminProvider extends BaseProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger;
  final Map<String, dynamic> _cache = {};
  bool _isDisposed = false;
  bool _isLoading = false;
  bool _hasMoreUsers = true;
  bool _hasMoreBookings = true;
  bool _isConnected = true;

  AdminProvider({Logger? logger}) : _logger = logger ?? Logger('AdminProvider'), super(logger ?? Logger('AdminProvider'));

  @override
  bool get isDisposed => _isDisposed;
  @override
  bool get isLoading => _isLoading;

  @override
  void setLoading(bool loading) {
    if (_isDisposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  void _setupConnectivityListener() {
    // TODO: Implement proper connectivity check using connectivity_plus package
    // This is a placeholder implementation
    _isConnected = true;
  }

  // Pagination
  static const int _usersPageSize = 15;
  static const int _bookingsPageSize = 20;

  // Cache keys
  static const String _usersCacheKey = 'admin_users';
  static const String _bookingsCacheKey = 'admin_bookings';
  static const Duration _cacheDuration = Duration(minutes: 10);

  // State
  final _usersController = BehaviorSubject<List<AdminUser>>.seeded([]);
  final _bookingsController = BehaviorSubject<List<AdminBooking>>.seeded([]);
  DocumentSnapshot? _lastUserDoc;
  DocumentSnapshot? _lastBookingDoc;

  // Stream getters
  Stream<List<AdminUser>> get usersStream => _usersController.stream;
  Stream<List<AdminBooking>> get bookingsStream => _bookingsController.stream;

  // Activity tracking
  List<AdminActivity> get recentActivities => [
    AdminActivity(
      id: '1',
      title: 'New user registered',
      subtitle: 'John Doe joined as customer',
      timeAgo: '2 hours ago',
    ),
    AdminActivity(
      id: '2',
      title: 'New booking created',
      subtitle: 'Standard Cleaning service booked',
      timeAgo: '4 hours ago',
    ),
  ];

  // Real-time subscriptions
  late StreamSubscription _usersSubscription;
  late StreamSubscription _bookingsSubscription;

  Future<void> initialize() async {
    try {
      setLoading(true);
      _setupConnectivityListener();
      await _setupRealtimeListeners();
      await refreshData();
    } catch (e, stackTrace) {
      handleError(Exception('Failed to initialize admin provider: $e'), stackTrace: stackTrace);
    } finally {
      setLoading(false);
    }
  }

  Future<void> _setupRealtimeListeners() async {
    try {
      await _cancelSubscriptions();

      // Users listener
      _usersSubscription = _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(_usersPageSize)
          .snapshots(includeMetadataChanges: true)
          .handleError((error) {
            handleError(Exception('Users stream error: $error'), stackTrace: StackTrace.current, notify: false);
            _usersController.addError(error);
          })
          .listen((snapshot) {
            if (snapshot.metadata.isFromCache) {
              _logger.info('Using cached users data');
            }
            _processUsers(snapshot);
          });

      // Bookings listener
      _bookingsSubscription = _firestore
          .collection('bookings')
          .orderBy('createdAt', descending: true)
          .limit(_bookingsPageSize)
          .snapshots(includeMetadataChanges: true)
          .handleError((error) {
            handleError(Exception('Bookings stream error: $error'), stackTrace: StackTrace.current, notify: false);
            _bookingsController.addError(error);
          })
          .listen((snapshot) {
            if (snapshot.metadata.isFromCache) {
              _logger.info('Using cached bookings data');
            }
            _processBookings(snapshot);
          });
    } catch (e, stackTrace) {
      handleError(Exception('Failed to set up real-time listeners: $e'), stackTrace: stackTrace);
      // Schedule retry
      Future.delayed(const Duration(seconds: 5), _setupRealtimeListeners);
    }
  }

  void _processUsers(QuerySnapshot snapshot) {
    try {
      final users = snapshot.docs
          .map((doc) => AdminUser.fromJson(doc.data() as Map<String, dynamic>..['id'] = doc.id))
          .toList();
      _usersController.add(users);
      _cache[_usersCacheKey] = users;
    } catch (e, stackTrace) {
      handleError(Exception('Failed to process users: $e'), stackTrace: stackTrace, notify: false);
    }
  }

  void _processBookings(QuerySnapshot snapshot) {
    try {
      final bookings = snapshot.docs
          .map((doc) => AdminBooking.fromJson(doc.data() as Map<String, dynamic>..['id'] = doc.id))
          .toList();
      _bookingsController.add(bookings);
      _cache[_bookingsCacheKey] = bookings;
    } catch (e, stackTrace) {
      handleError(Exception('Failed to process bookings: $e'), stackTrace: stackTrace, notify: false);
    }
  }

  Future<void> refreshData() async {
    if (!_isConnected) {
      _logger.warning('Skipping refresh: No internet connection');
      return Future.value();
    }

    try {
      setLoading(true);
      await Future.wait([
        loadMoreUsers(reset: true),
        loadMoreBookings(reset: true),
      ]);
    } catch (e, stackTrace) {
      handleError(Exception('Failed to refresh admin data: $e'), stackTrace: stackTrace);
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadMoreUsers({bool reset = false}) async {
    if ((!reset && (!_hasMoreUsers || _isLoading)) || _isDisposed) return;

    try {
      setLoading(true);

      await withRetry(() async {
        if (reset) {
          _lastUserDoc = null;
          _hasMoreUsers = true;
        }

        if (!_hasMoreUsers) return;

        var query = _firestore
            .collection('users')
            .orderBy('createdAt', descending: true)
            .limit(_usersPageSize);

        if (_lastUserDoc != null) {
          query = query.startAfterDocument(_lastUserDoc!);
        }

        final snapshot = await query.get(const GetOptions(source: Source.serverAndCache));

        if (snapshot.docs.isEmpty) {
          _hasMoreUsers = false;
          return;
        }

        _lastUserDoc = snapshot.docs.last;
        final newUsers = snapshot.docs
            .map((doc) => AdminUser.fromJson((doc.data() as Map<String, dynamic>)..['id'] = doc.id))
            .toList();

        if (reset) {
          _usersController.add(newUsers);
        } else {
          _usersController.add([..._usersController.value, ...newUsers]);
        }

        _hasMoreUsers = newUsers.length == _usersPageSize;
      }, cacheKey: '${_usersCacheKey}_page_${_lastUserDoc?.id ?? "first"}', cacheDuration: _cacheDuration);
    } catch (e, stackTrace) {
      handleError(Exception('Failed to load users: $e'), stackTrace: stackTrace);
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadMoreBookings({bool reset = false}) async {
    if ((!reset && (!_hasMoreBookings || _isLoading)) || _isDisposed) return;

    try {
      setLoading(true);

      await withRetry(() async {
        if (reset) {
          _lastBookingDoc = null;
          _hasMoreBookings = true;
        }

        if (!_hasMoreBookings) return;

        var query = _firestore
            .collection('bookings')
            .orderBy('createdAt', descending: true)
            .limit(_bookingsPageSize);

        if (_lastBookingDoc != null) {
          query = query.startAfterDocument(_lastBookingDoc!);
        }

        final snapshot = await query.get(const GetOptions(source: Source.serverAndCache));

        if (snapshot.docs.isEmpty) {
          _hasMoreBookings = false;
          return;
        }

        _lastBookingDoc = snapshot.docs.last;
        final newBookings = snapshot.docs
            .map((doc) => AdminBooking.fromJson((doc.data() as Map<String, dynamic>)..['id'] = doc.id))
            .toList();

        if (reset) {
          _bookingsController.add(newBookings);
        } else {
          _bookingsController.add([..._bookingsController.value, ...newBookings]);
        }

        _hasMoreBookings = newBookings.length == _bookingsPageSize;
      }, cacheKey: '${_bookingsCacheKey}_page_${_lastBookingDoc?.id ?? "first"}', cacheDuration: _cacheDuration);
    } catch (e, stackTrace) {
      handleError(Exception('Failed to load more bookings: $e'), stackTrace: stackTrace);
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // Admin actions
  Future<void> updateUserStatus(String userId, bool isBanned) async {
    try {
      setLoading(true);
      
      // Update in Firestore
      await _firestore.collection('users').doc(userId).update({
        'isBanned': isBanned,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Update local state using copyWith for immutability
      final users = List<AdminUser>.from(_usersController.value);
      final userIndex = users.indexWhere((user) => user.id == userId);
      if (userIndex != -1) {
        final updatedUser = users[userIndex].copyWith(isBanned: isBanned);
        users[userIndex] = updatedUser;
        _usersController.add(users);
      }
      
      _logger.info('User $userId ${isBanned ? 'banned' : 'unbanned'} successfully');
    } catch (e, stackTrace) {
      handleError(Exception('Failed to update user status: $e'), stackTrace: stackTrace);
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      setLoading(true);
      await withRetry(() => _firestore.collection('bookings').doc(bookingId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      }));

      // Update local state
      final bookings = List<AdminBooking>.from(_bookingsController.value);
      final bookingIndex = bookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex != -1) {
        final updatedBooking = AdminBooking(
          id: bookings[bookingIndex].id,
          title: bookings[bookingIndex].title,
          staffName: bookings[bookingIndex].staffName,
          customerName: bookings[bookingIndex].customerName,
          status: newStatus,
          price: bookings[bookingIndex].price,
          startTime: bookings[bookingIndex].startTime,
          endTime: bookings[bookingIndex].endTime,
        );
        bookings[bookingIndex] = updatedBooking;
        _bookingsController.add(bookings);
      }
    } catch (e, stackTrace) {
      handleError(Exception('Failed to update booking status: $e'), stackTrace: stackTrace);
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // Batch operations
  Future<void> batchUpdateUsersStatus(List<String> userIds, bool isBanned) async {
    if (userIds.isEmpty) return;

    try {
      setLoading(true);
      final batch = _firestore.batch();
      final collection = _firestore.collection('users');

      for (final id in userIds) {
        batch.update(collection.doc(id), {
          'isBanned': isBanned,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await withRetry(() => batch.commit());

      // Update local state
      final users = List<AdminUser>.from(_usersController.value);
      for (final id in userIds) {
        final userIndex = users.indexWhere((u) => u.id == id);
        if (userIndex != -1) {
          final updatedUser = users[userIndex]..isBanned = isBanned;
          users[userIndex] = updatedUser;
        }
      }
      _usersController.add(users);
    } catch (e, stackTrace) {
      handleError(Exception('Batch update users failed: $e'), stackTrace: stackTrace);
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      _cancelSubscriptions();
      _usersController.close();
      _bookingsController.close();
      super.dispose();
    }
  }

  Future<void> _cancelSubscriptions() async {
    await _usersSubscription.cancel();
    await _bookingsSubscription.cancel();
  }

  // Statistics
  Stream<Map<String, dynamic>> getStatistics() {
    return _firestore
        .collection('statistics')
        .doc('admin')
        .snapshots()
        .map((doc) => doc.data() ?? {})
        .handleError((error) {
          handleError(Exception('Failed to load statistics: $error'), stackTrace: StackTrace.current);
          return {};
        });
  }

  // Search functionality
  Stream<List<AdminUser>> searchUsers(String query) {
    if (query.isEmpty) {
      return _usersController.stream;
    }
    
    final normalizedQuery = query.toLowerCase();
    return _usersController.stream.map((users) => users.where((user) {
      return user.name.toLowerCase().contains(normalizedQuery) ||
             (user.email?.toLowerCase().contains(normalizedQuery) ?? false) ||
             (user.phoneNumber?.contains(normalizedQuery) ?? false);
    }).toList());
  }

  Stream<List<AdminBooking>> searchBookings(String query) {
    if (query.isEmpty) {
      return _bookingsController.stream;
    }
    
    final normalizedQuery = query.toLowerCase();
    return _bookingsController.stream.map((bookings) => bookings.where((booking) {
      return booking.title.toLowerCase().contains(normalizedQuery) ||
             booking.staffName.toLowerCase().contains(normalizedQuery) ||
             booking.customerName.toLowerCase().contains(normalizedQuery) ||
             booking.status.toLowerCase().contains(normalizedQuery);
    }).toList());
  }

  // ===== NEW ADMIN FEATURES =====

  // Temp Card Management
  final _tempCardsController = BehaviorSubject<List<TempCard>>.seeded([]);
  Stream<List<TempCard>> get tempCardsStream => _tempCardsController.stream;

  /// Generates a unique 6-digit temp card code
  String generateTempCardCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Issues a new temp card to a staff member
  Future<TempCard> issueTempCard({
    required String staffId,
    required String staffName,
    String? notes,
  }) async {
    try {
      setLoading(true);
      
      final code = generateTempCardCode();
      final now = DateTime.now();
      final expiryDate = now.add(const Duration(hours: 24)); // 24-hour expiry
      
      final tempCard = TempCard(
        id: 'temp_${now.millisecondsSinceEpoch}',
        userId: staffId,
        userName: staffName,
        cardNumber: code,
        issueDate: now,
        expiryDate: expiryDate,
        notes: notes,
      );
      
      // Save to Firestore
      await _firestore.collection('temp_cards').doc(tempCard.id).set({
        'id': tempCard.id,
        'userId': tempCard.userId,
        'userName': tempCard.userName,
        'cardNumber': tempCard.cardNumber,
        'issueDate': tempCard.issueDate,
        'expiryDate': tempCard.expiryDate,
        'isActive': tempCard.isActive,
        'notes': tempCard.notes,
      });
      
      // Log audit trail
      await _logAuditEvent(
        action: 'TEMP_CARD_ISSUED',
        targetId: staffId,
        targetName: staffName,
        details: {
          'cardId': tempCard.id,
          'cardNumber': code,
          'expiryDate': expiryDate.toIso8601String(),
        },
      );
      
      // Update local list
      final currentCards = _tempCardsController.value.toList();
      currentCards.add(tempCard);
      _tempCardsController.add(currentCards);
      
      _logger.info('Temp card issued: $code to $staffName');
      return tempCard;
    } catch (e, stackTrace) {
      handleError(Exception('Failed to issue temp card: $e'), stackTrace: stackTrace);
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Validates a temp card code
  Future<TempCard?> validateTempCard(String code) async {
    try {
      final snapshot = await _firestore
          .collection('temp_cards')
          .where('cardNumber', isEqualTo: code)
          .where('isActive', isEqualTo: true)
          .where('expiryDate', isGreaterThan: DateTime.now())
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return null;
      }
      
      final doc = snapshot.docs.first;
      return TempCard.fromJson(doc.data());
    } catch (e) {
      _logger.warning('Failed to validate temp card: $e');
      return null;
    }
  }

  /// Deactivates a temp card
  Future<void> deactivateTempCard(String cardId, String reason) async {
    try {
      setLoading(true);
      
      await _firestore.collection('temp_cards').doc(cardId).update({
        'isActive': false,
        'deactivationDate': DateTime.now(),
        'deactivationReason': reason,
      });
      
      // Update local list
      final currentCards = _tempCardsController.value;
      final updatedCards = currentCards.map((card) {
        if (card.id == cardId) {
          return card.copyWith(
            isActive: false,
            deactivationDate: DateTime.now(),
            deactivationReason: reason,
          );
        }
        return card;
      }).toList();
      _tempCardsController.add(updatedCards);
      
      _logger.info('Temp card deactivated: $cardId');
    } catch (e, stackTrace) {
      handleError(Exception('Failed to deactivate temp card: $e'), stackTrace: stackTrace);
    } finally {
      setLoading(false);
    }
  }

  // Proxy Time Management
  final _proxyRecordsController = BehaviorSubject<List<TimeRecord>>.seeded([]);
  Stream<List<TimeRecord>> get proxyRecordsStream => _proxyRecordsController.stream;

  /// Creates a proxy time record for staff without phone
  Future<TimeRecord> createProxyTimeRecord({
    required String staffId,
    required String staffName,
    required String jobId,
    required String jobName,
    required DateTime checkInTime,
    DateTime? checkOutTime,
    String? notes,
  }) async {
    try {
      setLoading(true);
      
      final now = DateTime.now();
      final record = TimeRecord(
        id: 'proxy_${now.millisecondsSinceEpoch}',
        staffId: staffId,
        jobId: jobId,
        jobName: jobName,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        startTime: checkInTime,
        endTime: checkOutTime,
        type: TimeRecordType.proxy,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );
      
      // Save to Firestore
      await _firestore.collection('time_records').doc(record.id).set({
        'id': record.id,
        'staffId': record.staffId,
        'jobId': record.jobId,
        'jobName': record.jobName,
        'checkInTime': record.checkInTime,
        'checkOutTime': record.checkOutTime,
        'startTime': record.startTime,
        'endTime': record.endTime,
        'type': record.type.toString(),
        'notes': record.notes,
        'createdAt': record.createdAt,
        'updatedAt': record.updatedAt,
        'isProxy': true,
        'needsApproval': true,
      });
      
      // Log audit trail
      await _logAuditEvent(
        action: 'PROXY_TIME_CREATED',
        targetId: staffId,
        targetName: staffName,
        details: {
          'recordId': record.id,
          'jobId': jobId,
          'checkInTime': checkInTime.toIso8601String(),
          'checkOutTime': checkOutTime?.toIso8601String(),
        },
      );
      
      // Update local list
      final currentRecords = _proxyRecordsController.value.toList();
      currentRecords.add(record);
      _proxyRecordsController.add(currentRecords);
      
      _logger.info('Proxy time record created for $staffName');
      return record;
    } catch (e, stackTrace) {
      handleError(Exception('Failed to create proxy time record: $e'), stackTrace: stackTrace);
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Checks if hours are included in draft payroll
  Future<bool> areHoursInPayroll(String recordId) async {
    try {
      final snapshot = await _firestore
          .collection('draft_payroll')
          .where('timeRecordIds', arrayContains: recordId)
          .limit(1)
          .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      _logger.warning('Failed to check payroll status: $e');
      return false;
    }
  }

  /// Approves or rejects proxy hours
  Future<void> approveProxyHours({
    required String recordId,
    required bool approved,
    String? adminNotes,
  }) async {
    try {
      setLoading(true);
      
      final updateData = {
        'approved': approved,
        'approvedAt': DateTime.now(),
        'adminNotes': adminNotes,
        'needsApproval': false,
      };
      
      await _firestore.collection('time_records').doc(recordId).update(updateData);
      
      // Update local list
      final currentRecords = _proxyRecordsController.value;
      final updatedRecords = currentRecords.map((record) {
        if (record.id == recordId) {
          return record.copyWith(
            status: approved ? TimeRecordStatus.completed : TimeRecordStatus.rejected,
            updatedAt: DateTime.now(),
          );
        }
        return record;
      }).toList();
      _proxyRecordsController.add(updatedRecords);
      
      // Log audit trail
      await _logAuditEvent(
        action: approved ? 'PROXY_HOURS_APPROVED' : 'PROXY_HOURS_REJECTED',
        targetId: recordId,
        details: {
          'approved': approved,
          'adminNotes': adminNotes,
        },
      );
      
      _logger.info('Proxy hours ${approved ? "approved" : "rejected"}: $recordId');
    } catch (e, stackTrace) {
      handleError(Exception('Failed to approve proxy hours: $e'), stackTrace: stackTrace);
    } finally {
      setLoading(false);
    }
  }

  // Staff Interface Blocking
  final _blockedStaffController = BehaviorSubject<List<String>>.seeded([]);
  Stream<List<String>> get blockedStaffStream => _blockedStaffController.stream;

  /// Blocks staff from accepting new jobs
  Future<void> blockStaffInterface(String staffId, String reason) async {
    try {
      setLoading(true);
      
      await _firestore.collection('staff_restrictions').doc(staffId).set({
        'blocked': true,
        'reason': reason,
        'blockedAt': DateTime.now(),
        'blockedUntil': null, // Until manually unblocked
      });
      
      // Update local list
      final currentBlocked = _blockedStaffController.value.toList();
      if (!currentBlocked.contains(staffId)) {
        currentBlocked.add(staffId);
        _blockedStaffController.add(currentBlocked);
      }
      
      // Log audit trail
      await _logAuditEvent(
        action: 'STAFF_INTERFACE_BLOCKED',
        targetId: staffId,
        details: {'reason': reason},
      );
      
      _logger.info('Staff interface blocked: $staffId');
    } catch (e, stackTrace) {
      handleError(Exception('Failed to block staff interface: $e'), stackTrace: stackTrace);
    } finally {
      setLoading(false);
    }
  }

  /// Unblocks staff interface
  Future<void> unblockStaffInterface(String staffId) async {
    try {
      setLoading(true);
      
      await _firestore.collection('staff_restrictions').doc(staffId).update({
        'blocked': false,
        'unblockedAt': DateTime.now(),
      });
      
      // Update local list
      final currentBlocked = _blockedStaffController.value;
      currentBlocked.remove(staffId);
      _blockedStaffController.add(currentBlocked);
      
      // Log audit trail
      await _logAuditEvent(
        action: 'STAFF_INTERFACE_UNBLOCKED',
        targetId: staffId,
        details: {},
      );
      
      _logger.info('Staff interface unblocked: $staffId');
    } catch (e, stackTrace) {
      handleError(Exception('Failed to unblock staff interface: $e'), stackTrace: stackTrace);
    } finally {
      setLoading(false);
    }
  }

  /// Checks if staff interface is blocked
  Future<bool> isStaffBlocked(String staffId) async {
    try {
      final doc = await _firestore.collection('staff_restrictions').doc(staffId).get();
      if (!doc.exists) return false;
      
      final data = doc.data() as Map<String, dynamic>;
      return data['blocked'] == true;
    } catch (e) {
      _logger.warning('Failed to check staff block status: $e');
      return false;
    }
  }

  // Quality Audit Flagging
  final _qualityFlagsController = BehaviorSubject<List<QualityFlag>>.seeded([]);
  Stream<List<QualityFlag>> get qualityFlagsStream => _qualityFlagsController.stream;

  /// Flags a job for quality audit
  Future<void> flagQualityIssue({
    required String jobId,
    required String jobName,
    required String staffId,
    required String staffName,
    required String issueType,
    required String description,
    int severity = 1, // 1-5 scale
  }) async {
    try {
      setLoading(true);
      
      final flag = QualityFlag(
        id: 'flag_${DateTime.now().millisecondsSinceEpoch}',
        jobId: jobId,
        jobName: jobName,
        staffId: staffId,
        staffName: staffName,
        issueType: issueType,
        description: description,
        severity: severity,
        createdAt: DateTime.now(),
        status: QualityFlagStatus.pending,
      );
      
      await _firestore.collection('quality_flags').doc(flag.id).set({
        'id': flag.id,
        'jobId': flag.jobId,
        'jobName': flag.jobName,
        'staffId': flag.staffId,
        'staffName': flag.staffName,
        'issueType': flag.issueType,
        'description': flag.description,
        'severity': flag.severity,
        'createdAt': flag.createdAt,
        'status': flag.status.toString(),
      });
      
      // Update local list
      final currentFlags = _qualityFlagsController.value.toList();
      currentFlags.add(flag);
      _qualityFlagsController.add(currentFlags);
      
      // Log audit trail
      await _logAuditEvent(
        action: 'QUALITY_FLAG_CREATED',
        targetId: jobId,
        targetName: jobName,
        details: {
          'flagId': flag.id,
          'issueType': issueType,
          'severity': severity,
        },
      );
      
      _logger.info('Quality flag created: ${flag.id}');
    } catch (e, stackTrace) {
      handleError(Exception('Failed to create quality flag: $e'), stackTrace: stackTrace);
    } finally {
      setLoading(false);
    }
  }

  /// Resolves a quality flag
  Future<void> resolveQualityFlag(String flagId, String resolution, String resolvedBy) async {
    try {
      setLoading(true);
      
      await _firestore.collection('quality_flags').doc(flagId).update({
        'status': QualityFlagStatus.resolved.toString(),
        'resolution': resolution,
        'resolvedBy': resolvedBy,
        'resolvedAt': DateTime.now(),
      });
      
      // Update local list
      final currentFlags = _qualityFlagsController.value;
      final updatedFlags = currentFlags.map((flag) {
        if (flag.id == flagId) {
          return flag.copyWith(
            status: QualityFlagStatus.resolved,
            resolution: resolution,
            resolvedBy: resolvedBy,
            resolvedAt: DateTime.now(),
          );
        }
        return flag;
      }).toList();
      _qualityFlagsController.add(updatedFlags);
      
      // Log audit trail
      await _logAuditEvent(
        action: 'QUALITY_FLAG_RESOLVED',
        targetId: flagId,
        details: {
          'resolution': resolution,
          'resolvedBy': resolvedBy,
        },
      );
      
      _logger.info('Quality flag resolved: $flagId');
    } catch (e, stackTrace) {
      handleError(Exception('Failed to resolve quality flag: $e'), stackTrace: stackTrace);
    } finally {
      setLoading(false);
    }
  }

  // B2B Lead Management
  final _leadsController = BehaviorSubject<List<B2BLead>>.seeded([]);
  Stream<List<B2BLead>> get leadsStream => _leadsController.stream;

  /// Adds a new B2B lead
  Future<void> addB2BLead({
    required String companyName,
    required String contactName,
    required String email,
    required String phone,
    required String serviceInterest,
    String? notes,
  }) async {
    try {
      setLoading(true);
      
      final lead = B2BLead(
        id: 'lead_${DateTime.now().millisecondsSinceEpoch}',
        companyName: companyName,
        contactName: contactName,
        email: email,
        phone: phone,
        serviceInterest: serviceInterest,
        notes: notes,
        createdAt: DateTime.now(),
        status: LeadStatus.newLead,
      );
      
      await _firestore.collection('b2b_leads').doc(lead.id).set({
        'id': lead.id,
        'companyName': lead.companyName,
        'contactName': lead.contactName,
        'email': lead.email,
        'phone': lead.phone,
        'serviceInterest': lead.serviceInterest,
        'notes': lead.notes,
        'createdAt': lead.createdAt,
        'status': lead.status.toString(),
      });
      
      // Update local list
      final currentLeads = _leadsController.value.toList();
      currentLeads.add(lead);
      _leadsController.add(currentLeads);
      
      // Log audit trail
      await _logAuditEvent(
        action: 'B2B_LEAD_ADDED',
        targetId: lead.id,
        targetName: companyName,
        details: {
          'contactName': contactName,
          'serviceInterest': serviceInterest,
        },
      );
      
      _logger.info('B2B lead added: ${lead.id}');
    } catch (e, stackTrace) {
      handleError(Exception('Failed to add B2B lead: $e'), stackTrace: stackTrace);
    } finally {
      setLoading(false);
    }
  }

  /// Updates lead status
  Future<void> updateLeadStatus(String leadId, LeadStatus status, String? notes) async {
    try {
      setLoading(true);
      
      await _firestore.collection('b2b_leads').doc(leadId).update({
        'status': status.toString(),
        'statusUpdatedAt': DateTime.now(),
        if (notes != null) 'notes': notes,
      });
      
      // Update local list
      final currentLeads = _leadsController.value;
      final updatedLeads = currentLeads.map((lead) {
        if (lead.id == leadId) {
          return lead.copyWith(
            status: status,
            statusUpdatedAt: DateTime.now(),
            notes: notes ?? lead.notes,
          );
        }
        return lead;
      }).toList();
      _leadsController.add(updatedLeads);
      
      // Log audit trail
      await _logAuditEvent(
        action: 'B2B_LEAD_STATUS_UPDATED',
        targetId: leadId,
        details: {
          'newStatus': status.toString(),
          'notes': notes,
        },
      );
      
      _logger.info('B2B lead status updated: $leadId to $status');
    } catch (e, stackTrace) {
      handleError(Exception('Failed to update lead status: $e'), stackTrace: stackTrace);
    } finally {
      setLoading(false);
    }
  }

  // Live Logistics Tracking
  final _logisticsController = BehaviorSubject<List<LogisticsEvent>>.seeded([]);
  Stream<List<LogisticsEvent>> get logisticsStream => _logisticsController.stream;

  /// Logs a logistics event
  Future<void> logLogisticsEvent({
    required String staffId,
    required String jobId,
    required String eventType,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final event = LogisticsEvent(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        staffId: staffId,
        jobId: jobId,
        eventType: eventType,
        description: description,
        metadata: metadata ?? {},
        timestamp: DateTime.now(),
      );
      
      await _firestore.collection('logistics_events').doc(event.id).set({
        'id': event.id,
        'staffId': event.staffId,
        'jobId': event.jobId,
        'eventType': event.eventType,
        'description': event.description,
        'metadata': event.metadata,
        'timestamp': event.timestamp,
      });
      
      // Update local list
      final currentEvents = _logisticsController.value.toList();
      currentEvents.add(event);
      _logisticsController.add(currentEvents);
      
      _logger.info('Logistics event logged: ${event.id}');
    } catch (e, stackTrace) {
      handleError(Exception('Failed to log logistics event: $e'), stackTrace: stackTrace);
    }
  }

  /// Gets live logistics events for a job
  Stream<List<LogisticsEvent>> getJobLogistics(String jobId) {
    return _firestore
        .collection('logistics_events')
        .where('jobId', isEqualTo: jobId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LogisticsEvent.fromJson(doc.data()))
            .toList());
  }

  // Payroll Reconciliation
  final _payrollReportsController = BehaviorSubject<List<PayrollReport>>.seeded([]);
  Stream<List<PayrollReport>> get payrollReportsStream => _payrollReportsController.stream;

  /// Generates a draft payroll report
  Future<PayrollReport> generateDraftPayroll({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      setLoading(true);
      
      // Get all time records in the period
      final timeRecordsSnapshot = await _firestore
          .collection('time_records')
          .where('checkInTime', isGreaterThanOrEqualTo: startDate)
          .where('checkInTime', isLessThanOrEqualTo: endDate)
          .where('approved', isEqualTo: true)
          .get();
      
      final report = PayrollReport(
        id: 'payroll_${DateTime.now().millisecondsSinceEpoch}',
        startDate: startDate,
        endDate: endDate,
        status: PayrollStatus.draft,
        timeRecordIds: timeRecordsSnapshot.docs.map((doc) => doc.id).toList(),
        totalAmount: 0.0, // Calculate based on rates
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('payroll_reports').doc(report.id).set({
        'id': report.id,
        'startDate': report.startDate,
        'endDate': report.endDate,
        'status': report.status.toString(),
        'timeRecordIds': report.timeRecordIds,
        'totalAmount': report.totalAmount,
        'createdAt': report.createdAt,
      });
      
      // Update local list
      final currentReports = _payrollReportsController.value.toList();
      currentReports.add(report);
      _payrollReportsController.add(currentReports);
      
      _logger.info('Draft payroll report generated: ${report.id}');
      return report;
    } catch (e, stackTrace) {
      handleError(Exception('Failed to generate payroll report: $e'), stackTrace: stackTrace);
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Finalizes and unlocks payroll
  Future<void> finalizePayroll(String reportId) async {
    try {
      setLoading(true);
      
      await _firestore.collection('payroll_reports').doc(reportId).update({
        'status': PayrollStatus.finalized.toString(),
        'finalizedAt': DateTime.now(),
      });
      
      // Update local list
      final currentReports = _payrollReportsController.value;
      final updatedReports = currentReports.map((report) {
        if (report.id == reportId) {
          return report.copyWith(
            status: PayrollStatus.finalized,
            finalizedAt: DateTime.now(),
          );
        }
        return report;
      }).toList();
      _payrollReportsController.add(updatedReports);
      
      // Log audit trail
      await _logAuditEvent(
        action: 'PAYROLL_FINALIZED',
        targetId: reportId,
        details: {},
      );
      
      _logger.info('Payroll finalized: $reportId');
    } catch (e, stackTrace) {
      handleError(Exception('Failed to finalize payroll: $e'), stackTrace: stackTrace);
    } finally {
      setLoading(false);
    }
  }

  // Audit Logging
  Future<void> _logAuditEvent({
    required String action,
    String? targetId,
    String? targetName,
    required Map<String, dynamic> details,
  }) async {
    try {
      final log = AuditLog(
        id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
        action: action,
        targetId: targetId,
        targetName: targetName,
        details: details,
        timestamp: DateTime.now(),
        userId: 'admin', // Would come from auth context
      );
      
      await _firestore.collection('audit_logs').doc(log.id).set({
        'id': log.id,
        'action': log.action,
        'targetId': log.targetId,
        'targetName': log.targetName,
        'details': log.details,
        'timestamp': log.timestamp,
        'userId': log.userId,
      });
    } catch (e) {
      _logger.warning('Failed to log audit event: $e');
    }
  }

  /// Gets audit logs for a target
  Stream<List<AuditLog>> getAuditLogs(String? targetId) {
    Query query = _firestore.collection('audit_logs').orderBy('timestamp', descending: true);
    if (targetId != null) {
      query = query.where('targetId', isEqualTo: targetId);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => AuditLog.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }
}