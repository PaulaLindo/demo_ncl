// lib/screens/staff/history_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/timekeeping_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/time_record_model.dart';

import '../../utils/color_utils.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  DateTimeRange? _dateRange;
  String _sortBy = 'newest';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimekeepingProvider>();
    var records = provider.timeRecords;

    // Apply filters
    if (_dateRange != null) {
      records = records.where((r) => 
        r.checkInTime.isAfter(_dateRange!.start) && 
        r.checkInTime.isBefore(_dateRange!.end)
      ).toList();
    }

    // Apply sorting
    records.sort((a, b) => _sortBy == 'newest' 
      ? b.checkInTime.compareTo(a.checkInTime)
      : a.checkInTime.compareTo(b.checkOutTime ?? DateTime.now())
    );

    return Column(
      children: [
        _buildFilterBar(context),
        Expanded(
          child: records.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: records.length,
                  itemBuilder: (ctx, i) => _TimeRecordCard(record: records[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No time records found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your time records will appear here',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Date Range Picker
            TextButton.icon(
              icon: const Icon(Icons.date_range, size: 20),
              label: Text(_dateRange == null 
                ? 'All Time' 
                : '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}'
              ),
              onPressed: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  initialDateRange: _dateRange,
                );
                if (range != null) {
                  setState(() => _dateRange = range);
                }
              },
            ),
            const Spacer(),
            // Sort Dropdown
            DropdownButton<String>(
              value: _sortBy,
              items: const [
                DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
              ],
              onChanged: (value) => setState(() => _sortBy = value!),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeRecordCard extends StatelessWidget {
  final TimeRecord record;
  
  const _TimeRecordCard({required this.record});

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  String _getTypeLabel(TimeRecordType type) {
    switch (type) {
      case TimeRecordType.self:
        return 'SELF';
      case TimeRecordType.proxy:
        return 'PROXY';
      case TimeRecordType.manual:
        return 'MANUAL';
    }
  }

  Color _getTypeColor(TimeRecordType type) {
    switch (type) {
      case TimeRecordType.self:
        return Colors.blue;
      case TimeRecordType.proxy:
        return Colors.purple;
      case TimeRecordType.manual:
        return Colors.orange;
    }
  }

  String _getStatusLabel(TimeRecordStatus status) {
    switch (status) {
      case TimeRecordStatus.inProgress:
        return 'In Progress';
      case TimeRecordStatus.completed:
        return 'Completed';
      case TimeRecordStatus.pendingApproval:
        return 'Pending Approval';
      case TimeRecordStatus.rejected:
        return 'Rejected';
      case TimeRecordStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(TimeRecordStatus status) {
    switch (status) {
      case TimeRecordStatus.completed:
        return Colors.green;
      case TimeRecordStatus.inProgress:
        return Colors.blue;
      case TimeRecordStatus.pendingApproval:
        return Colors.orange;
      case TimeRecordStatus.rejected:
        return Colors.red;
      case TimeRecordStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(TimeRecordStatus status) {
    switch (status) {
      case TimeRecordStatus.completed:
        return Icons.check_circle;
      case TimeRecordStatus.inProgress:
        return Icons.timer;
      case TimeRecordStatus.pendingApproval:
        return Icons.pending;
      case TimeRecordStatus.rejected:
        return Icons.close;
      case TimeRecordStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final checkInStr = DateFormat('HH:mm').format(record.checkInTime);
    final checkOutStr = record.checkOutTime != null 
        ? DateFormat('HH:mm').format(record.checkOutTime!)
        : 'In Progress';
    final dateStr = DateFormat('MMM d, yyyy').format(record.checkInTime);
    
    final duration = record.checkOutTime != null
        ? Duration(minutes: record.calculatedDuration ?? 0)
        : DateTime.now().difference(record.checkInTime);
    
    final typeColor = _getTypeColor(record.type);
    final statusColor = _getStatusColor(record.status);
    final statusLabel = _getStatusLabel(record.status);
    final typeLabel = _getTypeLabel(record.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withCustomOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job Name & Type Badge
          Row(
            children: [
              Expanded(
                child: Text(
                  record.jobName ?? 'Unknown Job',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withCustomOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  typeLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 
                      (typeColor.r * 255 * 0.7).round().clamp(0, 255),
                      (typeColor.g * 255 * 0.7).round().clamp(0, 255),
                      (typeColor.b * 255 * 0.7).round().clamp(0, 255)),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Time Details
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '$dateStr | $checkInStr - $checkOutStr',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Duration & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.green.shade700),
                  const SizedBox(width: 4),
                  Text(
                    'Duration: ${_formatDuration(duration)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withCustomOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(record.status),
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}