// lib/screens/admin/admin_active_gigs_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/admin_provider_web.dart';
import '../../providers/theme_provider.dart';
import '../../theme/theme_manager.dart';
import '../../utils/color_utils.dart';

class AdminActiveGigsScreen extends StatefulWidget {
  const AdminActiveGigsScreen({super.key});

  @override
  State<AdminActiveGigsScreen> createState() => _AdminActiveGigsScreenState();
}

class _AdminActiveGigsScreenState extends State<AdminActiveGigsScreen> {
  bool _isLoading = false;
  List<ActiveGig> _activeGigs = [];

  @override
  void initState() {
    super.initState();
    _loadActiveGigs();
  }

  Future<void> _loadActiveGigs() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load actual active gigs from provider
      _activeGigs = [
        ActiveGig(
          id: '1',
          staffName: 'John Doe',
          staffId: 'STAFF001',
          title: 'Office Cleaning - ABC Corp',
          clientName: 'ABC Corporation',
          location: '123 Main St, CBD',
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 4)),
          status: GigStatus.inProgress,
          payment: 150.00,
          uberETA: DateTime.now().add(const Duration(minutes: 8)), // On time
          rating: null,
          staffLocation: '123 Main St, CBD', // Staff geolocation
          distanceFromGig: 0.2, // km
        ),
        ActiveGig(
          id: '2',
          staffName: 'Jane Smith',
          staffId: 'STAFF002',
          title: 'Home Deep Cleaning',
          clientName: 'Sarah Johnson',
          location: '456 Oak Avenue',
          startTime: DateTime.now().subtract(const Duration(hours: 1)),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          status: GigStatus.inProgress,
          payment: 120.00,
          uberETA: DateTime.now().add(const Duration(minutes: 3)), // On time
          rating: null,
          staffLocation: 'Near 456 Oak Avenue', // Staff geolocation
          distanceFromGig: 0.5, // km
        ),
        ActiveGig(
          id: '3',
          staffName: 'Mike Wilson',
          staffId: 'STAFF003',
          title: 'Restaurant Cleaning',
          clientName: 'The Golden Fork',
          location: '789 Food Street',
          startTime: DateTime.now().subtract(const Duration(minutes: 30)),
          endTime: DateTime.now().add(const Duration(minutes: 30)),
          status: GigStatus.inProgress,
          payment: 180.00,
          uberETA: DateTime.now().add(const Duration(minutes: 12)), // Delayed
          rating: null,
          staffLocation: '5 km away from location', // Staff geolocation
          distanceFromGig: 5.0, // km
        ),
      ];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading active gigs: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        title: const Text('Active Gigs'),
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/admin/home');
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activeGigs.isEmpty
              ? _buildEmptyState()
              : _buildActiveGigsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Gigs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All staff members are currently idle',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveGigsList() {
    return RefreshIndicator(
      onRefresh: _loadActiveGigs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activeGigs.length,
        itemBuilder: (context, index) {
          final gig = _activeGigs[index];
          return _buildActiveGigCard(gig);
        },
      ),
    );
  }

  Widget _buildActiveGigCard(ActiveGig gig) {
    final now = DateTime.now();
    final uberDelay = gig.uberETA.isAfter(now.add(const Duration(minutes: 5)));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withCustomOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: uberDelay 
            ? Border.all(color: Colors.red.withCustomOpacity(0.3), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and alerts
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: uberDelay 
                  ? Colors.red.withCustomOpacity(0.1)
                  : Colors.green.withCustomOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        gig.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: uberDelay ? Colors.red : Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        uberDelay ? 'UBER DELAY' : gig.status.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (uberDelay) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Uber ETA delayed by ${gig.uberETA.difference(now).inMinutes} minutes',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.person, gig.staffName),
                _buildDetailRow(Icons.badge, gig.staffId),
                _buildDetailRow(Icons.location_on, gig.location),
                _buildDetailRow(Icons.my_location, 'Staff: ${gig.staffLocation} (${gig.distanceFromGig.toStringAsFixed(1)} km away)'),
                _buildDetailRow(Icons.access_time, 
                    '${DateFormat('HH:mm').format(gig.startTime)} - ${DateFormat('HH:mm').format(gig.endTime)}'),
                _buildDetailRow(Icons.attach_money, 'R${gig.payment.toStringAsFixed(2)}'),
                
                const SizedBox(height: 12),
                
                // Uber ETA
                if (gig.uberETA.isAfter(now))
                  _buildUberETA(gig.uberETA, uberDelay),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _contactStaff(gig),
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Contact Staff'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _requestUber(gig),
                        icon: const Icon(Icons.local_taxi, size: 16),
                        label: const Text('Request Uber'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _viewDetails(gig),
                        child: const Text('View Location'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildUberETA(DateTime eta, bool isDelayed) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDelayed 
            ? Colors.red.withCustomOpacity(0.1)
            : Colors.blue.withCustomOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_taxi,
            color: isDelayed ? Colors.red : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uber ETA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDelayed ? Colors.red : Colors.blue,
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(eta),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDelayed ? Colors.red : Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          if (isDelayed)
            Icon(Icons.warning, color: Colors.red, size: 16),
        ],
      ),
    );
  }

  void _contactStaff(ActiveGig gig) {
    // TODO: Implement staff contact functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contacting ${gig.staffName}...')),
    );
  }

  void _requestUber(ActiveGig gig) {
    // TODO: Implement Uber request functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Uber'),
        content: Text('Request Uber for ${gig.staffName} to ${gig.location}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Uber requested successfully')),
              );
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _viewDetails(ActiveGig gig) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Staff Location - ${gig.staffName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Location: ${gig.staffLocation}'),
            const SizedBox(height: 8),
            Text('Distance from Gig: ${gig.distanceFromGig.toStringAsFixed(1)} km'),
            const SizedBox(height: 8),
            Text('Gig Location: ${gig.location}'),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Map View'),
                    Text('(Would show staff location)'),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening navigation app...')),
              );
            },
            child: const Text('Navigate'),
          ),
        ],
      ),
    );
  }
}

class ActiveGig {
  String id;
  String staffName;
  String staffId;
  String title;
  String clientName;
  String location;
  DateTime startTime;
  DateTime endTime;
  GigStatus status;
  double payment;
  DateTime uberETA;
  double? rating;
  String staffLocation;
  double distanceFromGig;

  ActiveGig({
    required this.id,
    required this.staffName,
    required this.staffId,
    required this.title,
    required this.clientName,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.payment,
    required this.uberETA,
    this.rating,
    required this.staffLocation,
    required this.distanceFromGig,
  });
}

enum GigStatus {
  inProgress('In Progress'),
  completed('Completed'),
  cancelled('Cancelled');

  const GigStatus(this.name);
  final String name;
}
