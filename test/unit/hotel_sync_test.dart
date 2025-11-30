// test/unit/hotel_sync_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:demo_ncl/providers/hotel_sync_provider.dart';
import 'package:demo_ncl/models/hotel_sync_model.dart';
import 'package:demo_ncl/repositories/hotel_sync_repository.dart';

import 'hotel_sync_test.mocks.dart';

@GenerateMocks([HotelSyncRepository])
void main() {
  group('Hotel Partner Sync Features', () {
    late HotelSyncProvider provider;
    late MockHotelSyncRepository mockRepository;

    setUp(() {
      mockRepository = MockHotelSyncRepository();
      provider = HotelSyncProvider(repository: mockRepository);
    });

    group('TC 3.1: Hotel Partner Sync', () {
      test('should import hotel roster data successfully', () async {
        // Arrange
        final rosterData = [
          {
            'employeeId': 'HOTEL001',
            'name': 'John Smith',
            'onDutyStatus': 'On Duty',
            'department': 'Housekeeping',
            'shiftStart': '08:00',
            'shiftEnd': '16:00',
          },
          {
            'employeeId': 'HOTEL002',
            'name': 'Jane Doe',
            'onDutyStatus': 'Off Duty',
            'department': 'Housekeeping',
            'shiftStart': '16:00',
            'shiftEnd': '00:00',
          },
        ];

        when(mockRepository.fetchHotelRoster())
            .thenAnswer((_) async => rosterData);

        // Act
        final result = await provider.importHotelRoster();

        // Assert
        expect(result.success, isTrue);
        expect(result.importedCount, equals(2));
        expect(result.errors, isEmpty);
        verify(mockRepository.fetchHotelRoster()).called(1);
      });

      test('should update NCL scheduler based on hotel sync', () async {
        // Arrange
        final rosterData = [
          {
            'employeeId': 'HOTEL001',
            'name': 'John Smith',
            'onDutyStatus': 'On Duty',
            'department': 'Housekeeping',
          },
        ];

        when(mockRepository.fetchHotelRoster())
            .thenAnswer((_) async => rosterData);
        when(mockRepository.updateNCLScheduler(any))
            .thenAnswer((_) async => true);

        // Act
        await provider.importHotelRoster();
        final schedulerUpdated = await provider.updateSchedulerFromSync();

        // Assert
        expect(schedulerUpdated, isTrue);
        verify(mockRepository.updateNCLScheduler(any)).called(1);
      });

      test('should handle sync failures gracefully', () async {
        // Arrange
        when(mockRepository.fetchHotelRoster())
            .thenThrow(Exception('API connection failed'));

        // Act
        final result = await provider.importHotelRoster();

        // Assert
        expect(result.success, isFalse);
        expect(result.importedCount, equals(0));
        expect(result.errors, isNotEmpty);
        expect(result.errors.first, contains('API connection failed'));
      });

      test('should validate Employee ID format and uniqueness', () async {
        // Arrange
        final invalidRosterData = [
          {
            'employeeId': '', // Empty ID
            'name': 'John Smith',
            'onDutyStatus': 'On Duty',
          },
          {
            'employeeId': 'INVALID_FORMAT', // Invalid format
            'name': 'Jane Doe',
            'onDutyStatus': 'Off Duty',
          },
        ];

        when(mockRepository.fetchHotelRoster())
            .thenAnswer((_) async => invalidRosterData);

        // Act
        final result = await provider.importHotelRoster();

        // Assert
        expect(result.success, isFalse);
        expect(result.importedCount, equals(0));
        expect(result.errors.length, equals(2));
        expect(result.errors.first, contains('Invalid Employee ID format'));
      });

      test('should handle duplicate Employee IDs', () async {
        // Arrange
        final duplicateRosterData = [
          {
            'employeeId': 'HOTEL001',
            'name': 'John Smith',
            'onDutyStatus': 'On Duty',
          },
          {
            'employeeId': 'HOTEL001', // Duplicate
            'name': 'Jane Doe',
            'onDutyStatus': 'Off Duty',
          },
        ];

        when(mockRepository.fetchHotelRoster())
            .thenAnswer((_) async => duplicateRosterData);

        // Act
        final result = await provider.importHotelRoster();

        // Assert
        expect(result.success, isTrue);
        expect(result.importedCount, equals(1)); // Only one imported
        expect(result.warnings, isNotEmpty);
        expect(result.warnings.first, contains('Duplicate Employee ID'));
      });

      test('should map on-duty status to NCL availability correctly', () async {
        // Arrange
        final rosterData = [
          {
            'employeeId': 'HOTEL001',
            'name': 'John Smith',
            'onDutyStatus': 'On Duty',
            'shiftStart': '08:00',
            'shiftEnd': '16:00',
          },
          {
            'employeeId': 'HOTEL002',
            'name': 'Jane Doe',
            'onDutyStatus': 'Off Duty',
            'shiftStart': '16:00',
            'shiftEnd': '00:00',
          },
        ];

        when(mockRepository.fetchHotelRoster())
            .thenAnswer((_) async => rosterData);

        // Act
        final result = await provider.importHotelRoster();
        final availability = await provider.getStaffAvailability();

        // Assert
        expect(result.success, isTrue);
        expect(availability['HOTEL001'].isAvailable, isTrue); // On Duty
        expect(availability['HOTEL002'].isAvailable, isFalse); // Off Duty
      });

      test('should track sync history and audit logs', () async {
        // Arrange
        final rosterData = [
          {
            'employeeId': 'HOTEL001',
            'name': 'John Smith',
            'onDutyStatus': 'On Duty',
          },
        ];

        when(mockRepository.fetchHotelRoster())
            .thenAnswer((_) async => rosterData);
        when(mockRepository.logSyncActivity(any))
            .thenAnswer((_) async => true);

        // Act
        await provider.importHotelRoster();
        final syncHistory = await provider.getSyncHistory();

        // Assert
        expect(syncHistory, isNotEmpty);
        expect(syncHistory.first.type, equals('roster_import'));
        expect(syncHistory.first.status, equals('success'));
        verify(mockRepository.logSyncActivity(any)).called(1);
      });
    });

    group('TC 3.2: Conflict Alert System', () {
      test('should detect On Duty conflicts', () async {
        // Arrange
        final staffId = 'HOTEL001';
        final jobAssignment = {
          'staffId': staffId,
          'serviceType': 'Deep Cleaning',
          'scheduledTime': DateTime.now().add(const Duration(hours: 2)),
        };

        // Mock staff is On Duty according to hotel sync
        when(mockRepository.getStaffSyncStatus(staffId))
            .thenAnswer((_) async => StaffSyncStatus.onDuty);

        // Act
        final conflict = await provider.detectAssignmentConflict(jobAssignment);

        // Assert
        expect(conflict.hasConflict, isTrue);
        expect(conflict.conflictType, equals(ConflictType.onDuty));
        expect(conflict.staffId, equals(staffId));
      });

      test('should generate admin alerts for conflicts', () async {
        // Arrange
        final conflict = AssignmentConflict(
          staffId: 'HOTEL001',
          conflictType: ConflictType.onDuty,
          detectedAt: DateTime.now(),
        );

        when(mockRepository.createConflictAlert(any))
            .thenAnswer((_) async => ConflictAlert(id: 'alert_001'));

        // Act
        final alert = await provider.generateConflictAlert(conflict);

        // Assert
        expect(alert, isNotNull);
        expect(alert.id, equals('alert_001'));
        expect(alert.severity, equals(AlertSeverity.high));
        verify(mockRepository.createConflictAlert(conflict)).called(1);
      });

      test('should log conflict attempts', () async {
        // Arrange
        final staffId = 'HOTEL001';
        final jobAssignment = {
          'staffId': staffId,
          'serviceType': 'Deep Cleaning',
          'scheduledTime': DateTime.now().add(const Duration(hours: 2)),
        };

        when(mockRepository.getStaffSyncStatus(staffId))
            .thenAnswer((_) async => StaffSyncStatus.onDuty);
        when(mockRepository.logConflictAttempt(any))
            .thenAnswer((_) async => true);

        // Act
        await provider.detectAssignmentConflict(jobAssignment);

        // Assert
        verify(mockRepository.logConflictAttempt(any)).called(1);
      });

      test('should prevent conflicting assignments', () async {
        // Arrange
        final conflictingAssignment = {
          'staffId': 'HOTEL001',
          'serviceType': 'Deep Cleaning',
          'scheduledTime': DateTime.now().add(const Duration(hours: 2)),
        };

        when(mockRepository.getStaffSyncStatus('HOTEL001'))
            .thenAnswer((_) async => StaffSyncStatus.onDuty);

        // Act
        final canAssign = await provider.canAssignJob(conflictingAssignment);

        // Assert
        expect(canAssign, isFalse);
      });

      test('should allow assignment when no conflict exists', () async {
        // Arrange
        final validAssignment = {
          'staffId': 'HOTEL002',
          'serviceType': 'Regular Cleaning',
          'scheduledTime': DateTime.now().add(const Duration(hours: 2)),
        };

        when(mockRepository.getStaffSyncStatus('HOTEL002'))
            .thenAnswer((_) async => StaffSyncStatus.offDuty);

        // Act
        final canAssign = await provider.canAssignJob(validAssignment);

        // Assert
        expect(canAssign, isTrue);
      });
    });

    group('Data Validation and Edge Cases', () {
      test('should handle empty roster data', () async {
        // Arrange
        when(mockRepository.fetchHotelRoster())
            .thenAnswer((_) async => []);

        // Act
        final result = await provider.importHotelRoster();

        // Assert
        expect(result.success, isTrue);
        expect(result.importedCount, equals(0));
        expect(result.warnings, isNotEmpty);
      });

      test('should handle malformed roster entries', () async {
        // Arrange
        final malformedData = [
          {
            'employeeId': 'HOTEL001',
            // Missing required fields
          },
          {
            'name': 'Jane Doe',
            'onDutyStatus': 'Off Duty',
            // Missing employeeId
          },
        ];

        when(mockRepository.fetchHotelRoster())
            .thenAnswer((_) async => malformedData);

        // Act
        final result = await provider.importHotelRoster();

        // Assert
        expect(result.success, isFalse);
        expect(result.importedCount, equals(0));
        expect(result.errors.length, equals(2));
      });

      test('should handle network timeouts', () async {
        // Arrange
        when(mockRepository.fetchHotelRoster())
            .thenThrow(TimeoutException('Request timeout', const Duration(seconds: 30)));

        // Act
        final result = await provider.importHotelRoster();

        // Assert
        expect(result.success, isFalse);
        expect(result.errors.first, contains('timeout'));
      });

      test('should validate on-duty status values', () async {
        // Arrange
        final invalidStatusData = [
          {
            'employeeId': 'HOTEL001',
            'name': 'John Smith',
            'onDutyStatus': 'INVALID_STATUS', // Invalid status
          },
        ];

        when(mockRepository.fetchHotelRoster())
            .thenAnswer((_) async => invalidStatusData);

        // Act
        final result = await provider.importHotelRoster();

        // Assert
        expect(result.success, isFalse);
        expect(result.errors.first, contains('Invalid on-duty status'));
      });
    });
  });
}

// Mock classes for testing
class TimeoutException implements Exception {
  final String message;
  final Duration duration;
  
  const TimeoutException(this.message, this.duration);
}

// Test data classes
class SyncResult {
  final bool success;
  final int importedCount;
  final List<String> errors;
  final List<String> warnings;

  SyncResult({
    required this.success,
    required this.importedCount,
    this.errors = const [],
    this.warnings = const [],
  });
}

enum StaffSyncStatus { onDuty, offDuty }

enum ConflictType { onDuty, schedulingOverlap }

enum AlertSeverity { low, medium, high, critical }

class AssignmentConflict {
  final String staffId;
  final ConflictType conflictType;
  final DateTime detectedAt;

  AssignmentConflict({
    required this.staffId,
    required this.conflictType,
    required this.detectedAt,
  });

  bool get hasConflict => true;
}

class ConflictAlert {
  final String id;
  final AlertSeverity severity;

  ConflictAlert({required this.id, required this.severity});
}

class SyncHistoryEntry {
  final String type;
  final String status;

  SyncHistoryEntry({required this.type, required this.status});
}
