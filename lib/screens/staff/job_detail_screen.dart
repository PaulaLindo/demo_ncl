// lib/screens/staff/job_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/job_model.dart';
import '../../../models/job_status.dart';

import '../../features/staff/checklist/checklist_detail_screen.dart';

import '../../providers/staff_provider.dart';

import '../../utils/color_utils.dart';

class JobDetailScreen extends StatelessWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              // Navigate to shift swap
              context.push('/staff/shift-swap/request/$jobId');
            },
            tooltip: 'Request shift swap',
          ),
        ],
      ),
      body: Consumer<StaffProvider>(
        builder: (context, provider, _) {
          final job = provider.getJobById(jobId);
          if (job == null) {
            return const Center(child: Text('Job not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Header
                _buildJobHeader(context, job),
                const SizedBox(height: 24),

                // Job Details
                _buildDetailItem(
                  context,
                  icon: Icons.location_on,
                  title: 'Address',
                  value: job.address ?? 'No address',
                ),
                _buildDetailItem(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Date',
                  value: DateFormat('EEEE, MMMM d, y').format(job.startTime),
                ),
                _buildDetailItem(
                  context,
                  icon: Icons.access_time,
                  title: 'Time',
                  value:
                      '${_formatTime(job.startTime)} - ${_formatTime(job.endTime)}',
                ),
                _buildDetailItem(
                  context,
                  icon: Icons.work,
                  title: 'Service Type',
                  value: job.description ?? job.title,
                ),

                const SizedBox(height: 32),

                // Checklist Section
                if (job.checklistId != null) _buildChecklistSection(context, job),
                
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(context, job),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobHeader(BuildContext context, Job job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          job.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(job.status).withCustomOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getStatusColor(job.status),
                ),
              ),
              child: Text(
                job.status.toString().split('.').last,
                style: TextStyle(
                  color: _getStatusColor(job.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (job.checklistId != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: job.checklistCompleted
                      ? Colors.green[50]
                      : Colors.orange[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: job.checklistCompleted
                        ? Colors.green[200]!
                        : Colors.orange[200]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      job.checklistCompleted
                          ? Icons.check_circle
                          : Icons.pending,
                      size: 16,
                      color:
                          job.checklistCompleted ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.checklistCompleted ? 'Checklist Done' : 'Checklist Pending',
                      style: TextStyle(
                        color: job.checklistCompleted
                            ? Colors.green[800]
                            : Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistSection(BuildContext context, Job job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Checklist',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Icon(
                job.checklistCompleted
                    ? Icons.check_circle_outline
                    : Icons.assignment_outlined,
                size: 48,
                color: job.checklistCompleted ? Colors.green : Colors.blue,
              ),
              const SizedBox(height: 12),
              Text(
                job.checklistCompleted
                    ? 'Checklist Completed'
                    : 'Complete the job checklist',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                job.checklistCompleted
                    ? 'All tasks have been completed and submitted'
                    : 'Complete all required tasks and submit the checklist',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChecklistDetailScreen(
                        checklistId: job.checklistId!,
                      ),
                    ),
                  ).then((_) {
                    context.read<StaffProvider>().loadJobs();
                  });
                },
                child: Text(
                  job.checklistCompleted
                      ? 'View Checklist'
                      : 'Start Checklist',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Job job) {
    return Column(
      children: [
        if (!job.checklistCompleted && job.checklistId != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChecklistDetailScreen(
                      checklistId: job.checklistId!,
                    ),
                  ),
                ).then((_) {
                  context.read<StaffProvider>().loadJobs();
                });
              },
              icon: const Icon(Icons.checklist),
              label: const Text('Complete Checklist'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Open maps or navigation
              _launchMaps(job.address ?? '');
            },
            icon: const Icon(Icons.directions),
            label: const Text('Get Directions'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(JobStatus status) {
    switch (status) {
      case JobStatus.scheduled:
        return Colors.blue;
      case JobStatus.inProgress:
        return Colors.orange;
      case JobStatus.completed:
        return Colors.green;
      case JobStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  void _launchMaps(String address) async {
    // TODO: Implement maps integration
    final url = 'https://www.google.com/maps/search/?api=1&query=$address';
    // ignore: deprecated_member_use
    // if (await canLaunch(url)) {
    //   await launch(url);
    // }
  }
}