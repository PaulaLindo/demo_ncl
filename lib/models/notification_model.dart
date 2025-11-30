// lib/models/notification_model.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents different types of notifications
enum NotificationType {
  booking('booking', Icons.event),
  reminder('reminder', Icons.alarm),
  status('status', Icons.info),
  payment('payment', Icons.payment),
  system('system', Icons.settings),
  message('message', Icons.message);

  const NotificationType(this.value, this.icon);
  final String value;
  final IconData icon;
}

/// Represents notification priority levels
enum NotificationPriority {
  low('low', 1),
  normal('normal', 2),
  high('high', 3),
  urgent('urgent', 4);

  const NotificationPriority(this.value, this.level);
  final String value;
  final int level;
}

/// Represents a notification in the system
class AppNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  final String? imageUrl;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.expiresAt,
    this.isRead = false,
    this.data,
    this.actionUrl,
    this.imageUrl,
  });

  /// Creates a notification from JSON
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => NotificationType.system,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.value == json['priority'],
        orElse: () => NotificationPriority.normal,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      isRead: json['isRead'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
      actionUrl: json['actionUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  /// Converts notification to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.value,
      'priority': priority.value,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isRead': isRead,
      'data': data,
      'actionUrl': actionUrl,
      'imageUrl': imageUrl,
    };
  }

  /// Creates a booking confirmation notification
  factory AppNotification.bookingConfirmation({
    required String bookingId,
    required String serviceName,
    required DateTime bookingDate,
    required String customerName,
  }) {
    return AppNotification(
      id: 'booking_conf_$bookingId',
      title: 'Booking Confirmed!',
      body: 'Your $serviceName appointment for ${_formatDate(bookingDate)} has been confirmed.',
      type: NotificationType.booking,
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
      data: {
        'bookingId': bookingId,
        'serviceName': serviceName,
        'bookingDate': bookingDate.toIso8601String(),
        'customerName': customerName,
      },
      actionUrl: '/bookings/$bookingId',
    );
  }

  /// Creates a booking reminder notification
  factory AppNotification.bookingReminder({
    required String bookingId,
    required String serviceName,
    required DateTime bookingDate,
    required int hoursBefore,
  }) {
    return AppNotification(
      id: 'reminder_$bookingId',
      title: 'Booking Reminder',
      body: 'Your $serviceName appointment is in $hoursBefore hours (${_formatDate(bookingDate)}).',
      type: NotificationType.reminder,
      priority: NotificationPriority.high,
      createdAt: DateTime.now(),
      expiresAt: bookingDate,
      data: {
        'bookingId': bookingId,
        'serviceName': serviceName,
        'bookingDate': bookingDate.toIso8601String(),
        'hoursBefore': hoursBefore,
      },
      actionUrl: '/bookings/$bookingId',
    );
  }

  /// Creates a status update notification
  factory AppNotification.statusUpdate({
    required String bookingId,
    required String oldStatus,
    required String newStatus,
    required String serviceName,
  }) {
    return AppNotification(
      id: 'status_$bookingId',
      title: 'Booking Status Updated',
      body: 'Your $serviceName booking status changed from $oldStatus to $newStatus.',
      type: NotificationType.status,
      priority: NotificationPriority.normal,
      createdAt: DateTime.now(),
      data: {
        'bookingId': bookingId,
        'oldStatus': oldStatus,
        'newStatus': newStatus,
        'serviceName': serviceName,
      },
      actionUrl: '/bookings/$bookingId',
    );
  }

  /// Creates a payment notification
  factory AppNotification.payment({
    required String paymentId,
    required double amount,
    required String status,
    required String serviceName,
  }) {
    final isSuccessful = status.toLowerCase() == 'completed';
    return AppNotification(
      id: 'payment_$paymentId',
      title: isSuccessful ? 'Payment Successful' : 'Payment Failed',
      body: 'Payment of \$${amount.toStringAsFixed(2)} for $serviceName was $status.',
      type: NotificationType.payment,
      priority: isSuccessful ? NotificationPriority.normal : NotificationPriority.high,
      createdAt: DateTime.now(),
      data: {
        'paymentId': paymentId,
        'amount': amount,
        'status': status,
        'serviceName': serviceName,
      },
      actionUrl: '/payments/$paymentId',
    );
  }

  /// Creates a system notification
  factory AppNotification.system({
    required String title,
    required String body,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: 'system_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: NotificationType.system,
      priority: priority,
      createdAt: DateTime.now(),
      data: data,
    );
  }

  /// Check if notification is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if notification is recent (within 24 hours)
  bool get isRecent {
    final now = DateTime.now();
    return now.difference(createdAt).inHours < 24;
  }

  /// Get formatted creation time
  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${_formatDate(createdAt)}';
    }
  }

  /// Mark notification as read
  AppNotification markAsRead() {
    return copyWith(isRead: true);
  }

  /// Create a copy with updated values
  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isRead,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? imageUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        type,
        priority,
        createdAt,
        expiresAt,
        isRead,
        data,
        actionUrl,
        imageUrl,
      ];
}

/// Represents a notification channel for push notifications
class NotificationChannel extends Equatable {
  final String id;
  final String name;
  final String description;
  final bool enabled;
  final bool vibrationEnabled;
  final bool soundEnabled;

  const NotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    this.enabled = true,
    this.vibrationEnabled = true,
    this.soundEnabled = true,
  });

  @override
  List<Object?> get props => [id, name, description, enabled, vibrationEnabled, soundEnabled];
}

/// Default notification channels
class NotificationChannels {
  static const booking = NotificationChannel(
    id: 'bookings',
    name: 'Bookings',
    description: 'Booking confirmations, reminders, and updates',
  );

  static const payments = NotificationChannel(
    id: 'payments',
    name: 'Payments',
    description: 'Payment confirmations and failures',
  );

  static const promotions = NotificationChannel(
    id: 'promotions',
    name: 'Promotions',
    description: 'Special offers and discounts',
  );

  static const system = NotificationChannel(
    id: 'system',
    name: 'System',
    description: 'System updates and announcements',
  );

  static List<NotificationChannel> get all => [
    booking,
    payments,
    promotions,
    system,
  ];
}
