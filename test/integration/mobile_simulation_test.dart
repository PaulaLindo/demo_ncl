// test/integration/mobile_simulation_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/services/mock_data_service.dart';

void main() {
  group('Mobile Authentication Simulation Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    testWidgets('should simulate mobile customer login experience', (WidgetTester tester) async {
      // Create a simple mobile-like test app
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: const MobileLoginTestApp(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show mobile login screen
      expect(find.text('Mobile Login Test'), findsOneWidget);
      expect(find.text('Customer Login'), findsOneWidget);
      expect(find.text('Staff Login'), findsOneWidget);
      expect(find.text('Admin Login'), findsOneWidget);

      // Test customer login
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Should show login form
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);

      // Fill in credentials
      await tester.enterText(find.byType(TextField).first, 'customer@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'customer123');

      // Submit login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show success
      expect(find.text('Login Successful!'), findsOneWidget);
      expect(find.text('Welcome, customer@example.com!'), findsOneWidget);
    });

    testWidgets('should simulate mobile staff login experience', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: const MobileLoginTestApp(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test staff login
      await tester.tap(find.text('Staff Login'));
      await tester.pumpAndSettle();

      // Fill in credentials
      await tester.enterText(find.byType(TextField).first, 'staff@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'staff123');

      // Submit login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show success
      expect(find.text('Login Successful!'), findsOneWidget);
      expect(find.text('Welcome, staff@example.com!'), findsOneWidget);
    });

    testWidgets('should simulate mobile admin login experience', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: const MobileLoginTestApp(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test admin login
      await tester.tap(find.text('Admin Login'));
      await tester.pumpAndSettle();

      // Fill in credentials
      await tester.enterText(find.byType(TextField).first, 'admin@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'admin123');

      // Submit login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show success
      expect(find.text('Login Successful!'), findsOneWidget);
      expect(find.text('Welcome, admin@example.com!'), findsOneWidget);
    });

    testWidgets('should handle mobile login validation', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: const MobileLoginTestApp(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test customer login with empty fields
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Try to login without filling fields
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter email'), findsOneWidget);
      expect(find.text('Please enter password'), findsOneWidget);

      // Test with invalid email
      await tester.enterText(find.byType(TextField).first, 'invalid-email');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);

      // Test with short password
      await tester.enterText(find.byType(TextField).first, 'customer@example.com');
      await tester.enterText(find.byType(TextField).at(1), '123');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('should handle mobile login errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: authProvider,
          child: MaterialApp(
            home: const MobileLoginTestApp(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test customer login with wrong password
      await tester.tap(find.text('Customer Login'));
      await tester.pumpAndSettle();

      // Fill in wrong credentials
      await tester.enterText(find.byType(TextField).first, 'customer@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');

      // Submit login
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show error
      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}

// Simple mobile test app that simulates the login experience
class MobileLoginTestApp extends StatefulWidget {
  const MobileLoginTestApp({super.key});

  @override
  State<MobileLoginTestApp> createState() => _MobileLoginTestAppState();
}

class _MobileLoginTestAppState extends State<MobileLoginTestApp> {
  String _selectedRole = '';
  bool _showLoginForm = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Login Test'),
      ),
      body: _showLoginForm ? _buildLoginForm() : _buildRoleSelection(),
    );
  }

  Widget _buildRoleSelection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone_android, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'Choose Login Type',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _selectRole('customer'),
            child: const Text('Customer Login'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _selectRole('staff'),
            child: const Text('Staff Login'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _selectRole('admin'),
            child: const Text('Admin Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_selectedRole.capitalize()} Login',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              if (authProvider.errorMessage != null)
                Text(
                  authProvider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _goBack,
                child: const Text('Back'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      _showLoginForm = true;
      _errorMessage = null;
    });
  }

  void _goBack() {
    setState(() {
      _showLoginForm = false;
      _selectedRole = '';
      _emailController.clear();
      _passwordController.clear();
      _errorMessage = null;
    });
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Basic validation
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter email');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter password');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();
    
    try {
      final success = await authProvider.login(email: email, password: password);
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        if (success) {
          _showSuccessDialog();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Successful!'),
        content: Text('Welcome, ${context.read<AuthProvider>().currentUser?.email}!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _goBack();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
