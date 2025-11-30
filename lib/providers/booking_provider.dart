// lib/providers/booking_provider.dart
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../models/booking_model.dart';

class ServiceDetail {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final String duration;
  final String category;
  final bool isPopular;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final String priceDisplay;
  final List<String> features;

  ServiceDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.duration,
    required this.category,
    this.isPopular = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isFeatured = false,
    String? priceDisplay,
    List<String>? features,
  }) : priceDisplay = priceDisplay ?? 'R${basePrice.toInt()}',
       features = features ?? <String>[];
}

// Mock services data
final List<ServiceDetail> mockServices = [
  ServiceDetail(
    id: 's1',
    name: 'Standard Cleaning',
    description: 'A thorough standard cleaning of your home.',
    basePrice: 50.0,
    duration: '2 hours',
    category: 'Residential',
    isPopular: true,
    rating: 4.5,
    reviewCount: 128,
    isFeatured: false,
    features: ['Living room cleaning', 'Kitchen cleaning', 'Bathroom cleaning', 'Bedroom dusting'],
  ),
  ServiceDetail(
    id: 's2',
    name: 'Deep Cleaning',
    description: 'A comprehensive deep clean for a spotless finish.',
    basePrice: 100.0,
    duration: '4 hours',
    category: 'Residential',
    isPopular: false,
    rating: 4.8,
    reviewCount: 89,
    isFeatured: true,
    features: ['Deep scrub all surfaces', 'Window cleaning', 'Carpet shampooing', 'Oven cleaning', 'Refrigerator cleaning'],
  ),
  ServiceDetail(
    id: 's3',
    name: 'Office Cleaning',
    description: 'Professional cleaning for office spaces.',
    basePrice: 150.0,
    duration: '3 hours',
    category: 'Commercial',
    isPopular: true,
    rating: 4.2,
    reviewCount: 56,
    isFeatured: false,
    features: ['Desk sanitization', 'Floor cleaning', 'Trash removal', 'Common area cleaning'],
  ),
];

enum LoadingState { 
  initial, 
  loading, 
  loaded, 
  error 
}

/// BookingProvider manages booking and service state with proper error handling
class BookingProvider extends ChangeNotifier {
  final Logger _logger = Logger('BookingProvider');

  List<Booking> _bookings = [];
  final List<ServiceDetail> _services = mockServices;

  LoadingState _loadingState = LoadingState.initial;
  
  String? _errorMessage;

  bool _isLoading = false;

  String _bookingFilter = 'all';
  String _serviceFilter = 'all';

  // Getters
  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<ServiceDetail> get services => List.unmodifiable(_services);

  LoadingState get loadingState => _loadingState;

  bool get isLoading => _loadingState == LoadingState.loading;
  bool get hasError => _loadingState == LoadingState.error;
  bool get isLoaded => _loadingState == LoadingState.loaded;

  String? get errorMessage => _errorMessage;
  String get currentFilter => _bookingFilter;
  String get serviceFilter => _serviceFilter;

  Future<void> addBooking(Booking booking) async {
    _setLoading(true);
    try {
      _bookings.add(booking);
      notifyListeners();
    } catch (e, stackTrace) {
      _handleError('Failed to add booking', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _loadingState = loading ? LoadingState.loading : LoadingState.initial;
      notifyListeners();
    }
  }

  void _handleError(String message, dynamic error, StackTrace stackTrace) {
    _errorMessage = message;
    _logger.severe(message, error, stackTrace);
    notifyListeners();
  }

  // Add a method to get bookings by status
  List<Booking> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((booking) => booking.status == status).toList();
  }

  // Add a method to get upcoming bookings
  List<Booking> getUpcomingBookings() {
    final now = DateTime.now();
    return _bookings.where((booking) => 
      booking.bookingDate.isAfter(now) && 
      booking.status != BookingStatus.cancelled &&
      booking.status != BookingStatus.completed
    ).toList();
  }

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

  // Helper methods for state management

  void _setLoaded() {
    _loadingState = LoadingState.loaded;
    notifyListeners();
  }

  void _setError(String message) {
    _loadingState = LoadingState.error;
    _errorMessage = message;
    notifyListeners();
  }

  // Add a method to cancel a booking
  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    _setLoading(true);
    try {
      // In a real app, this would call an API
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: BookingStatus.cancelled,
          cancellationReason: reason,
          updatedAt: DateTime.now(),
        );
        _setLoaded();
      } else {
        _setError('Booking not found');
      }
    } catch (e) {
      _setError('Failed to cancel booking: ${e.toString()}');
    }
  }

  // Add a method to reschedule a booking
  Future<void> rescheduleBooking({
    required String bookingId,
    required DateTime newDate,
    TimeOfDayPreference? newTimePreference,
  }) async {
    _setLoading(true);
    try {
      // In a real app, this would call an API
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          bookingDate: newDate,
          timePreference: newTimePreference ?? _bookings[index].timePreference,
          status: BookingStatus.confirmed, // Reset status to confirmed
          updatedAt: DateTime.now(),
        );
        _setLoaded();
      } else {
        _setError('Booking not found');
      }
    } catch (e) {
      _setError('Failed to reschedule booking: ${e.toString()}');
    }
  }

  /// Load bookings with error handling
  Future<void> loadBookings() async {
    _setLoading(true);

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
    required String address,
    required String propertySize,
    required String frequency,
    TimeOfDayPreference? timePreference,
    String? notes,
  }) async {
    _setLoading(true);
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Simulate potential validation error (5% chance) - REMOVED for reliability
      // if (DateTime.now().millisecond % 20 == 0) {
      //   throw Exception('Service not available on selected date');
      // }

      final service = getServiceById(serviceId);
      if (service == null) {
        _setError('Service not found');
        return false;
      }

      final propertySizeEnum = PropertySize.values.firstWhere(
        (size) => size.name == propertySize,
        orElse: () => PropertySize.medium,
      );
      
      final frequencyEnum = BookingFrequency.values.firstWhere(
        (freq) => freq.name == frequency,
        orElse: () => BookingFrequency.oneTime,
      );

      // Calculate final price
      final calculatedFinalPrice = Booking.calculateFinalPrice(
        service.basePrice,
        propertySizeEnum.priceMultiplier,
        frequencyEnum.discountMultiplier,
      );

      final newBooking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: 'C001',
        serviceId: serviceId,
        serviceName: service.name,
        bookingDate: bookingDate,
        timePreference: timePreference ?? TimeOfDayPreference.morning,
        address: address,
        status: BookingStatus.pending,
        basePrice: service.basePrice,
        propertySize: propertySizeEnum,
        frequency: frequencyEnum,
        startTime: bookingDate,
        endTime: bookingDate.add(const Duration(hours: 2)),
        createdAt: DateTime.now(),
        notes: notes,
        finalPrice: calculatedFinalPrice,
      );

      _bookings.insert(0, newBooking); // Add to start of list
      _setLoaded();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update booking method example
  void updateBooking(Booking booking) {
    final index = _bookings.indexWhere((b) => b.id == booking.id);
    if (index != -1) {
      _bookings[index] = booking;
      notifyListeners();
    }
  }

  // Mock data
  List<Booking> _getMockBookings() {
    return [
      Booking(
        id: 'B001',
        customerId: 'C001',
        serviceId: 'S01',
        serviceName: 'Standard Cleaning',
        bookingDate: DateTime.now().add(const Duration(days: 3)),
        timePreference: TimeOfDayPreference.morning,
        address: '47 NCL Lane, Apt 2B',
        status: BookingStatus.confirmed,
        basePrice: 250.0,
        propertySize: PropertySize.medium,
        frequency: BookingFrequency.oneTime,
        startTime: DateTime.now().add(const Duration(days: 3)),
        endTime: DateTime.now().add(const Duration(days: 3, hours: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        assignedStaffName: 'Sarah Mitchell',
      ),
      Booking(
        id: 'B002',
        customerId: 'C002',
        serviceId: 'S02',
        serviceName: 'Deep Cleaning',
        bookingDate: DateTime.now().add(const Duration(days: 7)),
        timePreference: TimeOfDayPreference.afternoon,
        address: '47 NCL Lane, Apt 2B',
        status: BookingStatus.pending,
        basePrice: 550.0,
        propertySize: PropertySize.medium,
        frequency: BookingFrequency.oneTime,
        startTime: DateTime.now().add(const Duration(days: 7)),
        endTime: DateTime.now().add(const Duration(days: 7, hours: 4)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Booking(
        id: 'B003',
        customerId: 'C003',
        serviceId: 'S01',
        serviceName: 'Standard Cleaning',
        bookingDate: DateTime.now().subtract(const Duration(days: 5)),
        timePreference: TimeOfDayPreference.morning,
        address: '47 NCL Lane, Apt 2B',
        status: BookingStatus.completed,
        basePrice: 250.0,
        propertySize: PropertySize.medium,
        frequency: BookingFrequency.weekly,
        startTime: DateTime.now().subtract(const Duration(days: 5)),
        endTime: DateTime.now().subtract(const Duration(days: 5, hours: -2)),
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        assignedStaffName: 'David Johnson',
        specialInstructions: 'Please focus on kitchen area',
      ),
    ];
  }

  // Methods for tests compatibility
  void updateBookingStatus(String bookingId, BookingStatus status) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index != -1) {
      final updatedBooking = _bookings[index].copyWith(status: status);
      _bookings[index] = updatedBooking;
      notifyListeners();
    }
  }

  List<Booking> getBookingsForCustomer(String customerId) {
    return _bookings.where((booking) => booking.customerId == customerId).toList();
  }
}
