// Create a test file: test/migration_verification_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ncl_mobile_app/models/job_service_models.dart';
import 'package:ncl_mobile_app/services/auth_service.dart';

void main() {
  test('JobStatus enum exists and works', () {
    final status = JobStatus.inProgress;
    expect(status.displayName, 'In Progress');
    expect(status.getColor(), isNotNull);
  });

  test('User class from models works', () {
    final user = User(
      id: 'test1',
      name: 'Test User',
      isStaff: false,
    );
    expect(user.id, 'test1');
    expect(user.name, 'Test User');
  });

  test('AuthResult works correctly', () {
    final user = User(id: '1', name: 'Test', isStaff: false);
    final success = AuthResult.success(user);
    expect(success.success, true);
    expect(success.user, isNotNull);

    final failure = AuthResult.failure('Test error');
    expect(failure.success, false);
    expect(failure.errorMessage, 'Test error');
  });

  test('Job model uses JobStatus enum', () {
    final job = Job(
      id: 'job1',
      customerName: 'Customer',
      address: '123 Main St',
      startTime: DateTime.now(),
      endTime: DateTime.now().add(Duration(hours: 2)),
      serviceType: 'Cleaning',
      status: JobStatus.scheduled,
    );
    expect(job.status, JobStatus.scheduled);
    expect(job.status.displayName, 'Scheduled');
  });
}