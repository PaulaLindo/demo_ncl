import 'package:dartz/dartz.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../models/failure.dart';
import '../models/job_model.dart';
import '../models/job_status.dart';

class JobRepository {
    final Logger _logger = Logger('JobRepository');
    List<Job> _jobs = [];
    final _uuid = const Uuid();

  // Initialize with mock data
  JobRepository() {
    final now = DateTime.now();
    _jobs = [
      Job(
        id: _uuid.v4(),
        title: 'Office Cleaning',
        location: '123 Business St',
        description: 'Full office cleaning',
        customerName: 'Acme Inc',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 5)),
        status: JobStatus.scheduled,
        isActive: true,
        requiredSkills: const ['cleaning', 'organization'],
      ),
      Job(
        id: _uuid.v4(),
        title: 'Hotel Cleaning',
        location: '123 Business St, City',
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        endTime: DateTime(now.year, now.month, now.day, 17, 0),
        status: JobStatus.scheduled,
      ),
      Job(
        id: _uuid.v4(),
        title: 'Luxury Suites Cleaning',
        location: '456 Premium Ave, City',
        startTime: DateTime(now.year, now.month, now.day + 1, 10, 0),
        endTime: DateTime(now.year, now.month, now.day + 1, 14, 0),
        status: JobStatus.scheduled,
      ),
    ];
  }

    Future<Either<Exception, List<Job>>> getStaffJobs({
        required String staffId,
        DateTime? startDate,
        DateTime? endDate,
    }) async {
        try {
        // In a real app, this would fetch from a database
        return const Right([]);
        } catch (e) {
        return Left(Exception('Failed to fetch staff jobs: $e'));
        }
    }

    Future<Either<Failure, Job>> updateJobStatus(
        String jobId,
        JobStatus status,
    ) async {
            try {
            final index = _jobs.indexWhere((j) => j.id == jobId);
            if (index == -1) {
                return Left(Failure(message: 'Job not found'));
            }

            final updatedJob = _jobs[index].copyWith(status: status);
            _jobs[index] = updatedJob;
            
                return Right(updatedJob);
            } catch (e) {
                return Left(Failure(message: 'Failed to update job status: $e'));
            }
    }

  Future<Either<Failure, Job>> updateChecklistStatus({
    required String jobId,
    required bool isCompleted,
  }) async {
    try {
      final index = _jobs.indexWhere((j) => j.id == jobId);
      if (index == -1) {
        return Left(Failure(message: 'Job not found'));
      }

      final updatedJob = _jobs[index].copyWith(
        checklistCompleted: isCompleted,
        status: isCompleted ? JobStatus.completed : JobStatus.inProgress,
      );
      _jobs[index] = updatedJob;
      
      return Right(updatedJob);
    } catch (e) {
      return Left(Failure(message: 'Failed to update checklist status: $e'));
    }
  }

  
  Future<Either<Exception, List<Job>>> getAll() async {
    try {
      return Right(List<Job>.from(_jobs));
    } catch (e) {
      return Left(Exception('Failed to fetch jobs: $e'));
    }
  }

  
  Future<Either<Exception, Job?>> getById(String id) async {
    try {
      final job = _jobs.firstWhere(
        (j) => j.id == id,
        orElse: () => throw Exception('Job not found'),
      );
      return Right(job);
    } on Exception catch (e) {
      return Left(e);
    }
  }

  
  Future<Either<Exception, Job>> save(Job job) async {
    try {
      final index = _jobs.indexWhere((j) => j.id == job.id);
      final updatedJob = job.copyWith(
        id: job.id.isEmpty ? _uuid.v4() : job.id,
      );
      
      if (index >= 0) {
        _jobs[index] = updatedJob;
      } else {
        _jobs.add(updatedJob);
      }
      
      return Right(updatedJob);
    } catch (e) {
      return Left(Exception('Failed to save job: $e'));
    }
  }

  
  Future<Either<Exception, void>> delete(String id) async {
    try {
      _jobs.removeWhere((j) => j.id == id);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to delete job: $e'));
    }
  }

  
  Future<Either<Exception, List<Job>>> query(Map<String, dynamic> query) async {
    try {
      var results = List<Job>.from(_jobs);
      
      if (query.containsKey('status')) {
        results = results.where((j) => j.status == query['status']).toList();
      }
      
      if (query.containsKey('date')) {
        final date = query['date'] as DateTime;
        results = results.where((j) {
          return j.startTime.year == date.year &&
                 j.startTime.month == date.month &&
                 j.startTime.day == date.day;
        }).toList();
      }
      
      if (query.containsKey('dateRange')) {
        final range = query['dateRange'] as Map<String, DateTime>;
        final start = range['start']!;
        final end = range['end']!;
        
        results = results.where((j) {
          return !j.startTime.isBefore(start) && !j.startTime.isAfter(end);
        }).toList();
      }
      
      // Sort by start time by default
      results.sort((a, b) => a.startTime.compareTo(b.startTime));
      
      return Right(results);
    } catch (e) {
      return Left(Exception('Query failed: $e'));
    }
  }
  
  // Additional job-specific methods
  
  Future<Either<Exception, List<Job>>> getJobsByDateRange(
    DateTime start,
    DateTime end, {
    JobStatus? status,
  }) async {
    try {
      final result = await query({
        'dateRange': {'start': start, 'end': end},
        if (status != null) 'status': status,
      });
      return result;
    } catch (e) {
      return Left(Exception('Failed to get jobs by date range: $e'));
    }
  }

  Future<Either<Exception, List<Job>>> getJobsByStatus(JobStatus status) async {
    try {
      final result = await query({'status': status});
      return result;
    } catch (e) {
      return Left(Exception('Failed to get jobs by status: $e'));
    }
  }

   Future<Either<Failure, List<Job>>> getJobs() async {
    try {
      return Right(List<Job>.from(_jobs));
    } catch (e, stackTrace) {
      _logger.severe('Failed to get jobs', e, stackTrace);
      return Left(Failure(
        message: 'Failed to load jobs',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }
  
  Future<Either<Exception, List<Job>>> getAvailableJobs(DateTime date) async {
    try {
      final result = await query({
        'date': date,
        'status': JobStatus.scheduled,
      });
      return result;
    } catch (e) {
      return Left(Exception('Failed to get available jobs: $e'));
    }
  }

  Future<Either<Failure, bool>> updateJob(Job job) async {
    try {
      final index = _jobs.indexWhere((j) => j.id == job.id);
      if (index != -1) {
        _jobs[index] = job;
      } else {
        _jobs.add(job);
      }
      return const Right(true);
    } catch (e, stackTrace) {
      _logger.severe('Failed to update job', e, stackTrace);
      return Left(Failure(
        message: 'Failed to update job',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  Future<Either<Failure, bool>> deleteJob(String jobId) async {
    try {
      _jobs.removeWhere((j) => j.id == jobId);
      return const Right(true);
    } catch (e, stackTrace) {
      _logger.severe('Failed to delete job', e, stackTrace);
      return Left(Failure(
        message: 'Failed to delete job',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
