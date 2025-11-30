// lib/screens/admin/audit_logs.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../models/audit_log_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';

class AuditLogsPage extends StatefulWidget {
  const AuditLogsPage({super.key});

  @override
  State<AuditLogsPage> createState() => _AuditLogsPageState();
}

class _AuditLogsPageState extends State<AuditLogsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedTargetId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Target ID',
                      hintText: 'Enter staff ID, job ID, etc.',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _selectedTargetId = null;
                                });
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedTargetId = value.isEmpty ? null : value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedTargetId = null;
                      _searchController.clear();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Audit Logs List
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, child) {
                return StreamBuilder<List<AuditLog>>(
                  stream: provider.getAuditLogs(_selectedTargetId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    final logs = snapshot.data ?? [];

                    if (logs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _selectedTargetId != null
                                  ? 'No audit logs found for "$_selectedTargetId"'
                                  : 'No audit logs yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return _buildAuditLogCard(context, log);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogCard(BuildContext context, AuditLog log) {
    final actionColor = _getActionColor(log.action);

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
                    color: actionColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getActionDisplayName(log.action),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.history, color: actionColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  'AUDIT',
                  style: TextStyle(
                    color: actionColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (log.targetName != null) ...[
              Row(
                children: [
                  Icon(Icons.business, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    log.targetName!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Time: ${log.timestamp.toString().substring(0, 16)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (log.targetId != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 32),
                  Text(
                    'Target ID: ${log.targetId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'User: ${log.userId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (log.details.isNotEmpty) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                title: Text(
                  'Details (${log.details.length} items)',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: log.details.entries.map((entry) {
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

  Color _getActionColor(String action) {
    switch (action) {
      case 'TEMP_CARD_ISSUED':
        return Colors.blue;
      case 'TEMP_CARD_DEACTIVATED':
        return Colors.orange;
      case 'PROXY_TIME_CREATED':
        return Colors.purple;
      case 'PROXY_HOURS_APPROVED':
        return Colors.green;
      case 'PROXY_HOURS_REJECTED':
        return Colors.red;
      case 'STAFF_INTERFACE_BLOCKED':
        return Colors.red;
      case 'STAFF_INTERFACE_UNBLOCKED':
        return Colors.green;
      case 'QUALITY_FLAG_CREATED':
        return Colors.orange;
      case 'QUALITY_FLAG_RESOLVED':
        return Colors.green;
      case 'B2B_LEAD_ADDED':
        return Colors.blue;
      case 'B2B_LEAD_STATUS_UPDATED':
        return Colors.indigo;
      case 'PAYROLL_FINALIZED':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getActionDisplayName(String action) {
    switch (action) {
      case 'TEMP_CARD_ISSUED':
        return 'Temp Card Issued';
      case 'TEMP_CARD_DEACTIVATED':
        return 'Temp Card Deactivated';
      case 'PROXY_TIME_CREATED':
        return 'Proxy Time Created';
      case 'PROXY_HOURS_APPROVED':
        return 'Proxy Hours Approved';
      case 'PROXY_HOURS_REJECTED':
        return 'Proxy Hours Rejected';
      case 'STAFF_INTERFACE_BLOCKED':
        return 'Staff Blocked';
      case 'STAFF_INTERFACE_UNBLOCKED':
        return 'Staff Unblocked';
      case 'QUALITY_FLAG_CREATED':
        return 'Quality Flag Created';
      case 'QUALITY_FLAG_RESOLVED':
        return 'Quality Flag Resolved';
      case 'B2B_LEAD_ADDED':
        return 'B2B Lead Added';
      case 'B2B_LEAD_STATUS_UPDATED':
        return 'Lead Status Updated';
      case 'PAYROLL_FINALIZED':
        return 'Payroll Finalized';
      default:
        return action.replaceAll('_', ' ');
    }
  }
}
