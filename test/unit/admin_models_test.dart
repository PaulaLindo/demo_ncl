// test/unit/admin_models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/models/temp_card_model.dart';
import 'package:demo_ncl/models/quality_flag_model.dart';
import 'package:demo_ncl/models/b2b_lead_model.dart';
import 'package:demo_ncl/models/payroll_model.dart';
import 'package:demo_ncl/models/logistics_model.dart';
import 'package:demo_ncl/models/audit_log_model.dart';

void main() {
  group('Admin Models Tests', () {
    group('TempCard Model', () {
      test('should create temp card with valid data', () {
        // Arrange
        const staffId = 'staff123';
        const staffName = 'John Doe';
        const cardNumber = '123456';
        final issueDate = DateTime.now();
        final expiryDate = issueDate.add(const Duration(hours: 24));

        // Act
        final tempCard = TempCard(
          id: 'temp123',
          userId: staffId,
          userName: staffName,
          cardNumber: cardNumber,
          issueDate: issueDate,
          expiryDate: expiryDate,
        );

        // Assert
        expect(tempCard.userId, equals(staffId));
        expect(tempCard.userName, equals(staffName));
        expect(tempCard.cardNumber, equals(cardNumber));
        expect(tempCard.isActive, isTrue);
        expect(tempCard.isValid, isTrue);
      });

      test('should handle temp card status correctly', () {
        // Arrange
        final now = DateTime.now();
        final expiredCard = TempCard(
          id: 'temp123',
          userId: 'staff123',
          userName: 'John Doe',
          cardNumber: '123456',
          issueDate: now.subtract(const Duration(days: 2)),
          expiryDate: now.subtract(const Duration(days: 1)),
        );

        final activeCard = TempCard(
          id: 'temp456',
          userId: 'staff456',
          userName: 'Jane Doe',
          cardNumber: '456789',
          issueDate: now,
          expiryDate: now.add(const Duration(hours: 24)),
        );

        final deactivatedCard = TempCard(
          id: 'temp789',
          userId: 'staff789',
          userName: 'Bob Smith',
          cardNumber: '789012',
          issueDate: now,
          expiryDate: now.add(const Duration(hours: 24)),
          isActive: false,
          deactivationDate: now,
          deactivationReason: 'Lost card',
        );

        // Assert
        expect(expiredCard.isExpired, isTrue);
        expect(expiredCard.isValid, isFalse);
        expect(expiredCard.status, equals('Expired'));

        expect(activeCard.isExpired, isFalse);
        expect(activeCard.isValid, isTrue);
        expect(activeCard.status, equals('Active'));

        expect(deactivatedCard.isActive, isFalse);
        expect(deactivatedCard.isValid, isFalse);
        expect(deactivatedCard.status, equals('Deactivated'));
      });

      test('should support copyWith functionality', () {
        // Arrange
        final originalCard = TempCard(
          id: 'temp123',
          userId: 'staff123',
          userName: 'John Doe',
          cardNumber: '123456',
          issueDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(hours: 24)),
        );

        // Act
        final updatedCard = originalCard.copyWith(
          isActive: false,
          deactivationReason: 'Card lost',
        );

        // Assert
        expect(originalCard.isActive, isTrue);
        expect(updatedCard.isActive, isFalse);
        expect(updatedCard.deactivationReason, equals('Card lost'));
        expect(updatedCard.userId, equals(originalCard.userId));
      });

      test('should format dates correctly', () {
        // Arrange
        final issueDate = DateTime(2023, 1, 15);
        final expiryDate = DateTime(2023, 2, 15);

        final tempCard = TempCard(
          id: 'temp123',
          userId: 'staff123',
          userName: 'John Doe',
          cardNumber: '123456',
          issueDate: issueDate,
          expiryDate: expiryDate,
        );

        // Assert
        expect(tempCard.formattedIssueDate, equals('Jan 15, 2023'));
        expect(tempCard.formattedExpiryDate, equals('Feb 15, 2023'));
      });
    });

    group('QualityFlag Model', () {
      test('should create quality flag with valid data', () {
        // Arrange
        const jobId = 'job123';
        const jobName = 'Office Cleaning';
        const staffId = 'staff123';
        const staffName = 'John Doe';
        const issueType = 'Cleaning Quality';
        const description = 'Areas not properly cleaned';
        const severity = 3;

        // Act
        final qualityFlag = QualityFlag(
          id: 'flag123',
          jobId: jobId,
          jobName: jobName,
          staffId: staffId,
          staffName: staffName,
          issueType: issueType,
          description: description,
          severity: severity,
          createdAt: DateTime.now(),
          status: QualityFlagStatus.pending,
        );

        // Assert
        expect(qualityFlag.jobId, equals(jobId));
        expect(qualityFlag.staffId, equals(staffId));
        expect(qualityFlag.issueType, equals(issueType));
        expect(qualityFlag.status, equals(QualityFlagStatus.pending));
        expect(qualityFlag.severity, equals(severity));
      });

      test('should handle quality flag status transitions', () {
        // Arrange
        final flag = QualityFlag(
          id: 'flag123',
          jobId: 'job123',
          jobName: 'Office Cleaning',
          staffId: 'staff123',
          staffName: 'John Doe',
          issueType: 'Cleaning Quality',
          description: 'Areas not properly cleaned',
          severity: 3,
          createdAt: DateTime.now(),
          status: QualityFlagStatus.pending,
        );

        // Act
        final resolvedFlag = flag.copyWith(
          status: QualityFlagStatus.resolved,
          resolution: 'Issue addressed',
          resolvedBy: 'Admin',
          resolvedAt: DateTime.now(),
        );

        // Assert
        expect(flag.status, equals(QualityFlagStatus.pending));
        expect(resolvedFlag.status, equals(QualityFlagStatus.resolved));
        expect(resolvedFlag.resolution, equals('Issue addressed'));
        expect(resolvedFlag.resolvedBy, equals('Admin'));
      });

      test('should validate severity range', () {
        // Test valid severities
        for (int i = 1; i <= 5; i++) {
          final flag = QualityFlag(
            id: 'flag$i',
            jobId: 'job123',
            jobName: 'Office Cleaning',
            staffId: 'staff123',
            staffName: 'John Doe',
            issueType: 'Test Issue',
            description: 'Test description',
            severity: i,
            createdAt: DateTime.now(),
            status: QualityFlagStatus.pending,
          );
          expect(flag.severity, equals(i));
        }
      });
    });

    group('B2B Lead Model', () {
      test('should create B2B lead with valid data', () {
        // Arrange
        const companyName = 'ABC Corp';
        const contactName = 'Jane Smith';
        const email = 'jane@abc.com';
        const phone = '555-0123';
        const serviceInterest = 'Regular Cleaning';

        // Act
        final lead = B2BLead(
          id: 'lead123',
          companyName: companyName,
          contactName: contactName,
          email: email,
          phone: phone,
          serviceInterest: serviceInterest,
          createdAt: DateTime.now(),
          status: LeadStatus.newLead,
        );

        // Assert
        expect(lead.companyName, equals(companyName));
        expect(lead.contactName, equals(contactName));
        expect(lead.email, equals(email));
        expect(lead.status, equals(LeadStatus.newLead));
      });

      test('should handle B2B lead status transitions', () {
        // Arrange
        final lead = B2BLead(
          id: 'lead123',
          companyName: 'ABC Corp',
          contactName: 'Jane Smith',
          email: 'jane@abc.com',
          phone: '555-0123',
          serviceInterest: 'Regular Cleaning',
          createdAt: DateTime.now(),
          status: LeadStatus.newLead,
        );

        // Act
        final contactedLead = lead.copyWith(
          status: LeadStatus.contacted,
          statusUpdatedAt: DateTime.now(),
        );

        // Assert
        expect(lead.status, equals(LeadStatus.newLead));
        expect(contactedLead.status, equals(LeadStatus.contacted));
        expect(contactedLead.status.displayName, equals('Contacted'));
      });

      test('should provide correct display names for all statuses', () {
        final testCases = {
          LeadStatus.newLead: 'New',
          LeadStatus.contacted: 'Contacted',
          LeadStatus.qualified: 'Qualified',
          LeadStatus.proposal: 'Proposal',
          LeadStatus.negotiation: 'Negotiation',
          LeadStatus.won: 'Won',
          LeadStatus.lost: 'Lost',
        };

        testCases.forEach((status, displayName) {
          expect(status.displayName, equals(displayName));
        });
      });
    });

    group('LogisticsEvent Model', () {
      test('should create logistics event with valid data', () {
        // Arrange
        const staffId = 'staff123';
        const jobId = 'job123';
        const eventType = LogisticsEventTypes.staffCheckedIn;
        const description = 'Staff checked in for job';

        // Act
        final event = LogisticsEvent(
          id: 'log123',
          staffId: staffId,
          jobId: jobId,
          eventType: eventType,
          description: description,
          metadata: {},
          timestamp: DateTime.now(),
        );

        // Assert
        expect(event.staffId, equals(staffId));
        expect(event.jobId, equals(jobId));
        expect(event.eventType, equals(eventType));
        expect(event.description, equals(description));
      });

      test('should handle metadata correctly', () {
        // Arrange
        final metadata = {
          'location': 'Office Building A',
          'temperature': 72.5,
          'equipment': ['vacuum', 'mop'],
          'verified': true,
        };

        // Act
        final event = LogisticsEvent(
          id: 'log123',
          staffId: 'staff123',
          jobId: 'job123',
          eventType: LogisticsEventTypes.locationVerified,
          description: 'Location verified',
          metadata: metadata,
          timestamp: DateTime.now(),
        );

        // Assert
        expect(event.metadata.length, equals(4));
        expect(event.metadata['location'], equals('Office Building A'));
        expect(event.metadata['temperature'], equals(72.5));
        expect(event.metadata['equipment'], equals(['vacuum', 'mop']));
        expect(event.metadata['verified'], isTrue);
      });
    });

    group('PayrollReport Model', () {
      test('should create payroll report with valid data', () {
        // Arrange
        final startDate = DateTime.now().subtract(const Duration(days: 30));
        final endDate = DateTime.now();

        // Act
        final report = PayrollReport(
          id: 'payroll123',
          startDate: startDate,
          endDate: endDate,
          status: PayrollStatus.draft,
          timeRecordIds: ['record1', 'record2'],
          totalAmount: 1500.0,
          createdAt: DateTime.now(),
        );

        // Assert
        expect(report.status, equals(PayrollStatus.draft));
        expect(report.timeRecordIds.length, equals(2));
        expect(report.totalAmount, equals(1500.0));
      });

      test('should handle payroll status transitions', () {
        // Arrange
        final draftReport = PayrollReport(
          id: 'payroll123',
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
          status: PayrollStatus.draft,
          timeRecordIds: ['record1'],
          totalAmount: 750.0,
          createdAt: DateTime.now(),
        );

        // Act
        final finalizedReport = draftReport.copyWith(
          status: PayrollStatus.finalized,
          finalizedAt: DateTime.now(),
        );

        final paidReport = finalizedReport.copyWith(
          status: PayrollStatus.paid,
          paidAt: DateTime.now().add(const Duration(days: 7)),
        );

        // Assert
        expect(draftReport.status, equals(PayrollStatus.draft));
        expect(draftReport.status.displayName, equals('Draft'));
        
        expect(finalizedReport.status, equals(PayrollStatus.finalized));
        expect(finalizedReport.status.displayName, equals('Finalized'));
        expect(finalizedReport.finalizedAt, isNotNull);
        
        expect(paidReport.status, equals(PayrollStatus.paid));
        expect(paidReport.status.displayName, equals('Paid'));
        expect(paidReport.paidAt, isNotNull);
      });

      test('should provide correct display names for all statuses', () {
        final testCases = {
          PayrollStatus.draft: 'Draft',
          PayrollStatus.review: 'Under Review',
          PayrollStatus.approved: 'Approved',
          PayrollStatus.finalized: 'Finalized',
          PayrollStatus.paid: 'Paid',
        };

        testCases.forEach((status, displayName) {
          expect(status.displayName, equals(displayName));
        });
      });
    });

    group('AuditLog Model', () {
      test('should create audit log with valid data', () {
        // Arrange
        const action = 'TEMP_CARD_ISSUED';
        const targetId = 'staff123';
        const targetName = 'John Doe';
        final details = {'cardNumber': '123456', 'issuedBy': 'Admin'};
        final timestamp = DateTime.now();
        const userId = 'admin';

        // Act
        final auditLog = AuditLog(
          id: 'audit123',
          action: action,
          targetId: targetId,
          targetName: targetName,
          details: details,
          timestamp: timestamp,
          userId: userId,
        );

        // Assert
        expect(auditLog.action, equals(action));
        expect(auditLog.targetId, equals(targetId));
        expect(auditLog.targetName, equals(targetName));
        expect(auditLog.details, equals(details));
        expect(auditLog.userId, equals(userId));
      });

      test('should handle complex audit details', () {
        // Arrange
        final complexDetails = {
          'action': 'PROXY_HOURS_APPROVED',
          'staffId': 'staff123',
          'jobId': 'job456',
          'hours': 8.5,
          'rate': 25.0,
          'totalAmount': 212.5,
          'approvedBy': 'Manager',
          'approvalTimestamp': DateTime.now().toIso8601String(),
          'notes': 'Quality work completed on time',
        };

        // Act
        final auditLog = AuditLog(
          id: 'audit456',
          action: 'PROXY_HOURS_APPROVED',
          details: complexDetails,
          timestamp: DateTime.now(),
          userId: 'manager',
        );

        // Assert
        expect(auditLog.details.length, equals(9));
        expect(auditLog.details['hours'], equals(8.5));
        expect(auditLog.details['totalAmount'], equals(212.5));
        expect(auditLog.details['approvedBy'], equals('Manager'));
      });
    });

    group('Model Equatable Tests', () {
      test('TempCard should be equatable', () {
        final now = DateTime.now();
        final card1 = TempCard(
          id: 'temp123',
          userId: 'staff123',
          userName: 'John Doe',
          cardNumber: '123456',
          issueDate: now,
          expiryDate: now.add(const Duration(hours: 24)),
        );

        final card2 = TempCard(
          id: 'temp123',
          userId: 'staff123',
          userName: 'John Doe',
          cardNumber: '123456',
          issueDate: now,
          expiryDate: now.add(const Duration(hours: 24)),
        );

        final card3 = TempCard(
          id: 'temp456',
          userId: 'staff456',
          userName: 'Jane Doe',
          cardNumber: '456789',
          issueDate: now,
          expiryDate: now.add(const Duration(hours: 24)),
        );

        expect(card1, equals(card2));
        expect(card1, isNot(equals(card3)));
      });

      test('QualityFlag should be equatable', () {
        final flag1 = QualityFlag(
          id: 'flag123',
          jobId: 'job123',
          jobName: 'Office Cleaning',
          staffId: 'staff123',
          staffName: 'John Doe',
          issueType: 'Cleaning Quality',
          description: 'Areas not properly cleaned',
          severity: 3,
          createdAt: DateTime.now(),
          status: QualityFlagStatus.pending,
        );

        final flag2 = QualityFlag(
          id: 'flag123',
          jobId: 'job123',
          jobName: 'Office Cleaning',
          staffId: 'staff123',
          staffName: 'John Doe',
          issueType: 'Cleaning Quality',
          description: 'Areas not properly cleaned',
          severity: 3,
          createdAt: DateTime.now(),
          status: QualityFlagStatus.pending,
        );

        final flag3 = QualityFlag(
          id: 'flag456',
          jobId: 'job456',
          jobName: 'Deep Cleaning',
          staffId: 'staff456',
          staffName: 'Jane Doe',
          issueType: 'Customer Complaint',
          description: 'Customer reported issues',
          severity: 4,
          createdAt: DateTime.now(),
          status: QualityFlagStatus.pending,
        );

        expect(flag1, equals(flag2));
        expect(flag1, isNot(equals(flag3)));
      });

      test('B2BLead should be equatable', () {
        final lead1 = B2BLead(
          id: 'lead123',
          companyName: 'ABC Corp',
          contactName: 'Jane Smith',
          email: 'jane@abc.com',
          phone: '555-0123',
          serviceInterest: 'Regular Cleaning',
          createdAt: DateTime.now(),
          status: LeadStatus.newLead,
        );

        final lead2 = B2BLead(
          id: 'lead123',
          companyName: 'ABC Corp',
          contactName: 'Jane Smith',
          email: 'jane@abc.com',
          phone: '555-0123',
          serviceInterest: 'Regular Cleaning',
          createdAt: DateTime.now(),
          status: LeadStatus.newLead,
        );

        final lead3 = B2BLead(
          id: 'lead456',
          companyName: 'XYZ Corp',
          contactName: 'Bob Johnson',
          email: 'bob@xyz.com',
          phone: '555-9876',
          serviceInterest: 'Deep Cleaning',
          createdAt: DateTime.now(),
          status: LeadStatus.contacted,
        );

        expect(lead1, equals(lead2));
        expect(lead1, isNot(equals(lead3)));
      });
    });
  });
}
