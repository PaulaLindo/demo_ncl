// test/integration_test_setup.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Test setup helper for integration tests
class TestSetup {
  static Widget createTestApp() {
    // Create a minimal version of the app for testing
    return MaterialApp(
      title: 'NCL Test',
      home: const TestLoginScreen(),
      routes: {
        '/register': (context) => const TestRegistrationScreen(),
        '/customer': (context) => const TestCustomerDashboard(),
        '/staff': (context) => const TestStaffDashboard(),
        '/admin': (context) => const TestAdminDashboard(),
      },
    );
  }

  static Widget createTestAppWithLoginChooser() {
    // Create test app with the actual login chooser
    return MaterialApp(
      title: 'NCL Test',
      home: const TestLoginChooserScreen(),
      routes: {
        '/login/customer': (context) => const TestLoginScreen(userRole: 'customer'),
        '/login/staff': (context) => const TestLoginScreen(userRole: 'staff'),
        '/login/admin': (context) => const TestLoginScreen(userRole: 'admin'),
        '/customer': (context) => const TestCustomerDashboard(),
        '/staff': (context) => const TestStaffDashboard(),
        '/admin': (context) => const TestAdminDashboard(),
      },
    );
  }
}

class TestLoginChooserScreen extends StatelessWidget {
  const TestLoginChooserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NCL Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to NCL', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('customer_login_button'),
              onPressed: () => Navigator.pushNamed(context, '/login/customer'),
              child: const Text('Customer Login'),
            ),
            ElevatedButton(
              key: const Key('staff_login_button'),
              onPressed: () => Navigator.pushNamed(context, '/login/staff'),
              child: const Text('Staff Access'),
            ),
            ElevatedButton(
              key: const Key('admin_login_button'),
              onPressed: () => Navigator.pushNamed(context, '/login/admin'),
              child: const Text('Admin Portal'),
            ),
          ],
        ),
      ),
    );
  }
}

class TestLoginScreen extends StatelessWidget {
  const TestLoginScreen({super.key, this.userRole = 'customer'});
  final String userRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NCL Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${userRole[0].toUpperCase() + userRole.substring(1)} Login', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            TextField(
              key: const Key('email_field'),
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              key: const Key('password_field'),
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('login_button'),
              onPressed: () {
                // Navigate to appropriate dashboard based on role
                Navigator.pushReplacementNamed(context, '/$userRole');
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class TestRegistrationScreen extends StatelessWidget {
  const TestRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Registration')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Create Account', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            TextField(
              key: Key('full_name_field'),
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              key: Key('email_field'),
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              key: Key('phone_field'),
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              key: Key('password_field'),
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              key: Key('confirm_password_field'),
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            Checkbox(
              key: const Key('terms_checkbox'),
              value: false,
              onChanged: null,
            ),
            Text('I agree to Terms & Conditions'),
            SizedBox(height: 20),
            ElevatedButton(
              key: Key('submit_registration'),
              child: Text('Create Account'),
              onPressed: null, // Will be implemented in test
            ),
          ],
        ),
      ),
    );
  }
}

class TestCustomerDashboard extends StatelessWidget {
  const TestCustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome Customer!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('book_service_button'),
              onPressed: () {},
              child: const Text('Book Service'),
            ),
            ElevatedButton(
              key: const Key('my_bookings_button'),
              onPressed: () {},
              child: const Text('My Bookings'),
            ),
            ElevatedButton(
              key: const Key('profile_button'),
              onPressed: () {},
              child: const Text('Profile'),
            ),
            ElevatedButton(
              key: const Key('subscription_button'),
              onPressed: () {},
              child: const Text('Subscription'),
            ),
            const SizedBox(height: 20),
            const Text('Core Cleaning'),
            const SizedBox(height: 10),
            const Text('Deep Cleaning'),
            const SizedBox(height: 10),
            const Text('Post-Construction'),
          ],
        ),
      ),
    );
  }
}

class TestStaffDashboard extends StatelessWidget {
  const TestStaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome Staff!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('my_schedule_button'),
              onPressed: () {},
              child: const Text('My Schedule'),
            ),
            ElevatedButton(
              key: const Key('timekeeping_button'),
              onPressed: () {},
              child: const Text('Timekeeping'),
            ),
            ElevatedButton(
              key: const Key('availability_button'),
              onPressed: () {},
              child: const Text('Availability'),
            ),
            ElevatedButton(
              key: const Key('job_offers_button'),
              onPressed: () {},
              child: const Text('Job Offers'),
            ),
            const SizedBox(height: 20),
            const Text('Available Shifts'),
            const SizedBox(height: 10),
            const Text('Transport Request'),
            const SizedBox(height: 10),
            const Text('Clock In/Clock Out'),
          ],
        ),
      ),
    );
  }
}

class TestAdminDashboard extends StatelessWidget {
  const TestAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome Admin!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              key: const Key('partner_management_button'),
              onPressed: () {},
              child: const Text('Partner Management'),
            ),
            ElevatedButton(
              key: const Key('quality_management_button'),
              onPressed: () {},
              child: const Text('Quality Management'),
            ),
            ElevatedButton(
              key: const Key('staff_performance_button'),
              onPressed: () {},
              child: const Text('Staff Performance'),
            ),
            ElevatedButton(
              key: const Key('b2b_sales_button'),
              onPressed: () {},
              child: const Text('B2B Sales'),
            ),
            ElevatedButton(
              key: const Key('temp_card_button'),
              onPressed: () {},
              child: const Text('Temp Card Management'),
            ),
            const SizedBox(height: 20),
            const Text('User Management'),
            const SizedBox(height: 10),
            const Text('Booking Management'),
            const SizedBox(height: 10),
            const Text('Reports'),
          ],
        ),
      ),
    );
  }
}
