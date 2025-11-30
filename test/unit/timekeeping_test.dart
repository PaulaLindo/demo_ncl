// test/unit/timekeeping_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:demo_ncl/models/time_record_model.dart';

void main() {
  group('TimeRecord Model Tests', () {
    test('should create TimeRecord with required fields', () {
      // Arrange
      final timeRecord = TimeRecord(
        id: '1',
        staffId: 'staff123',
        jobId: 'job123',
        checkInTime: DateTime(2023, 12, 25, 9, 0),
        startTime: DateTime(2023, 12, 25, 9, 0),
        type: TimeRecordType.self,
        status: TimeRecordStatus.inProgress,
      );

      // Assert
      expect(timeRecord.id, equals('1'));
      expect(timeRecord.staffId, equals('staff123'));
      expect(timeRecord.jobId, equals('job123'));
      expect(timeRecord.type, equals(TimeRecordType.self));
      expect(timeRecord.status, equals(TimeRecordStatus.inProgress));
      expect(timeRecord.isBreak, isFalse);
    });

    test('should create TimeRecord with all fields', () {
      // Arrange
      final timeRecord = TimeRecord(
        id: '2',
        staffId: 'staff456',
        jobId: 'job456',
        jobName: 'Standard Cleaning',
        proxyStaffId: 'proxy123',
        checkInTime: DateTime(2023, 12, 26, 8, 30),
        checkOutTime: DateTime(2023, 12, 26, 16, 30),
        startTime: DateTime(2023, 12, 26, 8, 30),
        endTime: DateTime(2023, 12, 26, 16, 30),
        type: TimeRecordType.proxy,
        status: TimeRecordStatus.completed,
        isBreak: false,
        notes: 'Completed job successfully',
        checkInLocation: 'Client Location',
        checkOutLocation: 'Client Location',
        proxyCardId: 'card123',
      );

      // Assert
      expect(timeRecord.id, equals('2'));
      expect(timeRecord.jobName, equals('Standard Cleaning'));
      expect(timeRecord.proxyStaffId, equals('proxy123'));
      expect(timeRecord.checkOutTime, isNotNull);
      expect(timeRecord.endTime, isNotNull);
      expect(timeRecord.type, equals(TimeRecordType.proxy));
      expect(timeRecord.status, equals(TimeRecordStatus.completed));
      expect(timeRecord.notes, equals('Completed job successfully'));
      expect(timeRecord.checkInLocation, equals('Client Location'));
    });

    test('should handle break records correctly', () {
      // Arrange
      final breakRecord = TimeRecord(
        id: '3',
        staffId: 'staff789',
        jobId: 'break123',
        checkInTime: DateTime(2023, 12, 27, 12, 0),
        startTime: DateTime(2023, 12, 27, 12, 0),
        type: TimeRecordType.self,
        status: TimeRecordStatus.inProgress,
        isBreak: true,
        notes: 'Lunch break',
      );

      // Assert
      expect(breakRecord.isBreak, isTrue);
      expect(breakRecord.notes, equals('Lunch break'));
      expect(breakRecord.jobId, equals('break123'));
    });
  });

  group('TimeRecordType Enum Tests', () {
    test('should have correct values', () {
      expect(TimeRecordType.values, containsAll([
        TimeRecordType.self,
        TimeRecordType.proxy,
        TimeRecordType.manual,
      ]));
    });

    test('should support all time record types', () {
      for (final type in TimeRecordType.values) {
        expect(type, isA<TimeRecordType>());
      }
    });

    test('should convert type to string correctly', () {
      expect(TimeRecordType.self.toString(), contains('self'));
      expect(TimeRecordType.proxy.toString(), contains('proxy'));
      expect(TimeRecordType.manual.toString(), contains('manual'));
    });
  });

  group('TimeRecordStatus Enum Tests', () {
    test('should have correct values', () {
      expect(TimeRecordStatus.values, containsAll([
        TimeRecordStatus.inProgress,
        TimeRecordStatus.completed,
        TimeRecordStatus.cancelled,
        TimeRecordStatus.rejected,
        TimeRecordStatus.pendingApproval,
      ]));
    });

    test('should support all status types', () {
      for (final status in TimeRecordStatus.values) {
        expect(status, isA<TimeRecordStatus>());
      }
    });

    test('should convert status to string correctly', () {
      expect(TimeRecordStatus.inProgress.toString(), contains('inProgress'));
      expect(TimeRecordStatus.completed.toString(), contains('completed'));
      expect(TimeRecordStatus.cancelled.toString(), contains('cancelled'));
      expect(TimeRecordStatus.rejected.toString(), contains('rejected'));
      expect(TimeRecordStatus.pendingApproval.toString(), contains('pendingApproval'));
    });
  });

  group('TimeRecord Date and Time Tests', () {
    test('should handle different date formats', () {
      final dates = [
        DateTime(2023, 12, 25),
        DateTime(2024, 1, 1),
        DateTime(2023, 2, 28), // Leap year handling
      ];

      for (final date in dates) {
        final timeRecord = TimeRecord(
          id: date.millisecondsSinceEpoch.toString(),
          staffId: 'staff123',
          jobId: 'job123',
          checkInTime: date,
          startTime: date,
          type: TimeRecordType.self,
          status: TimeRecordStatus.inProgress,
        );

        expect(timeRecord.checkInTime, equals(date));
        expect(timeRecord.startTime, equals(date));
      }
    });

    test('should handle time zones correctly', () {
      final utcDate = DateTime.utc(2023, 12, 25);
      final localDate = DateTime(2023, 12, 25);

      final utcRecord = TimeRecord(
        id: 'utc',
        staffId: 'staff123',
        jobId: 'job123',
        checkInTime: utcDate,
        startTime: utcDate,
        type: TimeRecordType.self,
        status: TimeRecordStatus.inProgress,
      );

      final localRecord = TimeRecord(
        id: 'local',
        staffId: 'staff123',
        jobId: 'job123',
        checkInTime: localDate,
        startTime: localDate,
        type: TimeRecordType.self,
        status: TimeRecordStatus.inProgress,
      );

      expect(utcRecord.checkInTime.isUtc, isTrue);
      expect(localRecord.checkInTime.isUtc, isFalse);
    });

    test('should calculate duration correctly', () {
      final checkInTime = DateTime(2023, 12, 25, 9, 0);
      final checkOutTime = DateTime(2023, 12, 25, 17, 30); // 8.5 hours later

      final timeRecord = TimeRecord(
        id: 'duration_test',
        staffId: 'staff123',
        jobId: 'job123',
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        startTime: checkInTime,
        endTime: checkOutTime,
        type: TimeRecordType.self,
        status: TimeRecordStatus.completed,
      );

      final duration = timeRecord.endTime!.difference(timeRecord.startTime);
      expect(duration.inHours, equals(8));
      expect(duration.inMinutes % 60, equals(30));
    });
  });

  group('TimeRecord Status Transitions Tests', () {
    test('should support valid status transitions', () {
      final timeRecord = TimeRecord(
        id: '1',
        staffId: 'staff123',
        jobId: 'job123',
        checkInTime: DateTime(2023, 12, 25, 9, 0),
        startTime: DateTime(2023, 12, 25, 9, 0),
        type: TimeRecordType.self,
        status: TimeRecordStatus.inProgress,
      );

      // Initial state
      expect(timeRecord.status, equals(TimeRecordStatus.inProgress));
      expect(timeRecord.checkOutTime, isNull);
      expect(timeRecord.endTime, isNull);

      // Simulate clock out
      final completedRecord = TimeRecord(
        id: '1',
        staffId: 'staff123',
        jobId: 'job123',
        checkInTime: DateTime(2023, 12, 25, 9, 0),
        checkOutTime: DateTime(2023, 12, 25, 17, 0),
        startTime: DateTime(2023, 12, 25, 9, 0),
        endTime: DateTime(2023, 12, 25, 17, 0),
        type: TimeRecordType.self,
        status: TimeRecordStatus.completed,
      );

      expect(completedRecord.status, equals(TimeRecordStatus.completed));
      expect(completedRecord.checkOutTime, isNotNull);
      expect(completedRecord.endTime, isNotNull);
    });
  });

  group('TimeRecord Special Cases Tests', () {
    test('should handle proxy records', () {
      final proxyRecord = TimeRecord(
        id: 'proxy_test',
        staffId: 'staff123',
        jobId: 'job123',
        proxyStaffId: 'proxy456',
        checkInTime: DateTime(2023, 12, 25, 9, 0),
        startTime: DateTime(2023, 12, 25, 9, 0),
        type: TimeRecordType.proxy,
        status: TimeRecordStatus.inProgress,
        proxyCardId: 'card789',
      );

      expect(proxyRecord.type, equals(TimeRecordType.proxy));
      expect(proxyRecord.proxyStaffId, equals('proxy456'));
      expect(proxyRecord.proxyCardId, equals('card789'));
    });

    test('should handle manual records', () {
      final manualRecord = TimeRecord(
        id: 'manual_test',
        staffId: 'staff123',
        jobId: 'job123',
        checkInTime: DateTime(2023, 12, 25, 9, 0),
        checkOutTime: DateTime(2023, 12, 25, 17, 0),
        startTime: DateTime(2023, 12, 25, 9, 0),
        endTime: DateTime(2023, 12, 25, 17, 0),
        type: TimeRecordType.manual,
        status: TimeRecordStatus.pendingApproval,
        notes: 'Manual entry approved by supervisor',
      );

      expect(manualRecord.type, equals(TimeRecordType.manual));
      expect(manualRecord.status, equals(TimeRecordStatus.pendingApproval));
      expect(manualRecord.notes, equals('Manual entry approved by supervisor'));
    });

    test('should handle rejected records', () {
      final rejectedRecord = TimeRecord(
        id: 'rejected_test',
        staffId: 'staff123',
        jobId: 'job123',
        checkInTime: DateTime(2023, 12, 25, 9, 0),
        startTime: DateTime(2023, 12, 25, 9, 0),
        type: TimeRecordType.manual,
        status: TimeRecordStatus.rejected,
        notes: 'Rejected: Invalid time entry',
      );

      expect(rejectedRecord.status, equals(TimeRecordStatus.rejected));
      expect(rejectedRecord.notes, equals('Rejected: Invalid time entry'));
    });
  });

  group('TimeRecord Location Tests', () {
    test('should handle location data', () {
      final recordWithLocation = TimeRecord(
        id: 'location_test',
        staffId: 'staff123',
        jobId: 'job123',
        checkInTime: DateTime(2023, 12, 25, 9, 0),
        startTime: DateTime(2023, 12, 25, 9, 0),
        type: TimeRecordType.self,
        status: TimeRecordStatus.inProgress,
        checkInLocation: '40.7128,-74.0060', // NYC coordinates
        checkOutLocation: '40.7589,-73.9851', // Times Square coordinates
      );

      expect(recordWithLocation.checkInLocation, equals('40.7128,-74.0060'));
      expect(recordWithLocation.checkOutLocation, equals('40.7589,-73.9851'));
    });

    test('should handle records without location data', () {
      final recordWithoutLocation = TimeRecord(
        id: 'no_location_test',
        staffId: 'staff123',
        jobId: 'job123',
        checkInTime: DateTime(2023, 12, 25, 9, 0),
        startTime: DateTime(2023, 12, 25, 9, 0),
        type: TimeRecordType.self,
        status: TimeRecordStatus.inProgress,
      );

      expect(recordWithoutLocation.checkInLocation, isNull);
      expect(recordWithoutLocation.checkOutLocation, isNull);
    });
  });

  group('TimeRecord Notes Tests', () {
    test('should handle null notes', () {
      final recordWithoutNotes = TimeRecord(
        id: 'no_notes_test',
        staffId: 'staff123',
        jobId: 'job123',
        checkInTime: DateTime(2023, 12, 25, 9, 0),
        startTime: DateTime(2023, 12, 25, 9, 0),
        type: TimeRecordType.self,
        status: TimeRecordStatus.inProgress,
      );

      expect(recordWithoutNotes.notes, isNull);
    });

    test('should handle empty notes', () {
      final recordWithEmptyNotes = TimeRecord(
        id: 'empty_notes_test',
        staffId: 'staff123',
        jobId: 'job123',
        checkInTime: DateTime(2023, 12, 25, 9, 0),
        startTime: DateTime(2023, 12, 25, 9, 0),
        type: TimeRecordType.self,
        status: TimeRecordStatus.inProgress,
        notes: '',
      );

      expect(recordWithEmptyNotes.notes, equals(''));
    });

    test('should handle long notes', () {
      final longNotes = 'This is a very long note that contains multiple words and should be handled properly by the time record model without any issues. It includes details about the job, special circumstances, and any relevant information that might be important for future reference.';
      
      final recordWithLongNotes = TimeRecord(
        id: 'long_notes_test',
        staffId: 'staff123',
        jobId: 'job123',
        checkInTime: DateTime(2023, 12, 25, 9, 0),
        startTime: DateTime(2023, 12, 25, 9, 0),
        type: TimeRecordType.self,
        status: TimeRecordStatus.inProgress,
        notes: longNotes,
      );

      expect(recordWithLongNotes.notes, equals(longNotes));
      expect(recordWithLongNotes.notes!.length, greaterThan(100));
    });
  });
}
