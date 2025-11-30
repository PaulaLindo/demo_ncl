// test/unit/provider_initialization_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import 'package:demo_ncl/providers/checklist_provider.dart';
import 'package:demo_ncl/providers/staff_provider.dart';
import 'package:demo_ncl/repositories/job_repository.dart';
import 'package:demo_ncl/repositories/staff_schedule_repository.dart';

void main() {
  group('Provider Initialization Tests', () {
    test('should initialize AuthProvider without errors', () {
      expect(() => AuthProvider(), returnsNormally);
    });

    test('should initialize AuthProvider with service without errors', () {
      final mockDataService = MockDataService();
      expect(() => AuthProvider(mockDataService), returnsNormally);
    });

    test('should initialize ChecklistProvider without errors', () {
      expect(() => ChecklistProvider(), returnsNormally);
    });

    test('should initialize JobRepository without errors', () {
      expect(() => JobRepository(), returnsNormally);
    });

    test('should initialize StaffScheduleRepository without errors', () {
      expect(() => StaffScheduleRepository(), returnsNormally);
    });

    test('should initialize StaffProvider with dependencies', () {
      final jobRepository = JobRepository();
      final staffScheduleRepository = StaffScheduleRepository();
      final authProvider = AuthProvider();
      
      expect(() => StaffProvider(
        jobRepository: jobRepository,
        scheduleRepository: staffScheduleRepository,
        authProvider: authProvider,
      ), returnsNormally);
    });

    test('should test AuthProvider basic functionality', () async {
      final authProvider = AuthProvider();
      
      // Test initial state
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.state, equals(AuthState.unauthenticated));
      expect(authProvider.errorMessage, isNull);
      
      // Test login
      final result = await authProvider.login(
        email: 'customer@example.com',
        password: 'customer123',
      );
      
      expect(result, isTrue);
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.currentUser?.email, equals('customer@example.com'));
      
      // Test logout
      await authProvider.logout();
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.currentUser, isNull);
      
      authProvider.dispose();
    });
  });
}
