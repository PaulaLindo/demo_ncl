// lib/providers/scheduler_provider.dart - Simplified version
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../models/job_model.dart';
import '../models/staff_model.dart' as staff_model;
import '../models/user_model.dart';
import '../models/quality_flag_model.dart';
import '../models/time_record_model.dart';
import '../models/booking_model.dart' as booking_model;

import 'base_provider.dart';
import 'staff_provider.dart';
import 'timekeeping_provider.dart';
import 'auth_provider.dart';

class SchedulerProvider extends BaseProvider {
  final StaffProvider _staffProvider;
  final TimekeepingProvider _timekeepingProvider;
  final AuthProvider _authProvider;

  // Job Assignment State
  List<Job> _jobs = [];
  final List<QualityFlag> _qualityFlags = [];
  
  // Integration State
  final List<TimeRecord> _timeRecords = [];
  final List<booking_model.Booking> _customerBookings = [];

  SchedulerProvider({
    required StaffProvider staffProvider,
    required TimekeepingProvider timekeepingProvider,
    required AuthProvider authProvider,
    Logger? logger,
  }) : _staffProvider = staffProvider,
       _timekeepingProvider = timekeepingProvider,
       _authProvider = authProvider,
       super(logger ?? Logger('SchedulerProvider'));

  // Getters
  List<Job> get jobs => _jobs;
  List<QualityFlag> get qualityFlags => _qualityFlags;
  List<TimeRecord> get timeRecords => _timeRecords;
  List<booking_model.Booking> get customerBookings => _customerBookings;

  // Initialize the provider
  Future<void> initialize() async {
    try {
      _setLoading(true);
      await _loadInitialData();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to initialize scheduler: $e');
      _setLoading(false);
      rethrow;
    }
  }

  // Load initial data
  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadJobs(),
      _loadQualityFlags(),
      _loadTimeRecords(),
      _loadCustomerBookings(),
    ]);
  }

  // Load jobs
  Future<void> _loadJobs() async {
    // Get jobs from staff provider
    final staffJobs = _staffProvider.jobs;
    _jobs = staffJobs;
  }

  // Load quality flags
  Future<void> _loadQualityFlags() async {
    // Mock quality flags for now
    _qualityFlags.clear();
  }

  // Load time records
  Future<void> _loadTimeRecords() async {
    // Get time records from timekeeping provider
    final records = _timekeepingProvider.timeRecords;
    _timeRecords.clear();
    _timeRecords.addAll(records);
  }

  // Load customer bookings
  Future<void> _loadCustomerBookings() async {
    // Mock customer bookings for now
    _customerBookings.clear();
  }

  // Get jobs for staff
  List<Job> getJobsForStaff(String staffId) {
    // For now, return all jobs since Job model doesn't have staff assignment
    // In a real implementation, this would filter by assigned staff
    return _jobs;
  }

  // Get quality flags for job
  List<QualityFlag> getQualityFlagsForJob(String jobId) {
    return _qualityFlags.where((flag) => flag.jobId == jobId).toList();
  }

  // Get time records for staff
  List<TimeRecord> getTimeRecordsForStaff(String staffId) {
    return _timeRecords.where((record) => record.staffId == staffId).toList();
  }

  // Get customer bookings
  List<booking_model.Booking> getCustomerBookings(String customerId) {
    return _customerBookings.where((booking) => booking.customerId == customerId).toList();
  }

  // Create quality flag
  Future<void> createQualityFlag({
    required String jobId,
    required String jobName,
    required String staffId,
    required String staffName,
    required String issueType,
    required String description,
    required int severity,
  }) async {
    try {
      final qualityFlag = QualityFlag(
        id: 'quality_${DateTime.now().millisecondsSinceEpoch}',
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

      _qualityFlags.add(qualityFlag);
      _notifyListeners();
      
      logger.info('Quality flag created: ${qualityFlag.id}');
    } catch (e) {
      _setError('Failed to create quality flag: $e');
      logger.severe('Quality flag creation error: $e');
      rethrow;
    }
  }

  // Resolve quality flag
  Future<void> resolveQualityFlag(String qualityFlagId, String resolution, String resolvedBy) async {
    try {
      final index = _qualityFlags.indexWhere((flag) => flag.id == qualityFlagId);
      if (index != -1) {
        final flag = _qualityFlags[index];
        _qualityFlags[index] = flag.copyWith(
          status: QualityFlagStatus.resolved,
          resolution: resolution,
          resolvedBy: resolvedBy,
          resolvedAt: DateTime.now(),
        );
        _notifyListeners();
        
        logger.info('Quality flag resolved: $qualityFlagId');
      }
    } catch (e) {
      _setError('Failed to resolve quality flag: $e');
      logger.severe('Quality flag resolution error: $e');
      rethrow;
    }
  }

  // Create customer booking
  Future<void> createCustomerBooking({
    required String customerId,
    required String serviceId,
    required String serviceName,
    required DateTime bookingDate,
    required String address,
    required double basePrice,
  }) async {
    try {
      final booking = booking_model.Booking(
        id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
        customerId: customerId,
        serviceId: serviceId,
        serviceName: serviceName,
        bookingDate: bookingDate,
        timePreference: booking_model.TimeOfDayPreference.flexible,
        address: address,
        status: booking_model.BookingStatus.pending,
        basePrice: basePrice,
        propertySize: booking_model.PropertySize.medium,
        frequency: booking_model.BookingFrequency.oneTime,
        startTime: bookingDate,
        endTime: bookingDate.add(const Duration(hours: 2)),
        createdAt: DateTime.now(),
      );

      _customerBookings.add(booking);
      _notifyListeners();
      
      logger.info('Customer booking created: ${booking.id}');
    } catch (e) {
      _setError('Failed to create customer booking: $e');
      logger.severe('Customer booking creation error: $e');
      rethrow;
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, booking_model.BookingStatus status) async {
    try {
      final index = _customerBookings.indexWhere((booking) => booking.id == bookingId);
      if (index != -1) {
        final booking = _customerBookings[index];
        _customerBookings[index] = booking.copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        _notifyListeners();
        
        logger.info('Booking status updated: $bookingId to $status');
      }
    } catch (e) {
      _setError('Failed to update booking status: $e');
      logger.severe('Booking status update error: $e');
      rethrow;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    // This would be implemented in BaseProvider
  }

  void _setError(String error) {
    // This would be implemented in BaseProvider
  }

  void _notifyListeners() {
    // This would be implemented in BaseProvider
  }
}
