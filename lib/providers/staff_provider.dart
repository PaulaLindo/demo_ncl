// lib/providers/staff_provider.dart
import 'package:logging/logging.dart';

import '../models/gig_assignment.dart';
import '../models/staff_availability.dart';
import '../models/shift_swap_request.dart';
import '../models/job_model.dart';
import '../models/job_status.dart';
import '../models/work_shift_model.dart';
import '../models/review_model.dart';
import '../models/staff_model.dart' as staff_model;

import '../providers/auth_provider.dart';
import '../models/user_model.dart';

import '../repositories/job_repository.dart';
import '../repositories/staff_schedule_repository.dart';

import '../services/mock_data_service.dart';
import '../utils/notification_utils.dart';

import 'base_provider.dart';
import 'package:flutter/material.dart';

class StaffProvider extends BaseProvider {
  final JobRepository _jobRepository;
  final StaffScheduleRepository _staffScheduleRepository;
  final AuthProvider? _authProvider; // Make nullable

  List<Job> _jobs = [];
  final List<WorkShift> _shifts = [];
  final List<User> _staff = []; // Add staff list
  bool _isLoading = false;
  String? _error;
  
  StaffProvider({
    JobRepository? jobRepository,
    StaffScheduleRepository? scheduleRepository,
    AuthProvider? authProvider,
    Logger? logger,
  })  : _jobRepository = jobRepository ?? JobRepository(),
        _staffScheduleRepository = scheduleRepository ?? StaffScheduleRepository(),
        _authProvider = authProvider, // Don't create new instance, use provided one
        super(logger ?? Logger('StaffProvider'));

  // State
  List<GigAssignment> _upcomingGigs = [];
  final List<GigAssignment> _pendingGigs = [];
  List<StaffAvailability> _availability = [];
  final List<ShiftSwapRequest> _shiftSwapRequests = [];
  String? _swapError;
  final bool _isLoadingSwapRequests = false;

  // Getters
  List<GigAssignment> get upcomingGigs => List.unmodifiable(_upcomingGigs);
  List<GigAssignment> get pendingGigs => List.unmodifiable(_pendingGigs);
  List<StaffAvailability> get availability => List.unmodifiable(_availability);
  List<ShiftSwapRequest> get shiftSwapRequests => List.unmodifiable(_shiftSwapRequests);
  List<Job> get jobs => List.unmodifiable(_jobs);
  List<User> get staff => List.unmodifiable(_staff); // Add staff getter

  List<Job> get upcomingJobs => _jobs
      .where((job) => 
          job.status == JobStatus.scheduled || 
          job.status == JobStatus.inProgress)
      .toList();

  @override
  String? get error => _error;
  String? get swapError => _swapError;
  
  @override
  bool get isLoading => _isLoading;
  bool get isLoadingSwapRequests => _isLoadingSwapRequests;

  List<WorkShift> get shifts => List.unmodifiable(_shifts);

  // Load staff data
  Future<void> loadStaffData(String staffId) async {
    _setLoading(true);
    try {
      // Load jobs
      final jobsResult = await _jobRepository.getStaffJobs(staffId: staffId);
      jobsResult.fold(
        (failure) => _error = failure.toString(),
        (jobs) => _jobs = jobs,
      );

      // TODO: Implement getStaffShifts method in StaffScheduleRepository
      // final shiftsResult = await _staffScheduleRepository.getStaffShifts(staffId);
      // shiftsResult.fold(
      //   (failure) => _error = failure.toString(),
      //   (shifts) => _shifts = shifts,
      // );
    } catch (e) {
      _error = 'Failed to load staff data: $e';
      logger.severe(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Load jobs for staff member
  Future<void> loadJobs({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;
    
    _setLoading(true);
    _error = null;
    
    try {
      final result = await _jobRepository.getStaffJobs(
        staffId: _authProvider?.currentUser?.id ?? '',
      );
      
      result.fold(
        (error) => _setError(error.toString()),
        (jobs) => _jobs = jobs,
      );
    } catch (e) {
      _setError('Failed to load jobs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get job by ID
  Job? getJobById(String jobId) {
    try {
      return _jobs.firstWhere((job) => job.id == jobId);
    } catch (e) {
      return null;
    }
  }

  // Update job status
  Future<bool> updateJobStatus(String jobId, JobStatus newStatus) async {
    _setLoading(true);
    try {
      final job = _jobs.firstWhere((j) => j.id == jobId);
      final updatedJob = job.copyWith(status: newStatus);
      
      final result = await _jobRepository.updateJob(updatedJob);
      return result.fold(
        (failure) {
          _error = failure.toString();
          return false;
        },
        (success) {
          final index = _jobs.indexWhere((j) => j.id == jobId);
          if (index != -1) {
            _jobs[index] = updatedJob;
            notifyListeners();
          }
          return success;
        },
      );
    } catch (e) {
      _error = 'Failed to update job status: $e';
      logger.severe(_error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update checklist status
  Future<bool> updateChecklistStatus(String jobId, bool isCompleted) async {
    _setLoading(true);
    _error = null;
    
    try {
      final result = await _jobRepository.updateChecklistStatus(
        jobId: jobId,
        isCompleted: isCompleted,
      );
      
      return result.fold(
        (error) {
          _setError(error.toString());
          return false;
        },
        (updatedJob) {
          final index = _jobs.indexWhere((j) => j.id == jobId);
          if (index != -1) {
            _jobs[index] = updatedJob;
            notifyListeners();
          }
          return true;
        },
      );
    } catch (e) {
      _setError('Failed to update checklist status');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Accept a gig
  Future<bool> acceptGig(String gigId) async {
    _setLoading(true);
    _error = null;
    
    try {
      final result = await _staffScheduleRepository.acceptGig(gigId);
      
      return result.fold(
        (error) {
          _setError(error.toString());
          return false;
        },
        (gig) {
          _pendingGigs.removeWhere((g) => g.id == gigId);
          final updatedGigs = [..._upcomingGigs, gig];
          // Sort by creating a new sorted list
          final sortedGigs = List<GigAssignment>.from(updatedGigs)
            ..sort((a, b) => a.startTime.compareTo(b.startTime));
          _upcomingGigs = sortedGigs;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Failed to accept gig');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Decline a gig
  Future<bool> declineGig(String gigId, {String? reason}) async {
    _setLoading(true);
    _error = null;
    
    try {
      final result = await _staffScheduleRepository.declineGig(gigId, reason: reason);
      
      return result.fold(
        (error) {
          _setError(error.toString());
          return false;
        },
        (_) {
          // Update local state
          _pendingGigs.removeWhere((g) => g.id == gigId);
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Failed to decline gig');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set availability
  Future<bool> setAvailability(StaffAvailability availability) async {
    _setLoading(true);
    _error = null;
    
    try {
      final result = await _staffScheduleRepository.setAvailability(availability);
      
      return result.fold(
        (error) {
          _setError(error.toString());
          return false;
        },
        (updated) {
          // Update local state
          final index = _availability.indexWhere((a) => a.id == (updated as StaffAvailability).id);
          
          if (index >= 0) {
            _availability[index] = updated as StaffAvailability;
          } else {
            _availability.add(updated as StaffAvailability);
          }
          
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError('Failed to update availability');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setError(String? error) {
    _error = error;
    if (error != null) {
      debugPrint('StaffProvider error: $error');
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Get available time slots for a specific date range
  Future<List<DateTimeRange>> getAvailableTimeSlots({
    required DateTime startDate,
    required DateTime endDate,
    Duration slotDuration = const Duration(hours: 1),
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      // TODO: Implement getAvailableTimeSlots method in StaffScheduleRepository
      // final result = await _staffScheduleRepository.getAvailableTimeSlots(
      //   staffId: 'current_user_id', // This should come from auth
      //   startDate: startDate,
      //   endDate: endDate,
      //   slotDuration: slotDuration,
      // );
      
      // For now, return empty list
      return [];
    } catch (e) {
      _setError('Failed to load available time slots');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Create a new shift swap request
  Future<bool> createShiftSwapRequest({
    required String gigId,
    required String reason,
    String? recipientId,
  }) async {
    final currentUserId = _authProvider?.currentUser?.id;
    if (currentUserId == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    // TODO: Implement createShiftSwapRequest method in StaffScheduleRepository
    // For now, return false as placeholder
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Respond to a shift swap request
  Future<bool> respondToShiftSwapRequest({
    required String requestId,
    required bool isApproved,
    String? responseNote,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // TODO: Implement respondToShiftSwapRequest method in StaffScheduleRepository
    // For now, return false as placeholder
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Get all shift swap requests for the current user
  Future<void> loadShiftSwapRequests({bool includeCompleted = false, bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement getShiftSwapRequests method in StaffScheduleRepository
      // final result = await _staffScheduleRepository.getShiftSwapRequests(
      //   staffId: _authProvider.currentUser?.id ?? '',
      //   includeCompleted: includeCompleted,
      // );

      // result.fold(
      //   (failure) => _error = failure.toString(),
      //   (requests) => _shiftSwapRequests = requests,
      // );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel a shift swap request
  Future<bool> cancelShiftSwapRequest(String requestId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // TODO: Implement cancelShiftSwapRequest method in StaffScheduleRepository
    // For now, return false as placeholder
    _isLoading = false;
    notifyListeners();
    return false;
  }
  
  // Add to StaffProvider
  Future<void> checkForNewGigs() async {
    // Check for new gigs and show notifications
  }

  Future<void> setUpcomingShiftReminders() async {
    // Schedule local notifications for upcoming shifts
  }

  // Add to your StaffProvider class
  // When a new gig is assigned
  Future<bool> assignGig(GigAssignment gig) async {
    _setLoading(true);
    try {
      // TODO: Implement assignGig method in StaffScheduleRepository
      // final result = await _staffScheduleRepository.assignGig(gig);
      
      // For now, just return true as a placeholder
      await NotificationUtils.notifyNewGigAssigned(
        gigId: gig.id,
        gigTitle: gig.title,
        startTime: gig.startTime,
      );
      
      await NotificationUtils.scheduleGigReminder(
        gigId: gig.id,
        gigTitle: gig.title,
        startTime: gig.startTime,
      );
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add a method to handle notification actions
  void handleNotificationAction(String payload) {
    if (payload.startsWith('gig_')) {
      // Navigation should be handled by the UI layer, not the provider
      // Consider using a callback or event system
      final gigId = payload.replaceFirst('gig_', '');
      debugPrint('Handling gig notification for ID: $gigId');
    }
  }

  /// Check if staff is available for a specific time range
  Future<bool> checkAvailability({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      // TODO: Implement checkStaffAvailability method in StaffScheduleRepository
      // final result = await _staffScheduleRepository.checkStaffAvailability(
      //   staffId: 'current_user_id', // This should come from auth
      //   startTime: startTime,
      //   endTime: endTime,
      // );
      
      // For now, just return true
      return true;
    } catch (e) {
      _setError('Failed to check availability');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Batch update availability
  Future<bool> updateWeeklyAvailability({
    required Map<DateTime, List<TimeOfDay>> availabilityMap,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      final availabilities = availabilityMap.entries.map((entry) {
        final date = entry.key;
        final times = entry.value;
        
        return StaffAvailability(
          id: '${_authProvider?.currentUser?.id ?? 'unknown'}_${date.millisecondsSinceEpoch}',
          staffId: _authProvider?.currentUser?.id ?? 'unknown',
          date: date,
          startTime: const TimeOfDay(hour: 9, minute: 0), // Default start time
          endTime: const TimeOfDay(hour: 17, minute: 0), // Default end time
          status: times.isNotEmpty ? AvailabilityStatus.available : AvailabilityStatus.unavailable,
        );
      }).toList();

      // For now, just update local state
      _availability = availabilities.cast<StaffAvailability>();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update availability');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get schedule conflicts
  Future<List<GigAssignment>> getScheduleConflicts() async {
    _setLoading(true);
    _error = null;
    
    try {
      // TODO: Implement getScheduleConflicts method in StaffScheduleRepository
      // final result = await _staffScheduleRepository.getScheduleConflicts(
      //   staffId: 'current_user_id', // This should come from auth
      // );
      
      // return result.fold(
      //   (error) {
      //     _setError(error.toString());
      //     return [];
      //   },
      //   (conflicts) => conflicts,
      // );
      return [];
    } catch (e) {
      _setError('Failed to check schedule conflicts');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Methods for tests compatibility
  void addStaffMember(User staffMember) {
    _staff.add(staffMember);
    notifyListeners();
  }

  void removeStaffMember(String staffId) {
    _staff.removeWhere((member) => member.id == staffId);
    notifyListeners();
  }

  List<User> getActiveStaff() {
    return _staff.where((member) => member.isStaff).toList();
  }

  /// Get available staff members for customer selection
  Future<List<staff_model.StaffMember>> getAvailableStaff() async {
    _setLoading(true);
    try {
      // Mock data for available staff - in real app this would query database
      await Future.delayed(const Duration(milliseconds: 500));
      
      final availableStaff = [
        staff_model.StaffMember(
          id: '1',
          name: 'Sarah Johnson',
          email: 'sarah@example.com',
          phone: '+1234567890',
          bio: 'Experienced cleaning professional with 5+ years in residential and commercial cleaning. I take pride in delivering exceptional service and attention to detail.',
          specialties: ['Regular Cleaning', 'Deep Cleaning', 'Eco-Friendly'],
          experienceYears: 5,
          completedJobs: 234,
          responseRate: 98,
          reviews: [
            Review(
              id: '1',
              bookingId: 'booking1',
              customerId: 'customer1',
              customerName: 'John Doe',
              staffId: '1',
              staffName: 'Sarah Johnson',
              rating: 5,
              comment: 'Excellent service! Very thorough and professional.',
              createdAt: DateTime.now().subtract(const Duration(days: 2)),
            ),
            Review(
              id: '2',
              bookingId: 'booking2',
              customerId: 'customer2',
              customerName: 'Jane Smith',
              staffId: '1',
              staffName: 'Sarah Johnson',
              rating: 5,
              comment: 'Sarah did an amazing job. My house has never been cleaner!',
              createdAt: DateTime.now().subtract(const Duration(days: 7)),
            ),
          ],
          isVerified: true,
          isInsured: true,
          hasOwnSupplies: true,
          isEcoFriendly: true,
          isPetFriendly: true,
          isFlexibleSchedule: true,
          lastActive: DateTime.now().subtract(const Duration(minutes: 30)),
          averageRating: 5.0,
        ),
        staff_model.StaffMember(
          id: '2',
          name: 'Mike Wilson',
          email: 'mike@example.com',
          phone: '+1234567891',
          bio: 'Detail-oriented cleaning specialist with expertise in deep cleaning and organization. Committed to creating clean, comfortable spaces for clients.',
          specialties: ['Deep Cleaning', 'Organizational', 'Move In/Out'],
          experienceYears: 3,
          completedJobs: 156,
          responseRate: 95,
          reviews: [
            Review(
              id: '3',
              bookingId: 'booking3',
              customerId: 'customer3',
              customerName: 'Bob Brown',
              staffId: '2',
              staffName: 'Mike Wilson',
              rating: 4,
              comment: 'Good job, very thorough with deep cleaning.',
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ],
          isVerified: true,
          isInsured: true,
          hasOwnSupplies: false,
          isEcoFriendly: false,
          isPetFriendly: true,
          isFlexibleSchedule: false,
          lastActive: DateTime.now().subtract(const Duration(hours: 2)),
          averageRating: 4.5,
        ),
        staff_model.StaffMember(
          id: '3',
          name: 'Emily Chen',
          email: 'emily@example.com',
          phone: '+1234567892',
          bio: 'Passionate about eco-friendly cleaning solutions. I use environmentally safe products that are effective and gentle on your home and the planet.',
          specialties: ['Eco-Friendly', 'Regular Cleaning', 'Kitchen Cleaning'],
          experienceYears: 4,
          completedJobs: 189,
          responseRate: 92,
          reviews: [
            Review(
              id: '4',
              bookingId: 'booking4',
              customerId: 'customer4',
              customerName: 'Alice Green',
              staffId: '3',
              staffName: 'Emily Chen',
              rating: 5,
              comment: 'Love that she uses eco-friendly products! Great service.',
              createdAt: DateTime.now().subtract(const Duration(days: 3)),
            ),
          ],
          isVerified: true,
          isInsured: true,
          hasOwnSupplies: true,
          isEcoFriendly: true,
          isPetFriendly: false,
          isFlexibleSchedule: true,
          lastActive: DateTime.now().subtract(const Duration(minutes: 15)),
          averageRating: 4.8,
        ),
      ];
      
      _setLoading(false);
      return availableStaff;
    } catch (e) {
      _setError('Failed to load available staff: $e');
      _setLoading(false);
      return [];
    }
  }
}
