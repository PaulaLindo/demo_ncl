import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../routes/app_routes.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../theme/theme_manager.dart';
import '../../utils/color_utils.dart';

class ConfirmationScreen extends StatelessWidget {
  final String serviceId;
  final String? gigId;
  final bool isAvailableService;

  const ConfirmationScreen({
    super.key,
    required this.serviceId,
    this.gigId,
    this.isAvailableService = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get service/gig data based on ID
    final itemData = _getItemData(serviceId);

    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        title: Text(isAvailableService ? 'Confirm Service' : 'Confirm Gig'),
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
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
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ready to Confirm!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please review the details below',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Service/Gig Details
            _buildDetailCard(
              context,
              'Service Information',
              Icons.assignment_outlined,
              [
                _buildDetailRow('Title', itemData['title'] as String),
                _buildDetailRow('Client', itemData['client'] as String),
                _buildDetailRow('Location', itemData['location'] as String),
                _buildDetailRow('Distance', itemData['distance'] as String),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Timing Details
            _buildDetailCard(
              context,
              'Schedule',
              Icons.schedule_outlined,
              [
                _buildDetailRow('Date', itemData['date'] as String),
                _buildDetailRow('Time', itemData['time'] as String),
                _buildDetailRow('Duration', itemData['duration'] as String),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Payment Details
            _buildDetailCard(
              context,
              'Payment',
              Icons.attach_money,
              [
                _buildDetailRow('Base Rate', itemData['baseRate'] as String),
                _buildDetailRow('Transport', itemData['transport'] as String),
                _buildDetailRow(
                  'Total Earnings',
                  itemData['totalPay'] as String,
                  isHighlight: true,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Requirements
            _buildDetailCard(
              context,
              'Requirements',
              Icons.list_alt_outlined,
              (itemData['requirements'] as List<String>)
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
                      ))
                  .toList(),
            ),
            
            const SizedBox(height: 32),
            
            // Important Notes
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withCustomOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withCustomOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_outlined, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Important Notes',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Please arrive 15 minutes before scheduled time\n'
                    '• Bring all required equipment and supplies\n'
                    '• Confirm client arrival before starting work\n'
                    '• Document before/after photos if required\n'
                    '• Report any issues immediately to support',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _confirmService(context, itemData['title'] as String);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Confirm Service'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.watch<ThemeProvider>().primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
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
            width: 100,
            child: Text(
              '$label:',
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

  Map<String, dynamic> _getItemData(String id) {
    // Mock data based on service ID
    switch (id) {
      case 'service_1':
        return {
          'title': 'Emergency Deep Clean',
          'client': 'Office Building A',
          'location': 'Cape Town CBD',
          'distance': '2.5 km',
          'date': 'Dec 15, 2024',
          'time': 'Available Now',
          'duration': '4 hours',
          'baseRate': 'R 1,200',
          'transport': 'R 300',
          'totalPay': 'R 1,500',
          'requirements': [
            'Industrial cleaning equipment provided',
            'Safety gear required',
            '2+ years commercial cleaning experience',
            'Available for weekend work if needed',
          ],
        };
      case 'service_2':
        return {
          'title': 'Regular Home Cleaning',
          'client': 'Smith Family',
          'location': 'Suburbs',
          'distance': '5.1 km',
          'date': 'Dec 16, 2024',
          'time': '2:00 PM - 4:00 PM',
          'duration': '2 hours',
          'baseRate': 'R 600',
          'transport': 'R 200',
          'totalPay': 'R 800',
          'requirements': [
            'Residential cleaning experience',
            'Attention to detail',
            'Pet-friendly (family has 2 cats)',
            'Own cleaning supplies preferred',
          ],
        };
      case 'service_3':
        return {
          'title': 'Post-Construction Clean',
          'client': 'Construction Co',
          'location': 'New Development',
          'distance': '8.3 km',
          'date': 'Dec 17, 2024',
          'time': '6:00 PM - 12:00 AM',
          'duration': '6 hours',
          'baseRate': 'R 1,700',
          'transport': 'R 300',
          'totalPay': 'R 2,000',
          'requirements': [
            'Construction cleanup experience',
            'Heavy duty equipment knowledge',
            'Safety protocol compliance',
            'Available for evening work',
          ],
        };
      default:
        return {
          'title': 'Deep Cleaning Service',
          'client': 'Various Clients',
          'location': 'Cape Town',
          'distance': '5 km',
          'date': 'Dec 18, 2024',
          'time': '10:00 AM - 2:00 PM',
          'duration': '4 hours',
          'baseRate': 'R 1,200',
          'transport': 'R 300',
          'totalPay': 'R 1,500',
          'requirements': [
            'Professional cleaning experience',
            'Reliable transportation',
            'Good communication skills',
            'Attention to detail',
          ],
        };
    }
  }

  void _confirmService(BuildContext context, String serviceTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Service Confirmed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Service "$serviceTitle" has been confirmed successfully!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'You will receive a notification with all the details shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
              // Navigate back to staff home
              context.push(AppRoutes.staffHome);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
