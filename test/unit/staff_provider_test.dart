import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

// Import the Job model from the previous test
import 'job_model_test.dart';

// Simple Failure class for testing
class Failure {
  final String message;
  
  Failure(this.message);
  
  @override
  String toString() => 'Failure: $message';
}

// Mock repository
class MockJobRepository extends Mock {
  Future<Either<Failure, List<Job>>> getStaffJobs(String staffId);
  Future<Either<Failure, Job>> updateJobStatus(String jobId, JobStatus status);
  Future<Either<Failure, Job>> updateChecklistStatus({
    required String jobId,
    required bool isCompleted,
  });
}

// Simple StaffProvider for testing
class StaffProvider {
  final MockJobRepository _jobRepository;
  
  List<Job> _jobs = [];
  String? _error;
  bool _isLoading = false;
  
  StaffProvider({
    required MockJobRepository jobRepository,
  }) : _jobRepository = jobRepository;
  
  List<Job> get jobs => List.unmodifiable(_jobs);
  String? get error => _error;
  bool get isLoading => _isLoading;
  
  Future<void> loadJobs() async {
    _isLoading = true;
    _error = null;
    
    try {
      final result = await _jobRepository.getStaffJobs('test-staff-id');
      result.fold(
        (failure) => _error = failure.message,
        (jobs) => _jobs = jobs,
      );
    } catch (e) {
      _error = 'Unexpected error: $e';
    } finally {
      _isLoading = false;
    }
  }
  
  Future<void> updateJobStatus(String jobId, JobStatus status) async {
    try {
      final result = await _jobRepository.updateJobStatus(jobId, status);
      result.fold(
        (failure) => _error = failure.message,
        (updatedJob) {
          final index = _jobs.indexWhere((j) => j.id == jobId);
          if (index != -1) {
            _jobs[index] = updatedJob;
          }
        },
      );
    } catch (e) {
      _error = 'Unexpected error: $e';
    }
  }
  
  Future<void> updateChecklistStatus({
    required String jobId,
    required bool isCompleted,
  }) async {
    try {
      final result = await _jobRepository.updateChecklistStatus(
        jobId: jobId,
        isCompleted: isCompleted,
      );
      
      result.fold(
        (failure) => _error = failure.message,
        (updatedJob) {
          final index = _jobs.indexWhere((j) => j.id == jobId);
          if (index != -1) {
            _jobs[index] = updatedJob;
          }
        },
      );
    } catch (e) {
      _error = 'Unexpected error: $e';
    }
  }
}

void main() {
  late StaffProvider staffProvider;
  late MockJobRepository mockJobRepository;
  
  final now = DateTime.now();
  
  final testJob = Job(
    id: '1',
    name: 'Test Job',
    customerName: 'Test Customer',
    address: '123 Test St',
    startTime: now.add(const Duration(days: 1)),
    endTime: now.add(const Duration(days: 1, hours: 2)),
    serviceType: 'Cleaning',
    status: JobStatus.scheduled,
    checklistId: 'checklist_1',
    checklistCompleted: false,
  );
  
  setUp(() {
    mockJobRepository = MockJobRepository();
    staffProvider = StaffProvider(jobRepository: mockJobRepository);
  });
  
  group('StaffProvider', () {
    test('loadJobs should update jobs list when successful', () async {
      // Arrange
      when(() => mockJobRepository.getStaffJobs(any()))
          .thenAnswer((_) async => Right([testJob]));
      
      // Act
      await staffProvider.loadJobs();
      
      // Assert
      expect(staffProvider.jobs.length, 1);
      expect(staffProvider.jobs.first, testJob);
      expect(staffProvider.error, isNull);
      expect(staffProvider.isLoading, false);
    });
    
    test('loadJobs should set error when repository fails', () async {
      // Arrange
      when(() => mockJobRepository.getStaffJobs(any()))
          .thenAnswer((_) async => Left(Failure('Failed to load jobs')));
      
      // Act
      await staffProvider.loadJobs();
      
      // Assert
      expect(staffProvider.jobs, isEmpty);
      expect(staffProvider.error, 'Failed to load jobs');
      expect(staffProvider.isLoading, false);
    });
    
    test('updateJobStatus should update job status when successful', () async {
      // Arrange
      staffProvider = StaffProvider(jobRepository: mockJobRepository);
      staffProvider._jobs = [testJob];
      
      final updatedJob = testJob.copyWith(status: JobStatus.inProgress);
      
      when(() => mockJobRepository.updateJobStatus('1', JobStatus.inProgress))
          .thenAnswer((_) async => Right(updatedJob));
      
      // Act
      await staffProvider.updateJobStatus('1', JobStatus.inProgress);
      
      // Assert
      expect(staffProvider.jobs.first.status, JobStatus.inProgress);
      expect(staffProvider.error, isNull);
    });
    
    test('updateChecklistStatus should update checklist status when successful', 
      () async {
        // Arrange
        staffProvider = StaffProvider(jobRepository: mockJobRepository);
        staffProvider._jobs = [testJob];
        
        final updatedJob = testJob.copyWith(checklistCompleted: true);
        
        when(() => mockJobRepository.updateChecklistStatus(
          jobId: '1',
          isCompleted: true,
        )).thenAnswer((_) async => Right(updatedJob));
        
        // Act
        await staffProvider.updateChecklistStatus(
          jobId: '1',
          isCompleted: true,
        );
        
        // Assert
        expect(staffProvider.jobs.first.checklistCompleted, isTrue);
        expect(staffProvider.error, isNull);
      },
    );
  });
}
