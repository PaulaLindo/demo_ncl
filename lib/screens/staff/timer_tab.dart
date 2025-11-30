// lib/screens/staff/timer_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/auth_model.dart';
import '../../providers/timekeeping_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/location_check_dialog.dart';
import '../../widgets/job_selection_dialog.dart';

class TimerTab extends StatefulWidget {
  const TimerTab({super.key});

  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> {
  final TextEditingController _tempCardController = TextEditingController();
  bool _isAdmin = false;
  bool isCheckedIn = false;

  @override
  void initState() {
    super.initState();
    // Check if current user is admin
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _isAdmin = authProvider.currentUser?.role == UserRole.admin;
  }

  @override
  void dispose() {
    _tempCardController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckIn(String jobId, {String? proxyCardId}) async {
    try {
      final provider = Provider.of<TimekeepingProvider>(context, listen: false);
      await provider.checkIn(jobId, proxyCardId: proxyCardId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checked in successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking in: $e')),
        );
      }
    }
  }

  Future<void> _handleCheckOut() async {
    try {
      final provider = Provider.of<TimekeepingProvider>(context, listen: false);
      await provider.checkOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checked out successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking out: $e')),
        );
      }
    }
  }

  void _showTempCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Temp Card ID'),
        content: TextField(
          controller: _tempCardController,
          decoration: const InputDecoration(
            labelText: 'Temp Card ID',
            hintText: 'Enter the temporary card ID',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_tempCardController.text.isNotEmpty) {
                Navigator.pop(context);
                _handleCheckIn('job1', proxyCardId: _tempCardController.text);
              }
            },
            child: const Text('Use Card'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimekeepingProvider>(context);
    final primaryColor = context.watch<ThemeProvider>().primaryColor;
    final isCheckedIn = provider.activeJobId != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Check In/Out Button
          ElevatedButton(
            onPressed: isCheckedIn ? _handleCheckOut : _showJobSelection,
            style: ElevatedButton.styleFrom(
              backgroundColor: isCheckedIn ? Colors.red : primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              isCheckedIn ? 'CHECK OUT' : 'CHECK IN',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Current Status
          _buildStatusCard(context, provider),

          // Admin-only Temp Card Section
          if (_isAdmin) ...[
            const SizedBox(height: 24),
            _buildAdminSection(context, provider),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, TimekeepingProvider provider) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CURRENT STATUS',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.hintColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.activeJobId != null ? 'ON SHIFT' : 'OFF SHIFT',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: provider.activeJobId != null 
                    ? Colors.green 
                    : theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (provider.activeJobId != null) ...[
              const SizedBox(height: 8),
              Text(
                'Job: ${provider.activeJobId}',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Started: ${DateFormat('MMM d, y - h:mm a').format(DateTime.now())}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdminSection(BuildContext context, TimekeepingProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ADMIN TOOLS',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (provider.activeJobId == null) ...[
              const Text('Use a temporary card for check-in:'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tempCardController,
                      decoration: const InputDecoration(
                        labelText: 'Temp Card ID',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_tempCardController.text.isNotEmpty) {
                        _handleCheckIn(
                          'admin_job',
                          proxyCardId: _tempCardController.text,
                        );
                      }
                    },
                    child: const Text('Check In'),
                  ),
                ],
              ),
            ] else
              const Text(
                'Cannot assign temp card while user is checked in',
                style: TextStyle(color: Colors.orange),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showJobSelection() async {
    final jobId = await showDialog<String>(
      context: context,
      builder: (context) => const JobSelectionDialog(),
    );

    if (jobId != null && mounted) {
      await _handleCheckIn(jobId);
    }
}

  Future<void> _showLocationCheckDialog() async {
    try {
      final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => LocationCheckDialog(
        targetLat: -29.8587,  // Example coordinates
        targetLon: 31.0218,
        jobAddress: '123 Main St, Durban',
        onVerified: () => _handleCheckIn('job1'),
      ),
    );

      if (confirmed == true) {
        // Proceed with check-in
        _handleCheckIn('job1');
      }
    } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
    }
  }
}