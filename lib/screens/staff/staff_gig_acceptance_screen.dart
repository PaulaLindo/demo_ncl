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
  final String gigId;
  
  const GigAcceptanceScreen({
    super.key,
    required this.gigId,
  });

  @override
  State<GigAcceptanceScreen> createState() => _GigAcceptanceScreenState();
}

class _GigAcceptanceScreenState extends State<GigAcceptanceScreen> {
  bool _isLoading = false;
  late GigRequest _gig;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadGig();
  }

  Future<void> _loadGig() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load actual gig from provider using widget.gigId
      // For now, use mock data
      _gig = GigRequest(
        id: widget.gigId,
        title: 'Office Cleaning - CBD',
        clientName: 'ABC Corporation',
        location: '123 Main St, CBD',
        date: DateTime.now().add(const Duration(days: 2)),
        startTime: '09:00',
        endTime: '17:00',
        payment: 1500.00,
        description: 'Professional office cleaning service including vacuuming, dusting, and sanitizing all surfaces. Please bring your own cleaning supplies.',
        status: GigStatus.pending,
        postedBy: 'Admin',
        postedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading gig details: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Gig Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildGigDetails(),
    );
  }

  Widget _buildGigDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gig Header
          Container(
            padding: const EdgeInsets.all(16),
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
                Text(
                  _gig.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'R${_gig.payment.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _gig.status == GigStatus.pending
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _gig.status.name.toUpperCase(),
                        style: TextStyle(
                          color: _gig.status == GigStatus.pending
                              ? Colors.orange
                              : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Gig Details Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
                _buildDetailRow(Icons.location_on, _gig.location),
                _buildDetailRow(Icons.calendar_today, 
                    '${DateFormat('EEEE, MMMM d, yyyy').format(_gig.date)}'),
                _buildDetailRow(Icons.access_time, '${_gig.startTime} - ${_gig.endTime}'),
                _buildDetailRow(Icons.person_outline, 'Posted by ${_gig.postedBy}'),
                _buildDetailRow(Icons.schedule, 
                    'Posted ${DateFormat('MMM d, h:mm a').format(_gig.postedAt)}'),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _gig.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          if (_gig.status == GigStatus.pending) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () => _acceptGig(_gig),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.watch<ThemeProvider>().primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'ACCEPT GIG',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => _declineGig(_gig),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: Colors.grey[300]!,
                  ),
                ),
                child: const Text(
                  'DECLINE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _gig.status == GigStatus.accepted
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _gig.status == GigStatus.accepted
                      ? Colors.green.withOpacity(0.3)
                      : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Text(
                _gig.status == GigStatus.accepted
                    ? 'You have already accepted this gig.'
                    : 'You have declined this gig.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _gig.status == GigStatus.accepted
                      ? Colors.green[800]
                      : Colors.red[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
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


  Future<void> _acceptGig(GigRequest gig) async {
    setState(() => _isSubmitting = true);
    
    try {
      // TODO: Call provider to accept gig
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Update local state
      setState(() {
        _gig.status = GigStatus.accepted;
      });
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gig accepted successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );
        
        // Navigate back after a short delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting gig: $e'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
  
  Future<void> _declineGig(GigRequest gig) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Gig'),
        content: const Text('Are you sure you want to decline this gig? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DECLINE'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      // TODO: Call provider to decline gig
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Update local state
      setState(() {
        _gig.status = GigStatus.declined;
      });
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have declined the gig.'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );
        
        // Navigate back after a short delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context, false); // Return false to indicate decline
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error declining gig: $e'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
