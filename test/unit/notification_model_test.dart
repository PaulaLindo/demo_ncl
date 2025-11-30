// test/unit/notification_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:demo_ncl/models/notification_model.dart';

void main() {
  group('NotificationModel Tests', () {
    group('NotificationType', () {
      test('should have correct values and icons', () {
        expect(NotificationType.booking.value, 'booking');
        expect(NotificationType.booking.icon, Icons.event);
        expect(NotificationType.reminder.value, 'reminder');
        expect(NotificationType.reminder.icon, Icons.alarm);
        expect(NotificationType.status.value, 'status');
        expect(NotificationType.status.icon, Icons.info);
      });

      test('should contain all expected notification types', () {
        final types = NotificationType.values;
        expect(types.length, 6);
        expect(types, contains(NotificationType.booking));
        expect(types, contains(NotificationType.reminder));
        expect(types, contains(NotificationType.status));
        expect(types, contains(NotificationType.payment));
        expect(types, contains(NotificationType.system));
        expect(types, contains(NotificationType.message));
      });
    });

    group('NotificationPriority', () {
      test('should have correct values and levels', () {
        expect(NotificationPriority.low.value, 'low');
        expect(NotificationPriority.low.level, 1);
        expect(NotificationPriority.normal.value, 'normal');
        expect(NotificationPriority.normal.level, 2);
        expect(NotificationPriority.high.value, 'high');
        expect(NotificationPriority.high.level, 3);
        expect(NotificationPriority.urgent.value, 'urgent');
        expect(NotificationPriority.urgent.level, 4);
      });
    });

    group('AppNotification', () {
      test('should create notification with required properties', () {
        final notification = AppNotification(
          id: 'test_notification',
          title: 'Test Notification',
          body: 'This is a test notification',
          type: NotificationType.booking,
          priority: NotificationPriority.normal,
          createdAt: DateTime(2024, 1, 15, 10, 0),
        );

        expect(notification.id, 'test_notification');
        expect(notification.title, 'Test Notification');
        expect(notification.body, 'This is a test notification');
        expect(notification.type, NotificationType.booking);
        expect(notification.priority, NotificationPriority.normal);
        expect(notification.isRead, false);
      });

      test('should create booking confirmation notification', () {
        final notification = AppNotification.bookingConfirmation(
          bookingId: 'booking_123',
          serviceName: 'Regular Cleaning',
          bookingDate: DateTime(2024, 1, 20, 14, 0),
          customerName: 'John Doe',
        );

        expect(notification.id, 'booking_conf_booking_123');
        expect(notification.title, 'Booking Confirmed!');
        expect(notification.type, NotificationType.booking);
        expect(notification.priority, NotificationPriority.high);
        expect(notification.data!['bookingId'], 'booking_123');
        expect(notification.data!['serviceName'], 'Regular Cleaning');
        expect(notification.actionUrl, '/bookings/booking_123');
      });

      test('should create booking reminder notification', () {
        final notification = AppNotification.bookingReminder(
          bookingId: 'booking_123',
          serviceName: 'Deep Cleaning',
          bookingDate: DateTime(2024, 1, 20, 14, 0),
          hoursBefore: 2,
        );

        expect(notification.id, 'reminder_booking_123');
        expect(notification.title, 'Booking Reminder');
        expect(notification.type, NotificationType.reminder);
        expect(notification.priority, NotificationPriority.high);
        expect(notification.expiresAt, DateTime(2024, 1, 20, 14, 0));
      });

      test('should create status update notification', () {
        final notification = AppNotification.statusUpdate(
          bookingId: 'booking_123',
          oldStatus: 'pending',
          newStatus: 'confirmed',
          serviceName: 'Regular Cleaning',
        );

        expect(notification.id, 'status_booking_123');
        expect(notification.title, 'Booking Status Updated');
        expect(notification.type, NotificationType.status);
        expect(notification.priority, NotificationPriority.normal);
        expect(notification.body, 'Your Regular Cleaning booking status changed from pending to confirmed.');
      });

      test('should create payment notification', () {
        final successfulPayment = AppNotification.payment(
          paymentId: 'payment_123',
          amount: 150.0,
          status: 'completed',
          serviceName: 'Deep Cleaning',
        );

        expect(successfulPayment.title, 'Payment Successful');
        expect(successfulPayment.type, NotificationType.payment);
        expect(successfulPayment.priority, NotificationPriority.normal);

        final failedPayment = AppNotification.payment(
          paymentId: 'payment_456',
          amount: 200.0,
          status: 'failed',
          serviceName: 'Regular Cleaning',
        );

        expect(failedPayment.title, 'Payment Failed');
        expect(failedPayment.priority, NotificationPriority.high);
      });

      test('should create system notification', () {
        final notification = AppNotification.system(
          title: 'System Maintenance',
          body: 'The system will be under maintenance from 2 AM to 4 AM',
          priority: NotificationPriority.high,
        );

        expect(notification.id, startsWith('system_'));
        expect(notification.title, 'System Maintenance');
        expect(notification.type, NotificationType.system);
        expect(notification.priority, NotificationPriority.high);
      });

      test('should check if notification is expired', () {
        final nonExpiredNotification = AppNotification(
          id: 'test_1',
          title: 'Test',
          body: 'Test',
          type: NotificationType.system,
          priority: NotificationPriority.normal,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        final expiredNotification = AppNotification(
          id: 'test_2',
          title: 'Test',
          body: 'Test',
          type: NotificationType.system,
          priority: NotificationPriority.normal,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(nonExpiredNotification.isExpired, false);
        expect(expiredNotification.isExpired, true);
      });

      test('should check if notification is recent', () {
        final recentNotification = AppNotification(
          id: 'test_1',
          title: 'Test',
          body: 'Test',
          type: NotificationType.system,
          priority: NotificationPriority.normal,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );

        final oldNotification = AppNotification(
          id: 'test_2',
          title: 'Test',
          body: 'Test',
          type: NotificationType.system,
          priority: NotificationPriority.normal,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );

        expect(recentNotification.isRecent, true);
        expect(oldNotification.isRecent, false);
      });

      test('should format creation time correctly', () {
        final now = DateTime.now();
        final justNowNotification = AppNotification(
          id: 'test_1',
          title: 'Test',
          body: 'Test',
          type: NotificationType.system,
          priority: NotificationPriority.normal,
          createdAt: now.subtract(const Duration(seconds: 30)),
        );

        final minutesAgoNotification = AppNotification(
          id: 'test_2',
          title: 'Test',
          body: 'Test',
          type: NotificationType.system,
          priority: NotificationPriority.normal,
          createdAt: now.subtract(const Duration(minutes: 45)),
        );

        final hoursAgoNotification = AppNotification(
          id: 'test_3',
          title: 'Test',
          body: 'Test',
          type: NotificationType.system,
          priority: NotificationPriority.normal,
          createdAt: now.subtract(const Duration(hours: 3)),
        );

        final daysAgoNotification = AppNotification(
          id: 'test_4',
          title: 'Test',
          body: 'Test',
          type: NotificationType.system,
          priority: NotificationPriority.normal,
          createdAt: now.subtract(const Duration(days: 5)),
        );

        expect(justNowNotification.formattedCreatedAt, 'Just now');
        expect(minutesAgoNotification.formattedCreatedAt, '45m ago');
        expect(hoursAgoNotification.formattedCreatedAt, '3h ago');
        expect(daysAgoNotification.formattedCreatedAt, '5d ago');
      });

      test('should mark notification as read', () {
        final unreadNotification = AppNotification(
          id: 'test_1',
          title: 'Test',
          body: 'Test',
          type: NotificationType.system,
          priority: NotificationPriority.normal,
          createdAt: DateTime.now(),
        );

        expect(unreadNotification.isRead, false);

        final readNotification = unreadNotification.markAsRead();
        expect(readNotification.isRead, true);
        expect(readNotification.id, unreadNotification.id);
        expect(readNotification.title, unreadNotification.title);
      });

      test('should serialize to and from JSON', () {
        final originalNotification = AppNotification(
          id: 'test_notification',
          title: 'Test Notification',
          body: 'This is a test notification',
          type: NotificationType.booking,
          priority: NotificationPriority.high,
          createdAt: DateTime(2024, 1, 15, 10, 0),
          expiresAt: DateTime(2024, 1, 20, 10, 0),
          isRead: true,
          actionUrl: '/bookings/123',
          data: {'bookingId': '123', 'customerId': '456'},
        );

        final json = originalNotification.toJson();
        final deserializedNotification = AppNotification.fromJson(json);

        expect(deserializedNotification.id, originalNotification.id);
        expect(deserializedNotification.title, originalNotification.title);
        expect(deserializedNotification.type, originalNotification.type);
        expect(deserializedNotification.priority, originalNotification.priority);
        expect(deserializedNotification.isRead, originalNotification.isRead);
        expect(deserializedNotification.actionUrl, originalNotification.actionUrl);
        expect(deserializedNotification.data!['bookingId'], originalNotification.data!['bookingId']);
      });
    });

    group('NotificationChannel', () {
      test('should create channel with properties', () {
        const channel = NotificationChannel(
          id: 'test_channel',
          name: 'Test Channel',
          description: 'This is a test channel',
          enabled: true,
          vibrationEnabled: false,
          soundEnabled: true,
        );

        expect(channel.id, 'test_channel');
        expect(channel.name, 'Test Channel');
        expect(channel.description, 'This is a test channel');
        expect(channel.enabled, true);
        expect(channel.vibrationEnabled, false);
        expect(channel.soundEnabled, true);
      });
    });

    group('NotificationChannels', () {
      test('should provide default channels', () {
        final channels = NotificationChannels.all;
        expect(channels.length, 4);
        
        expect(channels, contains(NotificationChannels.booking));
        expect(channels, contains(NotificationChannels.payments));
        expect(channels, contains(NotificationChannels.promotions));
        expect(channels, contains(NotificationChannels.system));
      });

      test('should have correct channel properties', () {
        expect(NotificationChannels.booking.id, 'bookings');
        expect(NotificationChannels.booking.name, 'Bookings');
        expect(NotificationChannels.payments.id, 'payments');
        expect(NotificationChannels.payments.name, 'Payments');
        expect(NotificationChannels.promotions.id, 'promotions');
        expect(NotificationChannels.promotions.name, 'Promotions');
        expect(NotificationChannels.system.id, 'system');
        expect(NotificationChannels.system.name, 'System');
      });
    });
  });
}
