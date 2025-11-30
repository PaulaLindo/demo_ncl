// lib/screens/admin/admin_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/theme_manager.dart';
import '../../theme/app_theme.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 64,
              color: context.watch<ThemeProvider>().primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Admin Settings',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: context.watch<ThemeProvider>().primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure system settings and preferences',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Admin settings features coming soon!'),
                    backgroundColor: context.watch<ThemeProvider>().primaryColor,
                  ),
                );
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
