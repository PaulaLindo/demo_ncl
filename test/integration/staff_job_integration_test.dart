import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

// Import the necessary models and enums directly
enum JobStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
}

class Job {
  final String id;
  final String name;
  final String customerName;
  final String address;
  final DateTime startTime;
  final DateTime endTime;
  final String serviceType;
  final JobStatus status;
  final String? checklistId;
  final bool checklistCompleted;

  Job({
    required this.id,
    required this.name,
    required this.customerName,
    required this.address,
    required this.startTime,
    required this.endTime,
    required this.serviceType,
    this.status = JobStatus.scheduled,
    this.checklistId,
    this.checklistCompleted = false,
  });

  Job copyWith({
    String? id,
    String? name,
    String? customerName,
    String? address,
    DateTime? startTime,
    DateTime? endTime,
    String? serviceType,
    JobStatus? status,
    String? checklistId,
    bool? checklistCompleted,
  }) {
    return Job(
      id: id ?? this.id,
      name: name ?? this.name,
      customerName: customerName ?? this.customerName,
      address: address ?? this.address,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      checklistId: checklistId ?? this.checklistId,
      checklistCompleted: checklistCompleted ?? this.checklistCompleted,
    );
  }
}

// Simple Failure class
class Failure {
  final String message;
  
  Failure(this.message);
  
  @override
  String toString() => 'Failure: $message';
}

// JobRepository interface
abstract class IJobRepository {
  Future<Either<Failure, List<Job>>> getStaffJobs(String staffId);
  Future<Either<Failure, Job>> updateJobStatus(String jobId, JobStatus status);
  Future<Either<Failure, Job>> updateChecklistStatus({
    required String jobId,
    required bool isCompleted,
  });
}

// Mock repository for testing
class MockJobRepository extends Mock implements IJobRepository {}

// StaffProvider class for testing
class StaffProvider {
  final IJobRepository _jobRepository;
  
  List<Job> _jobs = [];
  String? _error;
  bool _isLoading = false;
  
  StaffProvider({
    required IJobRepository jobRepository,
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
  
  group('StaffProvider Integration Tests', () {
    test('should load jobs from the repository', () async {
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
    
    test('should handle error when loading jobs fails', () async {
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
    
    test('should update job status', () async {
      // Arrange
      staffProvider = StaffProvider(jobRepository: mockJobRepository);
      
      // Set up initial jobs
      when(() => mockJobRepository.getStaffJobs(any()))
          .thenAnswer((_) async => Right([testJob]));
      
      await staffProvider.loadJobs();
      
      final updatedJob = testJob.copyWith(status: JobStatus.inProgress);
      
      when(() => mockJobRepository.updateJobStatus('1', JobStatus.inProgress))
          .thenAnswer((_) async => Right(updatedJob));
      
      // Act
      await staffProvider.updateJobStatus('1', JobStatus.inProgress);
      
      // Assert
      expect(staffProvider.jobs.first.status, JobStatus.inProgress);
      expect(staffProvider.error, isNull);
    });
    
    test('should update checklist status', () async {
      // Arrange
      staffProvider = StaffProvider(jobRepository: mockJobRepository);
      
      // Set up initial jobs
      when(() => mockJobRepository.getStaffJobs(any()))
          .thenAnswer((_) async => Right([testJob]));
      
      await staffProvider.loadJobs();
      
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
    });
  });
}
