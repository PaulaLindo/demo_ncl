// lib/screens/admin/admin_timekeeping_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/timekeeping_provider.dart';
import '../../models/time_record_model.dart';

class AdminTimekeepingScreen extends StatefulWidget {
  const AdminTimekeepingScreen({super.key});

  @override
  State<AdminTimekeepingScreen> createState() => _AdminTimekeepingScreenState();
}

class _AdminTimekeepingScreenState extends State<AdminTimekeepingScreen> {
  DateTimeRange? _dateRange;
  String _selectedUser = 'All Users';
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
      : a.checkInTime.compareTo(b.checkInTime)
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildFilterBar(context),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: records.length,
              itemBuilder: (ctx, i) => _TimeRecordCard(record: records[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Date Range Picker
            TextButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text(_dateRange == null 
                ? 'Select Date Range' 
                : '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}'
              ),
              onPressed: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (range != null) {
                  setState(() => _dateRange = range);
                }
              },
            ),
            const SizedBox(width: 16),
            // User Filter
            DropdownButton<String>(
              value: _selectedUser,
              items: const [
                DropdownMenuItem(value: 'All Users', child: Text('All Users')),
                // Add more users as needed
              ],
              onChanged: (value) => setState(() => _selectedUser = value!),
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

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TimekeepingProvider>();
    final job = provider.getJobById(record.jobId);
    final theme = Theme.of(context);
    final duration = record.checkOutTime != null 
        ? record.checkOutTime!.difference(record.checkInTime)
        : DateTime.now().difference(record.checkInTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.access_time, size: 32),
        title: Text(
          job?.title ?? 'Unknown Job',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('User: ${record.staffId}'), // Replace with actual user name
            Text('Location: ${job?.location ?? 'N/A'}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${_formatTime(record.checkInTime)} - ${_formatTime(record.checkOutTime ?? DateTime.now())}',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  '${duration.inHours}h ${duration.inMinutes % 60}m',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: record.checkOutTime == null
            ? const Chip(
                label: Text('In Progress', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.orange,
              )
            : null,
      ),
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }
}