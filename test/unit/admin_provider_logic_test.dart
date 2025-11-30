// test/unit/admin_provider_logic_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Admin Provider Logic Tests', () {
    test('should generate 6-digit temp card code', () {
      // Act
      final code = _generateTempCardCode();

      // Assert
      expect(code, isNotNull);
      expect(code.length, equals(6));
      expect(int.tryParse(code), isNotNull);
      expect(int.parse(code), greaterThanOrEqualTo(100000));
      expect(int.parse(code), lessThanOrEqualTo(999999));
    });

    test('should generate unique codes', () async {
      // Act
      final code1 = _generateTempCardCode();
      
      // Add a small delay to ensure different timestamps
      await Future.delayed(const Duration(milliseconds: 1));
      
      final code2 = _generateTempCardCode();

      // Assert
      expect(code1, isNot(equals(code2)));
    });

    test('should validate temp card code format', () {
      // Arrange
      const validCode = '123456';
      const invalidCode1 = '12345'; // Too short
      const invalidCode2 = '1234567'; // Too long
      const invalidCode3 = 'abcdef'; // Not numeric

      // Act & Assert
      expect(_isValidTempCardCode(validCode), isTrue);
      expect(_isValidTempCardCode(invalidCode1), isFalse);
      expect(_isValidTempCardCode(invalidCode2), isFalse);
      expect(_isValidTempCardCode(invalidCode3), isFalse);
    });

    test('should calculate temp card expiry correctly', () {
      // Arrange
      final issueDate = DateTime.now();
      final expiryHours = 24;

      // Act
      final expiryDate = _calculateExpiryDate(issueDate, expiryHours);

      // Assert
      final expectedExpiry = issueDate.add(Duration(hours: expiryHours));
      expect(expiryDate.difference(expectedExpiry).inSeconds, equals(0));
    });

    test('should determine temp card status correctly', () {
      // Arrange
      final now = DateTime.now();
      
      final activeCard = {
        'isActive': true,
        'expiryDate': now.add(const Duration(hours: 24)),
      };
      
      final expiredCard = {
        'isActive': true,
        'expiryDate': now.subtract(const Duration(hours: 1)),
      };
      
      final deactivatedCard = {
        'isActive': false,
        'expiryDate': now.add(const Duration(hours: 24)),
      };

      // Act & Assert
      expect(_getTempCardStatus(activeCard, now), equals('Active'));
      expect(_getTempCardStatus(expiredCard, now), equals('Expired'));
      expect(_getTempCardStatus(deactivatedCard, now), equals('Deactivated'));
    });

    test('should validate proxy time record data', () {
      // Arrange
      final validRecord = {
        'staffId': 'staff123',
        'staffName': 'John Doe',
        'jobId': 'job123',
        'jobName': 'Office Cleaning',
        'checkInTime': DateTime.now().subtract(const Duration(hours: 2)),
        'checkOutTime': DateTime.now(),
      };

      final invalidRecord1 = {
        'staffId': '', // Empty staff ID
        'staffName': 'John Doe',
        'jobId': 'job123',
        'jobName': 'Office Cleaning',
        'checkInTime': DateTime.now().subtract(const Duration(hours: 2)),
        'checkOutTime': DateTime.now(),
      };

      final invalidRecord2 = {
        'staffId': 'staff123',
        'staffName': 'John Doe',
        'jobId': '', // Empty job ID
        'jobName': 'Office Cleaning',
        'checkInTime': DateTime.now().subtract(const Duration(hours: 2)),
        'checkOutTime': DateTime.now(),
      };

      // Act & Assert
      expect(_validateProxyTimeRecord(validRecord), isTrue);
      expect(_validateProxyTimeRecord(invalidRecord1), isFalse);
      expect(_validateProxyTimeRecord(invalidRecord2), isFalse);
    });

    test('should calculate duration correctly', () {
      // Arrange
      final checkInTime = DateTime.now().subtract(const Duration(hours: 2, minutes: 30));
      final checkOutTime = DateTime.now();

      // Act
      final duration = _calculateDuration(checkInTime, checkOutTime);

      // Assert
      expect(duration, equals(150)); // 2 hours 30 minutes = 150 minutes
    });

    test('should validate quality flag data', () {
      // Arrange
      final validFlag = {
        'jobId': 'job123',
        'jobName': 'Office Cleaning',
        'staffId': 'staff123',
        'staffName': 'John Doe',
        'issueType': 'Cleaning Quality',
        'description': 'Areas not properly cleaned',
        'severity': 3,
      };

      final invalidFlag1 = {
        'jobId': '', // Empty job ID
        'jobName': 'Office Cleaning',
        'staffId': 'staff123',
        'staffName': 'John Doe',
        'issueType': 'Cleaning Quality',
        'description': 'Areas not properly cleaned',
        'severity': 3,
      };

      final invalidFlag2 = {
        'jobId': 'job123',
        'jobName': 'Office Cleaning',
        'staffId': 'staff123',
        'staffName': 'John Doe',
        'issueType': 'Cleaning Quality',
        'description': 'Areas not properly cleaned',
        'severity': 6, // Invalid severity (should be 1-5)
      };

      // Act & Assert
      expect(_validateQualityFlag(validFlag), isTrue);
      expect(_validateQualityFlag(invalidFlag1), isFalse);
      expect(_validateQualityFlag(invalidFlag2), isFalse);
    });

    test('should validate B2B lead data', () {
      // Arrange
      final validLead = {
        'companyName': 'ABC Corp',
        'contactName': 'Jane Smith',
        'email': 'jane@abc.com',
        'phone': '555-0123',
        'serviceInterest': 'Regular Cleaning',
      };

      final invalidLead1 = {
        'companyName': '', // Empty company name
        'contactName': 'Jane Smith',
        'email': 'jane@abc.com',
        'phone': '555-0123',
        'serviceInterest': 'Regular Cleaning',
      };

      final invalidLead2 = {
        'companyName': 'ABC Corp',
        'contactName': 'Jane Smith',
        'email': 'invalid-email', // Invalid email format
        'phone': '555-0123',
        'serviceInterest': 'Regular Cleaning',
      };

      // Act & Assert
      expect(_validateB2BLead(validLead), isTrue);
      expect(_validateB2BLead(invalidLead1), isFalse);
      expect(_validateB2BLead(invalidLead2), isFalse);
    });

    test('should validate payroll report data', () {
      // Arrange
      final startDate = DateTime.now().subtract(const Duration(days: 30));
      final endDate = DateTime.now();

      final validReport = {
        'startDate': startDate,
        'endDate': endDate,
        'timeRecordIds': ['record1', 'record2'],
        'totalAmount': 1500.0,
      };

      final invalidReport1 = {
        'startDate': endDate, // Start date after end date
        'endDate': startDate,
        'timeRecordIds': ['record1', 'record2'],
        'totalAmount': 1500.0,
      };

      final invalidReport2 = {
        'startDate': startDate,
        'endDate': endDate,
        'timeRecordIds': [], // No time records
        'totalAmount': 1500.0,
      };

      // Act & Assert
      expect(_validatePayrollReport(validReport), isTrue);
      expect(_validatePayrollReport(invalidReport1), isFalse);
      expect(_validatePayrollReport(invalidReport2), isFalse);
    });

    test('should validate logistics event data', () {
      // Arrange
      final validEvent = {
        'staffId': 'staff123',
        'jobId': 'job123',
        'eventType': 'staff_checked_in',
        'description': 'Staff checked in for job',
        'timestamp': DateTime.now(),
      };

      final invalidEvent1 = {
        'staffId': '', // Empty staff ID
        'jobId': 'job123',
        'eventType': 'staff_checked_in',
        'description': 'Staff checked in for job',
        'timestamp': DateTime.now(),
      };

      final invalidEvent2 = {
        'staffId': 'staff123',
        'jobId': '', // Empty job ID
        'eventType': 'staff_checked_in',
        'description': 'Staff checked in for job',
        'timestamp': DateTime.now(),
      };

      // Act & Assert
      expect(_validateLogisticsEvent(validEvent), isTrue);
      expect(_validateLogisticsEvent(invalidEvent1), isFalse);
      expect(_validateLogisticsEvent(invalidEvent2), isFalse);
    });

    test('should format audit log details correctly', () {
      // Arrange
      final details = {
        'action': 'TEMP_CARD_ISSUED',
        'staffId': 'staff123',
        'cardNumber': '123456',
        'issuedBy': 'Admin',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Act
      final formattedDetails = _formatAuditLogDetails(details);

      // Assert
      expect(formattedDetails, contains('Action: TEMP_CARD_ISSUED'));
      expect(formattedDetails, contains('Staffid: staff123'));
      expect(formattedDetails, contains('Cardnumber: 123456'));
      expect(formattedDetails, contains('Issuedby: Admin'));
    });
  });
}

// Helper functions that simulate AdminProvider logic without Firebase dependency
String _generateTempCardCode() {
  final random = DateTime.now().millisecondsSinceEpoch;
  final code = (100000 + (random % 900000)).toString();
  return code;
}

bool _isValidTempCardCode(String code) {
  if (code.length != 6) return false;
  final numericCode = int.tryParse(code);
  return numericCode != null && numericCode >= 100000 && numericCode <= 999999;
}

DateTime _calculateExpiryDate(DateTime issueDate, int hours) {
  return issueDate.add(Duration(hours: hours));
}

String _getTempCardStatus(Map<String, dynamic> card, DateTime currentTime) {
  final isActive = card['isActive'] as bool? ?? false;
  final expiryDate = card['expiryDate'] as DateTime? ?? DateTime.now();
  
  if (!isActive) return 'Deactivated';
  if (currentTime.isAfter(expiryDate)) return 'Expired';
  return 'Active';
}

bool _validateProxyTimeRecord(Map<String, dynamic> record) {
  return (record['staffId'] as String?)?.isNotEmpty == true &&
      (record['staffName'] as String?)?.isNotEmpty == true &&
      (record['jobId'] as String?)?.isNotEmpty == true &&
      (record['jobName'] as String?)?.isNotEmpty == true &&
      record['checkInTime'] != null &&
      record['checkOutTime'] != null;
}

int _calculateDuration(DateTime checkInTime, DateTime checkOutTime) {
  return checkOutTime.difference(checkInTime).inMinutes;
}

bool _validateQualityFlag(Map<String, dynamic> flag) {
  return (flag['jobId'] as String?)?.isNotEmpty == true &&
      (flag['staffId'] as String?)?.isNotEmpty == true &&
      (flag['issueType'] as String?)?.isNotEmpty == true &&
      (flag['description'] as String?)?.isNotEmpty == true &&
      (flag['severity'] as int? ?? 0) >= 1 &&
      (flag['severity'] as int? ?? 0) <= 5;
}

bool _validateB2BLead(Map<String, dynamic> lead) {
  final email = lead['email'] as String? ?? '';
  final emailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  
  return (lead['companyName'] as String?)?.isNotEmpty == true &&
      (lead['contactName'] as String?)?.isNotEmpty == true &&
      emailValid &&
      (lead['phone'] as String?)?.isNotEmpty == true &&
      (lead['serviceInterest'] as String?)?.isNotEmpty == true;
}

bool _validatePayrollReport(Map<String, dynamic> report) {
  final startDate = report['startDate'] as DateTime? ?? DateTime.now();
  final endDate = report['endDate'] as DateTime? ?? DateTime.now();
  final timeRecordIds = report['timeRecordIds'] as List? ?? [];
  
  return startDate.isBefore(endDate) &&
      timeRecordIds.isNotEmpty &&
      (report['totalAmount'] as double? ?? 0.0) >= 0;
}

bool _validateLogisticsEvent(Map<String, dynamic> event) {
  return (event['staffId'] as String?)?.isNotEmpty == true &&
      (event['jobId'] as String?)?.isNotEmpty == true &&
      (event['eventType'] as String?)?.isNotEmpty == true &&
      (event['description'] as String?)?.isNotEmpty == true &&
      event['timestamp'] != null;
}

String _formatAuditLogDetails(Map<String, dynamic> details) {
  final buffer = StringBuffer();
  details.forEach((key, value) {
    final formattedKey = key.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
    buffer.writeln('$formattedKey: $value');
  });
  return buffer.toString().trim();
}
