import 'package:flutter/foundation.dart';
import '../models/job_service_models.dart';

/// JobsProvider - Manages job-related state, fetching, and filtering
class JobsProvider extends ChangeNotifier {
  List<Job> _jobs = [];
  bool _isLoading = false;
  String _currentFilter = 'today';
  Job? _activeJob;

  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String get currentFilter => _currentFilter;
  Job? get activeJob => _activeJob;

  List<Job> get filteredJobs {
    // Placeholder filtering logic
    if (_currentFilter == 'today') {
      return _jobs.where((job) => job.status != 'Completed').toList();
    }
    if (_currentFilter == 'completed') {
      return _jobs.where((job) => job.status == 'Completed').toList();
    }
    return _jobs;
  }

  // Placeholder for fetching data
  Future<void> loadJobs(bool forceReload) async {
    _isLoading = true;
    notifyListeners();
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Placeholder data
    _jobs = [
      Job(
        id: '101',
        serviceType: 'Deep Clean',
        customerName: 'Alice Johnson',
        address: '123 Main St, Anytown',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 4)),
        status: JobStatus.scheduled,
      ),
      Job(
        id: '102',
        serviceType: 'Regular Mowing',
        customerName: 'Bob Smith',
        address: '456 Oak Ave, Somewhere',
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        status: JobStatus.inProgress,
      ),
      Job(
        id: '103',
        serviceType: 'Window Washing',
        customerName: 'Charlie Brown',
        address: '789 Pine Ln, Nowhere',
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now().subtract(const Duration(hours: 20)),
        status: JobStatus.completed,
      ),
    ];
    
    // FIX: Replaced problematic firstWhere with a null-safe approach
    final activeJobs = _jobs.where((job) => job.status == JobStatus.inProgress);
    _activeJob = activeJobs.isNotEmpty ? activeJobs.first : null;

    _isLoading = false;
    notifyListeners();
  }

  void applyFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void startJob(Job job) {
    final index = _jobs.indexOf(job);
    if (index != -1) {
      // This call now works because the Job model has copyWith
      _jobs[index] = job.copyWith(status: JobStatus.inProgress);
      _activeJob = _jobs[index];
      notifyListeners();
    }
  }

  void completeJob(Job job) {
    final index = _jobs.indexOf(job);
    if (index != -1) {
      // This call now works because the Job model has copyWith
      _jobs[index] = job.copyWith(status: JobStatus.completed);
      _activeJob = null;
      notifyListeners();
    }
  }
}