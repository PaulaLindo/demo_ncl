import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../models/job_status.dart';
import 'package:intl/intl.dart';

import '../utils/color_utils.dart';

/// JobCard - Matches job card styling from staff_dashboard.html
/// Displays job information with actions
class JobCard extends StatelessWidget {
  final Job job;
  final bool isStaff;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;
  final VoidCallback? onNavigate;
  final VoidCallback? onViewDetails;

  const JobCard({
    super.key,
    required this.job,
    required this.isStaff,
    this.onStart,
    this.onComplete,
    this.onNavigate,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            _buildStatusBadge(),
            const SizedBox(height: 12),

            // Job Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.description ?? job.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              job.customerName ?? 'Unknown Customer',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Job Details
            _buildJobDetail(
              Icons.access_time,
              _formatTime(job.startTime, job.endTime),
            ),
            const SizedBox(height: 8),
            _buildJobDetail(
              Icons.location_on,
              job.address ?? 'No address',
            ),
            const SizedBox(height: 16),

            // Action Buttons
            if (isStaff) _buildStaffActions(context),
            if (!isStaff) _buildCustomerActions(context),
          ],
        ),
      ),
    );
  }

  /// Build status badge - matches job-status-badge from CSS
  Widget _buildStatusBadge() {
    final statusColor = job.status.getColor();
    final statusText = job.status.toString().split('.').last;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withCustomOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build job detail row
  Widget _buildJobDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  /// Build staff action buttons - matches staff_dashboard.js renderActionButtons
  Widget _buildStaffActions(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    if (job.status == JobStatus.inProgress) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Complete Job'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: onNavigate,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Icon(Icons.navigation, size: 20),
            ),
          ),
        ],
      );
    }

    if (job.status == JobStatus.scheduled) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Start Job'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: onNavigate,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Icon(Icons.navigation, size: 20),
            ),
          ),
        ],
      );
    }

    if (job.status == JobStatus.completed) {
      return ElevatedButton(
        onPressed: onViewDetails,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.grey[700],
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text('View Details'),
      );
    }

    return const SizedBox.shrink();
  }

  /// Build customer action buttons
  Widget _buildCustomerActions(BuildContext context) {
    return ElevatedButton(
      onPressed: onViewDetails,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: const Text('View Details'),
    );
  }

  /// Format time display - matches timing display from prototype
  String _formatTime(DateTime start, DateTime end) {
    final startFormat = DateFormat('h:mm a');
    final endFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM d');

    final today = DateTime.now();
    final isToday = start.year == today.year &&
        start.month == today.month &&
        start.day == today.day;

    final isTomorrow = start.year == today.year &&
        start.month == today.month &&
        start.day == today.day + 1;

    String datePrefix;
    if (isToday) {
      datePrefix = 'Today';
    } else if (isTomorrow) {
      datePrefix = 'Tomorrow';
    } else {
      datePrefix = dateFormat.format(start);
    }

    return '$datePrefix • ${startFormat.format(start)} - ${endFormat.format(end)}';
  }
}