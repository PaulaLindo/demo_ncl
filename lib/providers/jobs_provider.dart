import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../models/job_model.dart';
import '../models/job_status.dart';

import '../repositories/job_repository.dart';

/// JobsProvider - Manages job-related state, fetching, and filtering
class JobsProvider extends ChangeNotifier {
  final Logger _logger = Logger ('JobsProvider');
  final JobRepository _jobRepository;

  List<Job> _jobs = [];
  
  bool _isLoading = false;

  String _currentFilter = 'today';
  String? _error;

  Job? _activeJob;

  
  JobsProvider({JobRepository? jobRepository})
      : _jobRepository = jobRepository ?? JobRepository();

  List<Job> get jobs => List.unmodifiable(_jobs);
  Job? get activeJob => _activeJob;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Job> get activeJobs => _jobs
      .where((job) => job.status == JobStatus.inProgress)
      .toList();

  List<Job> get upcomingJobs => _jobs
      .where((job) => job.status == JobStatus.scheduled)
      .toList();

  List<Job> get completedJobs => _jobs
      .where((job) => job.status == JobStatus.completed)
      .toList();

  String get currentFilter => _currentFilter;

  List<Job> get filteredJobs {
     switch (_currentFilter) {
      case 'today':
        final now = DateTime.now();
        return _jobs.where((job) => 
          job.startTime.year == now.year &&
          job.startTime.month == now.month && 
          job.startTime.day == now.day
        ).toList();
      case 'upcoming':
        return _jobs.where((job) => 
          job.status == JobStatus.scheduled
        ).toList();
      case 'completed':
        return _jobs.where((job) => 
          job.status == JobStatus.completed
        ).toList();
      default:
        return List.from(_jobs);
    }
  }

  // Placeholder for fetching data
  Future<void> _loadJobs() async {
    _setLoading(true);
    try {
      final result = await _jobRepository.getJobs();
      result.fold(
        (failure) => setError(failure.message),
        (jobs) {
          _jobs = jobs;
          _error = null;
          notifyListeners();
        },
      );
    } catch (e, stackTrace) {
      setError('Failed to load jobs');
      _logger.severe('Failed to load jobs', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> startJob(Job job) async {
    _setLoading(true);
    try {
      final updatedJob = job.copyWith(status: JobStatus.inProgress);
      final result = await _jobRepository.updateJob(updatedJob);
      
      await result.fold(
        (failure) {
          setError(failure.message);
          _logger.severe('Failed to start job: ${failure.message}');
        },
        (success) {
          if (success) {
            final index = _jobs.indexWhere((j) => j.id == job.id);
            if (index != -1) {
              _jobs[index] = updatedJob;
            }
            _activeJob = updatedJob;
          } else {
            setError('Failed to start job: Unknown error');
          }
        },
      );
    } catch (e) {
      setError('Failed to start job: $e');
      _logger.severe('Failed to start job: $e', e, StackTrace.current);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeJob(Job job) async {
    _setLoading(true);
    try {
      final updatedJob = job.copyWith(
        status: JobStatus.completed,
        endTime: DateTime.now(),
      );
      
      final result = await _jobRepository.updateJob(updatedJob);
      
      await result.fold(
        (failure) {
          setError(failure.message);
          _logger.severe('Failed to complete job: ${failure.message}');
        },
        (success) {
          if (success) {
            final index = _jobs.indexWhere((j) => j.id == job.id);
            if (index != -1) {
              _jobs[index] = updatedJob;
              if (_activeJob?.id == job.id) {
                _activeJob = null;
              }
              notifyListeners();
            }
          }
        },
      );
    } catch (e, stackTrace) {
      _error = 'Failed to complete job: $e';
      _logger.severe(_error, e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  void setActiveJob(Job? job) {
    _activeJob = job;
    notifyListeners();
  }
}