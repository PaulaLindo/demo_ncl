// lib/screens/customer/customer_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/theme_manager.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.push('/customer/home');
          },
        ),
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.push('/');
            },
            tooltip: 'Back to Login',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.1),
                    context.watch<ThemeProvider>().secondaryColor.withCustomOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.2)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: context.watch<ThemeProvider>().primaryColor,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Test Customer',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: context.watch<ThemeProvider>().primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'customer@test.com',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Active',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Profile Information
            Text(
              'Profile Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: context.watch<ThemeProvider>().textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileItem(
                      context,
                      'Full Name',
                      'Test Customer',
                      Icons.person,
                    ),
                    const Divider(),
                    _buildProfileItem(
                      context,
                      'Email',
                      'customer@test.com',
                      Icons.email,
                    ),
                    const Divider(),
                    _buildProfileItem(
                      context,
                      'Phone',
                      '+1 234 567 8900',
                      Icons.phone,
                    ),
                    const Divider(),
                    _buildProfileItem(
                      context,
                      'Address',
                      '123 Main St, City, State',
                      Icons.location_on,
                    ),
                    const Divider(),
                    _buildProfileItem(
                      context,
                      'Member Since',
                      'November 2024',
                      Icons.calendar_today,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Preferences
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: context.watch<ThemeProvider>().textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPreferenceItem(
                      context,
                      'Email Notifications',
                      true,
                      Icons.email,
                    ),
                    const Divider(),
                    _buildPreferenceItem(
                      context,
                      'SMS Notifications',
                      false,
                      Icons.sms,
                    ),
                    const Divider(),
                    _buildPreferenceItem(
                      context,
                      'Marketing Communications',
                      false,
                      Icons.campaign,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Actions
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: context.watch<ThemeProvider>().textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.edit, color: context.colors.primary),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Edit profile feature coming soon!'),
                          backgroundColor: context.watch<ThemeProvider>().primaryColor,
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.lock, color: context.colors.primary),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Change password feature coming soon!'),
                          backgroundColor: context.watch<ThemeProvider>().primaryColor,
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.history, color: context.colors.primary),
                    title: const Text('Service History'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Service history feature coming soon!'),
                          backgroundColor: context.watch<ThemeProvider>().primaryColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: context.watch<ThemeProvider>().primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.watch<ThemeProvider>().textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem(BuildContext context, String label, bool isEnabled, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: context.watch<ThemeProvider>().primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.watch<ThemeProvider>().textColor,
              ),
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label ${value ? "enabled" : "disabled"}'),
                  backgroundColor: context.watch<ThemeProvider>().primaryColor,
                ),
              );
            },
            activeColor: context.watch<ThemeProvider>().primaryColor,
          ),
        ],
      ),
    );
  }
}
