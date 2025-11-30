// lib/screens/admin/payroll_management.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../models/payroll_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';

class PayrollManagementPage extends StatefulWidget {
  const PayrollManagementPage({super.key});

  @override
  State<PayrollManagementPage> createState() => _PayrollManagementPageState();
}

class _PayrollManagementPageState extends State<PayrollManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payroll Management'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showGeneratePayrollDialog(context),
            icon: const Icon(Icons.add),
            tooltip: 'Generate Payroll Report',
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          return StreamBuilder<List<PayrollReport>>(
            stream: provider.payrollReportsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final reports = snapshot.data ?? [];

              if (reports.isEmpty) {
                return const Center(
                  child: Text('No payroll reports yet'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return _buildPayrollReportCard(context, report, provider);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPayrollReportCard(
    BuildContext context,
    PayrollReport report,
    AdminProvider provider,
  ) {
    final statusColor = _getStatusColor(report.status);
    final canFinalize = report.status == PayrollStatus.draft;

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
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (canFinalize)
                  IconButton(
                    onPressed: () => _showFinalizeDialog(context, report, provider),
                    icon: const Icon(Icons.lock_open, color: Colors.green),
                    tooltip: 'Finalize Payroll',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.attach_money, color: AppTheme.primaryPurple),
                const SizedBox(width: 8),
                Text(
                  'Total Amount: \$${report.totalAmount.toStringAsFixed(2)}',
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
                Icon(Icons.date_range, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Period: ${report.startDate.toString().substring(0, 10)} - ${report.endDate.toString().substring(0, 10)}',
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
                Icon(Icons.access_time, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Time Records: ${report.timeRecordIds.length}',
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
                  'Created: ${report.createdAt.toString().substring(0, 16)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (report.finalizedAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 32),
                  Text(
                    'Finalized: ${report.finalizedAt!.toString().substring(0, 16)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            if (report.paidAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 32),
                  Text(
                    'Paid: ${report.paidAt!.toString().substring(0, 16)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withCustomOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: AppTheme.primaryPurple, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This report includes ${report.timeRecordIds.length} approved time records',
                      style: TextStyle(
                        color: AppTheme.primaryPurple,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(PayrollStatus status) {
    switch (status) {
      case PayrollStatus.draft:
        return Colors.grey;
      case PayrollStatus.review:
        return Colors.orange;
      case PayrollStatus.approved:
        return Colors.blue;
      case PayrollStatus.finalized:
        return Colors.purple;
      case PayrollStatus.paid:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showGeneratePayrollDialog(BuildContext context) {
    DateTime? startDate;
    DateTime? endDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Generate Payroll Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(startDate?.toString().substring(0, 10) ?? 'Select start date'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(const Duration(days: 30)),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      startDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('End Date'),
                subtitle: Text(endDate?.toString().substring(0, 10) ?? 'Select end date'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      endDate = date;
                    });
                  }
                },
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
                if (startDate == null || endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select both start and end dates'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (endDate!.isBefore(startDate!)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('End date must be after start date'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final provider = context.read<AdminProvider>();
                  await provider.generateDraftPayroll(
                    startDate: startDate!,
                    endDate: endDate!,
                  );

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payroll report generated'),
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
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFinalizeDialog(
    BuildContext context,
    PayrollReport report,
    AdminProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalize Payroll Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Period: ${report.startDate.toString().substring(0, 10)} - ${report.endDate.toString().substring(0, 10)}'),
            Text('Total Amount: \$${report.totalAmount.toStringAsFixed(2)}'),
            Text('Time Records: ${report.timeRecordIds.length}'),
            const SizedBox(height: 16),
            const Text(
              'Once finalized, this payroll report will be locked and cannot be modified.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
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
              try {
                await provider.finalizePayroll(report.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payroll report finalized'),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Finalize'),
          ),
        ],
      ),
    );
  }
}
