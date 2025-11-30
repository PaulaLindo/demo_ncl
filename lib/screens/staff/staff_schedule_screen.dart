// lib/screens/staff/staff_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../theme/theme_manager.dart';
import '../../theme/app_theme.dart';

class StaffScheduleScreen extends StatelessWidget {
  const StaffScheduleScreen({super.key});

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
            context.push('/staff/home');
          },
        ),
        title: const Text('Schedule'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              size: 64,
              color: context.watch<ThemeProvider>().primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Work Schedule',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: context.watch<ThemeProvider>().primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View and manage your work schedule',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Schedule features coming soon!'),
                    backgroundColor: context.watch<ThemeProvider>().primaryColor,
                  ),
                );
              },
              child: const Text('View Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
