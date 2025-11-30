// lib/services/notification_service_stub.dart
// Simplified stub for integration testing
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import 'package:rxdart/rxdart.dart';

class NotificationService {
    static final NotificationService _instance = NotificationService._internal();
    final BehaviorSubject<String> _onNotificationClick = BehaviorSubject<String>();

    factory NotificationService() {
        return _instance;
    }

    NotificationService._internal();

    Stream<String> get onNotificationClick => _onNotificationClick.stream;

    Future<void> initialize() async {
        // Stub implementation - does nothing
        print('🔕 NotificationService: Initialize (stub)');
    }

    Future<void> requestPermissions() async {
        // Stub implementation - does nothing
        print('🔕 NotificationService: Request permissions (stub)');
    }

    Future<void> showNotification({
        required int id,
        required String title,
        required String body,
        String? payload,
        String? channelId,
        String? channelName,
        String? channelDescription,
    }) async {
        // Stub implementation - just prints
        print('🔕 NotificationService: Show notification - $title: $body');
    }

    Future<void> scheduleNotification({
        required int id,
        required String title,
        required String body,
        required DateTime scheduledDate,
        String? payload,
        String? channelId,
        String? channelName,
        String? channelDescription,
    }) async {
        // Stub implementation - just prints
        print('🔕 NotificationService: Schedule notification - $title at $scheduledDate');
    }

    Future<void> cancelNotification(int id) async {
        print('🔕 NotificationService: Cancel notification $id');
    }

    Future<void> cancelAllNotifications() async {
        print('🔕 NotificationService: Cancel all notifications');
    }

    // Specific notification methods for the app
    Future<void> showNewGigNotification({
        required String gigId,
        required String gigTitle,
        required DateTime startTime,
    }) async {
        await showNotification(
            id: 'new_gig_${DateTime.now().millisecondsSinceEpoch}'.hashCode,
            title: 'New Gig Assigned',
            body: 'You have been assigned to: $gigTitle',
            payload: gigId,
            channelId: 'gig_updates',
            channelName: 'Gig Updates',
        );
    }

    Future<void> scheduleGigReminder({
        required String gigId,
        required String gigTitle,
        required DateTime startTime,
        Duration reminderBefore = const Duration(hours: 1),
    }) async {
        final reminderTime = startTime.subtract(reminderBefore);
        
        if (reminderTime.isAfter(DateTime.now())) {
            await scheduleNotification(
                id: 'reminder_${gigId.hashCode}'.hashCode.hashCode,
                title: 'Upcoming Gig',
                body: 'Your gig "$gigTitle" starts soon',
                scheduledDate: reminderTime,
                payload: gigId,
                channelId: 'gig_reminders',
                channelName: 'Gig Reminders',
            );
        }
    }

    Future<void> showShiftSwapRequest({
        required String requestId,
        required String gigTitle,
        required String fromUser,
    }) async {
        await showNotification(
            id: 'swap_request_${DateTime.now().millisecondsSinceEpoch}'.hashCode,
            title: 'Shift Swap Request',
            body: '$fromUser requested to swap shifts for: $gigTitle',
            payload: 'swap_$requestId',
            channelId: 'shift_swaps',
            channelName: 'Shift Swaps',
        );
    }

    void handleNotificationTap(String? payload, BuildContext context) {
        if (payload == null) return;

        print('🔕 NotificationService: Handle tap - $payload');
        
        if (payload.startsWith('shift_swap_')) {
            if (context.mounted) {
                Navigator.pushNamed(context, AppRoutes.staffShiftSwapInbox);
            }
        } else if (payload.startsWith('gig_')) {
            final gigId = payload.replaceFirst('gig_', '');
            Navigator.pushNamed(context, AppRoutes.gigDetailsById(gigId));
        }
    }

    // Helper methods
    String _formatDate(DateTime date) {
        return '${date.day}/${date.month}/${date.year}';
    }

    String _formatTime(DateTime time) {
        return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }

    String _formatDuration(Duration duration) {
        if (duration.inHours > 0) {
            return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
        } else if (duration.inMinutes > 0) {
            return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
        } else {
            return 'a few moments';
        }
    }
}
