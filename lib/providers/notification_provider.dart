// lib/providers/notification_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  static final NotificationProvider _instance = NotificationProvider._internal();
  factory NotificationProvider() => _instance;
  NotificationProvider._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  // Getters
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  // Initialize notifications
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();

      // Load existing notifications
      await _loadNotifications();

      _setLoading(false);
    } catch (e) {
      _setError('Failed to initialize notifications: $e');
      _setLoading(false);
    }
  }

  // Request notification permissions
  Future<bool> _requestPermissions() async {
    try {
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestPermission();
        return granted ?? false;
      }

      final iosPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return true;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  // Load existing notifications
  Future<void> _loadNotifications() async {
    try {
      // In a real app, this would load from local storage or backend
      // For now, we'll start with empty notifications
      _notifications = [];
      _updateUnreadCount();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load notifications: $e');
    }
  }

  // Add a new notification
  Future<void> addNotification(AppNotification notification) async {
    try {
      // Add to list
      _notifications.insert(0, notification);
      _updateUnreadCount();

      // Show local notification
      await _showLocalNotification(notification);

      // Save to storage (in real app)
      await _saveNotifications();

      notifyListeners();
    } catch (e) {
      _setError('Failed to add notification: $e');
    }
  }

  // Show local notification
  Future<void> _showLocalNotification(AppNotification notification) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'cleaning_service_channel',
        'Cleaning Service',
        channelDescription: 'Notifications for cleaning service bookings and updates',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _localNotifications.show(
        notification.id.hashCode,
        notification.title,
        notification.body,
        details,
        payload: notification.id,
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].markAsRead();
        _updateUnreadCount();
        await _saveNotifications();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      _notifications = _notifications.map((n) => n.markAsRead()).toList();
      _updateUnreadCount();
      await _saveNotifications();
      notifyListeners();
    } catch (e) {
      _setError('Failed to mark all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
      await _saveNotifications();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete notification: $e');
    }
  }

  // Clear all notifications
  Future<void> clearAllNotifications() async {
    try {
      _notifications.clear();
      _updateUnreadCount();
      await _saveNotifications();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear notifications: $e');
    }
  }

  // Get unread notifications
  List<AppNotification> get unreadNotifications => 
      _notifications.where((n) => !n.isRead && !n.isExpired).toList();

  // Get recent notifications (within 24 hours)
  List<AppNotification> get recentNotifications => 
      _notifications.where((n) => n.isRecent && !n.isExpired).toList();

  // Get notifications by type
  List<AppNotification> getNotificationsByType(NotificationType type) =>
      _notifications.where((n) => n.type == type && !n.isExpired).toList();

  // Schedule a booking reminder
  Future<void> scheduleBookingReminder({
    required String bookingId,
    required String serviceName,
    required DateTime bookingDate,
    required int hoursBefore,
  }) async {
    try {
      final reminderTime = bookingDate.subtract(Duration(hours: hoursBefore));
      final now = DateTime.now();

      // Only schedule if reminder time is in the future
      if (reminderTime.isAfter(now)) {
        final notification = AppNotification.bookingReminder(
          bookingId: bookingId,
          serviceName: serviceName,
          bookingDate: bookingDate,
          hoursBefore: hoursBefore,
        );

        await _scheduleLocalNotification(notification, reminderTime);
      }
    } catch (e) {
      _setError('Failed to schedule booking reminder: $e');
    }
  }

  // Schedule a local notification
  Future<void> _scheduleLocalNotification(AppNotification notification, DateTime scheduledTime) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'cleaning_service_channel',
        'Cleaning Service',
        channelDescription: 'Notifications for cleaning service bookings and updates',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _localNotifications.zonedSchedule(
        notification.id.hashCode,
        notification.title,
        notification.body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: notification.id,
      );
    } catch (e) {
      debugPrint('Error scheduling local notification: $e');
    }
  }

  // Cancel scheduled notification
  Future<void> cancelNotification(String notificationId) async {
    try {
      await _localNotifications.cancel(notificationId.hashCode);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final notificationId = response.payload;
    if (notificationId != null) {
      // Mark as read
      markAsRead(notificationId);
      
      // Handle navigation based on notification type
      final notification = _notifications.firstWhere(
        (n) => n.id == notificationId,
        orElse: () => AppNotification.system(
          title: 'Notification',
          body: 'Notification details',
        ),
      );

      _handleNotificationAction(notification);
    }
  }

  // Handle notification action
  void _handleNotificationAction(AppNotification notification) {
    // In a real app, this would navigate to the appropriate screen
    debugPrint('Notification tapped: ${notification.title}');
    debugPrint('Action URL: ${notification.actionUrl}');
    
    // You could use a navigation service here
    // NavigationService.navigateTo(notification.actionUrl);
  }

  // Update unread count
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead && !n.isExpired).length;
  }

  // Save notifications to storage
  Future<void> _saveNotifications() async {
    try {
      // In a real app, this would save to SharedPreferences or a database
      // For now, we'll just debug print
      debugPrint('Saving ${_notifications.length} notifications');
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  // Clean up expired notifications
  Future<void> cleanupExpiredNotifications() async {
    try {
      final beforeCount = _notifications.length;
      _notifications.removeWhere((n) => n.isExpired);
      _updateUnreadCount();
      
      if (_notifications.length < beforeCount) {
        await _saveNotifications();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to cleanup expired notifications: $e');
    }
  }

  // Get notification statistics
  Map<String, int> getNotificationStats() {
    final stats = <String, int>{};
    
    for (final type in NotificationType.values) {
      stats[type.value] = getNotificationsByType(type).length;
    }
    
    stats['total'] = _notifications.length;
    stats['unread'] = _unreadCount;
    stats['expired'] = _notifications.where((n) => n.isExpired).length;
    
    return stats;
  }

  // Loading and error management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    debugPrint('NotificationProvider Error: $error');
    notifyListeners();
  }

  // Reset provider
  void reset() {
    _notifications.clear();
    _unreadCount = 0;
    _error = null;
    notifyListeners();
  }
}
