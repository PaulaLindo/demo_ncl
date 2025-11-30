// lib/screens/admin/proxy_time_management.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../models/time_record_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';

class ProxyTimeManagementPage extends StatefulWidget {
  const ProxyTimeManagementPage({super.key});

  @override
  State<ProxyTimeManagementPage> createState() => _ProxyTimeManagementPageState();
}

class _ProxyTimeManagementPageState extends State<ProxyTimeManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxy Time Management'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showCreateProxyTimeDialog(context),
            icon: const Icon(Icons.add),
            tooltip: 'Create Proxy Time Record',
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          return StreamBuilder<List<TimeRecord>>(
            stream: provider.proxyRecordsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final proxyRecords = snapshot.data ?? [];

              if (proxyRecords.isEmpty) {
                return const Center(
                  child: Text('No proxy time records yet'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: proxyRecords.length,
                itemBuilder: (context, index) {
                  final record = proxyRecords[index];
                  return _buildProxyRecordCard(context, record, provider);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProxyRecordCard(
    BuildContext context,
    TimeRecord record,
    AdminProvider provider,
  ) {
    final needsApproval = record.status == TimeRecordStatus.pendingApproval;
    final duration = record.checkOutTime != null
        ? record.checkOutTime!.difference(record.checkInTime).inMinutes
        : null;

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
                    color: needsApproval ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    needsApproval ? 'Needs Approval' : 'Approved',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (needsApproval) ...[
                  IconButton(
                    onPressed: () => _showApprovalDialog(context, record, provider, true),
                    icon: const Icon(Icons.check, color: Colors.green),
                    tooltip: 'Approve',
                  ),
                  IconButton(
                    onPressed: () => _showApprovalDialog(context, record, provider, false),
                    icon: const Icon(Icons.close, color: Colors.red),
                    tooltip: 'Reject',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, color: AppTheme.primaryPurple),
                const SizedBox(width: 8),
                Text(
                  'Job: ${record.jobName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                  'Staff: ${record.staffId}',
                  style: TextStyle(
                    fontSize: 16,
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
                  'Check-in: ${record.checkInTime.toString().substring(0, 16)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (record.checkOutTime != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 32),
                  Text(
                    'Check-out: ${record.checkOutTime!.toString().substring(0, 16)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (duration != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const SizedBox(width: 32),
                    Text(
                      'Duration: ${duration ~/ 60}h ${duration % 60}m',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
            if (record.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${record.notes}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            FutureBuilder<bool>(
              future: provider.areHoursInPayroll(record.id),
              builder: (context, snapshot) {
                final inPayroll = snapshot.data ?? false;
                if (inPayroll) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withCustomOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue[700], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Hours included in draft payroll',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateProxyTimeDialog(BuildContext context) {
    final staffIdController = TextEditingController();
    final staffNameController = TextEditingController();
    final jobIdController = TextEditingController();
    final jobNameController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? checkInTime;
    DateTime? checkOutTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Proxy Time Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: staffIdController,
                  decoration: const InputDecoration(
                    labelText: 'Staff ID',
                    hintText: 'Enter staff ID',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: staffNameController,
                  decoration: const InputDecoration(
                    labelText: 'Staff Name',
                    hintText: 'Enter staff name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: jobIdController,
                  decoration: const InputDecoration(
                    labelText: 'Job ID',
                    hintText: 'Enter job ID',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: jobNameController,
                  decoration: const InputDecoration(
                    labelText: 'Job Name',
                    hintText: 'Enter job name',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Check-in Time'),
                  subtitle: Text(checkInTime?.toString().substring(0, 16) ?? 'Select time'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          checkInTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Check-out Time (Optional)'),
                  subtitle: Text(checkOutTime?.toString().substring(0, 16) ?? 'Select time'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          checkOutTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Any additional notes',
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
                if (staffIdController.text.isEmpty ||
                    staffNameController.text.isEmpty ||
                    jobIdController.text.isEmpty ||
                    jobNameController.text.isEmpty ||
                    checkInTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final provider = context.read<AdminProvider>();
                  await provider.createProxyTimeRecord(
                    staffId: staffIdController.text,
                    staffName: staffNameController.text,
                    jobId: jobIdController.text,
                    jobName: jobNameController.text,
                    checkInTime: checkInTime!,
                    checkOutTime: checkOutTime,
                    notes: notesController.text.isEmpty ? null : notesController.text,
                  );

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Proxy time record created'),
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
              child: const Text('Create Record'),
            ),
          ],
        ),
      ),
    );
  }

  void _showApprovalDialog(
    BuildContext context,
    TimeRecord record,
    AdminProvider provider,
    bool approve,
  ) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Approve Proxy Hours' : 'Reject Proxy Hours'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Staff: ${record.staffId}'),
            Text('Job: ${record.jobName}'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: approve ? 'Approval Notes (Optional)' : 'Rejection Reason',
                hintText: 'Enter notes',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await provider.approveProxyHours(
                  recordId: record.id,
                  approved: approve,
                  adminNotes: notesController.text.isEmpty ? null : notesController.text,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Proxy hours ${approve ? "approved" : "rejected"}'),
                    backgroundColor: approve ? Colors.green : Colors.red,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: approve ? Colors.green : Colors.red,
            ),
            child: Text(approve ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }
}
