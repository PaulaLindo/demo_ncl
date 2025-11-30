// lib/widgets/location_check_dialog.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../providers/timekeeping_provider.dart';

class LocationCheckDialog extends StatefulWidget {
  const LocationCheckDialog({
    super.key,
    this.targetLat,
    this.targetLon,
    this.jobAddress = 'the job location',
    this.onVerified,
    this.maxDistanceMeters = 100,
  });

  final double? targetLat;
  final double? targetLon;
  final String jobAddress;
  final VoidCallback? onVerified;
  final double maxDistanceMeters;

  @override
  State<LocationCheckDialog> createState() => _LocationCheckDialogState();
}

class _LocationCheckDialogState extends State<LocationCheckDialog> {
  bool _isChecking = true;
  bool _isLocationEnabled = false;
  bool _isInRange = false;
  String _status = 'Checking your location...';
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    if (!mounted) return;
    
    setState(() {
      _isChecking = true;
      _status = 'Checking location services...';
    });

    try {
      final timekeepingProvider = context.read<TimekeepingProvider>();
      await timekeepingProvider.checkLocationStatus();
      
      if (!mounted) return;
      
      setState(() {
        _isLocationEnabled = timekeepingProvider.isLocationEnabled;
        _isInRange = timekeepingProvider.isInTargetLocation;
        _currentPosition = timekeepingProvider.currentPosition;
        _status = _isInRange ? 'Location verified!' : 'You are not at the job location.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Error checking location';
        _isLocationEnabled = false;
      });
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _openLocationSettings() async {
    final timekeepingProvider = context.read<TimekeepingProvider>();
    await timekeepingProvider.openLocationSettings();
  }

  Future<void> _openMaps() async {
    final timekeepingProvider = context.read<TimekeepingProvider>();
    await timekeepingProvider.openMapsToJobLocation(
      widget.targetLat,
      widget.targetLon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timekeepingProvider = context.watch<TimekeepingProvider>();

    return AlertDialog(
      title: const Text('Location Verification'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isChecking)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              Icon(
                _isInRange ? Icons.check_circle_outline : Icons.location_off_outlined,
                color: _isInRange ? Colors.green : Colors.orange,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _status,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _isInRange ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (timekeepingProvider.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  timekeepingProvider.error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              if (_currentPosition != null) ...[
                const SizedBox(height: 16),
                _buildLocationInfo(theme),
              ],
            ],
          ],
        ),
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildLocationInfo(ThemeData theme) {
    final timekeepingProvider = context.read<TimekeepingProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your current location:',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Current position: ${timekeepingProvider.currentPosition?.latitude ?? 0}, ${timekeepingProvider.currentPosition?.longitude ?? 0}',
          style: theme.textTheme.bodySmall,
        ),
        if (widget.targetLat != null && widget.targetLon != null) ...[
          const SizedBox(height: 8),
          Text(
            'Job location:',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.targetLat!.toStringAsFixed(6)}, ${widget.targetLon!.toStringAsFixed(6)}',
            style: theme.textTheme.bodySmall,
          ),
          if (widget.jobAddress.isNotEmpty) ...[
            Text(
              widget.jobAddress,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ],
    );
  }

  List<Widget> _buildActions() {
    final timekeepingProvider = context.read<TimekeepingProvider>();
    
    return [
      if (!_isLocationEnabled)
        TextButton(
          onPressed: _openLocationSettings,
          child: const Text('Open Settings'),
        ),
      if (_isLocationEnabled && !_isInRange && widget.targetLat != null)
        TextButton(
          onPressed: _openMaps,
          child: const Text('Get Directions'),
        ),
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel'),
      ),
      if (_isInRange || widget.targetLat == null)
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
            widget.onVerified?.call();
          },
          child: const Text('Continue'),
        ),
      if (!_isInRange && widget.targetLat != null)
        ElevatedButton(
          onPressed: _checkLocation,
          child: const Text('Check Again'),
        ),
    ];
  }
}