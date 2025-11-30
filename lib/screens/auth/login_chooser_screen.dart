// lib/screens/auth/login_chooser_screen.dart - Login Chooser
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/theme_provider.dart';

class LoginChooserScreen extends StatelessWidget {
  const LoginChooserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Theme Switcher Button
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () {
              context.push('/theme-settings');
            },
            tooltip: 'Theme Settings',
            style: IconButton.styleFrom(
              backgroundColor: context.watch<ThemeProvider>().cardColor,
              foregroundColor: context.watch<ThemeProvider>().primaryColor,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.watch<ThemeProvider>().primaryColor.withOpacity(0.05),
              context.watch<ThemeProvider>().backgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(context),
                  const SizedBox(height: 40),
                  _buildWelcomeText(context),
                  const SizedBox(height: 40),
                  _buildRoleButtons(context),
                  const SizedBox(height: 24),
                  _buildHelpButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SvgPicture.asset(
        'assets/images/comprehensive_home_services.svg',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      children: [
        Text(
          'Welcome to NCL',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.watch<ThemeProvider>().textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Professional Home Services',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your role to continue',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.watch<ThemeProvider>().textColor.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleButtons(BuildContext context) {
    return Column(
      children: [
        _buildRoleButton(
          context,
          'Customer',
          'Book and manage home services',
          Icons.person,
          () => context.push('/login/customer'),
        ),
        const SizedBox(height: 16),
        _buildRoleButton(
          context,
          'Staff',
          'Provide services and manage gigs',
          Icons.work,
          () => context.push('/login/staff'),
        ),
        const SizedBox(height: 16),
        _buildRoleButton(
          context,
          'Admin',
          'Manage the entire platform',
          Icons.admin_panel_settings,
          () => context.push('/login/admin'),
        ),
      ],
    );
  }

  Widget _buildRoleButton(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: context.watch<ThemeProvider>().primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.watch<ThemeProvider>().textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: context.watch<ThemeProvider>().primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        // TODO: Navigate to help or support
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Help & Support coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Text(
        'Need Help?',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: context.watch<ThemeProvider>().primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
