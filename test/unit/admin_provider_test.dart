// test/unit/admin_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:demo_ncl/providers/admin_provider.dart';
import 'package:demo_ncl/models/temp_card_model.dart';
import 'package:demo_ncl/models/quality_flag_model.dart';
import 'package:demo_ncl/models/b2b_lead_model.dart';
import 'package:demo_ncl/models/payroll_model.dart';
import 'package:demo_ncl/models/logistics_model.dart';

void main() {
  group('AdminProvider Tests', () {
    late AdminProvider adminProvider;

    setUp(() {
      adminProvider = AdminProvider();
    });

    test('should generate 6-digit temp card code', () {
      // Act
      final code = adminProvider.generateTempCardCode();

      // Assert
      expect(code, isNotNull);
      expect(code.length, equals(6));
      expect(int.tryParse(code), isNotNull);
      expect(int.parse(code), greaterThanOrEqualTo(100000));
      expect(int.parse(code), lessThanOrEqualTo(999999));
    });

    test('should generate unique codes', () {
      // Act
      final code1 = adminProvider.generateTempCardCode();
      final code2 = adminProvider.generateTempCardCode();

      // Assert
      expect(code1, isNot(equals(code2)));
    });

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

      // Assert
      expect(expiredCard.isExpired, isTrue);
      expect(expiredCard.isValid, isFalse);
      expect(expiredCard.status, equals('Expired'));

      expect(activeCard.isExpired, isFalse);
      expect(activeCard.isValid, isTrue);
      expect(activeCard.status, equals('Active'));
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

    group('Model Validation', () {
      test('temp card should have valid props', () {
        final tempCard = TempCard(
          id: 'temp123',
          userId: 'staff123',
          userName: 'John Doe',
          cardNumber: '123456',
          issueDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(hours: 24)),
        );

        expect(tempCard.props.length, equals(8));
        expect(tempCard.props, contains('temp123'));
        expect(tempCard.props, contains('staff123'));
      });

      test('quality flag should have valid props', () {
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

        expect(flag.props.length, equals(12));
        expect(flag.props, contains('flag123'));
        expect(flag.props, contains('job123'));
      });

      test('B2B lead should have valid props', () {
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

        expect(lead.props.length, equals(9));
        expect(lead.props, contains('lead123'));
        expect(lead.props, contains('ABC Corp'));
      });
    });
  });
}
