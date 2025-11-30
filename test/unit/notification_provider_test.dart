// test/unit/notification_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:demo_ncl/providers/notification_provider.dart';
import 'package:demo_ncl/models/notification_model.dart';

void main() {
  // Initialize Flutter binding for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('NotificationProvider Tests', () {
    late NotificationProvider provider;

    setUp(() {
      provider = NotificationProvider();
      // Reset the provider state before each test
      provider.reset();
    });

    test('should initialize with default values', () {
      expect(provider.notifications, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.error, null);
      expect(provider.unreadCount, 0);
    });

    test('should add notification', () async {
      final notification = AppNotification(
        id: 'test-1',
        title: 'Test Notification',
        body: 'Test body',
        type: NotificationType.booking,
        priority: NotificationPriority.normal,
        createdAt: DateTime.now(),
      );

      await provider.addNotification(notification);

      expect(provider.notifications.length, 1);
      expect(provider.notifications.first, notification);
      expect(provider.unreadCount, 1);
    });

    test('should mark notification as read', () async {
      final notification = AppNotification(
        id: 'test-1',
        title: 'Test Notification',
        body: 'Test body',
        type: NotificationType.booking,
        priority: NotificationPriority.normal,
        createdAt: DateTime.now(),
      );

      await provider.addNotification(notification);
      expect(provider.unreadCount, 1);

      await provider.markAsRead('test-1');

      expect(provider.unreadCount, 0);
      expect(provider.notifications.first.isRead, true);
    });

    test('should mark all notifications as read', () async {
      final notifications = [
        AppNotification(
          id: 'test-1',
          title: 'Test Notification 1',
          body: 'Test body 1',
          type: NotificationType.booking,
          priority: NotificationPriority.normal,
          createdAt: DateTime.now(),
        ),
        AppNotification(
          id: 'test-2',
          title: 'Test Notification 2',
          body: 'Test body 2',
          type: NotificationType.payment,
          priority: NotificationPriority.high,
          createdAt: DateTime.now(),
        ),
      ];

      for (final notification in notifications) {
        await provider.addNotification(notification);
      }

      expect(provider.unreadCount, 2);

      await provider.markAllAsRead();

      expect(provider.unreadCount, 0);
      expect(provider.notifications.every((n) => n.isRead), true);
    });

    test('should delete notification', () async {
      final notification = AppNotification(
        id: 'test-1',
        title: 'Test Notification',
        body: 'Test body',
        type: NotificationType.booking,
        priority: NotificationPriority.normal,
        createdAt: DateTime.now(),
      );

      await provider.addNotification(notification);
      expect(provider.notifications.length, 1);

      await provider.deleteNotification('test-1');

      expect(provider.notifications.length, 0);
      expect(provider.unreadCount, 0);
    });

    test('should clear all notifications', () async {
      final notifications = [
        AppNotification(
          id: 'test-1',
          title: 'Test Notification 1',
          body: 'Test body 1',
          type: NotificationType.booking,
          priority: NotificationPriority.normal,
          createdAt: DateTime.now(),
        ),
        AppNotification(
          id: 'test-2',
          title: 'Test Notification 2',
          body: 'Test body 2',
          type: NotificationType.payment,
          priority: NotificationPriority.high,
          createdAt: DateTime.now(),
        ),
      ];

      for (final notification in notifications) {
        await provider.addNotification(notification);
      }

      expect(provider.notifications.length, 2);

      await provider.clearAllNotifications();

      expect(provider.notifications.length, 0);
      expect(provider.unreadCount, 0);
    });

    test('should get notifications by type', () async {
      final notifications = [
        AppNotification(
          id: 'test-1',
          title: 'Booking Notification',
          body: 'Test body 1',
          type: NotificationType.booking,
          priority: NotificationPriority.normal,
          createdAt: DateTime.now(),
        ),
        AppNotification(
          id: 'test-2',
          title: 'Payment Notification',
          body: 'Test body 2',
          type: NotificationType.payment,
          priority: NotificationPriority.high,
          createdAt: DateTime.now(),
        ),
        AppNotification(
          id: 'test-3',
          title: 'Another Booking',
          body: 'Test body 3',
          type: NotificationType.booking,
          priority: NotificationPriority.low,
          createdAt: DateTime.now(),
        ),
      ];

      for (final notification in notifications) {
        await provider.addNotification(notification);
      }

      final bookingNotifications = provider.getNotificationsByType(NotificationType.booking);
      final paymentNotifications = provider.getNotificationsByType(NotificationType.payment);

      expect(bookingNotifications.length, 2);
      expect(paymentNotifications.length, 1);
      expect(bookingNotifications.every((n) => n.type == NotificationType.booking), true);
      expect(paymentNotifications.every((n) => n.type == NotificationType.payment), true);
    });

    test('should get unread notifications', () async {
      final notifications = [
        AppNotification(
          id: 'test-1',
          title: 'Unread Notification',
          body: 'Test body 1',
          type: NotificationType.booking,
          priority: NotificationPriority.normal,
          createdAt: DateTime.now(),
        ),
        AppNotification(
          id: 'test-2',
          title: 'Read Notification',
          body: 'Test body 2',
          type: NotificationType.payment,
          priority: NotificationPriority.high,
          createdAt: DateTime.now(),
          isRead: true,
        ),
      ];

      for (final notification in notifications) {
        await provider.addNotification(notification);
      }

      final unreadNotifications = provider.notifications.where((n) => !n.isRead).toList();

      expect(unreadNotifications.length, 1);
      expect(unreadNotifications.first.isRead, false);
    });

    test('should schedule booking reminder', () async {
      final bookingDate = DateTime.now().add(const Duration(days: 1));
      
      await provider.scheduleBookingReminder(
        bookingId: 'booking-123',
        serviceName: 'Regular Cleaning',
        bookingDate: bookingDate,
        hoursBefore: 2,
      );

      // The reminder should be scheduled (we can't easily test the actual scheduling in unit tests)
      // but we can verify the method doesn't throw an exception
      expect(true, isTrue);
    });

    test('should cancel notification', () async {
      // Test that cancel notification doesn't throw
      await provider.cancelNotification('test-1');
      expect(true, isTrue);
    });

    test('should get notification statistics', () async {
      final notifications = [
        AppNotification(
          id: 'test-1',
          title: 'Unread Booking',
          body: 'Test body 1',
          type: NotificationType.booking,
          priority: NotificationPriority.high,
          createdAt: DateTime.now(),
        ),
        AppNotification(
          id: 'test-2',
          title: 'Read Payment',
          body: 'Test body 2',
          type: NotificationType.payment,
          priority: NotificationPriority.normal,
          createdAt: DateTime.now(),
          isRead: true,
        ),
        AppNotification(
          id: 'test-3',
          title: 'Unread System',
          body: 'Test body 3',
          type: NotificationType.system,
          priority: NotificationPriority.low,
          createdAt: DateTime.now(),
        ),
      ];

      for (final notification in notifications) {
        await provider.addNotification(notification);
      }

      final stats = provider.getNotificationStats();

      expect(stats, isA<Map<String, int>>());
      expect(stats.containsKey('booking'), true);
      expect(stats.containsKey('payment'), true);
      expect(stats.containsKey('system'), true);
      expect(stats['booking'], 1);
      expect(stats['payment'], 1);
      expect(stats['system'], 1);
    });

    test('should cleanup expired notifications', () async {
      // Add an expired notification
      final expiredNotification = AppNotification(
        id: 'expired-1',
        title: 'Expired Notification',
        body: 'This should be cleaned up',
        type: NotificationType.system,
        priority: NotificationPriority.low,
        createdAt: DateTime.now().subtract(const Duration(days: 8)), // Expired
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      final validNotification = AppNotification(
        id: 'valid-1',
        title: 'Valid Notification',
        body: 'This should remain',
        type: NotificationType.booking,
        priority: NotificationPriority.normal,
        createdAt: DateTime.now(),
      );

      await provider.addNotification(expiredNotification);
      await provider.addNotification(validNotification);

      expect(provider.notifications.length, 2);

      await provider.cleanupExpiredNotifications();

      // Should remove expired notification
      expect(provider.notifications.length, 1);
      expect(provider.notifications.first.id, 'valid-1');
    });

    test('should reset provider state', () async {
      final notification = AppNotification(
        id: 'test-1',
        title: 'Test Notification',
        body: 'Test body',
        type: NotificationType.booking,
        priority: NotificationPriority.normal,
        createdAt: DateTime.now(),
      );

      await provider.addNotification(notification);
      expect(provider.notifications.length, 1);

      provider.reset();

      expect(provider.notifications, isEmpty);
      expect(provider.unreadCount, 0);
      expect(provider.error, null);
    });

    test('should handle notification actions', () {
      // Test notification action handling (simulated)
      final notification = AppNotification(
        id: 'test-1',
        title: 'Action Notification',
        body: 'Tap to view booking',
        type: NotificationType.booking,
        priority: NotificationPriority.normal,
        createdAt: DateTime.now(),
        actionUrl: '/booking/123',
      );

      // In a real test, we would simulate tapping the notification
      // For now, we just verify the notification has the action URL
      expect(notification.actionUrl, '/booking/123');
    });

    test('should create different notification types', () {
      final bookingNotification = AppNotification.bookingConfirmation(
        bookingId: 'booking-1',
        serviceName: 'Regular Cleaning',
        bookingDate: DateTime.now().add(const Duration(days: 1)),
        customerName: 'John Doe',
      );

      final paymentNotification = AppNotification.payment(
        paymentId: 'payment-1',
        amount: 150.0,
        status: 'completed',
        serviceName: 'Regular Cleaning',
      );

      final reminderNotification = AppNotification.bookingReminder(
        bookingId: 'booking-1',
        serviceName: 'Regular Cleaning',
        bookingDate: DateTime.now().add(const Duration(hours: 24)),
        hoursBefore: 24,
      );

      expect(bookingNotification.type, NotificationType.booking);
      expect(paymentNotification.type, NotificationType.payment);
      expect(reminderNotification.type, NotificationType.reminder);
    });

    test('should handle notification priority levels', () async {
      final notifications = [
        AppNotification(
          id: 'low-1',
          title: 'Low Priority',
          body: 'Low priority notification',
          type: NotificationType.system,
          priority: NotificationPriority.low,
          createdAt: DateTime.now(),
        ),
        AppNotification(
          id: 'high-1',
          title: 'High Priority',
          body: 'High priority notification',
          type: NotificationType.payment,
          priority: NotificationPriority.high,
          createdAt: DateTime.now(),
        ),
        AppNotification(
          id: 'urgent-1',
          title: 'Urgent Priority',
          body: 'Urgent priority notification',
          type: NotificationType.status,
          priority: NotificationPriority.urgent,
          createdAt: DateTime.now(),
        ),
      ];

      for (final notification in notifications) {
        await provider.addNotification(notification);
      }

      final highPriorityNotifications = provider.notifications
          .where((n) => n.priority == NotificationPriority.high || n.priority == NotificationPriority.urgent)
          .toList();

      expect(highPriorityNotifications.length, 2);
    });

    test('should handle notification expiration', () {
      final expiredNotification = AppNotification(
        id: 'expired-1',
        title: 'Expired',
        body: 'This notification is expired',
        type: NotificationType.system,
        priority: NotificationPriority.low,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      final validNotification = AppNotification(
        id: 'valid-1',
        title: 'Valid',
        body: 'This notification is still valid',
        type: NotificationType.booking,
        priority: NotificationPriority.normal,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(expiredNotification.isExpired, true);
      expect(validNotification.isExpired, false);
    });
  });
}
