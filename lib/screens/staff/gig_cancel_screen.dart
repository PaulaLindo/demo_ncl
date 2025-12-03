// lib/screens/staff/gig_cancel_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/color_utils.dart';

class GigCancelScreen extends StatelessWidget {
  final String gigId;
  
  const GigCancelScreen({
    super.key,
    required this.gigId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        title: Text(
          'Cancel Gig',
          style: TextStyle(
            color: context.watch<ThemeProvider>().primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: context.watch<ThemeProvider>().primaryColor,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gig Information Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.watch<ThemeProvider>().cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gig Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.watch<ThemeProvider>().primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Gig ID:',
                    gigId,
                    Icons.info_outline,
                  ),
                  _buildDetailRow(
                    context,
                    'Service:',
                    'Home Cleaning',
                    Icons.cleaning_services,
                  ),
                  _buildDetailRow(
                    context,
                    'Date:',
                    '2024-12-15',
                    Icons.calendar_today,
                  ),
                  _buildDetailRow(
                    context,
                    'Time:',
                    '14:00 - 17:00',
                    Icons.access_time,
                  ),
                  _buildDetailRow(
                    context,
                    'Location:',
                    '123 Main St, City',
                    Icons.location_on,
                  ),
                  _buildDetailRow(
                    context,
                    'Payment:',
                    'R 450',
                    Icons.payments,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Warning Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withCustomOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withCustomOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Cancellation Warning',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please be aware of the following consequences:',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.watch<ThemeProvider>().textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildWarningItem(
                    context,
                    '• This gig will be marked as cancelled',
                  ),
                  _buildWarningItem(
                    context,
                    '• Your reliability rating may be affected',
                  ),
                  _buildWarningItem(
                    context,
                    '• Customer will need to find alternative staff',
                  ),
                  _buildWarningItem(
                    context,
                    '• This action cannot be undone',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Cancellation Reason
            Text(
              'Reason for Cancellation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.watch<ThemeProvider>().primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: context.watch<ThemeProvider>().cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.2),
                ),
              ),
              child: TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Please provide a reason for cancelling this gig...',
                  hintStyle: TextStyle(
                    color: context.watch<ThemeProvider>().textColor.withCustomOpacity(0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: TextStyle(
                  color: context.watch<ThemeProvider>().textColor,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: context.watch<ThemeProvider>().primaryColor,
                      ),
                    ),
                    child: Text(
                      'Keep Gig',
                      style: TextStyle(
                        color: context.watch<ThemeProvider>().primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Show confirmation dialog
                      _showCancellationConfirmation(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Cancel Gig',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: context.watch<ThemeProvider>().primaryColor,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: context.watch<ThemeProvider>().textColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: context.watch<ThemeProvider>().textColor.withCustomOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(
    BuildContext context,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: context.watch<ThemeProvider>().textColor,
        ),
      ),
    );
  }

  void _showCancellationConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Confirm Cancellation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel this gig? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('No, Keep Gig'),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Go back to previous screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gig cancelled successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel Gig'),
          ),
        ],
      ),
    );
  }
}
