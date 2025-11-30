import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../theme/theme_manager.dart';
import '../../utils/color_utils.dart';

class GigDetailsScreen extends StatelessWidget {
  final String gigId;
  
  const GigDetailsScreen({super.key, required this.gigId});

  @override
  Widget build(BuildContext context) {
    // Mock gig data based on ID
    final gigData = _getGigData(gigId);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Mock map image
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.8),
                          context.watch<ThemeProvider>().secondaryColor.withCustomOpacity(0.6),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map,
                            size: 80,
                            color: Colors.white.withCustomOpacity(0.7),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Interactive Map View',
                            style: TextStyle(
                              color: Colors.white.withCustomOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Distance: ${gigData['distance']}',
                            style: TextStyle(
                              color: Colors.white.withCustomOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Map overlay controls
                  Positioned(
                    top: 60,
                    right: 16,
                    child: Column(
                      children: [
                        _buildMapControl(context, Icons.my_location, 'My Location'),
                        const SizedBox(height: 8),
                        _buildMapControl(context, Icons.zoom_in, 'Zoom In'),
                        const SizedBox(height: 8),
                        _buildMapControl(context, Icons.zoom_out, 'Zoom Out'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          gigData['title'] as String,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: gigData['status'] == 'confirmed' 
                              ? Colors.green.withCustomOpacity(0.1)
                              : Colors.orange.withCustomOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (gigData['status'] as String).toUpperCase(),
                          style: TextStyle(
                            color: gigData['status'] == 'confirmed' 
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Client Info Card
                  _buildInfoCard(
                    context,
                    'Client Information',
                    Icons.person_outline,
                    [
                      _buildDetailRow('Client', gigData['client'] as String),
                      _buildDetailRow('Contact', '+27 21 123 4567'),
                      _buildDetailRow('Service Type', gigData['serviceType'] as String),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Location & Timing Card
                  _buildInfoCard(
                    context,
                    'Location & Timing',
                    Icons.location_on_outlined,
                    [
                      _buildDetailRow('Address', gigData['address'] as String),
                      _buildDetailRow('Distance', gigData['distance'] as String),
                      _buildDetailRow('Date', gigData['date'] as String),
                      _buildDetailRow('Time', gigData['time'] as String),
                      _buildDetailRow('Duration', gigData['duration'] as String),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Payment Details Card
                  _buildInfoCard(
                    context,
                    'Payment Details',
                    Icons.attach_money,
                    [
                      _buildDetailRow('Base Rate', gigData['baseRate'] as String),
                      _buildDetailRow('Transport Allowance', gigData['transport'] as String),
                      _buildDetailRow('Total Earnings', gigData['totalPay'] as String, isHighlight: true),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Requirements Card
                  _buildInfoCard(
                    context,
                    'Requirements',
                    Icons.assignment_outlined,
                    [
                      ...((gigData['requirements'] as List<String>)
                          .map((req) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        req,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ))),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Transport Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          context.watch<ThemeProvider>().primaryColor,
                          context.watch<ThemeProvider>().secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Uber Transport',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Get to your gig safely with Uber transport.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withCustomOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _requestUber(context);
                            },
                            icon: const Icon(Icons.local_taxi),
                            label: const Text('Request Uber'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: context.watch<ThemeProvider>().primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Close'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControl(BuildContext context, IconData icon, String tooltip) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withCustomOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$tooltip clicked')),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.2)),
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
          Row(
            children: [
              Icon(icon, color: context.watch<ThemeProvider>().primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: context.watch<ThemeProvider>().textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                color: isHighlight ? Colors.green : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getGigData(String gigId) {
    // Mock gig data based on ID
    switch (gigId) {
      case 'gig_1':
        return {
          'title': 'Deep Cleaning - Downtown Office',
          'client': 'ABC Corporation',
          'serviceType': 'Commercial Deep Cleaning',
          'address': '123 Main St, Downtown Cape Town',
          'distance': '2.5 km from your location',
          'date': 'Dec 15, 2024',
          'time': '10:00 AM - 2:00 PM',
          'duration': '4 hours',
          'baseRate': 'R 1,200',
          'transport': 'R 300',
          'totalPay': 'R 1,500',
          'status': 'confirmed',
          'requirements': [
            'Industrial cleaning equipment provided',
            'Safety gear required',
            '2+ years commercial cleaning experience',
            'Available for weekend work if needed',
          ],
        };
      case 'gig_2':
        return {
          'title': 'Regular Cleaning - Suburban Home',
          'client': 'Smith Family',
          'serviceType': 'Residential Cleaning',
          'address': '456 Oak Ave, Suburbs',
          'distance': '5.1 km from your location',
          'date': 'Dec 17, 2024',
          'time': '2:00 PM - 6:00 PM',
          'duration': '4 hours',
          'baseRate': 'R 600',
          'transport': 'R 200',
          'totalPay': 'R 800',
          'status': 'pending',
          'requirements': [
            'Residential cleaning experience',
            'Attention to detail',
            'Pet-friendly (family has 2 cats)',
            'Own cleaning supplies preferred',
          ],
        };
      default:
        return {
          'title': 'Kitchen Cleaning - Restaurant',
          'client': 'Italian Restaurant',
          'serviceType': 'Commercial Kitchen Cleaning',
          'address': '789 Food Court, City Center',
          'distance': '8.3 km from your location',
          'date': 'Dec 20, 2024',
          'time': '8:00 AM - 12:00 PM',
          'duration': '4 hours',
          'baseRate': 'R 1,200',
          'transport': 'R 300',
          'totalPay': 'R 1,500',
          'status': 'confirmed',
          'requirements': [
            'Food safety certified',
            'Commercial kitchen experience',
            'Available early morning hours',
            'Deep cleaning equipment knowledge',
          ],
        };
    }
  }

  void _requestUber(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Uber'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_taxi, size: 64, color: Colors.black),
            const SizedBox(height: 16),
            const Text('Requesting Uber to gig location...'),
            const SizedBox(height: 8),
            Text(
              'Estimated pickup: 5-10 minutes\nEstimated cost: R45-65',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Uber requested successfully! Driver arriving in 5 minutes.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirm Request'),
          ),
        ],
      ),
    );
  }
}
