// TODO: Add firebase_analytics to pubspec.yaml
// import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  // static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static void logScreenView(String screenName) {
    // _analytics.logScreenView(screenName: screenName);
    print('Screen viewed: $screenName');
  }

  static void logBookingCreated(String serviceId, double amount) {
    // _analytics.logEvent(
    //   name: 'booking_created',
    //   parameters: {
    //     'service_id': serviceId,
    //     'amount': amount,
    //   },
    // );
    print('Booking created: $serviceId - R$amount');
  }

  static void logServiceViewed(String serviceId) {
    // _analytics.logEvent(
    //   name: 'service_viewed',
    //   parameters: {'service_id': serviceId},
    // );
  }

  static void logSearchPerformed(String query) {
    // _analytics.logSearch(searchTerm: query);
  }
}