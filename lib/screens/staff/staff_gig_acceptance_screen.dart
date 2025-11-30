// lib/screens/staff/staff_gig_acceptance_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/staff_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/theme_manager.dart';
import '../../utils/color_utils.dart';

class GigAcceptanceScreen extends StatefulWidget {
  const GigAcceptanceScreen({super.key});

  @override
  State<GigAcceptanceScreen> createState() => _GigAcceptanceScreenState();
}

class _GigAcceptanceScreenState extends State<GigAcceptanceScreen> {
  bool _isLoading = false;
  List<GigRequest> _gigRequests = [];

  @override
  void initState() {
    super.initState();
    _loadGigRequests();
  }

  Future<void> _loadGigRequests() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load actual gig requests from provider
      // For now, use mock data
      _gigRequests = [
        GigRequest(
          id: '1',
          title: 'Office Cleaning - CBD',
          clientName: 'ABC Corporation',
          location: '123 Main St, CBD',
          date: DateTime.now().add(const Duration(days: 2)),
          startTime: '09:00',
          endTime: '17:00',
          payment: 150.00,
          description: 'Professional office cleaning service',
          status: GigStatus.pending,
          postedBy: 'Admin',
          postedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        GigRequest(
          id: '2',
          title: 'Home Deep Cleaning',
          clientName: 'John Smith',
          location: '456 Oak Avenue',
          date: DateTime.now().add(const Duration(days: 3)),
          startTime: '10:00',
          endTime: '14:00',
          payment: 120.00,
          description: 'Deep cleaning of 3-bedroom house',
          status: GigStatus.pending,
          postedBy: 'Admin',
          postedAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ];
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading gigs: $e')),
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
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Available Gigs'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gigRequests.isEmpty
              ? _buildEmptyState()
              : _buildGigList(),
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
            'No Available Gigs',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new opportunities',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGigList() {
    return RefreshIndicator(
      onRefresh: _loadGigRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _gigRequests.length,
        itemBuilder: (context, index) {
          final gig = _gigRequests[index];
          return _buildGigCard(gig);
        },
      ),
    );
  }

  Widget _buildGigCard(GigRequest gig) {
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
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: gig.status == GigStatus.pending
                  ? Colors.orange.withCustomOpacity(0.1)
                  : Colors.green.withCustomOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
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
                    color: gig.status == GigStatus.pending
                        ? Colors.orange
                        : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    gig.status.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                    DateFormat('MMM d, yyyy').format(gig.date)),
                _buildDetailRow(Icons.access_time, '${gig.startTime} - ${gig.endTime}'),
                _buildDetailRow(Icons.attach_money, 'R${gig.payment.toStringAsFixed(2)}'),
                
                const SizedBox(height: 12),
                
                Text(
                  gig.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showGigDetails(gig),
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: gig.status == GigStatus.pending
                            ? () => _acceptGig(gig)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.watch<ThemeProvider>().primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          gig.status == GigStatus.pending ? 'Accept Gig' : 'Accepted',
                        ),
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

  void _showGigDetails(GigRequest gig) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gig.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(Icons.person, gig.clientName),
                      _buildDetailRow(Icons.location_on, gig.location),
                      _buildDetailRow(Icons.calendar_today, 
                          DateFormat('EEEE, MMMM d, yyyy').format(gig.date)),
                      _buildDetailRow(Icons.access_time, '${gig.startTime} - ${gig.endTime}'),
                      _buildDetailRow(Icons.attach_money, 'R${gig.payment.toStringAsFixed(2)}'),
                      _buildDetailRow(Icons.person_outline, 'Posted by ${gig.postedBy}'),
                      _buildDetailRow(Icons.schedule, 
                          'Posted ${DateFormat('MMM d, h:mm a').format(gig.postedAt)}'),
                      
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(gig.description),
                    ],
                  ),
                ),
              ),
              if (gig.status == GigStatus.pending)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _acceptGig(gig);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.watch<ThemeProvider>().primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Accept This Gig'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acceptGig(GigRequest gig) async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Call provider to accept gig
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Update local state
      setState(() {
        gig.status = GigStatus.accepted;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gig accepted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting gig: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class GigRequest {
  String id;
  String title;
  String clientName;
  String location;
  DateTime date;
  String startTime;
  String endTime;
  double payment;
  String description;
  GigStatus status;
  String postedBy;
  DateTime postedAt;

  GigRequest({
    required this.id,
    required this.title,
    required this.clientName,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.payment,
    required this.description,
    required this.status,
    required this.postedBy,
    required this.postedAt,
  });
}

enum GigStatus {
  pending('Pending'),
  accepted('Accepted'),
  declined('Declined'),
  completed('Completed');

  const GigStatus(this.name);
  final String name;
}
