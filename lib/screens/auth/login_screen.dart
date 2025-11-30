// lib/screens/auth/login_screen.dart - Login Screen
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  final String userRole; // 'customer', 'staff', 'admin'

  const LoginScreen({super.key, required this.userRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        title: Text('${widget.userRole[0].toUpperCase()}${widget.userRole.substring(1)} Login'),
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              _buildHeader(context),
              const SizedBox(height: 40),
              _buildLoginForm(context),
              const SizedBox(height: 16),
              if (widget.userRole == 'customer') _buildCustomerLinks(context),
              const SizedBox(height: 24),
              _buildDemoCredentials(context),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildHeader(BuildContext context) {
    IconData icon;
    String title;
    String subtitle;
    Color themeColor;

    switch (widget.userRole) {
      case 'staff':
        icon = Icons.badge_rounded;
        title = 'Staff Portal';
        subtitle = 'Access your dashboard and manage gigs';
        themeColor = context.watch<ThemeProvider>().primaryColor;
        break;
      case 'admin':
        icon = Icons.admin_panel_settings;
        title = 'Admin Portal';
        subtitle = 'Manage the entire platform';
        themeColor = context.watch<ThemeProvider>().primaryColor;
        break;
      case 'customer':
      default:
        icon = Icons.person;
        title = 'Customer Portal';
        subtitle = 'Book and manage home services';
        themeColor = context.watch<ThemeProvider>().primaryColor;
        break;
    }

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: themeColor.withOpacity(0.3), width: 2),
          ),
          child: Icon(icon, size: 40, color: themeColor),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.watch<ThemeProvider>().textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Card(
      elevation: 4,
      color: context.watch<ThemeProvider>().cardColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Field
              TextFormField(
                key: Key('email_field'),
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined, color: context.watch<ThemeProvider>().primaryColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: context.watch<ThemeProvider>().primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: context.watch<ThemeProvider>().primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Email is required';
                  if (!value.contains('@')) return 'Please enter a valid email';
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Password Field
              TextFormField(
                key: Key('password_field'),
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock_outline, color: context.watch<ThemeProvider>().primaryColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: context.watch<ThemeProvider>().primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: context.watch<ThemeProvider>().primaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Password is required';
                  if (value.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Login Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return ElevatedButton(
                    key: Key('login_button'),
                    onPressed: _isLoading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        print('🔄 Login submitted for ${widget.userRole}');
                        setState(() => _isLoading = true);
                        
                        try {
                          print('🔄 Calling AuthProvider.login()...');
                          final success = await authProvider.login(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );
                          print('🔄 AuthProvider.login() returned: $success');
                          
                          if (success) {
                            print('🔄 Login successful, navigating to /${widget.userRole}/home');
                            // Navigate to the appropriate home page
                            if (mounted) {
                              context.go('/${widget.userRole}/home');
                            }
                          } else {
                            print('🔄 Login failed, showing error message');
                            // Show error message
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(authProvider.errorMessage ?? 'Login failed'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } catch (error) {
                          print('🔄 Login error: $error');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Login error: ${error.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.watch<ThemeProvider>().primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCredentials(BuildContext context) {
    final credentials = _getDemoCredentials();
    
    return Card(
      elevation: 2,
      color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: context.watch<ThemeProvider>().primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Demo Credentials',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.watch<ThemeProvider>().primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Email credential
            GestureDetector(
              onTap: () {
                _emailController.text = credentials['email']!;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email filled!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      credentials['email']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Password credential
            GestureDetector(
              onTap: () {
                _passwordController.text = credentials['password']!;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password filled!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      credentials['password']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Tap on credentials to copy',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerLinks(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () => context.go('/forgot-password'),
          style: TextButton.styleFrom(
            foregroundColor: context.watch<ThemeProvider>().primaryColor,
          ),
          child: const Text(
            'Forgot Password?',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        TextButton(
          onPressed: () => context.go('/register/customer'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
          ),
          child: RichText(
            text: TextSpan(
              text: "New to NCL? ",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: 'Create Account',
                  style: TextStyle(
                    color: context.watch<ThemeProvider>().primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Map<String, String> _getDemoCredentials() {
    switch (widget.userRole) {
      case 'staff':
        return {
          'email': 'staff@example.com',
          'password': 'staff123',
        };
      case 'admin':
        return {
          'email': 'admin@example.com',
          'password': 'admin123',
        };
      case 'customer':
      default:
        return {
          'email': 'customer@example.com',
          'password': 'customer123',
        };
    }
  }
}
