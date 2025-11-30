// lib/screens/admin/admin_upcoming_gigs_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/admin_provider_web.dart';
import '../../providers/theme_provider.dart';
import '../../theme/theme_manager.dart';
import '../../utils/color_utils.dart';

class AdminUpcomingGigsScreen extends StatefulWidget {
  const AdminUpcomingGigsScreen({super.key});

  @override
  State<AdminUpcomingGigsScreen> createState() => _AdminUpcomingGigsScreenState();
}

class _AdminUpcomingGigsScreenState extends State<AdminUpcomingGigsScreen> {
  bool _isLoading = false;
  List<UpcomingGig> _upcomingGigs = [];

  @override
  void initState() {
    super.initState();
    _loadUpcomingGigs();
  }

  Future<void> _loadUpcomingGigs() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load actual upcoming gigs from provider
      _upcomingGigs = [
        UpcomingGig(
          id: '1',
          title: 'Office Cleaning - Tech Park',
          clientName: 'Tech Solutions Ltd',
          location: '789 Innovation Drive',
          date: DateTime.now().add(const Duration(days: 1)),
          startTime: '09:00',
          endTime: '17:00',
          payment: 180.00,
          assignedStaff: 'John Doe',
          status: GigStatus.scheduled,
          priority: GigPriority.high,
          notes: 'Client requires special equipment',
        ),
        UpcomingGig(
          id: '2',
          title: 'Restaurant Deep Clean',
          clientName: 'The Golden Fork',
          location: '321 Food Street',
          date: DateTime.now().add(const Duration(days: 2)),
          startTime: '22:00',
          endTime: '06:00',
          payment: 250.00,
          assignedStaff: 'Jane Smith',
          status: GigStatus.scheduled,
          priority: GigPriority.medium,
          notes: 'After-hours cleaning required',
        ),
        UpcomingGig(
          id: '3',
          title: 'Medical Facility Cleaning',
          clientName: 'City Medical Center',
          location: '555 Health Avenue',
          date: DateTime.now().add(const Duration(days: 3)),
          startTime: '19:00',
          endTime: '23:00',
          payment: 200.00,
          assignedStaff: 'Mike Wilson',
          status: GigStatus.scheduled,
          priority: GigPriority.high,
          notes: 'Medical-grade sanitation required',
        ),
      ];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading upcoming gigs: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Gigs'),
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _upcomingGigs.isEmpty
              ? _buildEmptyState()
              : _buildUpcomingGigsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Upcoming Gigs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No confirmed gigs scheduled',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingGigsList() {
    return RefreshIndicator(
      onRefresh: _loadUpcomingGigs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _upcomingGigs.length,
        itemBuilder: (context, index) {
          final gig = _upcomingGigs[index];
          return _buildUpcomingGigCard(gig);
        },
      ),
    );
  }

  Widget _buildUpcomingGigCard(UpcomingGig gig) {
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and priority
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getPriorityColor(gig.priority).withCustomOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gig.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(gig.priority),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        gig.priority.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(gig.status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        gig.status.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.person, gig.clientName),
                _buildDetailRow(Icons.location_on, gig.location),
                _buildDetailRow(Icons.calendar_today, 
                    DateFormat('EEEE, MMMM d, yyyy').format(gig.date)),
                _buildDetailRow(Icons.access_time, '${gig.startTime} - ${gig.endTime}'),
                _buildDetailRow(Icons.attach_money, 'R${gig.payment.toStringAsFixed(2)}'),
                _buildDetailRow(Icons.person_outline, 
                    'Assigned to ${gig.assignedStaff}'),
                
                if (gig.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withCustomOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.note, color: Colors.amber[700], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            gig.notes,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Action buttons - View only
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _viewDetails(gig),
                        child: const Text('View Details'),
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

  Color _getPriorityColor(GigPriority priority) {
    switch (priority) {
      case GigPriority.high:
        return Colors.red;
      case GigPriority.medium:
        return Colors.orange;
      case GigPriority.low:
        return Colors.blue;
    }
  }

  Color _getStatusColor(GigStatus status) {
    switch (status) {
      case GigStatus.scheduled:
        return Colors.green;
      case GigStatus.pending:
        return Colors.orange;
      case GigStatus.cancelled:
        return Colors.grey;
    }
  }

  void _viewDetails(UpcomingGig gig) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(gig.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.person, gig.clientName),
            _buildDetailRow(Icons.location_on, gig.location),
            _buildDetailRow(Icons.calendar_today, 
                DateFormat('EEEE, MMMM d, yyyy').format(gig.date)),
            _buildDetailRow(Icons.access_time, '${gig.startTime} - ${gig.endTime}'),
            _buildDetailRow(Icons.attach_money, 'R${gig.payment.toStringAsFixed(2)}'),
            _buildDetailRow(Icons.person_outline, 'Assigned to ${gig.assignedStaff}'),
            if (gig.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${gig.notes}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class UpcomingGig {
  String id;
  String title;
  String clientName;
  String location;
  DateTime date;
  String startTime;
  String endTime;
  double payment;
  String assignedStaff;
  GigStatus status;
  GigPriority priority;
  String notes;

  UpcomingGig({
    required this.id,
    required this.title,
    required this.clientName,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.payment,
    required this.assignedStaff,
    required this.status,
    required this.priority,
    required this.notes,
  });
}

enum GigStatus {
  scheduled('Scheduled'),
  pending('Pending'),
  cancelled('Cancelled');

  const GigStatus(this.name);
  final String name;
}

enum GigPriority {
  high('High'),
  medium('Medium'),
  low('Low');

  const GigPriority(this.name);
  final String name;
}
