// TODO: Add firebase_messaging to pubspec.yaml
// import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  // static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permission
    // await _firebaseMessaging.requestPermission();

    // Get FCM token
    // String? token = await _firebaseMessaging.getToken();
    // print('FCM Token: $token');

    // Handle foreground messages
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   _handleMessage(message);
    // });
  }

  static void _handleMessage(dynamic message) {
    // Show local notification
    print('Notification received: ${message.notification?.title}');
  }

  static Future<void> subscribeToTopic(String topic) async {
    // await _firebaseMessaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    // await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}