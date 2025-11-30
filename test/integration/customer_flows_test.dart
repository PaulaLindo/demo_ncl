// test/integration/customer_flows_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:demo_ncl/main.dart' as app;
import 'package:demo_ncl/providers/booking_provider.dart';
import 'package:demo_ncl/services/mock_data_service.dart';
import '../integration_test_setup.dart';

// Helper methods
Future<void> _loginAsCustomer(WidgetTester tester) async {
  // Use the proper test app setup that includes our login chooser
  await tester.pumpWidget(TestSetup.createTestAppWithLoginChooser());
  await tester.pumpAndSettle();
  
  // First, click Customer Login button on login chooser
  await tester.tap(find.text('Customer Login'));
  await tester.pumpAndSettle();
  
  // Now enter customer credentials on the login screen
  await tester.enterText(find.byKey(const Key('email_field')), 'customer@example.com');
  await tester.enterText(find.byKey(const Key('password_field')), 'customer123');
  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle(Duration(seconds: 3));
}

Future<void> _loginAsCustomerWithBooking(WidgetTester tester) async {
  await _loginAsCustomer(tester);
  // Mock setup for customer with existing booking
}

Future<void> _loginAsCustomerWithCompletedService(WidgetTester tester) async {
  await _loginAsCustomer(tester);
  // Mock setup for customer with completed service
}

Future<void> _navigateToServiceScope(WidgetTester tester) async {
  await _loginAsCustomer(tester);
  await tester.tap(find.text('Book Service'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Core Cleaning'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Deep Cleaning'));
  await tester.pumpAndSettle();
}

Future<void> _navigateToScheduling(WidgetTester tester) async {
  await _navigateToServiceScope(tester);
  await tester.tap(find.text('3 Bedroom'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Customer End-to-End Flows', () {
    late MockFirebaseAuth auth;
    late FakeFirebaseFirestore firestore;
    late MockDataService mockDataService;

    setUp(() {
      auth = MockFirebaseAuth();
      firestore = FakeFirebaseFirestore();
      mockDataService = MockDataService();
    });

    testWidgets('Customer Registration Flow', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Switch to customer tab
      await tester.tap(find.text('Customer'));
      await tester.pumpAndSettle();

      // Click on "Register" instead of login
      await tester.tap(find.text('New Customer? Register Here'));
      await tester.pumpAndSettle();

      // Verify registration screen
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.byKey(const Key('full_name_field')), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('phone_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('confirm_password_field')), findsOneWidget);

      // Fill registration form
      await tester.enterText(find.byKey(const Key('full_name_field')), 'John Doe');
      await tester.enterText(find.byKey(const Key('email_field')), 'john.doe@example.com');
      await tester.enterText(find.byKey(const Key('phone_field')), '+27 83 123 4567');
      await tester.enterText(find.byKey(const Key('password_field')), 'Password123!');
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'Password123!');

      // Accept terms and conditions
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Submit registration
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Verify successful registration and login
      expect(find.text('Welcome, John Doe!'), findsOneWidget);
      expect(find.text('My Bookings'), findsOneWidget);
    });

    testWidgets('Customer Step 1: Select Service Category', (WidgetTester tester) async {
      // Setup: Login as customer
      await _loginAsCustomer(tester);
      await tester.pumpAndSettle();

      // Navigate to booking
      await tester.tap(find.text('Book Service'));
      await tester.pumpAndSettle();

      // Verify service categories
      expect(find.text('Choose Service Category'), findsOneWidget);
      expect(find.text('Core Cleaning'), findsOneWidget);
      expect(find.text('Home Care Expansion'), findsOneWidget);

      // Select Core Cleaning
      await tester.tap(find.text('Core Cleaning'));
      await tester.pumpAndSettle();

      // Verify cleaning service options
      expect(find.text('Standard Cleaning'), findsOneWidget);
      expect(find.text('Deep Cleaning'), findsOneWidget);
      expect(find.text('Move-In/Out Cleaning'), findsOneWidget);
      expect(find.text('Weekly Subscription'), findsOneWidget);

      // Select Deep Cleaning
      await tester.tap(find.text('Deep Cleaning'));
      await tester.pumpAndSettle();
    });

    testWidgets('Customer Step 2: Define Scope & Get Fixed Price', (WidgetTester tester) async {
      // Setup: Customer has selected Deep Cleaning
      await _navigateToServiceScope(tester);
      await tester.pumpAndSettle();

      // Verify property size selection
      expect(find.text('Property Size'), findsOneWidget);
      expect(find.text('1 Bedroom'), findsOneWidget);
      expect(find.text('2 Bedroom'), findsOneWidget);
      expect(find.text('3 Bedroom'), findsOneWidget);
      expect(find.text('4+ Bedroom'), findsOneWidget);

      // Select 3 bedroom/2 bathroom
      await tester.tap(find.text('3 Bedroom'));
      await tester.pumpAndSettle();

      // Add high-margin options
      await tester.tap(find.text('Inside Oven (+R50)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Carpet Cleaning (+R80)'));
      await tester.pumpAndSettle();

      // Verify fixed price calculation
      expect(find.text('Base Price: R280'), findsOneWidget);
      expect(find.text('Add-ons: R130'), findsOneWidget);
      expect(find.text('Total: R410'), findsOneWidget);
      expect(find.text('Fixed Price - No Hidden Fees'), findsOneWidget);
    });

    testWidgets('Customer Step 3: Schedule & Confirm', (WidgetTester tester) async {
      // Setup: Customer has defined scope
      await _navigateToScheduling(tester);
      await tester.pumpAndSettle();

      // Verify scheduling screen
      expect(find.text('Select Date & Time'), findsOneWidget);
      expect(find.byType(TableCalendar), findsOneWidget);

      // Select tomorrow
      await tester.tap(find.text('Tomorrow'));
      await tester.pumpAndSettle();

      // Select time slot
      await tester.tap(find.text('9:00 AM - 1:00 PM'));
      await tester.pumpAndSettle();

      // Proceed to payment
      await tester.tap(find.text('Continue to Payment'));
      await tester.pumpAndSettle();

      // Verify payment screen
      expect(find.text('Payment Details'), findsOneWidget);
      expect(find.text('Total Amount: R410'), findsOneWidget);

      // Enter payment details
      await tester.enterText(find.byKey(const Key('card_number_field')), '4111111111111111');
      await tester.enterText(find.byKey(const Key('card_holder_field')), 'John Doe');
      await tester.enterText(find.byKey(const Key('expiry_field')), '12/25');
      await tester.enterText(find.byKey(const Key('cvv_field')), '123');

      // Confirm booking
      await tester.tap(find.text('Confirm Booking'));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Verify booking confirmation
      expect(find.text('Booking Confirmed!'), findsOneWidget);
      expect(find.text('R410'), findsOneWidget);
      expect(find.text('Tomorrow, 9:00 AM'), findsOneWidget);
      expect(find.text('Deep Cleaning - 3 Bed/2 Bath'), findsOneWidget);
    });

    testWidgets('Customer Step 4: Staff Vetting Transparency', (WidgetTester tester) async {
      // Setup: Customer has confirmed booking
      await _loginAsCustomerWithBooking(tester);
      await tester.pumpAndSettle();

      // Navigate to booking details
      await tester.tap(find.text('My Bookings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deep Cleaning'));
      await tester.pumpAndSettle();

      // Verify staff profile information
      expect(find.text('Assigned Staff'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('Accredited & Hotel-Trained'), findsOneWidget);
      expect(find.text('⭐ 4.8 Rating'), findsOneWidget);
      expect(find.text('2+ Years Experience'), findsOneWidget);
      expect(find.text('Specialized in Deep Cleaning'), findsOneWidget);

      // Verify staff photo and badge
      expect(find.byKey(const Key('staff_photo')), findsOneWidget);
      expect(find.byKey(const Key('hotel_trained_badge')), findsOneWidget);
    });

    testWidgets('Customer Step 5: Post-Service Experience', (WidgetTester tester) async {
      // Setup: Service has been completed
      await _loginAsCustomerWithCompletedService(tester);
      await tester.pumpAndSettle();

      // Navigate to completed booking
      await tester.tap(find.text('My Bookings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deep Cleaning'));
      await tester.pumpAndSettle();

      // Verify rating prompt
      expect(find.text('Rate Your Service'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsAtLeastNWidgets(1));

      // Give 5-star rating
      await tester.tap(find.byIcon(Icons.star));
      await tester.tap(find.byIcon(Icons.star));
      await tester.tap(find.byIcon(Icons.star));
      await tester.tap(find.byIcon(Icons.star));
      await tester.tap(find.byIcon(Icons.star));
      await tester.pumpAndSettle();

      // Add comment
      await tester.enterText(find.byKey(const Key('rating_comment')), 'Excellent service! Very thorough and professional.');
      await tester.pumpAndSettle();

      // Submit rating
      await tester.tap(find.text('Submit Rating'));
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Verify rating submitted and wellness gift notification
      expect(find.text('Thank you for your feedback!'), findsOneWidget);
      expect(find.text('Your Wellness Gift'), findsOneWidget);
      expect(find.text('Eco-friendly cleaning products delivered to your door'), findsOneWidget);
      expect(find.text('Expected delivery: 3-5 business days'), findsOneWidget);
    });

    testWidgets('Customer Subscription Flow', (WidgetTester tester) async {
      // Setup: Customer selects weekly subscription
      await _loginAsCustomer(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Book Service'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Core Cleaning'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Weekly Subscription'));
      await tester.pumpAndSettle();

      // Verify subscription benefits
      expect(find.text('Weekly Subscription Benefits'), findsOneWidget);
      expect(find.text('Save 15% vs one-time bookings'), findsOneWidget);
      expect(find.text('Same staff member every week'), findsOneWidget);
      expect(find.text('Priority scheduling'), findsOneWidget);

      // Select property size
      await tester.tap(find.text('3 Bedroom'));
      await tester.pumpAndSettle();

      // Verify subscription pricing
      expect(find.text('Weekly Price: R238'), findsOneWidget);
      expect(find.text('Regular Price: R280'), findsOneWidget);
      expect(find.text('You save: R42 per week'), findsOneWidget);

      // Start subscription
      await tester.tap(find.text('Start Subscription'));
      await tester.pumpAndSettle();

      // Schedule first service
      await tester.tap(find.text('Schedule First Service'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next Monday'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('9:00 AM'));
      await tester.pumpAndSettle();

      // Confirm subscription
      await tester.tap(find.text('Confirm Subscription'));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Verify subscription active
      expect(find.text('Subscription Active!'), findsOneWidget);
      expect(find.text('Every Monday at 9:00 AM'), findsOneWidget);
      expect(find.text('Next service: Next Monday'), findsOneWidget);
      expect(find.text('Manage Subscription'), findsOneWidget);
    });
  });
}
