// lib/screens/admin/quality_audit_management.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../models/quality_flag_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';

class QualityAuditManagementPage extends StatefulWidget {
  const QualityAuditManagementPage({super.key});

  @override
  State<QualityAuditManagementPage> createState() => _QualityAuditManagementPageState();
}

class _QualityAuditManagementPageState extends State<QualityAuditManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Audit Management'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showCreateQualityFlagDialog(context),
            icon: const Icon(Icons.add),
            tooltip: 'Flag Quality Issue',
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          return StreamBuilder<List<QualityFlag>>(
            stream: provider.qualityFlagsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final flags = snapshot.data ?? [];

              if (flags.isEmpty) {
                return const Center(
                  child: Text('No quality flags yet'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: flags.length,
                itemBuilder: (context, index) {
                  final flag = flags[index];
                  return _buildQualityFlagCard(context, flag, provider);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildQualityFlagCard(
    BuildContext context,
    QualityFlag flag,
    AdminProvider provider,
  ) {
    final isResolved = flag.status == QualityFlagStatus.resolved;
    final severityColor = _getSeverityColor(flag.severity);

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
                    color: isResolved ? Colors.green : severityColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isResolved ? 'Resolved' : 'Pending',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withCustomOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Severity ${flag.severity}',
                    style: TextStyle(
                      color: severityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (!isResolved)
                  IconButton(
                    onPressed: () => _showResolveDialog(context, flag, provider),
                    icon: const Icon(Icons.check, color: Colors.green),
                    tooltip: 'Resolve',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.flag, color: AppTheme.primaryPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    flag.issueType,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
                  'Job: ${flag.jobName}',
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
                Icon(Icons.person, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Staff: ${flag.staffName}',
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
                  'Created: ${flag.createdAt.toString().substring(0, 16)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              flag.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            if (flag.resolution != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withCustomOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Resolution',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flag.resolution!,
                      style: TextStyle(
                        color: Colors.green[700],
                      ),
                    ),
                    if (flag.resolvedBy != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Resolved by: ${flag.resolvedBy}',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      case 5:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showCreateQualityFlagDialog(BuildContext context) {
    final jobIdController = TextEditingController();
    final jobNameController = TextEditingController();
    final staffIdController = TextEditingController();
    final staffNameController = TextEditingController();
    final issueTypeController = TextEditingController();
    final descriptionController = TextEditingController();
    int severity = 3;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Flag Quality Issue'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  controller: issueTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Issue Type',
                    hintText: 'e.g., Cleaning Quality, Customer Complaint',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe the issue in detail',
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Severity (1-5):'),
                    Row(
                      children: List.generate(5, (index) {
                        final value = index + 1;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('$value'),
                            selected: severity == value,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  severity = value;
                                });
                              }
                            },
                            backgroundColor: _getSeverityColor(value).withCustomOpacity(0.2),
                            selectedColor: _getSeverityColor(value),
                            labelStyle: TextStyle(
                              color: severity == value ? Colors.white : _getSeverityColor(value),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
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
                if (jobIdController.text.isEmpty ||
                    jobNameController.text.isEmpty ||
                    staffIdController.text.isEmpty ||
                    staffNameController.text.isEmpty ||
                    issueTypeController.text.isEmpty ||
                    descriptionController.text.isEmpty) {
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
                  await provider.flagQualityIssue(
                    jobId: jobIdController.text,
                    jobName: jobNameController.text,
                    staffId: staffIdController.text,
                    staffName: staffNameController.text,
                    issueType: issueTypeController.text,
                    description: descriptionController.text,
                    severity: severity,
                  );

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quality flag created'),
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
              child: const Text('Create Flag'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResolveDialog(
    BuildContext context,
    QualityFlag flag,
    AdminProvider provider,
  ) {
    final resolutionController = TextEditingController();
    final resolvedByController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Quality Flag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Issue: ${flag.issueType}'),
            Text('Description: ${flag.description}'),
            const SizedBox(height: 16),
            TextField(
              controller: resolutionController,
              decoration: const InputDecoration(
                labelText: 'Resolution',
                hintText: 'Describe how this was resolved',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resolvedByController,
              decoration: const InputDecoration(
                labelText: 'Resolved By',
                hintText: 'Enter your name',
              ),
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
              if (resolutionController.text.isEmpty || resolvedByController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await provider.resolveQualityFlag(
                  flag.id,
                  resolutionController.text,
                  resolvedByController.text,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Quality flag resolved'),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }
}
