// lib/screens/admin/live_logistics.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../models/logistics_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';

class LiveLogisticsPage extends StatefulWidget {
  const LiveLogisticsPage({super.key});

  @override
  State<LiveLogisticsPage> createState() => _LiveLogisticsPageState();
}

class _LiveLogisticsPageState extends State<LiveLogisticsPage> {
  final TextEditingController _jobIdController = TextEditingController();
  final TextEditingController _staffIdController = TextEditingController();
  final TextEditingController _eventTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _jobIdController.dispose();
    _staffIdController.dispose();
    _eventTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Logistics Tracking'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showLogEventDialog(context),
            icon: const Icon(Icons.add),
            tooltip: 'Log Event',
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          return StreamBuilder<List<LogisticsEvent>>(
            stream: provider.logisticsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final events = snapshot.data ?? [];

              if (events.isEmpty) {
                return const Center(
                  child: Text('No logistics events yet'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildLogisticsEventCard(context, event);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLogisticsEventCard(BuildContext context, LogisticsEvent event) {
    final eventColor = _getEventColor(event.eventType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: eventColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getEventDisplayName(event.eventType),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.gps_fixed, color: eventColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: eventColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.description, color: AppTheme.primaryPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.business, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Job: ${event.jobId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Staff: ${event.staffId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Time: ${event.timestamp.toString().substring(0, 16)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (event.metadata.isNotEmpty) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                title: Text(
                  'Metadata (${event.metadata.length} items)',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: event.metadata.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key}:',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case LogisticsEventTypes.staffCheckedIn:
        return Colors.green;
      case LogisticsEventTypes.staffCheckedOut:
        return Colors.red;
      case LogisticsEventTypes.jobStarted:
        return Colors.blue;
      case LogisticsEventTypes.jobCompleted:
        return Colors.purple;
      case LogisticsEventTypes.locationVerified:
        return Colors.orange;
      case LogisticsEventTypes.qrCodeScanned:
        return Colors.indigo;
      case LogisticsEventTypes.qualityCheckCompleted:
        return Colors.teal;
      case LogisticsEventTypes.issueReported:
        return Colors.red;
      case LogisticsEventTypes.suppliesRestocked:
        return Colors.brown;
      case LogisticsEventTypes.emergencyCalled:
        return Colors.red;
      case LogisticsEventTypes.delayReported:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getEventDisplayName(String eventType) {
    switch (eventType) {
      case LogisticsEventTypes.staffCheckedIn:
        return 'Check In';
      case LogisticsEventTypes.staffCheckedOut:
        return 'Check Out';
      case LogisticsEventTypes.jobStarted:
        return 'Job Started';
      case LogisticsEventTypes.jobCompleted:
        return 'Job Completed';
      case LogisticsEventTypes.locationVerified:
        return 'Location Verified';
      case LogisticsEventTypes.qrCodeScanned:
        return 'QR Scanned';
      case LogisticsEventTypes.qualityCheckCompleted:
        return 'Quality Check';
      case LogisticsEventTypes.issueReported:
        return 'Issue Reported';
      case LogisticsEventTypes.suppliesRestocked:
        return 'Supplies Restocked';
      case LogisticsEventTypes.emergencyCalled:
        return 'Emergency';
      case LogisticsEventTypes.delayReported:
        return 'Delay Reported';
      default:
        return 'Unknown';
    }
  }

  void _showLogEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Logistics Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _jobIdController,
                decoration: const InputDecoration(
                  labelText: 'Job ID',
                  hintText: 'Enter job ID',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _staffIdController,
                decoration: const InputDecoration(
                  labelText: 'Staff ID',
                  hintText: 'Enter staff ID',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _eventTypeController.text.isEmpty ? null : _eventTypeController.text,
                decoration: const InputDecoration(
                  labelText: 'Event Type',
                  hintText: 'Select event type',
                ),
                items: [
                  LogisticsEventTypes.staffCheckedIn,
                  LogisticsEventTypes.staffCheckedOut,
                  LogisticsEventTypes.jobStarted,
                  LogisticsEventTypes.jobCompleted,
                  LogisticsEventTypes.locationVerified,
                  LogisticsEventTypes.qrCodeScanned,
                  LogisticsEventTypes.qualityCheckCompleted,
                  LogisticsEventTypes.issueReported,
                  LogisticsEventTypes.suppliesRestocked,
                  LogisticsEventTypes.emergencyCalled,
                  LogisticsEventTypes.delayReported,
                ].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getEventDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  _eventTypeController.text = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the event',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_jobIdController.text.isEmpty ||
                  _staffIdController.text.isEmpty ||
                  _eventTypeController.text.isEmpty ||
                  _descriptionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final provider = context.read<AdminProvider>();
                await provider.logLogisticsEvent(
                  staffId: _staffIdController.text,
                  jobId: _jobIdController.text,
                  eventType: _eventTypeController.text,
                  description: _descriptionController.text,
                );

                Navigator.of(context).pop();
                _jobIdController.clear();
                _staffIdController.clear();
                _eventTypeController.clear();
                _descriptionController.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Event logged successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Log Event'),
          ),
        ],
      ),
    );
  }
}
