// lib/providers/timekeeping_provider.dart

import 'package:flutter/foundation.dart';
import '../models/timekeeping_models.dart';
import '../models/job_service_models.dart';

class TimekeepingProvider with ChangeNotifier {
  // State
  TimekeepingStats _stats = TimekeepingStats();
  final List<TimeRecord> _timeRecords = [];
  List<WorkShift> _workShifts = [];
  List<TempCard> _tempCards = [];
  String? _activeJobId;
  String? _activeProxyCardId;
  DateTime _selectedMonth = DateTime.now();

  // Mock data
  final List<Job> _mockJobs = [
    Job(
      id: 'job001',
      customerName: 'Robert Smith',
      address: '123 Oak St, Durban',
      startTime: DateTime.now().add(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 4)),
      serviceType: 'Deep Clean',
      status: JobStatus.scheduled,
    ),
    Job(
      id: 'job002',
      customerName: 'Alice Johnson',
      address: '45 Pine Ave, Durban',
      startTime: DateTime.now().add(const Duration(hours: 5)),
      endTime: DateTime.now().add(const Duration(hours: 8)),
      serviceType: 'Standard Clean',
      status: JobStatus.scheduled,
    ),
  ];

  // Getters
  TimekeepingStats get stats => _stats;
  List<TimeRecord> get timeRecords => List.unmodifiable(_timeRecords);
  List<WorkShift> get workShifts => List.unmodifiable(_workShifts);
  List<TempCard> get tempCards => List.unmodifiable(_tempCards);
  String? get activeJobId => _activeJobId;
  Job? get activeJob => _mockJobs.firstWhere((j) => j.id == _activeJobId, orElse: () => _mockJobs.first);
  List<Job> get availableJobs => _mockJobs;
  DateTime get selectedMonth => _selectedMonth;
  bool get hasActiveJob => _activeJobId != null;
  bool get hasActiveProxy => _activeProxyCardId != null;

  TimekeepingProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Initialize temp cards
    _tempCards = [
      TempCard(
        cardNumber: 'A1B2C3',
        staffId: 'staff005',
        staffName: 'Maria Lopez',
        role: 'Cleaner',
      ),
      TempCard(
        cardNumber: 'D4E5F6',
        staffId: 'staff006',
        staffName: 'James Kim',
        role: 'Driver',
      ),
    ];

    // Initialize work shifts
    final now = DateTime.now();
    _workShifts = [
      // External shifts (Hotel)
      WorkShift(
        id: 'shift001',
        date: DateTime(now.year, now.month, 6),
        type: 'External',
        name: 'Hotel Shift (Perm)',
        hours: '08:00-16:00',
        location: 'City Center Hotel',
        isBooked: true,
      ),
      WorkShift(
        id: 'shift002',
        date: DateTime(now.year, now.month, 13),
        type: 'External',
        name: 'Hotel Shift (Perm)',
        hours: '08:00-16:00',
        location: 'City Center Hotel',
        isBooked: true,
      ),
      // NCL shifts
      WorkShift(
        id: 'shift003',
        date: DateTime(now.year, now.month, 7),
        type: 'NCL Shift',
        name: 'Supervisor Training',
        hours: '10:00-14:00',
        location: 'NCL Office',
        isBooked: true,
      ),
      WorkShift(
        id: 'shift004',
        date: DateTime(now.year, now.month, 10),
        type: 'NCL Shift',
        name: 'Deep Clean - Smith',
        hours: '14:00-17:00',
        location: 'Smith Residence',
        isBooked: true,
      ),
    ];

    // Add a mock completed record
    _timeRecords.add(TimeRecord(
      id: 'rec001',
      jobId: 'job003',
      jobName: 'Window Washing - Corporate HQ',
      checkInTime: DateTime.now().subtract(const Duration(hours: 5)),
      checkOutTime: DateTime.now().subtract(const Duration(hours: 1)),
      type: 'Self',
      isCompleted: true,
    ));
  }

  // Actions
  Future<bool> checkIn(String jobId, {bool isProxy = false, String? cardNumber}) async {
    if (_activeJobId != null) {
      return false; // Already checked in
    }

    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API

    _activeJobId = jobId;
    
    if (isProxy && cardNumber != null) {
      _activeProxyCardId = cardNumber;
      _updateTempCardStatus(cardNumber, true);
      _stats = _stats.copyWith(status: 'Proxy Check-In', activeJobs: 1);
    } else {
      _stats = _stats.copyWith(status: 'On-Duty', activeJobs: 1);
    }

    // Create time record
    final job = _mockJobs.firstWhere((j) => j.id == jobId, orElse: () => _mockJobs.first);
    _timeRecords.insert(0, TimeRecord(
      id: 'rec${DateTime.now().millisecondsSinceEpoch}',
      jobId: jobId,
      jobName: job.customerName,
      checkInTime: DateTime.now(),
      type: isProxy ? 'Proxy' : 'Self',
      proxyCardId: cardNumber,
    ));

    notifyListeners();
    return true;
  }

  Future<bool> checkOut({String? cardNumber}) async {
    if (_activeJobId == null) {
      return false; // Not checked in
    }

    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API

    // Complete the active time record
    final activeRecord = _timeRecords.firstWhere(
      (r) => r.jobId == _activeJobId && !r.isCompleted,
      orElse: () => _timeRecords.first,
    );

    final index = _timeRecords.indexOf(activeRecord);
    if (index != -1) {
      _timeRecords[index] = activeRecord.copyWith(
        checkOutTime: DateTime.now(),
        isCompleted: true,
      );
    }

    // Update stats
    final duration = _timeRecords[index].duration;
    _stats = _stats.copyWith(
      hoursToday: _stats.hoursToday + duration.inMinutes / 60,
      activeJobs: 0,
      status: 'Off-Duty',
      completedJobsThisMonth: _stats.completedJobsThisMonth + 1,
    );

    if (_activeProxyCardId != null) {
      _updateTempCardStatus(_activeProxyCardId!, false);
      _activeProxyCardId = null;
    }

    _activeJobId = null;
    notifyListeners();
    return true;
  }

  void _updateTempCardStatus(String cardNumber, bool isInUse) {
    final index = _tempCards.indexWhere((c) => c.cardNumber == cardNumber);
    if (index != -1) {
      _tempCards[index] = _tempCards[index].copyWith(isInUse: isInUse);
    }
  }

  void changeMonth(int offset) {
    _selectedMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + offset,
      1,
    );
    notifyListeners();
  }

  List<WorkShift> getShiftsForDate(DateTime date) {
    return _workShifts.where((shift) {
      return shift.date.year == date.year &&
          shift.date.month == date.month &&
          shift.date.day == date.day;
    }).toList();
  }

  TempCard? getTempCard(String cardNumber) {
    try {
      return _tempCards.firstWhere((c) => c.cardNumber == cardNumber.toUpperCase());
    } catch (e) {
      return null;
    }
  }
}