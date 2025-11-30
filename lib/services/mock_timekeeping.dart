// lib/services/mock_timekeeping.dart
import '../models/timekeeping_exports.dart';

class MockTimekeepingData {
  static List<TimeRecord> getTimeRecords() {
    final now = DateTime.now();
    return [
      TimeRecord(
        id: '1',
        staffId: 'staff1',
        jobId: 'office_clean',
        jobName: 'Office Cleaning',
        checkInTime: now.subtract(const Duration(hours: 2)),
        checkOutTime: now.subtract(const Duration(hours: 1)),
        startTime: now.subtract(const Duration(hours: 2)),
        type: TimeRecordType.self,
        status: TimeRecordStatus.completed,
      ),
      TimeRecord(
        id: '2',
        staffId: 'staff1',
        jobId: 'meeting_room',
        jobName: 'Meeting Room Setup',
        checkInTime: now.subtract(const Duration(hours: 5)),
        checkOutTime: now.subtract(const Duration(hours: 4)),
        startTime: now.subtract(const Duration(hours: 5)),
        type: TimeRecordType.proxy,
        proxyCardId: 'card1',
        status: TimeRecordStatus.completed,
      ),
      TimeRecord(
        id: '3',
        staffId: 'staff1',
        jobId: 'reception',
        jobName: 'Reception Area',
        checkInTime: now.subtract(const Duration(minutes: 30)),
        startTime: now.subtract(const Duration(minutes: 30)),
        type: TimeRecordType.self,
        status: TimeRecordStatus.inProgress,
      ),
    ];
  }

  static List<WorkShift> getWorkShifts() {
    final now = DateTime.now();
    return [
      WorkShift(
        id: 'shift1',
        name: 'Morning Shift',
        type: WorkShiftType.regular,
        userId: 'user1',
        startTime: now.subtract(const Duration(days: 1, hours: 8)),
        endTime: now.subtract(const Duration(days: 1)),
        breaks: [
          Break(
            startTime: now.subtract(const Duration(days: 1, hours: 4)),
            endTime: now.subtract(const Duration(days: 1, hours: 3, minutes: 30)),
            reason: 'Lunch Break',
          )
        ],
      ),
      WorkShift(
        id: 'shift2',
        name: 'Afternoon Shift',
        type: WorkShiftType.regular,
        userId: 'user2',
                startTime: now.subtract(const Duration(days: 1, hours: 12)),
        endTime: now.subtract(const Duration(days: 1, hours: 4)),
      ),
    ];
  }

  static List<TempCard> getTempCards() {
    return [
      TempCard(
        id: 'card1',
        userId: 'user1',
        userName: 'John Doe',
        cardNumber: 'TC001',
        issueDate: DateTime.now().subtract(const Duration(days: 30)),
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
      ),
      TempCard(
        id: 'card2',
        userId: 'user2',
        userName: 'Jane Smith',
        cardNumber: 'TC002',
        issueDate: DateTime.now().subtract(const Duration(days: 15)),
        expiryDate: DateTime.now().add(const Duration(days: 45)),
        isActive: true,
      ),
    ];
  }

  static Map<String, dynamic> getTimekeepingStats() {
    return {
      'totalHoursThisWeek': 32.5,
      'averageDailyHours': 6.5,
      'overtimeHours': 4.5,
      'jobsCompleted': 12,
      'activeJobs': 2,
    };
  }
}