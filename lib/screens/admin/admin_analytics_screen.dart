// lib/screens/admin/admin_analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/theme_manager.dart';
import '../../theme/app_theme.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 64,
              color: context.watch<ThemeProvider>().primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Analytics Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: context.watch<ThemeProvider>().primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View business analytics and reports',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Analytics features coming soon!'),
                    backgroundColor: context.watch<ThemeProvider>().primaryColor,
                  ),
                );
              },
              child: const Text('View Analytics'),
            ),
          ],
        ),
      ),
    );
  }
}
