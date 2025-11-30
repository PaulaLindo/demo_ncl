// lib/models/availability_model.dart
import 'package:equatable/equatable.dart';

/// Represents a time slot for availability
class TimeSlot extends Equatable {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String? staffId;
  final String? staffName;
  final int maxBookings;
  final int currentBookings;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.staffId,
    this.staffName,
    this.maxBookings = 1,
    this.currentBookings = 0,
  });

  /// Creates a TimeSlot from JSON
  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      isAvailable: json['isAvailable'] as bool? ?? true,
      staffId: json['staffId'] as String?,
      staffName: json['staffName'] as String?,
      maxBookings: json['maxBookings'] as int? ?? 1,
      currentBookings: json['currentBookings'] as int? ?? 0,
    );
  }

  /// Converts TimeSlot to JSON
  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAvailable': isAvailable,
      'staffId': staffId,
      'staffName': staffName,
      'maxBookings': maxBookings,
      'currentBookings': currentBookings,
    };
  }

  /// Gets the duration of the time slot
  Duration get duration => endTime.difference(startTime);

  /// Gets the formatted time range
  String get timeRange => '${_formatTime(startTime)} - ${_formatTime(endTime)}';

  /// Gets the availability status text
  String get statusText {
    if (!isAvailable) return 'Unavailable';
    if (currentBookings >= maxBookings) return 'Fully Booked';
    if (currentBookings > 0) return '${maxBookings - currentBookings} spots left';
    return 'Available';
  }

  /// Gets the availability color
  String get statusColor {
    if (!isAvailable) return 'grey';
    if (currentBookings >= maxBookings) return 'red';
    if (currentBookings > 0) return 'orange';
    return 'green';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  List<Object?> get props => [
        startTime,
        endTime,
        isAvailable,
        staffId,
        staffName,
        maxBookings,
        currentBookings,
      ];
}

/// Represents daily availability
class DailyAvailability extends Equatable {
  final DateTime date;
  final List<TimeSlot> timeSlots;
  final bool isFullyBooked;
  final bool hasAvailability;

  const DailyAvailability({
    required this.date,
    required this.timeSlots,
    required this.isFullyBooked,
    required this.hasAvailability,
  });

  /// Creates DailyAvailability from JSON
  factory DailyAvailability.fromJson(Map<String, dynamic> json) {
    return DailyAvailability(
      date: DateTime.parse(json['date'] as String),
      timeSlots: (json['timeSlots'] as List<dynamic>?)
          ?.map((slot) => TimeSlot.fromJson(slot as Map<String, dynamic>))
          .toList() ?? [],
      isFullyBooked: json['isFullyBooked'] as bool? ?? false,
      hasAvailability: json['hasAvailability'] as bool? ?? true,
    );
  }

  /// Converts DailyAvailability to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'timeSlots': timeSlots.map((slot) => slot.toJson()).toList(),
      'isFullyBooked': isFullyBooked,
      'hasAvailability': hasAvailability,
    };
  }

  /// Gets available time slots only
  List<TimeSlot> get availableSlots => 
      timeSlots.where((slot) => slot.isAvailable && slot.currentBookings < slot.maxBookings).toList();

  /// Gets the formatted date
  String get formattedDate => '${_dayName(date.weekday)}, ${_monthName(date.month)} ${date.day}';

  /// Gets the number of available slots
  int get availableSlotCount => availableSlots.length;

  String _dayName(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  List<Object?> get props => [date, timeSlots, isFullyBooked, hasAvailability];
}

/// Represents availability check result
class AvailabilityCheckResult extends Equatable {
  final bool isAvailable;
  final List<DailyAvailability> weeklyAvailability;
  final List<String> conflictingBookings;
  final String? message;
  final DateTime? nextAvailableDate;

  const AvailabilityCheckResult({
    required this.isAvailable,
    required this.weeklyAvailability,
    required this.conflictingBookings,
    this.message,
    this.nextAvailableDate,
  });

  /// Creates AvailabilityCheckResult from JSON
  factory AvailabilityCheckResult.fromJson(Map<String, dynamic> json) {
    return AvailabilityCheckResult(
      isAvailable: json['isAvailable'] as bool? ?? false,
      weeklyAvailability: (json['weeklyAvailability'] as List<dynamic>?)
          ?.map((day) => DailyAvailability.fromJson(day as Map<String, dynamic>))
          .toList() ?? [],
      conflictingBookings: (json['conflictingBookings'] as List<dynamic>?)
          ?.map((booking) => booking as String)
          .toList() ?? [],
      message: json['message'] as String?,
      nextAvailableDate: json['nextAvailableDate'] != null
          ? DateTime.parse(json['nextAvailableDate'] as String)
          : null,
    );
  }

  /// Converts AvailabilityCheckResult to JSON
  Map<String, dynamic> toJson() {
    return {
      'isAvailable': isAvailable,
      'weeklyAvailability': weeklyAvailability.map((day) => day.toJson()).toList(),
      'conflictingBookings': conflictingBookings,
      'message': message,
      'nextAvailableDate': nextAvailableDate?.toIso8601String(),
    };
  }

  /// Gets the next available day
  DailyAvailability? get nextAvailableDay {
    for (final day in weeklyAvailability) {
      if (day.hasAvailability && day.availableSlotCount > 0) {
        return day;
      }
    }
    return null;
  }

  /// Gets total available slots for the week
  int get totalAvailableSlots {
    return weeklyAvailability.fold(0, (sum, day) => sum + day.availableSlotCount);
  }

  @override
  List<Object?> get props => [
        isAvailable,
        weeklyAvailability,
        conflictingBookings,
        message,
        nextAvailableDate,
      ];
}

/// Represents a booking conflict
class BookingConflict extends Equatable {
  final String bookingId;
  final DateTime startTime;
  final DateTime endTime;
  final String staffId;
  final String staffName;
  final String conflictType; // 'time', 'staff', 'resource'
  final String description;

  const BookingConflict({
    required this.bookingId,
    required this.startTime,
    required this.endTime,
    required this.staffId,
    required this.staffName,
    required this.conflictType,
    required this.description,
  });

  /// Creates BookingConflict from JSON
  factory BookingConflict.fromJson(Map<String, dynamic> json) {
    return BookingConflict(
      bookingId: json['bookingId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      staffId: json['staffId'] as String,
      staffName: json['staffName'] as String,
      conflictType: json['conflictType'] as String,
      description: json['description'] as String,
    );
  }

  /// Converts BookingConflict to JSON
  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'staffId': staffId,
      'staffName': staffName,
      'conflictType': conflictType,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [
        bookingId,
        startTime,
        endTime,
        staffId,
        staffName,
        conflictType,
        description,
      ];
}
