// lib/providers/availability_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/availability_model.dart';
import '../models/pricing_model.dart';

class AvailabilityProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  AvailabilityCheckResult? _currentAvailability;
  List<DailyAvailability> _weeklyAvailability = [];
  DateTime? _selectedDate;
  TimeSlot? _selectedTimeSlot;
  String? _selectedStaffId;
  List<String> _conflictingBookings = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  AvailabilityCheckResult? get currentAvailability => _currentAvailability;
  List<DailyAvailability> get weeklyAvailability => List.unmodifiable(_weeklyAvailability);
  DateTime? get selectedDate => _selectedDate;
  TimeSlot? get selectedTimeSlot => _selectedTimeSlot;
  String? get selectedStaffId => _selectedStaffId;
  List<String> get conflictingBookings => List.unmodifiable(_conflictingBookings);

  // Check availability for a specific date and service
  Future<bool> checkAvailability({
    required DateTime date,
    required ServiceType serviceType,
    required PropertySize propertySize,
    String? preferredStaffId,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // Generate mock availability data
      final availability = _generateMockAvailability(date, serviceType, propertySize);
      
      _currentAvailability = availability;
      _weeklyAvailability = availability.weeklyAvailability;
      _conflictingBookings = availability.conflictingBookings;

      _setLoading(false);
      return availability.isAvailable;
    } catch (e) {
      _setError('Failed to check availability: $e');
      _setLoading(false);
      return false;
    }
  }

  // Check availability for a week
  Future<AvailabilityCheckResult> checkWeeklyAvailability({
    required DateTime startDate,
    required ServiceType serviceType,
    required PropertySize propertySize,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1000));

      final weeklyAvailability = _generateMockWeeklyAvailability(startDate, serviceType, propertySize);
      
      _weeklyAvailability = weeklyAvailability.weeklyAvailability;
      _currentAvailability = weeklyAvailability;

      _setLoading(false);
      return weeklyAvailability;
    } catch (e) {
      _setError('Failed to check weekly availability: $e');
      _setLoading(false);
      rethrow;
    }
  }

  // Select a date and time slot
  Future<bool> selectDateTime({
    required DateTime date,
    required TimeSlot timeSlot,
    String? staffId,
  }) async {
    // Check if the slot is still available
    if (!timeSlot.isAvailable || timeSlot.currentBookings >= timeSlot.maxBookings) {
      _setError('Selected time slot is no longer available');
      return false;
    }

    _selectedDate = date;
    _selectedTimeSlot = timeSlot;
    _selectedStaffId = staffId ?? timeSlot.staffId;

    // Check for conflicts
    await _checkForConflicts();

    notifyListeners();
    return true;
  }

  // Clear selection
  void clearSelection() {
    _selectedDate = null;
    _selectedTimeSlot = null;
    _selectedStaffId = null;
    _conflictingBookings.clear();
    notifyListeners();
  }

  // Check for booking conflicts
  Future<void> _checkForConflicts() async {
    if (_selectedDate == null || _selectedTimeSlot == null) return;

    try {
      // Simulate conflict check
      await Future.delayed(const Duration(milliseconds: 300));

      // Mock conflict check - in real app, this would query the backend
      final conflicts = <String>[];
      
      // Simulate occasional conflicts for demo
      if (kDebugMode && DateTime.now().millisecond % 10 == 0) {
        conflicts.add('Another booking exists for this time slot');
      }

      _conflictingBookings = conflicts;
    } catch (e) {
      _setError('Error checking conflicts: $e');
    }
  }

  // Generate mock availability data
  AvailabilityCheckResult _generateMockAvailability(
    DateTime date,
    ServiceType serviceType,
    PropertySize propertySize,
  ) {
    final timeSlots = _generateTimeSlotsForDate(date, serviceType, propertySize);
    final hasAvailability = timeSlots.any((slot) => slot.isAvailable);
    const fullyBooked = false;

    final dailyAvailability = DailyAvailability(
      date: date,
      timeSlots: timeSlots,
      isFullyBooked: fullyBooked,
      hasAvailability: hasAvailability,
    );

    return AvailabilityCheckResult(
      isAvailable: hasAvailability,
      weeklyAvailability: [dailyAvailability],
      conflictingBookings: [],
      message: hasAvailability ? 'Available slots found' : 'No availability found',
    );
  }

  // Generate mock weekly availability
  AvailabilityCheckResult _generateMockWeeklyAvailability(
    DateTime startDate,
    ServiceType serviceType,
    PropertySize propertySize,
  ) {
    final weeklyDays = <DailyAvailability>[];
    var hasAnyAvailability = false;

    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      final timeSlots = _generateTimeSlotsForDate(date, serviceType, propertySize);
      final hasAvailability = timeSlots.any((slot) => slot.isAvailable);
      
      if (hasAvailability) hasAnyAvailability = true;

      weeklyDays.add(DailyAvailability(
        date: date,
        timeSlots: timeSlots,
        isFullyBooked: !hasAvailability,
        hasAvailability: hasAvailability,
      ));
    }

    return AvailabilityCheckResult(
      isAvailable: hasAnyAvailability,
      weeklyAvailability: weeklyDays,
      conflictingBookings: [],
      message: hasAnyAvailability ? 'Available slots found this week' : 'No availability this week',
    );
  }

  // Generate time slots for a specific date
  List<TimeSlot> _generateTimeSlotsForDate(
    DateTime date,
    ServiceType serviceType,
    PropertySize propertySize,
  ) {
    final timeSlots = <TimeSlot>[];
    final serviceDuration = _getServiceDuration(serviceType, propertySize);
    
    // Generate slots from 8 AM to 8 PM
    for (int hour = 8; hour < 20; hour++) {
      final startTime = DateTime(date.year, date.month, date.day, hour);
      final endTime = startTime.add(serviceDuration);

      // Skip if end time goes past 8 PM
      if (endTime.hour > 20) continue;

      // Skip weekends for some services
      if (date.weekday >= 6 && serviceType == ServiceType.postConstruction) continue;

      // Random availability for demo
      final randomAvailability = _getRandomAvailability(hour, date.weekday);
      final currentBookings = _getCurrentBookings(hour, date.weekday);
      final maxBookings = _getMaxBookings(serviceType);

      timeSlots.add(TimeSlot(
        startTime: startTime,
        endTime: endTime,
        isAvailable: randomAvailability && currentBookings < maxBookings,
        staffId: 'staff_${hour % 3 + 1}',
        staffName: 'Staff Member ${(hour % 3) + 1}',
        maxBookings: maxBookings,
        currentBookings: currentBookings,
      ));
    }

    return timeSlots;
  }

  // Get service duration based on type and property size
  Duration _getServiceDuration(ServiceType serviceType, PropertySize propertySize) {
    final baseDurations = {
      ServiceType.regularCleaning: 2,
      ServiceType.deepCleaning: 4,
      ServiceType.windowCleaning: 2,
      ServiceType.carpetCleaning: 3,
      ServiceType.kitchenCleaning: 2,
      ServiceType.bathroomCleaning: 1.5,
      ServiceType.moveInOutCleaning: 5,
      ServiceType.postConstruction: 6,
    };

    final baseHours = baseDurations[serviceType] ?? 2;
    final sizeMultiplier = propertySize.multiplier;
    final totalHours = (baseHours * sizeMultiplier).round();

    return Duration(hours: totalHours);
  }

  // Get random availability (for demo purposes)
  bool _getRandomAvailability(int hour, int weekday) {
    // Higher availability on weekdays
    if (weekday >= 1 && weekday <= 5) {
      return hour >= 9 && hour <= 17 && (hour % 3 != 0); // Every 3rd hour is unavailable
    } else {
      // Lower availability on weekends
      return hour >= 10 && hour <= 16 && (hour % 2 == 0); // Every 2nd hour is available
    }
  }

  // Get current bookings for demo
  int _getCurrentBookings(int hour, int weekday) {
    // Simulate higher bookings during peak hours
    if (hour >= 10 && hour <= 14) return (hour % 3);
    if (hour >= 15 && hour <= 17) return (hour % 2);
    return 0;
  }

  // Get max bookings based on service type
  int _getMaxBookings(ServiceType serviceType) {
    switch (serviceType) {
      case ServiceType.regularCleaning:
        return 3;
      case ServiceType.deepCleaning:
        return 2;
      case ServiceType.windowCleaning:
        return 2;
      case ServiceType.carpetCleaning:
        return 1;
      case ServiceType.kitchenCleaning:
        return 2;
      case ServiceType.bathroomCleaning:
        return 3;
      case ServiceType.moveInOutCleaning:
        return 1;
      case ServiceType.postConstruction:
        return 1;
    }
  }

  // Get available time slots for a specific date
  List<TimeSlot> getAvailableSlotsForDate(DateTime date) {
    final dailyAvailability = _weeklyAvailability.firstWhere(
      (day) => _isSameDay(day.date, date),
      orElse: () => DailyAvailability(
        date: date,
        timeSlots: [],
        isFullyBooked: true,
        hasAvailability: false,
      ),
    );

    return dailyAvailability.availableSlots;
  }

  // Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Get next available date
  DateTime? getNextAvailableDate() {
    for (final day in _weeklyAvailability) {
      if (day.hasAvailability && day.availableSlotCount > 0) {
        return day.date;
      }
    }
    return null;
  }

  // Check if selected slot is valid
  bool get isSelectionValid {
    return _selectedDate != null && 
           _selectedTimeSlot != null && 
           _selectedTimeSlot!.isAvailable &&
           _conflictingBookings.isEmpty;
  }

  // Get selection summary
  Map<String, dynamic> getSelectionSummary() {
    if (!isSelectionValid) return {};

    return {
      'date': _selectedDate.toString(),
      'time': _selectedTimeSlot!.timeRange,
      'staff': _selectedTimeSlot!.staffName,
      'duration': '${_selectedTimeSlot!.duration.inHours} hours',
      'status': _selectedTimeSlot!.statusText,
    };
  }

  // Loading and error management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Reset provider state
  void reset() {
    _isLoading = false;
    _error = null;
    _currentAvailability = null;
    _weeklyAvailability.clear();
    _selectedDate = null;
    _selectedTimeSlot = null;
    _selectedStaffId = null;
    _conflictingBookings.clear();
    notifyListeners();
  }
}
