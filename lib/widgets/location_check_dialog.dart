// lib/widgets/location_check_dialog.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';

class LocationCheckDialog extends StatefulWidget {
  final double targetLat;
  final double targetLon;
  final String jobAddress;
  final VoidCallback onVerified;

  const LocationCheckDialog({
    super.key,
    required this.targetLat,
    required this.targetLon,
    required this.jobAddress,
    required this.onVerified,
  });

  @override
  State<LocationCheckDialog> createState() => _LocationCheckDialogState();
}

class _LocationCheckDialogState extends State<LocationCheckDialog> {
  bool _isChecking = false;
  LocationVerificationResult? _result;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    setState(() {
      _isChecking = true;
      _result = null;
    });

    final result = await LocationService.verifyLocation(
      targetLat: widget.targetLat,
      targetLon: widget.targetLon,
      radiusMeters: 100, // 100 meters radius
    );

    if (mounted) {
      setState(() {
        _isChecking = false;
        _result = result;
      });

      if (result.verified) {
        // Auto-close and proceed after short delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context);
          widget.onVerified();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (_isChecking)
              const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
                ),
              )
            else if (_result?.verified == true)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.greenStatus.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 40,
                  color: AppTheme.greenStatus,
                ),
              )
            else
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.redStatus.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_rounded,
                  size: 40,
                  color: AppTheme.redStatus,
                ),
              ),

            const SizedBox(height: 24),

            // Title
            Text(
              _isChecking
                  ? 'Verifying Location...'
                  : _result?.verified == true
                      ? 'Location Verified!'
                      : 'Location Check Failed',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              _isChecking
                  ? 'Please wait while we verify your location...'
                  : _result?.message ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textGrey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            if (_result != null && _result!.distance != null) ...[
              const SizedBox(height: 12),
              Text(
                'Distance: ${_result!.distance!.toInt()}m',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textGrey,
                ),
              ),
            ],

            if (!_isChecking && _result != null) ...[
              const SizedBox(height: 24),

              // Actions
              if (_result!.verified)
                const Text(
                  'Proceeding with check-in...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.greenStatus,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _checkLocation,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _showManualOverride,
                      child: const Text('Manual Override'),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showManualOverride() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Override'),
        content: const Text(
          'Manual override requires supervisor approval. '
          'Please contact your supervisor to proceed with check-in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // In production, this would notify supervisor
              Navigator.pop(context); // Close override dialog
              Navigator.pop(context); // Close location dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Supervisor notified for approval'),
                  backgroundColor: AppTheme.warningOrange,
                ),
              );
            },
            child: const Text('Request Approval'),
          ),
        ],
      ),
    );
  }
}
