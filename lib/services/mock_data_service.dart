// lib/services/mock_data_service.dart
import 'dart:async';
import 'package:logging/logging.dart';

import '../models/auth_model.dart';
import '../models/booking_model.dart';
import '../models/job_model.dart';

/// A service that provides mock data for development and testing purposes
class MockDataService {
  static final Logger _logger = Logger('MockDataService');

  // Mock user data with passwords for demonstration
  final List<AuthUser> _users = [
    AuthUser(
      id: '1',
      email: 'customer@example.com',
      role: UserRole.customer,
      firstName: 'John',
      lastName: 'Doe',
      password: 'customer123', // In a real app, this would be hashed
    ),
    const AuthUser(
      id: '2',
      email: 'staff@example.com',
      role: UserRole.staff,
      firstName: 'Jane',
      lastName: 'Smith',
      password: 'staff123', // In a real app, this would be hashed
    ),
    AuthUser(
      id: '3',
      email: 'admin@example.com',
      role: UserRole.admin,
      firstName: 'Admin',
      lastName: 'User',
      password: 'admin123', // In a real app, this would be hashed
    ),
  ];

  // Mock booking data
  final List<Booking> _bookings = [
    Booking(
      id: '101',
      customerId: '1',
      serviceId: 's1',
      serviceName: 'Standard Cleaning',
      bookingDate: DateTime.now().add(const Duration(days: 2)),
      timePreference: TimeOfDayPreference.morning,
      address: '123 Main St',
      status: BookingStatus.pending,
      basePrice: 250.0,
      propertySize: PropertySize.medium,
      frequency: BookingFrequency.oneTime,
      startTime: DateTime.now().add(const Duration(days: 2, hours: 9)),
      endTime: DateTime.now().add(const Duration(days: 2, hours: 11)),
      createdAt: DateTime.now(),
      notes: 'Please bring extra cleaning supplies',
    ),
    Booking(
      id: '102',
      customerId: '1',
      serviceId: 's2',
      serviceName: 'Deep Cleaning',
      bookingDate: DateTime.now().add(const Duration(days: 5)),
      timePreference: TimeOfDayPreference.afternoon,
      address: '456 Oak Ave',
      status: BookingStatus.pending,
      basePrice: 350.0,
      propertySize: PropertySize.large,
      frequency: BookingFrequency.oneTime,
      startTime: DateTime.now().add(const Duration(days: 5, hours: 14)),
      endTime: DateTime.now().add(const Duration(days: 5, hours: 18)),
      createdAt: DateTime.now(),
      notes: 'Pet-friendly home',
    ),
  ];

  // Mock job service data
  final List<Job> _services = [
    Job(
      id: 's1',
      title: 'Standard Cleaning',
      location: 'Residential Area',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 2)),
    ),
    Job(
      id: 's2',
      title: 'Deep Cleaning',
      location: 'Residential Area',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 4)),
    ),
    Job(
      id: 's3',
      title: 'Office Cleaning',
      location: 'Commercial Area',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 3)),
    ),
  ];

  // In-memory cache for data
  final Map<String, dynamic> _cache = {};
  static const Duration _defaultDelay = Duration(milliseconds: 500);

  /// Simulates a network delay
  Future<void> _simulateNetworkDelay([Duration? delay]) async {
    await Future.delayed(delay ?? _defaultDelay);
  }

  /// Gets a user by email and password
  Future<AuthResult> authenticateUser(String email, String password) async {
    try {
      await _simulateNetworkDelay();
      
      final user = _users.firstWhere(
        (user) => user.email == email,
        orElse: () => throw StateError('User not found'),
      );

      // Verify password (in a real app, this would be hashed password comparison)
      if (user.password != password) {
        return AuthResult.failure('Invalid credentials');
      }

      // Return a copy without the password
      return AuthResult.success(user.copyWith(password: null));
    } catch (e, stackTrace) {
      _logger.severe('Authentication failed', e, stackTrace);
      return AuthResult.failure(
        e is StateError ? 'User not found' : 'Invalid credentials',
      );
    }
  }

  /// Gets a user by ID
  Future<AuthUser?> getUserById(String id) async {
    try {
      await _simulateNetworkDelay();
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      _logger.warning('User not found with ID: $id');
      return null;
    }
  }

  /// Gets a user by email
  Future<AuthUser?> getUserByEmail(String email) async {
    try {
      await _simulateNetworkDelay();
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      _logger.warning('User not found with email: $email');
      return null;
    }
  }

  /// Gets all bookings for a customer
  Future<List<Booking>> getBookingsForCustomer(String customerId) async {
    try {
      await _simulateNetworkDelay();
      return _bookings
          .where((booking) => booking.customerId == customerId)
          .toList();
    } catch (e, stackTrace) {
      _logger.severe('Failed to fetch bookings', e, stackTrace);
      rethrow;
    }
  }

  /// Gets all bookings for a staff member
  Future<List<Booking>> getBookingsForStaff(String staffId) async {
    try {
      await _simulateNetworkDelay();
      // In a real app, this would filter by assigned staff
      return List<Booking>.from(_bookings);
    } catch (e, stackTrace) {
      _logger.severe('Failed to fetch staff bookings', e, stackTrace);
      rethrow;
    }
  }

  /// Gets all available services
  Future<List<Job>> getAllServices() async {
    try {
      const cacheKey = 'all_services';
      if (_cache.containsKey(cacheKey)) {
        return _cache[cacheKey] as List<Job>;
      }

      await _simulateNetworkDelay();
      _cache[cacheKey] = List<Job>.from(_services);
      return _cache[cacheKey];
    } catch (e, stackTrace) {
      _logger.severe('Failed to fetch services', e, stackTrace);
      rethrow;
    }
  }

  /// Gets a service by ID
  Future<Job?> getServiceById(String serviceId) async {
    try {
      await _simulateNetworkDelay();
      return _services.firstWhere((service) => service.id == serviceId);
    } catch (e) {
      _logger.warning('Service not found with ID: $serviceId');
      return null;
    }
  }

  /// Creates a new booking
  Future<Booking> createBooking(Booking booking) async {
    try {
      await _simulateNetworkDelay();
      // In a real app, this would validate the booking and save to a database
      final newBooking = booking.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        status: BookingStatus.pending,
      );
      
      _bookings.add(newBooking);
      _invalidateCache('bookings');
      
      return newBooking;
    } catch (e, stackTrace) {
      _logger.severe('Failed to create booking', e, stackTrace);
      rethrow;
    }
  }

  /// Updates an existing booking
  Future<Booking> updateBooking(Booking booking) async {
    try {
      await _simulateNetworkDelay();
      final index = _bookings.indexWhere((b) => b.id == booking.id);
      if (index == -1) {
        throw Exception('Booking not found');
      }
      
      _bookings[index] = booking;
      _invalidateCache('bookings');
      
      return booking;
    } catch (e, stackTrace) {
      _logger.severe('Failed to update booking', e, stackTrace);
      rethrow;
    }
  }

  /// Invalidates cached data
  void _invalidateCache(String key) {
    _cache.remove(key);
  }

  /// Clears all cached data
  void clearCache() {
    _cache.clear();
  }
}