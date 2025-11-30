// lib/providers/scheduler_provider.dart
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../models/job_model.dart';
import '../models/staff_model.dart' as staff_model;
import '../models/user_model.dart';
import '../models/transport_model.dart';
import '../models/availability_model.dart';
import '../models/quality_flag_model.dart';
import '../models/payroll_model.dart';
import '../models/time_record_model.dart';
import '../models/service_model.dart';
import '../models/pricing_model.dart';
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
  List<JobAssignment> get jobAssignments => List.unmodifiable(_jobAssignments);
  List<JobTemplate> get jobTemplates => List.unmodifiable(_jobTemplates);
  List<ServicePricing> get servicePricings => List.unmodifiable(_servicePricings);
  List<TransportRequest> get transportRequests => List.unmodifiable(_transportRequests);
  List<QualityFlag> get qualityFlags => List.unmodifiable(_qualityFlags);
  List<TrainingRecord> get trainingRecords => List.unmodifiable(_trainingRecords);
  Map<String, List<JobAssignment>> get staffSchedule => Map.unmodifiable(_staffSchedule);
  Map<DateTime, List<JobAssignment>> get dailySchedule => Map.unmodifiable(_dailySchedule);
  List<StaffAvailability> get staffAvailabilities => List.unmodifiable(_staffAvailabilities);
  List<PayrollEntry> get payrollEntries => List.unmodifiable(_payrollEntries);
  List<TimeRecord> get timeRecords => List.unmodifiable(_timeRecords);
  List<Booking> get customerBookings => List.unmodifiable(_customerBookings);

  // Initialize scheduler with mock data
  Future<void> initializeScheduler() async {
    _setLoading(true);
    try {
      await _loadJobTemplates();
      await _loadServicePricings();
      await _loadStaffAvailabilities();
      await _loadExistingAssignments();
      await _loadTrainingRecords();
      
      logger.info('Scheduler initialized successfully');
    } catch (e) {
      _setError('Failed to initialize scheduler: $e');
      logger.severe('Scheduler initialization error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ITC 5.1: Schedule-to-Job Assignment Flow
  Future<JobAssignment> createJobAssignment({
    required String serviceId,
    required String staffId,
    required DateTime scheduledDate,
    required String customerId,
    Map<String, dynamic>? customizations,
  }) async {
    _setLoading(true);
    try {
      // Get service pricing
      final service = _servicePricings.firstWhere((s) => s.serviceId == serviceId);
      final staff = _staffProvider.staff.firstWhere((s) => s.id == staffId);
      
      // Create job assignment
      final assignment = JobAssignment(
        id: 'job_${DateTime.now().millisecondsSinceEpoch}',
        serviceId: serviceId,
        staffId: staffId,
        customerId: customerId,
        scheduledDate: scheduledDate,
        status: JobAssignmentStatus.scheduled,
        basePrice: service.basePrice,
        estimatedDuration: service.estimatedDuration,
        customizations: customizations ?? {},
        createdAt: DateTime.now(),
      );

      _jobAssignments.add(assignment);
      
      // Update staff schedule
      _staffSchedule[staffId] = (_staffSchedule[staffId] ?? [])..add(assignment);
      
      // Update daily schedule
      final dateKey = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
      _dailySchedule[dateKey] = (_dailySchedule[dateKey] ?? [])..add(assignment);
      
      // Block staff availability during work hours
      await _blockStaffAvailability(staffId, scheduledDate, service.estimatedDuration);
      
      // Create customer booking
      await _createCustomerBooking(assignment);
      
      notifyListeners();
      logger.info('Job assignment created: ${assignment.id}');
      
      return assignment;
    } catch (e) {
      _setError('Failed to create job assignment: $e');
      logger.severe('Job assignment creation error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ITC 5.2: Managed Logistics to Punctuality
  Future<TransportRequest> requestTransport({
    required String jobAssignmentId,
    required String staffId,
    required String pickupLocation,
    required String destinationLocation,
    required DateTime pickupTime,
  }) async {
    try {
      final transportRequest = TransportRequest(
        id: 'transport_${DateTime.now().millisecondsSinceEpoch}',
        jobAssignmentId: jobAssignmentId,
        staffId: staffId,
        pickupLocation: pickupLocation,
        destinationLocation: destinationLocation,
        pickupTime: pickupTime,
        status: TransportStatus.requested,
        requestedAt: DateTime.now(),
      );

      _transportRequests.add(transportRequest);
      
      // Simulate Uber API integration
      await _simulateUberIntegration(transportRequest);
      
      notifyListeners();
      logger.info('Transport request created: ${transportRequest.id}');
      
      return transportRequest;
    } catch (e) {
      _setError('Failed to request transport: $e');
      logger.severe('Transport request error: $e');
      rethrow;
    }
  }

  Future<void> _simulateUberIntegration(TransportRequest request) async {
    // Simulate API call to Uber
    await Future.delayed(const Duration(seconds: 2));
    
    // Update request with Uber details
    final index = _transportRequests.indexWhere((r) => r.id == request.id);
    if (index != -1) {
      _transportRequests[index] = request.copyWith(
        status: TransportStatus.confirmed,
        uberDriverId: 'driver_${DateTime.now().millisecondsSinceEpoch}',
        uberVehicleInfo: 'Toyota Camry - ABC 123 GP',
        estimatedArrival: request.pickupTime.subtract(const Duration(minutes: 5)),
        estimatedDuration: const Duration(minutes: 25),
        cost: 85.0,
      );
    }
    
    notifyListeners();
  }

  // ITC 5.3: Quality-Gated Payroll Integration
  Future<QualityFlag> createQualityFlag({
    required String jobAssignmentId,
    required String staffId,
    required List<QualityChecklistItem> checklistItems,
    required int customerRating,
    String? customerNotes,
    List<String>? issues,
  }) async {
    try {
      final qualityFlag = QualityFlag(
        id: 'quality_${DateTime.now().millisecondsSinceEpoch}',
        jobAssignmentId: jobAssignmentId,
        staffId: staffId,
        checklistItems: checklistItems,
        customerRating: customerRating,
        customerNotes: customerNotes,
        issues: issues ?? [],
        status: QualityStatus.pendingReview,
        createdAt: DateTime.now(),
      );

      _qualityFlags.add(qualityFlag);
      
      // Update job assignment status
      await _updateJobAssignmentQuality(jobAssignmentId, qualityFlag);
      
      notifyListeners();
      logger.info('Quality flag created: ${qualityFlag.id}');
      
      return qualityFlag;
    } catch (e) {
      _setError('Failed to create quality flag: $e');
      logger.severe('Quality flag creation error: $e');
      rethrow;
    }
  }

  Future<PayrollEntry> processPayrollEntry({
    required String staffId,
    required DateTime workDate,
    required double hoursWorked,
    required double hourlyRate,
    required String qualityStatus,
    double? bonusAmount,
  }) async {
    try {
      // Calculate payroll based on quality status
      final qualityMultiplier = _getQualityMultiplier(qualityStatus);
      final basePay = hoursWorked * hourlyRate;
      final finalPay = basePay * qualityMultiplier + (bonusAmount ?? 0.0);

      final payrollEntry = PayrollEntry(
        id: 'payroll_${DateTime.now().millisecondsSinceEpoch}',
        staffId: staffId,
        workDate: workDate,
        hoursWorked: hoursWorked,
        hourlyRate: hourlyRate,
        basePay: basePay,
        qualityMultiplier: qualityMultiplier,
        bonusAmount: bonusAmount ?? 0.0,
        finalPay: finalPay,
        qualityStatus: qualityStatus,
        status: PayrollStatus.pending,
        createdAt: DateTime.now(),
      );

      _payrollEntries.add(payrollEntry);
      
      notifyListeners();
      logger.info('Payroll entry processed: ${payrollEntry.id}');
      
      return payrollEntry;
    } catch (e) {
      _setError('Failed to process payroll entry: $e');
      logger.severe('Payroll processing error: $e');
      rethrow;
    }
  }

  // ITC 5.4: Fixed-Price Quote to Billing
  Future<ServiceQuote> generateServiceQuote({
    required String serviceId,
    required Map<String, dynamic> customizations,
    required String customerId,
  }) async {
    try {
      final service = _servicePricings.firstWhere((s) => s.serviceId == serviceId);
      
      // Calculate dynamic pricing
      double basePrice = service.basePrice;
      
      // Add customization costs
      for (final customization in customizations.entries) {
        final option = service.customizationOptions
            .where((opt) => opt.id == customization.key)
            .firstOrNull;
        if (option != null) {
          final selectedOption = option.options
              .where((opt) => opt.id == customization.value)
              .firstOrNull;
          if (selectedOption != null) {
            basePrice += selectedOption.priceAdjustment;
          }
        }
      }

      final quote = ServiceQuote(
        id: 'quote_${DateTime.now().millisecondsSinceEpoch}',
        serviceId: serviceId,
        customerId: customerId,
        basePrice: service.basePrice,
        customizationPrice: basePrice - service.basePrice,
        totalPrice: basePrice,
        validUntil: DateTime.now().add(const Duration(days: 7)),
        customizations: customizations,
        status: QuoteStatus.draft,
        createdAt: DateTime.now(),
      );

      notifyListeners();
      logger.info('Service quote generated: ${quote.id}');
      
      return quote;
    } catch (e) {
      _setError('Failed to generate service quote: $e');
      logger.severe('Quote generation error: $e');
      rethrow;
    }
  }

  // ITC 5.5: Proxy Shift to Payroll Audit Trail
  Future<TempCardEntry> createTempCardEntry({
    required String staffId,
    required DateTime workDate,
    required double hoursWorked,
    required String workType,
    String? approvedBy,
    String? notes,
  }) async {
    try {
      final tempCard = TempCardEntry(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        staffId: staffId,
        workDate: workDate,
        hoursWorked: hoursWorked,
        workType: workType,
        approvedBy: approvedBy,
        notes: notes,
        status: TempCardStatus.pendingApproval,
        createdAt: DateTime.now(),
      );

      _tempCardEntries.add(tempCard);
      
      // Create corresponding payroll entry (pending approval)
      await _createPendingPayrollForTempCard(tempCard);
      
      notifyListeners();
      logger.info('Temp card entry created: ${tempCard.id}');
      
      return tempCard;
    } catch (e) {
      _setError('Failed to create temp card entry: $e');
      logger.severe('Temp card creation error: $e');
      rethrow;
    }
  }

  Future<void> approveTempCardEntry(String tempCardId, String approvedBy) async {
    try {
      final index = _tempCardEntries.indexWhere((entry) => entry.id == tempCardId);
      if (index != -1) {
        final tempCard = _tempCardEntries[index];
        _tempCardEntries[index] = tempCard.copyWith(
          status: TempCardStatus.approved,
          approvedBy: approvedBy,
          approvedAt: DateTime.now(),
        );

        // Update corresponding payroll entry
        await _approvePayrollForTempCard(tempCard);
        
        notifyListeners();
        logger.info('Temp card entry approved: $tempCardId');
      }
    } catch (e) {
      _setError('Failed to approve temp card entry: $e');
      logger.severe('Temp card approval error: $e');
    }
  }

  // ITC 5.6: Training Completion to Job Eligibility
  Future<TrainingRecord> updateTrainingCompletion({
    required String staffId,
    required String trainingId,
    required TrainingStatus status,
    DateTime? completionDate,
    String? certificateUrl,
  }) async {
    try {
      // Remove existing record if any
      _trainingRecords.removeWhere((record) => 
          record.staffId == staffId && record.trainingId == trainingId);

      final trainingRecord = TrainingRecord(
        id: 'training_${DateTime.now().millisecondsSinceEpoch}',
        staffId: staffId,
        trainingId: trainingId,
        status: status,
        completionDate: completionDate ?? DateTime.now(),
        certificateUrl: certificateUrl,
        createdAt: DateTime.now(),
      );

      _trainingRecords.add(trainingRecord);
      
      // Update job eligibility based on training
      await _updateStaffJobEligibility(staffId);
      
      notifyListeners();
      logger.info('Training record updated: ${trainingRecord.id}');
      
      return trainingRecord;
    } catch (e) {
      _setError('Failed to update training completion: $e');
      logger.severe('Training update error: $e');
      rethrow;
    }
  }

  Future<List<JobTemplate>> getEligibleJobsForStaff(String staffId) async {
    // For now, return all job templates as eligible
    // In a real implementation, this would check training records
    final eligibleJobs = <JobTemplate>[];
    
    for (final template in _jobTemplates) {
      // Skip training check for now - all jobs are eligible
      eligibleJobs.add(template);
    }
    
    return eligibleJobs;
  }

  // Helper methods
  Future<void> _loadJobTemplates() async {
    _jobTemplates = [
      JobTemplate(
        id: 'cleaning_basic',
        name: 'Basic Cleaning',
        description: 'Standard residential cleaning service',
        requiredTraining: [],
        estimatedDuration: const Duration(hours: 2),
        basePrice: 50.0,
      ),
      JobTemplate(
        id: 'cleaning_deep',
        name: 'Deep Cleaning',
        description: 'Comprehensive deep cleaning service',
        requiredTraining: ['deep_cleaning_cert'],
        estimatedDuration: const Duration(hours: 4),
        basePrice: 100.0,
      ),
      JobTemplate(
        id: 'carpet_cleaning',
        name: 'Carpet Cleaning',
        description: 'Professional carpet shampooing service',
        requiredTraining: ['carpet_cleaning_cert'],
        estimatedDuration: const Duration(hours: 3),
        basePrice: 80.0,
      ),
    ];
  }

  Future<void> _loadServicePricings() async {
    _servicePricings = [
      ServicePricing(
        serviceId: 'cleaning_basic',
        basePrice: 50.0,
        estimatedDuration: const Duration(hours: 2),
        customizationOptions: [
          CustomizationOption(
            id: 'rooms',
            name: 'Number of Rooms',
            options: [
              CustomizationOptionItem(id: '1_room', name: '1 Room', priceAdjustment: 0.0),
              CustomizationOptionItem(id: '2_rooms', name: '2 Rooms', priceAdjustment: 20.0),
              CustomizationOptionItem(id: '3_rooms', name: '3+ Rooms', priceAdjustment: 40.0),
            ],
          ),
        ],
      ),
    ];
  }

  Future<void> _loadStaffAvailabilities() async {
    // Mock staff availability data
    _staffAvailabilities = [
      StaffAvailability(
        id: 'avail_1',
        staffId: 'staff_1',
        date: DateTime.now(),
        startTime: TimeOfDay(hour: 8, minute: 0),
        endTime: TimeOfDay(hour: 17, minute: 0),
        isAvailable: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  Future<void> _loadExistingAssignments() async {
    // Load existing job assignments
    _jobAssignments = [];
    _staffSchedule = {};
    _dailySchedule = {};
  }

  Future<void> _loadTrainingRecords() async {
    // Load existing training records - using mock data for now
    // This would typically come from a training completion model
  }

  Future<void> _blockStaffAvailability(String staffId, DateTime scheduledDate, Duration duration) async {
    // Implementation for blocking staff availability
    final availability = StaffAvailability(
      id: 'avail_${DateTime.now().millisecondsSinceEpoch}',
      staffId: staffId,
      date: scheduledDate,
      startTime: TimeOfDay.fromDateTime(scheduledDate),
      endTime: TimeOfDay.fromDateTime(scheduledDate.add(duration)),
      isAvailable: false,
      createdAt: DateTime.now(),
    );
    
    _staffAvailabilities.add(availability);
  }

  Future<void> _createCustomerBooking(JobAssignment assignment) async {
    // Implementation for creating customer booking
    final booking = booking_model.Booking(
      id: 'booking_${assignment.id}',
      customerId: assignment.customerId,
      serviceId: assignment.serviceId,
      serviceName: _getServiceName(assignment.serviceId),
      bookingDate: assignment.scheduledDate,
      timePreference: booking_model.TimeOfDayPreference.flexible,
      address: 'Customer Address', // Mock address
      status: booking_model.BookingStatus.confirmed,
      basePrice: assignment.basePrice,
      propertySize: booking_model.PropertySize.medium,
      frequency: booking_model.BookingFrequency.oneTime,
      startTime: assignment.scheduledDate,
      endTime: assignment.scheduledDate.add(assignment.estimatedDuration),
      createdAt: DateTime.now(),
    );
    
    _customerBookings.add(booking);
  }

  String _getServiceName(String serviceId) {
    switch (serviceId) {
      case 'cleaning_basic':
        return 'Basic Cleaning';
      case 'cleaning_deep':
        return 'Deep Cleaning';
      case 'carpet_cleaning':
        return 'Carpet Cleaning';
      default:
        return 'Service';
    }
  }

  Future<void> _updateJobAssignmentQuality(String jobAssignmentId, QualityFlag qualityFlag) async {
    final index = _jobAssignments.indexWhere((assignment) => assignment.id == jobAssignmentId);
    if (index != -1) {
      // For now, just mark as completed since QualityFlag doesn't have customerRating
      _jobAssignments[index] = _jobAssignments[index].copyWith(
        qualityFlagId: qualityFlag.id,
        status: JobAssignmentStatus.completed,
      );
    }
  }

  double _getQualityMultiplier(String qualityStatus) {
    switch (qualityStatus) {
      case 'excellent':
        return 1.2;
      case 'good':
        return 1.1;
      case 'satisfactory':
        return 1.0;
      case 'needs_improvement':
        return 0.9;
      default:
        return 1.0;
    }
  }

  Future<void> _updateStaffJobEligibility(String staffId) async {
    // Implementation for updating staff job eligibility
    notifyListeners();
  }

  // Temp card entries storage
  final List<TempCardEntry> _tempCardEntries = [];
  List<TempCardEntry> get tempCardEntries => List.unmodifiable(_tempCardEntries);

  Future<void> _createPendingPayrollForTempCard(TempCardEntry tempCard) async {
    // Implementation for creating pending payroll
  }

  Future<void> _approvePayrollForTempCard(TempCardEntry tempCard) async {
    // Implementation for approving payroll
  }

  // Private methods for state management
  void _setLoading(bool loading) {
    // Implementation from BaseProvider
  }

  void _setError(String error) {
    // Implementation from BaseProvider
  }
}

// Supporting models for the scheduler
enum JobAssignmentStatus { scheduled, inProgress, completed, needsReview, cancelled }
enum TransportStatus { requested, confirmed, inTransit, completed, cancelled }
enum QualityStatus { pendingReview, approved, rejected, needsImprovement }
enum PayrollStatus { pending, approved, processed, paid }
enum QuoteStatus { draft, sent, accepted, rejected, expired }
enum TempCardStatus { pendingApproval, approved, rejected, processed }
enum TrainingStatus { notStarted, inProgress, completed, expired }
enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

class JobAssignment {
  final String id;
  final String serviceId;
  final String staffId;
  final String customerId;
  final DateTime scheduledDate;
  final JobAssignmentStatus status;
  final double basePrice;
  final Duration estimatedDuration;
  final Map<String, dynamic> customizations;
  final String? qualityFlagId;
  final DateTime createdAt;

  JobAssignment({
    required this.id,
    required this.serviceId,
    required this.staffId,
    required this.customerId,
    required this.scheduledDate,
    required this.status,
    required this.basePrice,
    required this.estimatedDuration,
    required this.customizations,
    this.qualityFlagId,
    required this.createdAt,
  });

  JobAssignment copyWith({
    String? id,
    String? serviceId,
    String? staffId,
    String? customerId,
    DateTime? scheduledDate,
    JobAssignmentStatus? status,
    double? basePrice,
    Duration? estimatedDuration,
    Map<String, dynamic>? customizations,
    String? qualityFlagId,
    DateTime? createdAt,
  }) {
    return JobAssignment(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      staffId: staffId ?? this.staffId,
      customerId: customerId ?? this.customerId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      basePrice: basePrice ?? this.basePrice,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      customizations: customizations ?? this.customizations,
      qualityFlagId: qualityFlagId ?? this.qualityFlagId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class JobTemplate {
  final String id;
  final String name;
  final String description;
  final List<String> requiredTraining;
  final Duration estimatedDuration;
  final double basePrice;

  JobTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredTraining,
    required this.estimatedDuration,
    required this.basePrice,
  });
}

class ServicePricing {
  final String serviceId;
  final double basePrice;
  final Duration estimatedDuration;
  final List<CustomizationOption> customizationOptions;

  ServicePricing({
    required this.serviceId,
    required this.basePrice,
    required this.estimatedDuration,
    required this.customizationOptions,
  });
}

class CustomizationOption {
  final String id;
  final String name;
  final List<CustomizationOptionItem> options;

  CustomizationOption({
    required this.id,
    required this.name,
    required this.options,
  });
}

class CustomizationOptionItem {
  final String id;
  final String name;
  final double priceAdjustment;

  CustomizationOptionItem({
    required this.id,
    required this.name,
    required this.priceAdjustment,
  });
}

// Additional supporting classes would be implemented here...
class TransportRequest { /* Implementation */ }
class QualityFlag { /* Implementation */ }
class TrainingRecord { /* Implementation */ }
class PayrollEntry { /* Implementation */ }
class ServiceQuote { /* Implementation */ }
class TempCardEntry { /* Implementation */ }
class QualityChecklistItem { /* Implementation */ }
class StaffAvailability { /* Implementation */ }
class Booking { /* Implementation */ }
