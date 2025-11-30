// lib/providers/timekeeping_provider.dart
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/time_record_model.dart';
import '../models/job_model.dart';
import '../models/job_status.dart';
import '../models/work_shift_model.dart';
import '../models/timekeeping_stats_model.dart';
import '../models/temp_card_model.dart';
import '../models/qr_validation_model.dart';
import '../repositories/timekeeping_repository.dart';
import 'base_provider.dart';

class TimekeepingProvider extends BaseProvider {
  // State

  final TimekeepingRepository _repository;

  final List<Job> _jobs = [];
  List<Job> _availableJobs = [];
  final List<WorkShift> _shifts = [];
  final List<TempCard> _tempCards = [];
  final List<TimeRecord> _timeRecords = [];
  final List<WorkShift> _workShifts = [];
  List<WorkShift> _scheduledJobs = [];

  String? _activeJobId;
  String? _error;
  TimekeepingStats? _stats;

  // Location state
  bool _isLocationEnabled = false;
  bool _isInTargetLocation = false;
  Position? _currentPosition;
  double? _targetLat;
  double? _targetLon;
  final double _maxDistanceMeters = 100;
  
  // UI state
  bool _isSyncing = false;
  
  // Getters
  List<TimeRecord> get timeRecords => List.unmodifiable(_timeRecords);
  
  List<Job> get jobs => List.unmodifiable(_jobs);
  
  List<WorkShift> get workShifts => List.unmodifiable(_workShifts);

  List<TempCard> get tempCards => List.unmodifiable(_tempCards);
  
  String? get activeJobId => _activeJobId;
  
  @override
  String? get error => _error;
  TimekeepingStats? get stats => _stats;
  bool get isSyncing => _isSyncing;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get isInTargetLocation => _isInTargetLocation;
  Position? get currentPosition => _currentPosition;
  
  TimekeepingProvider({TimekeepingRepository? repository, Logger? logger})
      : _repository = repository ?? 
          TimekeepingRepository(
            timeRecordRepo: TimeRecordRepository(),
            workShiftRepo: WorkShiftRepository(),
            tempCardRepo: TempCardRepository(),
          ),
        super(logger ?? Logger('TimekeepingProvider')) {
    _initialize();
    setupConnectivityListener();
  }
  
  Future<void> _initialize() async {
    await loadInitialData();
  }
  
  Future<void> loadInitialData() async {
    setLoading(true);
    try {
      // Load jobs (in a real app, this would come from an API)
      final now = DateTime.now();
      _availableJobs = [
        Job(
          id: 'hotel',
          title: 'Hotel Cleaning',
          location: '123 Main St',
          startTime: now,
          endTime: now.add(const Duration(hours: 8)),
        ),
        Job(
          id: 'office',
          title: 'Office Cleaning',
          location: '456 Business Ave',
          startTime: now.add(const Duration(days: 1)),
          endTime: now.add(const Duration(days: 1, hours: 8)),
        ),
        Job(
          id: 'residential',
          title: 'Residential Cleaning',
          location: '789 Home St',
          startTime: now.add(const Duration(days: 2)),
          endTime: now.add(const Duration(days: 2, hours: 6)),
        ),
      ];
      
      // Load time records from repository
      final result = await _repository.getTimeRecords();
      result.fold(
        (error) => setError(error.toString()),
        (records) {
          _timeRecords.clear();
          _timeRecords.addAll(records);
        },
      );
    } catch (e) {
      setError('Failed to load initial data: $e');
    } finally {
      setLoading(false);
    }
  }

  List<Job> get availableJobs => _availableJobs;

  Job? getJobById(String id) {
    try {
      return _availableJobs.firstWhere((job) => job.id == id);
    } catch (e) {
      logger.severe('Job not found: $id', e, StackTrace.current);
      return null;
    }
  }

  
  Future<void> initialize() async {
    try {
      setLoading(true);
      await _loadMockData();
      _updateStats();
    } catch (e, stackTrace) {
      handleError(Exception('Failed to initialize timekeeping: $e'), stackTrace: stackTrace);
    } finally {
      setLoading(false);
    }
  }

  Future<void> _loadMockData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Add mock time records
    final now = DateTime.now();
    _timeRecords.addAll([
      TimeRecord(
        id: 'tr1',
        staffId: 'staff1',
        jobId: 'hotel',
        checkInTime: now.subtract(const Duration(hours: 8)),
        checkOutTime: now.subtract(const Duration(hours: 1)),
        startTime: now.subtract(const Duration(hours: 8)),
        endTime: now.subtract(const Duration(hours: 1)),
        status: TimeRecordStatus.completed,
        type: TimeRecordType.self,
      ),
      TimeRecord(
        id: 'tr2',
        staffId: 'staff1',
        jobId: 'office',
        checkInTime: now.subtract(const Duration(days: 1, hours: 8)),
        checkOutTime: now.subtract(const Duration(days: 1, hours: 1)),
        startTime: now.subtract(const Duration(days: 1, hours: 8)),
        endTime: now.subtract(const Duration(days: 1, hours: 1)),
        status: TimeRecordStatus.completed,
        type: TimeRecordType.self,
      ),
    ]);
    
    // Add mock work shifts
    _workShifts.addAll([
      WorkShift(
        id: 'ws1',
        name: 'Morning Shift',
        type: WorkShiftType.regular,
        startTime: now.subtract(const Duration(days: 1, hours: 8)),
        endTime: now.subtract(const Duration(days: 1, hours: 1)),
        status: WorkShiftStatus.completed,
      ),
      WorkShift(
        id: 'ws2',
        name: 'Afternoon Shift',
        type: WorkShiftType.overtime,
        startTime: now.add(const Duration(hours: 2)),
        endTime: now.add(const Duration(hours: 10)),
        status: WorkShiftStatus.scheduled,
      ),
    ]);
    
    // Add some mock temp cards
    _tempCards.addAll([
      TempCard(
        id: 'card1',
        userId: 'user1',
        userName: 'John Doe',
        cardNumber: 'TC001',
        issueDate: DateTime.now().subtract(const Duration(days: 30)),
        expiryDate: DateTime.now().add(const Duration(days: 335)),
        isActive: true,
      ),
      TempCard(
        id: 'card2',
        userId: 'user2',
        userName: 'Jane Smith',
        cardNumber: 'TC002',
        issueDate: DateTime.now().subtract(const Duration(days: 60)),
        expiryDate: DateTime.now().add(const Duration(days: 305)),
        isActive: true,
      ),
    ]);

    _availableJobs.addAll([
      Job(
        id: 'hotel',
        title: 'Hotel Cleaning',
        location: '123 Main St',
        startTime: now,
        endTime: now.add(const Duration(hours: 8)),
      ),
      Job(
        id: 'office',
        title: 'Office Cleaning',
        location: '456 Business Ave',
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 8)),
      ),
      Job(
        id: 'residential',
        title: 'Residential Cleaning',
        location: '789 Home St',
        startTime: now.add(const Duration(days: 2)),
        endTime: now.add(const Duration(days: 2, hours: 6)),
      ),
    ]);

    // Add some scheduled jobs
    _scheduledJobs = [
      WorkShift(
        id: '1',
        name: 'Hotel Cleaning Shift',
        type: WorkShiftType.regular,
        jobId: 'hotel',
        startTime: DateTime(now.year, now.month, now.day, 9),
        endTime: DateTime(now.year, now.month, now.day, 17),
        status: WorkShiftStatus.scheduled,
      ),
      // Add more mock shifts...
    ];
    
    notifyListeners();
  }

  // Job methods
  Future<void> addJob(Job job) async {
    _jobs.add(job);
    _sortJobs();
    notifyListeners();
  }

  Future<void> updateJob(Job updatedJob) async {
    final index = _jobs.indexWhere((j) => j.id == updatedJob.id);
    if (index != -1) {
      _jobs[index] = updatedJob;
      _sortJobs();
      notifyListeners();
    }
  }

  Future<void> deleteJob(String jobId) async {
    _jobs.removeWhere((j) => j.id == jobId);
    notifyListeners();
  }

  List<Job> getJobsForDate(DateTime date) {
    return _jobs.where((job) {
      return job.startTime.year == date.year &&
          job.startTime.month == date.month &&
          job.startTime.day == date.day;
    }).toList();
  }

  // Shift methods
  List<WorkShift> getShiftsForDate(DateTime date) {
    return _shifts.where((shift) {
      return shift.startTime.year == date.year &&
          shift.startTime.month == date.month &&
          shift.startTime.day == date.day;
    }).toList();
  }

  // Helper methods
  void _sortJobs() {
    _jobs.sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Initialize with sample data
  void initializeSampleData() {
    final now = DateTime.now();
    _jobs.addAll([
      Job(
        id: '1',
        title: 'Morning Shift',
        startTime: DateTime(now.year, now.month, now.day, 9),
        endTime: DateTime(now.year, now.month, now.day, 17),
        status: JobStatus.scheduled,
      ),
      // Add more sample jobs as needed
    ]);
    notifyListeners();
  }

  Future<void> assignJobToUser(String userId, String jobId, DateTime date) async {
    try {
      setLoading(true);
      notifyListeners();
      
      // In a real app, this would call an API
      await Future.delayed(const Duration(seconds: 1));
      
      _scheduledJobs.add(WorkShift(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Assigned Job Shift',
        type: WorkShiftType.regular,
        jobId: jobId,
        userId: userId,
        startTime: date,
        endTime: date.add(const Duration(hours: 8)),
        status: WorkShiftStatus.scheduled,
      ));
      
      notifyListeners();
    } catch (e, stackTrace) {
      handleError(Exception('Failed to assign job: $e'), stackTrace: stackTrace);
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  // Check in/out methods
  Future<void> checkIn(String jobId, {String? proxyCardId}) async {
    try {
      setLoading(true);
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate network
      
      final record = TimeRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        staffId: 'current_user_id', // This should come from auth
        jobId: jobId,
        jobName: 'Job $jobId',
        checkInTime: DateTime.now(),
        startTime: DateTime.now(),
        type: proxyCardId != null ? TimeRecordType.proxy : TimeRecordType.self,
        proxyCardId: proxyCardId,
      );
      
      _timeRecords.add(record);
      _activeJobId = jobId;
      
      // Block staff availability during work
      await blockAvailabilityDuringWork(record.staffId, jobId);
      
      _updateStats();
      notifyListeners();
      
      logger.info('Checked in to job $jobId');
    } catch (e, stackTrace) {
      handleError(Exception('Failed to check in: $e'), stackTrace: stackTrace);
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// Validates a QR code for check-in
  Future<QRValidationResult> validateQRCode(String qrData) async {
    try {
      setLoading(true);
      
      // Parse QR data (expected format: "JOB:{jobId}:{timestamp}")
      if (qrData.startsWith('JOB:')) {
        final parts = qrData.split(':');
        if (parts.length >= 2) {
          final jobId = parts[1];
          
          // Check if job exists and is active
          final job = _jobs.firstWhere(
            (j) => j.id == jobId,
            orElse: () => Job.empty(),
          );
          
          if (job.id.isEmpty) {
            return QRValidationResult(
              isValid: false,
              error: 'Invalid job ID',
              jobId: null,
            );
          }
          
          // Check if staff is already checked in
          if (_activeJobId != null) {
            return QRValidationResult(
              isValid: false,
              error: 'Already checked in to another job',
              jobId: null,
            );
          }
          
          // Check if job is scheduled for today
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final jobDate = DateTime(
            job.startTime.year,
            job.startTime.month,
            job.startTime.day,
          );
          
          if (jobDate.isBefore(today)) {
            return QRValidationResult(
              isValid: false,
              error: 'Job date has passed',
              jobId: null,
            );
          }
          
          return QRValidationResult(
            isValid: true,
            error: null,
            jobId: jobId,
            job: job,
          );
        }
      }
      
      // Try to parse as direct job ID
      final job = _jobs.firstWhere(
        (j) => j.id == qrData,
        orElse: () => Job.empty(),
      );
      
      if (job.id.isNotEmpty) {
        return QRValidationResult(
          isValid: true,
          error: null,
          jobId: qrData,
          job: job,
        );
      }
      
      return QRValidationResult(
        isValid: false,
        error: 'Invalid QR code format',
        jobId: null,
      );
    } catch (e) {
      return QRValidationResult(
        isValid: false,
        error: 'Error validating QR code: $e',
        jobId: null,
      );
    } finally {
      setLoading(false);
    }
  }
  
  /// Checks if staff availability allows check-in
  Future<bool> canCheckIn(String staffId, DateTime dateTime) async {
    // Check if staff has availability for this time
    // In a real app, this would check against staff availability
    return true; // For demo, always allow
  }
  
  /// Blocks staff availability during work hours
  Future<void> blockAvailabilityDuringWork(String staffId, String jobId) async {
    // In a real app, this would update staff availability
    // to prevent double-booking during work hours
    logger.info('Blocked availability for staff $staffId during job $jobId');
  }
  
  /// Releases staff availability after check-out
  Future<void> releaseAvailabilityAfterWork(String staffId, String jobId) async {
    // In a real app, this would update staff availability
    // to make staff available for new assignments
    logger.info('Released availability for staff $staffId after job $jobId');
  }

  Future<void> checkOut({
    Map<String, dynamic>? qualityData,
    String? notes,
    List<String>? issues,
    int? customerRating,
  }) async {
    if (_activeJobId == null) return;
    
    try {
      setLoading(true);
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate network
      
      final now = DateTime.now();
      final activeRecord = _timeRecords.firstWhere(
        (r) => r.jobId == _activeJobId && r.checkOutTime == null,
      );
      
      final updatedRecord = activeRecord.copyWith(
        checkOutTime: now,
        qualityData: qualityData,
        notes: notes,
        issues: issues,
        customerRating: customerRating,
      );
      
      final index = _timeRecords.indexOf(activeRecord);
      _timeRecords[index] = updatedRecord;
      
      // Release staff availability after work
      await releaseAvailabilityAfterWork(activeRecord.staffId, activeRecord.jobId);
      
      _activeJobId = null;
      _updateStats();
      notifyListeners();
      
      logger.info('Checked out from job ${activeRecord.jobId}');
    } catch (e, stackTrace) {
      handleError(Exception('Failed to check out: $e'), stackTrace: stackTrace);
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // Methods for tests compatibility
  void addTimeRecord(TimeRecord record) {
    _timeRecords.add(record);
    notifyListeners();
  }

  List<TimeRecord> getTimeRecordsForStaff(String staffId) {
    return _timeRecords.where((record) => record.staffId == staffId).toList();
  }

  List<TimeRecord> getActiveTimeRecords() {
    return _timeRecords.where((record) => record.checkOutTime == null).toList();
  }

  double getTotalHoursForStaff(String staffId) {
    final staffRecords = getTimeRecordsForStaff(staffId);
    double totalHours = 0;
    
    for (final record in staffRecords) {
      if (record.checkOutTime != null) {
        totalHours += record.checkOutTime!.difference(record.checkInTime).inHours;
      }
    }
    
    return totalHours;
  }

  // Data access methods
  List<TimeRecord> getTimeRecords() => List.unmodifiable(_timeRecords);
  List<WorkShift> getWorkShifts() => List.unmodifiable(_workShifts);
  List<TempCard> getTempCards() => List.unmodifiable(_tempCards);

  // Stats calculation
  void _updateStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final todayRecords = _timeRecords.where((r) => 
      r.checkInTime.isAfter(today) && 
      r.checkOutTime != null
    ).toList();
    
    final totalHours = todayRecords.fold<double>(
      0, 
      (sum, r) => sum + (r.calculatedDuration ?? 0) / 60
    );
    
    _stats = TimekeepingStats(
      hoursToday: totalHours,
      activeJobs: _activeJobId != null ? 1 : 0,
      completedJobsThisMonth: todayRecords.length,
    );
  }

  // Mock sync with server
  Future<void> syncWithServer() async {
    if (_isSyncing) return;
    
    try {
      _isSyncing = true;
      notifyListeners();
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, this would sync with the server
      logger.info('Data synced with server');
    } catch (e, stackTrace) {
      handleError(Exception('Sync failed: $e'), stackTrace: stackTrace);
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Checks the current location status and verifies if the user is within
  /// the target location radius. Updates [_isLocationEnabled] and 
  /// [_isInTargetLocation] accordingly.
  Future<void> checkLocationStatus() async {
  try {
    setLoading(true);
    _error = null;
    
    // Check if location services are enabled
    _isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_isLocationEnabled) {
      _error = 'Location services are disabled. Please enable them to continue.';
      return;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _error = 'Location permissions are required to verify your location.';
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _error = 'Location permissions are permanently denied. Please enable them in app settings.';
      return;
    }

    // Get current position
    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // If no target location provided, just confirm location is available
    if (_targetLat == null || _targetLon == null) {
      _isInTargetLocation = true;
      return;
    }

    // Calculate distance to target location
    final distanceInMeters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      _targetLat!,
      _targetLon!,
    );

    _isInTargetLocation = distanceInMeters <= _maxDistanceMeters;
  } catch (e) {
    _error = 'Error checking location: ${e.toString()}';
    _isLocationEnabled = false;
    _isInTargetLocation = false;
  } finally {
    setLoading(false);
    notifyListeners();
  }
}

Future<void> openLocationSettings() async {
  try {
    await Geolocator.openLocationSettings();
  } catch (e) {
    _error = 'Could not open location settings.';
    notifyListeners();
  }
}

Future<void> openMapsToJobLocation(double? targetLat, double? targetLon) async {
  if (targetLat == null || 
      targetLon == null || 
      _currentPosition == null) {
    _error = 'Location data not available';
    notifyListeners();
    return;
  }
  
  final url = 
      'https://www.google.com/maps/dir/?api=1&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=$targetLat,$targetLon&travelmode=driving';
  
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    _error = 'Could not open maps.';
    notifyListeners();
  }
}

  
  @override
  void dispose() {
    _jobs.clear();
    _availableJobs.clear();
    _shifts.clear();
    _tempCards.clear();
    _timeRecords.clear();
    _workShifts.clear();
    _scheduledJobs.clear();
    super.dispose();
  }
}
