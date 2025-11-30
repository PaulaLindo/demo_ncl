import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/staff_provider.dart';
import 'notification_service.dart';

class NotificationHandler {
  final BuildContext context;
  final NotificationService _notificationService = NotificationService();
  
  NotificationHandler(this.context) {
    _setupNotificationListeners();
  }

  void _setupNotificationListeners() {
    // Handle notification clicks
    _notificationService.onNotificationClick.listen((payload) {
      _handleNotificationPayload(payload);
    });
  }

  void _handleNotificationPayload(String payload) {
    if (payload.startsWith('gig_')) {
      final gigId = payload.replaceFirst('gig_', '');
      _navigateToGigDetails(gigId);
    } 
    else if (payload.startsWith('swap_')) {
      final requestId = payload.replaceFirst('swap_', '');
      _showSwapRequestDialog(requestId);
    }
  }

  void _navigateToGigDetails(String gigId) {
    final provider = context.read<StaffProvider>();
    final gig = provider.getJobById(gigId);
    
    if (gig != null) {
      // Navigate to gig details screen or show dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(gig.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${gig.status.toString().split('.').last}'),
              const SizedBox(height: 8),
              Text('Date: ${gig.startTime.toString()}'),
              if (gig.location?.isNotEmpty == true) Text('Location: ${gig.location}'),
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
    } else {
      // Gig not found, refresh the list and try again
      provider.loadJobs().then((_) {
        final updatedGig = provider.getJobById(gigId);
        if (updatedGig != null) {
          _navigateToGigDetails(gigId);
        }
      });
    }
  }

  void _showSwapRequestDialog(String requestId) {
    // In a real app, you would fetch the swap request details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shift Swap Request'),
        content: const Text('John Doe wants to swap shifts with you for the upcoming gig.'),
        actions: [
          TextButton(
            onPressed: () => _respondToSwapRequest(requestId, false),
            child: const Text('Decline', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => _respondToSwapRequest(requestId, true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _respondToSwapRequest(String requestId, bool accepted) async {
    final provider = context.read<StaffProvider>();
    Navigator.pop(context); // Close the dialog
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      // In a real app, you would call an API to respond to the swap request
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      Navigator.pop(context); // Close loading indicator
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accepted 
            ? 'You have accepted the shift swap request.'
            : 'You have declined the shift swap request.'
          ),
          backgroundColor: accepted ? Colors.green : Colors.orange,
        ),
      );
      
      // Refresh data if needed
      if (accepted) {
        await provider.loadJobs();
      }
      
    } catch (e) {
      Navigator.pop(context); // Close loading indicator
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to process your response. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Public method to test notifications
  static void showTestNotification(BuildContext context) {
    final notificationService = NotificationService();
    
    notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Test Notification',
      body: 'This is a test notification from the staff app.',
      payload: 'test_payload',
    );
  }
}
