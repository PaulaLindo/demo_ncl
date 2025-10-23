// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final bool isStaffLogin;

  const LoginScreen({super.key, required this.isStaffLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _secretController = TextEditingController();
  
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.isStaffLogin 
                    ? AppTheme.secondaryColor.withOpacity(0.1)
                    : AppTheme.primaryPurple.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              // App Bar
              _buildAppBar(context),
              
              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Header
                      _buildHeader(context),
                      
                      const SizedBox(height: 40),
                      
                      // Login Form
                      _buildLoginForm(context),
                      
                      const SizedBox(height: 24),
                      
                      // Demo Credentials
                      if (!widget.isStaffLogin)
                        _buildDemoCredentials(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/'),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 2,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.isStaffLogin ? 'Staff Login' : 'Customer Login',
              style: context.textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isStaffLogin
                  ? [AppTheme.secondaryColor, AppTheme.secondaryColor.withOpacity(0.8)]
                  : [AppTheme.primaryPurple, AppTheme.primaryPurple.withOpacity(0.8)],
            ),
            shape: BoxShape.circle,
            boxShadow: AppTheme.cardShadow,
          ),
          child: Icon(
            widget.isStaffLogin ? Icons.badge_rounded : Icons.person_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          widget.isStaffLogin ? 'Staff Portal' : 'Welcome Back',
          style: context.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.isStaffLogin 
              ? 'Access your schedule and jobs'
              : 'Sign in to manage your bookings',
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textGrey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Identifier Field
            TextFormField(
              controller: _identifierController,
              keyboardType: widget.isStaffLogin 
                  ? TextInputType.text 
                  : TextInputType.emailAddress,
              textCapitalization: widget.isStaffLogin
                  ? TextCapitalization.none
                  : TextCapitalization.none,
              decoration: InputDecoration(
                labelText: widget.isStaffLogin ? 'Staff ID' : 'Email',
                hintText: widget.isStaffLogin ? 'Enter your staff ID' : 'you@example.com',
                prefixIcon: Icon(
                  widget.isStaffLogin ? Icons.badge : Icons.email_outlined,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return widget.isStaffLogin 
                      ? 'Please enter your staff ID'
                      : 'Please enter your email';
                }
                if (!widget.isStaffLogin && !AuthService.isValidEmail(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            
            const SizedBox(height: 20),
            
            // Secret Field
            TextFormField(
              controller: _secretController,
              obscureText: _obscureText,
              keyboardType: widget.isStaffLogin 
                  ? TextInputType.number 
                  : TextInputType.visiblePassword,
              inputFormatters: widget.isStaffLogin
                  ? [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ]
                  : null,
              decoration: InputDecoration(
                labelText: widget.isStaffLogin ? 'PIN' : 'Password',
                hintText: widget.isStaffLogin ? '4-digit PIN' : 'Enter your password',
                prefixIcon: Icon(
                  widget.isStaffLogin ? Icons.pin : Icons.lock_outline,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() => _obscureText = !_obscureText);
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return widget.isStaffLogin 
                      ? 'Please enter your PIN'
                      : 'Please enter your password';
                }
                if (widget.isStaffLogin && !AuthService.isValidPin(value)) {
                  return 'PIN must be 4 digits';
                }
                if (!widget.isStaffLogin && value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            
            const SizedBox(height: 12),
            
            // Error Message
            if (authProvider.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.redStatus.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.redStatus.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppTheme.redStatus,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        authProvider.errorMessage!,
                        style: TextStyle(
                          color: AppTheme.redStatus,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Login Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isStaffLogin 
                    ? AppTheme.secondaryColor 
                    : AppTheme.primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sign In'),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
            
            // Forgot Password
            if (!widget.isStaffLogin) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset coming soon!'),
                    ),
                  );
                },
                child: const Text('Forgot password?'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCredentials(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.infoBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.infoBlue.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.infoBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Demo Credentials',
                style: context.textTheme.labelLarge?.copyWith(
                  color: AppTheme.infoBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Email: user@example.com\nPassword: password',
            style: context.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    // Clear previous errors
    context.read<AuthProvider>().clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      identifier: _identifierController.text.trim(),
      secret: _secretController.text.trim(),
      isStaffAttempt: widget.isStaffLogin,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        // Navigation is handled by GoRouter redirect
        if (widget.isStaffLogin) {
          context.go('/staff/home');
        } else {
          context.go('/customer/home');
        }
      }
    }
  }
}