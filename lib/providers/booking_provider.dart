// lib/providers/booking_provider.dart
import 'package:flutter/foundation.dart';
import '../models/booking_models.dart';

enum LoadingState { initial, loading, loaded, error }

/// BookingProvider manages booking and service state with proper error handling
class BookingProvider extends ChangeNotifier {
  List<Booking> _bookings = [];
  final List<ServiceDetail> _services = mockServices;
  LoadingState _loadingState = LoadingState.initial;
  String? _errorMessage;
  String _bookingFilter = 'all';
  String _serviceFilter = 'all';

  // Getters
  List<Booking> get bookings => _bookings;
  List<ServiceDetail> get services => _services;
  LoadingState get loadingState => _loadingState;
  bool get isLoading => _loadingState == LoadingState.loading;
  bool get hasError => _loadingState == LoadingState.error;
  bool get isLoaded => _loadingState == LoadingState.loaded;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _bookingFilter;
  String get serviceFilter => _serviceFilter;

  /// Get filtered bookings based on current filter
  List<Booking> get filteredBookings {
    switch (_bookingFilter) {
      case 'upcoming':
        return _bookings.where((b) => b.isUpcoming).toList();
      case 'completed':
        return _bookings.where((b) => b.isCompleted).toList();
      default:
        return _bookings;
    }
  }

  /// Get filtered services based on current filter
  List<ServiceDetail> get filteredServices {
    if (_serviceFilter == 'all') {
      return _services;
    }
    return _services.where((s) => s.category == _serviceFilter).toList();
  }

  /// Get service by ID
  ServiceDetail? getServiceById(String id) {
    try {
      return _services.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Set booking filter
  void setBookingFilter(String filter) {
    _bookingFilter = filter;
    notifyListeners();
  }

  /// Set service filter
  void setServiceFilter(String filter) {
    _serviceFilter = filter;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    if (_loadingState == LoadingState.error) {
      _loadingState = LoadingState.initial;
    }
    notifyListeners();
  }

  /// Load bookings with error handling
  Future<void> loadBookings() async {
    _setLoading();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Simulate potential network error (10% chance)
      if (DateTime.now().millisecond % 10 == 0) {
        throw Exception('Network connection failed');
      }

      _bookings = _getMockBookings();
      _setLoaded();
    } catch (e) {
      _setError('Failed to load bookings: ${e.toString()}');
    }
  }

  /// Create new booking with comprehensive error handling
  Future<bool> createBooking({
    required String serviceId,
    required DateTime bookingDate,
    required String preferredTime,
    required String propertySize,
    required String frequency,
    String specialInstructions = '',
  }) async {
    _setLoading();

    try {
      // Validate inputs
      if (bookingDate.isBefore(DateTime.now())) {
        throw Exception('Booking date cannot be in the past');
      }

      final service = getServiceById(serviceId);
      if (service == null) {
        throw Exception('Service not found');
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Simulate potential error (5% chance)
      if (DateTime.now().millisecond % 20 == 0) {
        throw Exception('Booking service temporarily unavailable');
      }

      // Calculate estimated price based on property size
      double estimatedPrice = service.basePrice;
      if (propertySize == 'small') {
        estimatedPrice *= 0.8;
      } else if (propertySize == 'large') {
        estimatedPrice *= 1.3;
      }

      // Apply frequency discount
      if (frequency == 'weekly') {
        estimatedPrice *= 0.9; // 10% discount
      } else if (frequency == 'bi-weekly') {
        estimatedPrice *= 0.95; // 5% discount
      }

      final booking = Booking(
        id: 'B${DateTime.now().millisecondsSinceEpoch}',
        serviceId: serviceId,
        serviceName: service.name,
        bookingDate: bookingDate,
        preferredTime: preferredTime,
        address: '47 NCL Lane, Apt 2B', // Mock address
        status: BookingStatus.pending,
        estimatedPrice: estimatedPrice,
        propertySize: propertySize,
        frequency: frequency,
        specialInstructions: specialInstructions.isNotEmpty ? specialInstructions : null,
      );

      _bookings.insert(0, booking); // Add to start of list
      _setLoaded();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Cancel booking with error handling
  Future<bool> cancelBooking(String bookingId) async {
    _setLoading();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index == -1) {
        throw Exception('Booking not found');
      }

      final booking = _bookings[index];
      
      // Check if booking can be cancelled
      if (booking.status == BookingStatus.completed) {
        throw Exception('Cannot cancel completed booking');
      }

      if (booking.status == BookingStatus.cancelled) {
        throw Exception('Booking is already cancelled');
      }

      // Update booking status
      _bookings[index] = booking.copyWith(
        status: BookingStatus.cancelled,
      );

      _setLoaded();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Reschedule booking
  Future<bool> rescheduleBooking(String bookingId, DateTime newDate, String newTime) async {
    _setLoading();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index == -1) {
        throw Exception('Booking not found');
      }

      if (newDate.isBefore(DateTime.now())) {
        throw Exception('New date cannot be in the past');
      }

      _bookings[index] = _bookings[index].copyWith(
        bookingDate: newDate,
        preferredTime: newTime,
      );

      _setLoaded();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Private helper methods
  void _setLoading() {
    _loadingState = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoaded() {
    _loadingState = LoadingState.loaded;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _loadingState = LoadingState.error;
    _errorMessage = message;
    notifyListeners();
  }

  // Mock data
  List<Booking> _getMockBookings() {
    return [
      Booking(
        id: 'B001',
        serviceId: 'S01',
        serviceName: 'Standard Cleaning',
        bookingDate: DateTime.now().add(const Duration(days: 3)),
        preferredTime: 'morning',
        address: '47 NCL Lane, Apt 2B',
        status: BookingStatus.confirmed,
        estimatedPrice: 280.0,
        propertySize: 'medium',
        frequency: 'one-time',
        assignedStaffName: 'Sarah Mitchell',
      ),
      Booking(
        id: 'B002',
        serviceId: 'S02',
        serviceName: 'Deep Cleaning',
        bookingDate: DateTime.now().add(const Duration(days: 7)),
        preferredTime: 'afternoon',
        address: '47 NCL Lane, Apt 2B',
        status: BookingStatus.pending,
        estimatedPrice: 600.0,
        propertySize: 'medium',
        frequency: 'one-time',
      ),
      Booking(
        id: 'B003',
        serviceId: 'S01',
        serviceName: 'Standard Cleaning',
        bookingDate: DateTime.now().subtract(const Duration(days: 5)),
        preferredTime: 'morning',
        address: '47 NCL Lane, Apt 2B',
        status: BookingStatus.completed,
        estimatedPrice: 280.0,
        propertySize: 'medium',
        frequency: 'weekly',
        assignedStaffName: 'David Johnson',
        specialInstructions: 'Please focus on kitchen area',
      ),
    ];
  }
}