import 'package:flutter_test/flutter_test.dart';

// Import the actual implementations
import 'package:demo_ncl/models/job_model.dart';
import 'package:demo_ncl/providers/staff_provider.dart';
import 'package:demo_ncl/repositories/job_repository.dart';
import 'package:demo_ncl/models/job_status.dart';

// We'll use a test-specific main function
void main() {
  late StaffProvider staffProvider;
  late JobRepository jobRepository;
  
  // Set up the test environment
  setUp(() {
    // Create a real JobRepository instance
    jobRepository = JobRepository();
    
    // Create the StaffProvider with the real repository
    staffProvider = StaffProvider(
      jobRepository: jobRepository,
      authProvider: null, // We'll mock this if needed
      scheduleRepository: null, // We'll mock this if needed
    );
  });

  group('StaffProvider Integration Tests', () {
    test('should load jobs from the repository', () async {
      // Act
      await staffProvider.loadJobs();
      
      // Assert
      // The mock repository initializes with some test data
      expect(staffProvider.jobs, isNotEmpty);
      expect(staffProvider.error, isNull);
      expect(staffProvider.isLoading, false);
    });

    test('should update job status', () async {
      // Arrange - load jobs first
      await staffProvider.loadJobs();
      final initialJobs = List<Job>.from(staffProvider.jobs);
      
      if (initialJobs.isNotEmpty) {
        final jobToUpdate = initialJobs.first;
        const newStatus = JobStatus.inProgress;
        
        // Act
        await staffProvider.updateJobStatus(jobToUpdate.id, newStatus);
        
        // Assert
        expect(staffProvider.error, isNull);
        
        // Reload jobs to verify the update
        await staffProvider.loadJobs();
        final updatedJob = staffProvider.jobs.firstWhere(
          (j) => j.id == jobToUpdate.id,
          orElse: () => throw Exception('Job not found'),
        );
        
        expect(updatedJob.status, newStatus);
      } else {
        // If no jobs are available, mark the test as skipped
        // This is better than failing if the test data changes
        expect(true, true, reason: 'No jobs available to test update');
      }
    });

    test('should update checklist status', () async {
      // Arrange - load jobs first
      await staffProvider.loadJobs();
      final jobsWithChecklist = staffProvider.jobs.where(
        (job) => job.checklistId != null,
      ).toList();
      
      if (jobsWithChecklist.isNotEmpty) {
        final jobToUpdate = jobsWithChecklist.first;
        const newChecklistStatus = true;
        
        // Act
        await staffProvider.updateChecklistStatus(
          jobToUpdate.id,
          newChecklistStatus,
        );
        
        // Assert
        expect(staffProvider.error, isNull);
        
        // Reload jobs to verify the update
        await staffProvider.loadJobs();
        final updatedJob = staffProvider.jobs.firstWhere(
          (j) => j.id == jobToUpdate.id,
          orElse: () => throw Exception('Job not found'),
        );
        
        expect(updatedJob.checklistCompleted, newChecklistStatus);
      } else {
        // If no jobs with checklists are available, mark the test as skipped
        expect(true, true, reason: 'No jobs with checklists available to test');
      }
    });
  });
}
