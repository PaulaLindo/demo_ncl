// lib/screens/customer/customer_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_manager.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';
import 'package:flutter/foundation.dart';

class CustomerSettingsScreen extends StatelessWidget {
  const CustomerSettingsScreen({super.key});

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
            context.go(AppRoutes.customerHome);
          },
        ),
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Settings
            Text(
              'Appearance',
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
                    leading: Icon(Icons.palette, color: context.watch<ThemeProvider>().primaryColor),
                    title: const Text('Theme Selection'),
                    subtitle: const Text('Choose your preferred color scheme'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showThemeSelector(context),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.text_fields, color: context.watch<ThemeProvider>().primaryColor),
                    title: const Text('Font Size'),
                    subtitle: const Text('Adjust text size'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Font size settings coming soon!'),
                          backgroundColor: context.watch<ThemeProvider>().primaryColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Developer Options (Testing Only)
            if (kDebugMode) ...[
              Text(
                'Developer Options',
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
                      leading: Icon(Icons.palette, color: context.watch<ThemeProvider>().primaryColor),
                      title: const Text('Theme Switcher (Testing)'),
                      subtitle: Text('Current: ${ThemeManager.instance.themeName}'),
                      trailing: ThemeManager.instance.currentTheme == ThemeType.purpleGold 
                          ? Icon(Icons.format_paint, color: context.watch<ThemeProvider>().secondaryColor)
                          : Icon(Icons.format_paint, color: context.watch<ThemeProvider>().primaryColor),
                      onTap: () {
                        // Toggle theme for testing
                        final currentTheme = ThemeManager.instance.currentTheme;
                        final newTheme = currentTheme == ThemeType.purpleGold 
                            ? ThemeType.navyGold 
                            : ThemeType.purpleGold;
                        ThemeManager.instance.setTheme(newTheme);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Switched to ${ThemeManager.instance.themeName}'),
                            backgroundColor: context.watch<ThemeProvider>().primaryColor,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
            
            // Account Settings
            Text(
              'Account',
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
                    leading: Icon(Icons.notifications, color: context.colors.primary),
                    title: const Text('Notifications'),
                    subtitle: const Text('Manage notification preferences'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Notification settings coming soon!'),
                          backgroundColor: context.watch<ThemeProvider>().primaryColor,
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.privacy_tip, color: context.colors.primary),
                    title: const Text('Privacy'),
                    subtitle: const Text('Privacy and security settings'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Privacy settings coming soon!'),
                          backgroundColor: context.watch<ThemeProvider>().primaryColor,
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.payment, color: context.colors.primary),
                    title: const Text('Payment Methods'),
                    subtitle: const Text('Manage payment options'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Payment methods coming soon!'),
                          backgroundColor: context.watch<ThemeProvider>().primaryColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Support
            Text(
              'Support',
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
                    leading: Icon(Icons.help, color: context.colors.primary),
                    title: const Text('Help Center'),
                    subtitle: const Text('Get help and support'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Help center coming soon!'),
                          backgroundColor: context.watch<ThemeProvider>().primaryColor,
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.contact_support, color: context.colors.primary),
                    title: const Text('Contact Us'),
                    subtitle: const Text('Get in touch with our team'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Contact us coming soon!'),
                          backgroundColor: context.watch<ThemeProvider>().primaryColor,
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.info, color: context.colors.primary),
                    title: const Text('About'),
                    subtitle: const Text('App information and version'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Danger Zone
            Text(
              'Account Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.withCustomOpacity(0.3)),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red,),
                    title: Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.red,),
                    ),
                    onTap: () {
                      _showSignOutDialog(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red,),
                    title: Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.red,),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Account deletion feature coming soon!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'NCL Professional Home Services',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Purple & Gold'),
              subtitle: const Text('Classic NCL theme'),
              onTap: () {
                ThemeManager.instance.setTheme(ThemeType.purpleGold);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Theme changed to Purple & Gold'),
                    backgroundColor: context.watch<ThemeProvider>().primaryColor,
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Navy & Gold'),
              subtitle: const Text('Professional corporate theme'),
              onTap: () {
                ThemeManager.instance.setTheme(ThemeType.navyGold);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Theme changed to Navy & Gold'),
                    backgroundColor: context.watch<ThemeProvider>().primaryColor,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About NCL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NCL Professional Home Services',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: context.watch<ThemeProvider>().primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your trusted partner for professional home cleaning services. We provide quality, reliable, and affordable cleaning solutions tailored to your needs.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Version: 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
              ),
            ),
            Text(
              '© 2024 NCL Professional Home Services',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate back to login chooser
              context.go(AppRoutes.home);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
