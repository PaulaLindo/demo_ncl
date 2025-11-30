// test/unit/admin_features_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:demo_ncl/providers/admin_provider.dart';
import 'package:demo_ncl/models/temp_card_model.dart';
import 'package:demo_ncl/models/time_record_model.dart';
import 'package:demo_ncl/models/quality_flag_model.dart';
import 'package:demo_ncl/models/b2b_lead_model.dart';
import 'package:demo_ncl/models/payroll_model.dart';
import 'package:demo_ncl/models/logistics_model.dart';
import 'package:demo_ncl/models/audit_log_model.dart';

import 'admin_features_test.mocks.dart';

@GenerateMocks([AdminProvider])
void main() {
  group('Admin Features Tests', () {
    late MockAdminProvider mockProvider;

    setUp(() {
      mockProvider = MockAdminProvider();
    });

    group('Temp Card Management', () {
      test('should generate 6-digit temp card code', () {
        // Act
        final code = mockProvider.generateTempCardCode();

        // Assert
        expect(code, isNotNull);
        expect(code.length, equals(6));
        expect(int.tryParse(code), isNotNull);
        expect(int.parse(code), greaterThanOrEqualTo(100000));
        expect(int.parse(code), lessThanOrEqualTo(999999));
      });

      test('should issue temp card successfully', () async {
        // Arrange
        const staffId = 'staff123';
        const staffName = 'John Doe';
        const notes = 'Temporary access';
        
        when(mockProvider.issueTempCard(
          staffId: staffId,
          staffName: staffName,
          notes: notes,
        )).thenAnswer((_) async => TempCard(
          id: 'temp123',
          userId: staffId,
          userName: staffName,
          cardNumber: '123456',
          issueDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(hours: 24)),
          notes: notes,
        ));

        // Act
        final tempCard = await mockProvider.issueTempCard(
          staffId: staffId,
          staffName: staffName,
          notes: notes,
        );

        // Assert
        expect(tempCard, isNotNull);
        expect(tempCard.userId, equals(staffId));
        expect(tempCard.userName, equals(staffName));
        expect(tempCard.cardNumber, equals('123456'));
        expect(tempCard.isActive, isTrue);
        verify(mockProvider.issueTempCard(
          staffId: staffId,
          staffName: staffName,
          notes: notes,
        )).called(1);
      });

      test('should validate temp card code', () async {
        // Arrange
        const validCode = '123456';
        final validTempCard = TempCard(
          id: 'temp123',
          userId: 'staff123',
          userName: 'John Doe',
          cardNumber: validCode,
          issueDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(hours: 24)),
        );

        when(mockProvider.validateTempCard(validCode))
            .thenAnswer((_) async => validTempCard);

        // Act
        final result = await mockProvider.validateTempCard(validCode);

        // Assert
        expect(result, isNotNull);
        expect(result!.cardNumber, equals(validCode));
        expect(result.isActive, isTrue);
        verify(mockProvider.validateTempCard(validCode)).called(1);
      });
    });

    group('Proxy Time Management', () {
      test('should create proxy time record', () async {
        // Arrange
        const staffId = 'staff123';
        const staffName = 'John Doe';
        const jobId = 'job123';
        const jobName = 'Office Cleaning';
        final checkInTime = DateTime.now().subtract(const Duration(hours: 2));
        final checkOutTime = DateTime.now();

        final proxyRecord = TimeRecord(
          id: 'proxy123',
          staffId: staffId,
          jobId: jobId,
          jobName: jobName,
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
          startTime: checkInTime,
          endTime: checkOutTime,
          type: TimeRecordType.proxy,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockProvider.createProxyTimeRecord(
          staffId: staffId,
          staffName: staffName,
          jobId: jobId,
          jobName: jobName,
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
        )).thenAnswer((_) async => proxyRecord);

        // Act
        final result = await mockProvider.createProxyTimeRecord(
          staffId: staffId,
          staffName: staffName,
          jobId: jobId,
          jobName: jobName,
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
        );

        // Assert
        expect(result, isNotNull);
        expect(result.staffId, equals(staffId));
        expect(result.type, equals(TimeRecordType.proxy));
        verify(mockProvider.createProxyTimeRecord(
          staffId: staffId,
          staffName: staffName,
          jobId: jobId,
          jobName: jobName,
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
        )).called(1);
      });

      test('should check if hours are in payroll', () async {
        // Arrange
        const recordId = 'record123';
        when(mockProvider.areHoursInPayroll(recordId))
            .thenAnswer((_) async => true);

        // Act
        final result = await mockProvider.areHoursInPayroll(recordId);

        // Assert
        expect(result, isTrue);
        verify(mockProvider.areHoursInPayroll(recordId)).called(1);
      });

      test('should approve proxy hours', () async {
        // Arrange
        const recordId = 'record123';
        const approved = true;
        const adminNotes = 'Hours verified';

        when(mockProvider.approveProxyHours(
          recordId: recordId,
          approved: approved,
          adminNotes: adminNotes,
        )).thenAnswer((_) async {});

        // Act
        await mockProvider.approveProxyHours(
          recordId: recordId,
          approved: approved,
          adminNotes: adminNotes,
        );

        // Assert
        verify(mockProvider.approveProxyHours(
          recordId: recordId,
          approved: approved,
          adminNotes: adminNotes,
        )).called(1);
      });
    });

    group('Staff Interface Blocking', () {
      test('should block staff interface', () async {
        // Arrange
        const staffId = 'staff123';
        const reason = 'Pending approval';

        when(mockProvider.blockStaffInterface(staffId, reason))
            .thenAnswer((_) async {});

        // Act
        await mockProvider.blockStaffInterface(staffId, reason);

        // Assert
        verify(mockProvider.blockStaffInterface(staffId, reason)).called(1);
      });

      test('should unblock staff interface', () async {
        // Arrange
        const staffId = 'staff123';

        when(mockProvider.unblockStaffInterface(staffId))
            .thenAnswer((_) async {});

        // Act
        await mockProvider.unblockStaffInterface(staffId);

        // Assert
        verify(mockProvider.unblockStaffInterface(staffId)).called(1);
      });

      test('should check if staff is blocked', () async {
        // Arrange
        const staffId = 'staff123';
        when(mockProvider.isStaffBlocked(staffId))
            .thenAnswer((_) async => true);

        // Act
        final result = await mockProvider.isStaffBlocked(staffId);

        // Assert
        expect(result, isTrue);
        verify(mockProvider.isStaffBlocked(staffId)).called(1);
      });
    });

    group('Quality Audit Flagging', () {
      test('should flag quality issue', () async {
        // Arrange
        const jobId = 'job123';
        const jobName = 'Office Cleaning';
        const staffId = 'staff123';
        const staffName = 'John Doe';
        const issueType = 'Cleaning Quality';
        const description = 'Areas not properly cleaned';
        const severity = 3;

        when(mockProvider.flagQualityIssue(
          jobId: jobId,
          jobName: jobName,
          staffId: staffId,
          staffName: staffName,
          issueType: issueType,
          description: description,
          severity: severity,
        )).thenAnswer((_) async {});

        // Act
        await mockProvider.flagQualityIssue(
          jobId: jobId,
          jobName: jobName,
          staffId: staffId,
          staffName: staffName,
          issueType: issueType,
          description: description,
          severity: severity,
        );

        // Assert
        verify(mockProvider.flagQualityIssue(
          jobId: jobId,
          jobName: jobName,
          staffId: staffId,
          staffName: staffName,
          issueType: issueType,
          description: description,
          severity: severity,
        )).called(1);
      });

      test('should resolve quality flag', () async {
        // Arrange
        const flagId = 'flag123';
        const resolution = 'Issue addressed';
        const resolvedBy = 'Admin';

        when(mockProvider.resolveQualityFlag(
          flagId: flagId,
          resolution: resolution,
          resolvedBy: resolvedBy,
        )).thenAnswer((_) async {});

        // Act
        await mockProvider.resolveQualityFlag(
          flagId: flagId,
          resolution: resolution,
          resolvedBy: resolvedBy,
        );

        // Assert
        verify(mockProvider.resolveQualityFlag(
          flagId: flagId,
          resolution: resolution,
          resolvedBy: resolvedBy,
        )).called(1);
      });
    });

    group('B2B Lead Management', () {
      test('should add B2B lead', () async {
        // Arrange
        const companyName = 'ABC Corp';
        const contactName = 'Jane Smith';
        const email = 'jane@abc.com';
        const phone = '555-0123';
        const serviceInterest = 'Regular Cleaning';

        when(mockProvider.addB2BLead(
          companyName: companyName,
          contactName: contactName,
          email: email,
          phone: phone,
          serviceInterest: serviceInterest,
        )).thenAnswer((_) async {});

        // Act
        await mockProvider.addB2BLead(
          companyName: companyName,
          contactName: contactName,
          email: email,
          phone: phone,
          serviceInterest: serviceInterest,
        );

        // Assert
        verify(mockProvider.addB2BLead(
          companyName: companyName,
          contactName: contactName,
          email: email,
          phone: phone,
          serviceInterest: serviceInterest,
        )).called(1);
      });

      test('should update lead status', () async {
        // Arrange
        const leadId = 'lead123';
        const newStatus = LeadStatus.newLead;
        const notes = 'Initial contact made';

        when(mockProvider.updateLeadStatus(
          leadId: leadId,
          status: newStatus,
          notes: notes,
        )).thenAnswer((_) async {});

        // Act
        await mockProvider.updateLeadStatus(
          leadId: leadId,
          status: newStatus,
          notes: notes,
        );

        // Assert
        verify(mockProvider.updateLeadStatus(
          leadId: leadId,
          status: newStatus,
          notes: notes,
        )).called(1);
      });
    });

    group('Live Logistics Tracking', () {
      test('should log logistics event', () async {
        // Arrange
        const staffId = 'staff123';
        const jobId = 'job123';
        const eventType = LogisticsEventTypes.staffCheckedIn;
        const description = 'Staff checked in for job';

        when(mockProvider.logLogisticsEvent(
          staffId: staffId,
          jobId: jobId,
          eventType: eventType,
          description: description,
        )).thenAnswer((_) async {});

        // Act
        await mockProvider.logLogisticsEvent(
          staffId: staffId,
          jobId: jobId,
          eventType: eventType,
          description: description,
        );

        // Assert
        verify(mockProvider.logLogisticsEvent(
          staffId: staffId,
          jobId: jobId,
          eventType: eventType,
          description: description,
        )).called(1);
      });
    });

    group('Payroll Management', () {
      test('should generate draft payroll', () async {
        // Arrange
        final startDate = DateTime.now().subtract(const Duration(days: 30));
        final endDate = DateTime.now();

        final payrollReport = PayrollReport(
          id: 'payroll123',
          startDate: startDate,
          endDate: endDate,
          status: PayrollStatus.draft,
          timeRecordIds: ['record1', 'record2'],
          totalAmount: 1500.0,
          createdAt: DateTime.now(),
        );

        when(mockProvider.generateDraftPayroll(
          startDate: startDate,
          endDate: endDate,
        )).thenAnswer((_) async => payrollReport);

        // Act
        final result = await mockProvider.generateDraftPayroll(
          startDate: startDate,
          endDate: endDate,
        );

        // Assert
        expect(result, isNotNull);
        expect(result.status, equals(PayrollStatus.draft));
        expect(result.timeRecordIds.length, equals(2));
        verify(mockProvider.generateDraftPayroll(
          startDate: startDate,
          endDate: endDate,
        )).called(1);
      });

      test('should finalize payroll', () async {
        // Arrange
        const reportId = 'payroll123';

        when(mockProvider.finalizePayroll(reportId))
            .thenAnswer((_) async {});

        // Act
        await mockProvider.finalizePayroll(reportId);

        // Assert
        verify(mockProvider.finalizePayroll(reportId)).called(1);
      });
    });

    group('Audit Logging', () {
      test('should retrieve audit logs', () async {
        // Arrange
        const targetId = 'staff123';
        final logs = [
          AuditLog(
            id: 'audit1',
            action: 'TEMP_CARD_ISSUED',
            targetId: targetId,
            targetName: 'John Doe',
            details: {'cardNumber': '123456'},
            timestamp: DateTime.now(),
            userId: 'admin',
          ),
        ];

        when(mockProvider.getAuditLogs(targetId))
            .thenAnswer((_) => Stream.value(logs));

        // Act
        final stream = mockProvider.getAuditLogs(targetId);

        // Assert
        expect(stream, isNotNull);
        verify(mockProvider.getAuditLogs(targetId)).called(1);
      });
    });

    group('Integration Tests', () {
      test('should handle complete temp card workflow', () async {
        // Arrange
        const staffId = 'staff123';
        const staffName = 'John Doe';
        const cardCode = '123456';

        when(mockProvider.generateTempCardCode()).thenReturn(cardCode);

        final tempCard = TempCard(
          id: 'temp123',
          userId: staffId,
          userName: staffName,
          cardNumber: cardCode,
          issueDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(hours: 24)),
        );

        when(mockProvider.issueTempCard(
          staffId: staffId,
          staffName: staffName,
        )).thenAnswer((_) async => tempCard);

        when(mockProvider.validateTempCard(cardCode))
            .thenAnswer((_) async => tempCard);

        // Act
        final generatedCode = mockProvider.generateTempCardCode();
        final issuedCard = await mockProvider.issueTempCard(
          staffId: staffId,
          staffName: staffName,
        );
        final validatedCard = await mockProvider.validateTempCard(cardCode);

        // Assert
        expect(generatedCode, equals(cardCode));
        expect(issuedCard.cardNumber, equals(cardCode));
        expect(validatedCard?.cardNumber, equals(cardCode));
        verify(mockProvider.generateTempCardCode()).called(1);
        verify(mockProvider.issueTempCard(
          staffId: staffId,
          staffName: staffName,
        )).called(1);
        verify(mockProvider.validateTempCard(cardCode)).called(1);
      });

      test('should handle proxy time approval workflow', () async {
        // Arrange
        const recordId = 'record123';
        final checkInTime = DateTime.now().subtract(const Duration(hours: 2));
        final checkOutTime = DateTime.now();

        final proxyRecord = TimeRecord(
          id: recordId,
          staffId: 'staff123',
          jobId: 'job123',
          jobName: 'Office Cleaning',
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
          startTime: checkInTime,
          endTime: checkOutTime,
          type: TimeRecordType.proxy,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockProvider.createProxyTimeRecord(
          staffId: 'staff123',
          staffName: 'John Doe',
          jobId: 'job123',
          jobName: 'Office Cleaning',
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
        )).thenAnswer((_) async => proxyRecord);

        when(mockProvider.areHoursInPayroll(recordId))
            .thenAnswer((_) async => false);

        when(mockProvider.approveProxyHours(
          recordId: recordId,
          approved: true,
          adminNotes: 'Hours verified',
        )).thenAnswer((_) async {});

        // Act
        final createdRecord = await mockProvider.createProxyTimeRecord(
          staffId: 'staff123',
          staffName: 'John Doe',
          jobId: 'job123',
          jobName: 'Office Cleaning',
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
        );

        final inPayroll = await mockProvider.areHoursInPayroll(recordId);

        await mockProvider.approveProxyHours(
          recordId: recordId,
          approved: true,
          adminNotes: 'Hours verified',
        );

        // Assert
        expect(createdRecord.id, equals(recordId));
        expect(inPayroll, isFalse);
        verify(mockProvider.createProxyTimeRecord(
          staffId: 'staff123',
          staffName: 'John Doe',
          jobId: 'job123',
          jobName: 'Office Cleaning',
          checkInTime: checkInTime,
          checkOutTime: checkOutTime,
        )).called(1);
        verify(mockProvider.areHoursInPayroll(recordId)).called(1);
        verify(mockProvider.approveProxyHours(
          recordId: recordId,
          approved: true,
          adminNotes: 'Hours verified',
        )).called(1);
      });
    });
  });
}
