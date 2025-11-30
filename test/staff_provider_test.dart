import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:demo_ncl/models/job_model.dart';
import 'package:demo_ncl/models/job_status.dart';
import 'package:demo_ncl/providers/staff_provider.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/repositories/job_repository.dart';
import 'package:demo_ncl/repositories/staff_schedule_repository.dart';

// Mock classes
class MockJobRepository extends Mock implements JobRepository {}
class MockAuthProvider extends Mock implements AuthProvider {}
class MockStaffScheduleRepository extends Mock implements StaffScheduleRepository {}

void main() {
  late StaffProvider staffProvider;
  late MockJobRepository mockJobRepository;
  late MockAuthProvider mockAuthProvider;
  late MockStaffScheduleRepository mockScheduleRepository;

  setUp(() {
    mockJobRepository = MockJobRepository();
    mockAuthProvider = MockAuthProvider();
    mockScheduleRepository = MockStaffScheduleRepository();
    
    staffProvider = StaffProvider(
      jobRepository: mockJobRepository,
      authProvider: mockAuthProvider,
      scheduleRepository: mockScheduleRepository,
    );
  });

  group('StaffProvider', () {
    test('loadJobs should update jobs list', () async {
      // Arrange
      final mockJobs = [
        Job(
          id: '1',
          title: 'Test Job',
          location: '123 Test St',
          startTime: DateTime.now().add(const Duration(days: 1)),
          endTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
          status: JobStatus.scheduled,
          checklistId: 'checklist_1',
          checklistCompleted: false,
        ),
      ];
      
      when(() => mockJobRepository.getStaffJobs(staffId: any(named: 'staffId')))
          .thenAnswer((_) async => Right(mockJobs));

      // Act
      await staffProvider.loadJobs();

      // Assert
      expect(staffProvider.jobs, mockJobs);
      expect(staffProvider.error, isNull);
    });
  });
}