// lib/screens/staff/staff_timekeeping_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'enhanced_mobile_timekeeping_tab.dart';

class StaffTimekeepingScreen extends StatelessWidget {
  const StaffTimekeepingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      body: const EnhancedMobileTimekeepingTab(),
    );
  }
}
