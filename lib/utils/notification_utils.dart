// lib/utils/notification_utils.dart
import 'package:flutter/material.dart';
import '../services/notification_service_stub.dart';

class NotificationUtils {
  static final NotificationService _notificationService = NotificationService();

  static Future<void> notifyNewGigAssigned({
    required String gigId,
    required String gigTitle,
    required DateTime startTime,
  }) async {
    await _notificationService.showNewGigNotification(
      gigId: gigId,
      gigTitle: gigTitle,
      startTime: startTime,
    );
  }

  static Future<void> scheduleGigReminder({
    required String gigId,
    required String gigTitle,
    required DateTime startTime,
    Duration reminderBefore = const Duration(hours: 1),
  }) async {
    await _notificationService.scheduleGigReminder(
      gigId: gigId,
      gigTitle: gigTitle,
      startTime: startTime,
      reminderBefore: reminderBefore,
    );
  }

  static Future<void> showTestNotification(BuildContext context) async {
    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Test Notification',
      body: 'This is a test notification',
      payload: 'test_payload',
    );
  }
}