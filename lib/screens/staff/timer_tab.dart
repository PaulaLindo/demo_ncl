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
import '../../widgets/qr_scanner_dialog.dart';

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

  Widget _buildCheckInOptions(Color primaryColor) {
    return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Check-in Method',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          // Location Check-in Option
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _handleLocationCheckIn,
              icon: const Icon(Icons.location_on_outlined),
              label: const Text('Location Check-in'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: primaryColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // QR Code Check-in Option
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showQRCodeScannerForCheckIn,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('QR Code Check-in'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      const Text(
        'Choose your preferred check-in method',
        style: TextStyle(fontSize: 12, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

  @override
Widget build(BuildContext context) {
  final provider = Provider.of<TimekeepingProvider>(context, listen: true);
  final primaryColor = context.watch<ThemeProvider>().primaryColor;
  final isCheckedIn = provider.activeJobId != null;

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Check In/Out Section
        if (isCheckedIn)
          // Show Check Out button when checked in
          ElevatedButton(
            onPressed: _handleCheckOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'CHECK OUT',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          // Show Check-in options when not checked in
          _buildCheckInOptions(primaryColor),
        
        const SizedBox(height: 24),
        
        // Current Status Card
        _buildStatusCard(context, provider),

        // Admin Section (if admin)
        if (_isAdmin) ...[
          const SizedBox(height: 24),
          _buildAdminSection(context, provider),
        ],
      ],
    ),
  );
}

// Add this new method to build the QR Scanner section
Widget _buildQRScannerSection() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SCAN QR CODE',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _showQRCodeScannerForCheckIn,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR Code'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use this to scan QR codes at the job site after clocking in.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
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
    try {
      // First verify location
      final locationVerified = await showDialog<bool>(
        context: context,
        builder: (context) => const LocationCheckDialog(),
      ) ?? false;

      if (!locationVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location verification required for check-in')),
          );
        }
        return;
      }

      // Show job selection after location verification
      final jobId = await showDialog<String>(
        context: context,
        builder: (context) => const JobSelectionDialog(),
      );

      if (jobId != null && jobId.isNotEmpty && mounted) {
        await _handleCheckIn(jobId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during check-in: $e')),
        );
      }
    }
  }

  // Handle location-based check-in
  Future<void> _handleLocationCheckIn() async {
    try {
      // First verify location
      final locationVerified = await showDialog<bool>(
        context: context,
        builder: (context) => const LocationCheckDialog(),
      ) ?? false;

      if (!locationVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location verification required for check-in')),
          );
        }
        return;
      }

      // Show job selection after location verification
      final jobId = await showDialog<String>(
        context: context,
        builder: (context) => const JobSelectionDialog(),
      );

      if (jobId != null && jobId.isNotEmpty && mounted) {
        await _handleCheckIn(jobId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during check-in: $e')),
        );
      }
    }
  }

  // Handle the actual check-in
Future<void> _handleCheckIn(String jobId) async {
  try {
    final provider = Provider.of<TimekeepingProvider>(context, listen: false);
    await provider.checkIn(jobId);
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

  Future<void> _showQRCodeScannerForCheckIn() async {
    try {
      // Check camera permissions first
      final cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Camera permission is required to scan QR codes')),
            );
          }
          return;
        }
      }

      // First scan QR code
      final qrCode = await showDialog<String>(
        context: context,
        builder: (context) => QRScannerDialog(
          title: 'Scan Job QR Code',
          subtitle: 'Scan the QR code at the job location',
          onQRCodeScanned: (code) => Navigator.pop(context, code),
        ),
      );

      if (qrCode == null || qrCode.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR code scan cancelled or failed')),
          );
        }
        return;
      }

      if (!_isValidQRCode(qrCode)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid QR code. Please scan a valid job QR code.')),
          );
        }
        return;
      }

      // Validate the scanned QR code
      final provider = Provider.of<TimekeepingProvider>(context, listen: false);
      final validation = await provider.validateQRCode(qrCode);

      if (!validation.isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid QR code: ${validation.error}')),
          );
        }
        return;
      }

      // Verify location
      final locationVerified = await showDialog<bool>(
        context: context,
        builder: (context) => const LocationCheckDialog(),
      ) ?? false;

      if (!locationVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location verification required for check-in')),
          );
        }
        return;
      }

      // Handle the scanned QR code
      if (mounted) {
        await _handleCheckIn(validation.jobId ?? qrCode);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning QR code: $e')),
        );
      }
    }
  }

  Future<QRValidationResult> validateQRCode(String qrCode) async {
    try {
      // Here you would typically validate the QR code against your backend
      // For now, we'll just check if it's not empty and has a valid format
      if (qrCode.isEmpty) {
        return QRValidationResult(
          isValid: false,
          error: 'Empty QR code',
        );
      }

      // Example validation - check if it's a valid job ID format
      // Adjust this based on your actual QR code format
      final job = _availableJobs.firstWhere(
        (job) => job.id == qrCode,
        orElse: () => null,
      );

      if (job == null) {
        return QRValidationResult(
          isValid: false,
          error: 'Invalid job ID',
        );
      }

    return QRValidationResult(
      isValid: true,
      jobId: job.id,
      job: job,
    );
  } catch (e) {
    return QRValidationResult(
        isValid: false,
        error: 'Error validating QR code: $e',
      );
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