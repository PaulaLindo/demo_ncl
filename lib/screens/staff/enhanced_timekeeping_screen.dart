// lib/screens/staff/enhanced_timekeeping_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/time_record_model.dart';
import '../../providers/timekeeping_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/color_utils.dart';

class EnhancedTimekeepingScreen extends StatefulWidget {
  const EnhancedTimekeepingScreen({super.key});

  @override
  State<EnhancedTimekeepingScreen> createState() => _EnhancedTimekeepingScreenState();
}

class _EnhancedTimekeepingScreenState extends State<EnhancedTimekeepingScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTimekeepingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTimekeepingData() async {
    setState(() => _isLoading = true);
    
    try {
      final timekeepingProvider = context.read<TimekeepingProvider>();
      await timekeepingProvider.loadInitialData();
    } catch (e) {
      _showErrorSnackBar('Failed to load timekeeping data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.currentUser?.name ?? 'Staff Member';

    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        title: Text('Timekeeping - $userName'),
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.watch<ThemeProvider>().primaryColor,
          labelColor: context.watch<ThemeProvider>().primaryColor,
          unselectedLabelColor: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.access_time), text: 'Clock In/Out'),
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.insert_chart), text: 'Statistics'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildClockInOutTab(),
                _buildHistoryTab(),
                _buildStatisticsTab(),
              ],
            ),
    );
  }

  Widget _buildClockInOutTab() {
    return Consumer<TimekeepingProvider>(
      builder: (context, timekeepingProvider, child) {
        final activeRecord = timekeepingProvider.timeRecords
            .where((record) => record.status == TimeRecordStatus.inProgress)
            .firstOrNull;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Current Status Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        activeRecord != null ? 'Currently Clocked In' : 'Currently Clocked Out',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: activeRecord != null ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (activeRecord != null) ...[
                        Text(
                          'Clock In: ${_formatTime(activeRecord.checkInTime)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Duration: ${_calculateDuration(activeRecord.checkInTime)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (activeRecord.jobName != null)
                          Text(
                            'Job: ${activeRecord.jobName}',
                            style: const TextStyle(fontSize: 16),
                          ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Clock In/Out Button
              if (activeRecord == null)
                _buildClockInButton()
              else
                _buildClockOutButton(activeRecord),

              const SizedBox(height: 24),

              // Quick Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showAddManualEntry(),
                              icon: const Icon(Icons.add),
                              label: const Text('Manual Entry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showBreakDialog(),
                              icon: const Icon(Icons.coffee),
                              label: const Text('Start Break'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Today's Summary
              Consumer<TimekeepingProvider>(
                builder: (context, provider, child) {
                  final todayRecords = provider.timeRecords.where((record) =>
                      _isSameDay(record.checkInTime, DateTime.now())).toList();
                  
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Today's Summary",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem(
                                'Shifts',
                                '${todayRecords.length}',
                                Icons.work,
                                Colors.blue,
                              ),
                              _buildSummaryItem(
                                'Hours',
                                _calculateTodayHours(todayRecords),
                                Icons.access_time,
                                Colors.green,
                              ),
                              _buildSummaryItem(
                                'Status',
                                provider.timeRecords.any((r) => r.status == TimeRecordStatus.inProgress) 
                                    ? 'Working' : 'Off',
                                Icons.circle,
                                provider.timeRecords.any((r) => r.status == TimeRecordStatus.inProgress) 
                                    ? Colors.green : Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClockInButton() {
    return Consumer<TimekeepingProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : _clockIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.watch<ThemeProvider>().primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.login, size: 48),
                const SizedBox(height: 8),
                Text(
                  'Clock In',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClockOutButton(TimeRecord activeRecord) {
    return Consumer<TimekeepingProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : () => _clockOut(activeRecord),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout, size: 48),
                const SizedBox(height: 8),
                Text(
                  'Clock Out',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withCustomOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<TimekeepingProvider>(
      builder: (context, provider, child) {
        final sortedRecords = List<TimeRecord>.from(provider.timeRecords)
          ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

        if (sortedRecords.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No time records yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedRecords.length,
          itemBuilder: (context, index) {
            final record = sortedRecords[index];
            return _buildTimeRecordCard(record);
          },
        );
      },
    );
  }

  Widget _buildTimeRecordCard(TimeRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(record.checkInTime),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                _buildStatusChip(record.status),
              ],
            ),
            const SizedBox(height: 8),
            if (record.jobName != null)
              Text(
                'Job: ${record.jobName}',
                style: const TextStyle(fontSize: 14),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'In: ${_formatTime(record.checkInTime)}',
                  style: const TextStyle(fontSize: 14),
                ),
                if (record.checkOutTime != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Out: ${_formatTime(record.checkOutTime!)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
            if (record.checkOutTime != null) ...[
              const SizedBox(height: 4),
              Text(
                'Duration: ${_calculateDuration(record.checkInTime, record.checkOutTime)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
            if (record.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${record.notes}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return Consumer<TimekeepingProvider>(
      builder: (context, provider, child) {
        final thisWeekRecords = _getRecordsForWeek(provider.timeRecords, DateTime.now());
        final thisMonthRecords = _getRecordsForMonth(provider.timeRecords, DateTime.now());

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Weekly Stats
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This Week',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Hours',
                            _calculateTotalHours(thisWeekRecords),
                            Colors.blue,
                          ),
                          _buildStatItem(
                            'Shifts',
                            '${thisWeekRecords.length}',
                            Colors.green,
                          ),
                          _buildStatItem(
                            'Avg/Day',
                            _calculateAverageHours(thisWeekRecords),
                            Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Monthly Stats
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This Month',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Hours',
                            _calculateTotalHours(thisMonthRecords),
                            Colors.blue,
                          ),
                          _buildStatItem(
                            'Shifts',
                            '${thisMonthRecords.length}',
                            Colors.green,
                          ),
                          _buildStatItem(
                            'Avg/Day',
                            _calculateAverageHours(thisMonthRecords),
                            Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Recent Activity
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Activity',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ...provider.timeRecords
                          .take(5)
                          .map((record) => _buildActivityItem(record)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildActivityItem(TimeRecord record) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            record.status == TimeRecordStatus.inProgress ? Icons.play_arrow : Icons.check,
            color: record.status == TimeRecordStatus.inProgress ? Colors.green : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_formatDate(record.checkInTime)} - ${record.jobName ?? 'General'}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TimeRecordStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case TimeRecordStatus.inProgress:
        color = Colors.green;
        text = 'Active';
        break;
      case TimeRecordStatus.completed:
        color = Colors.blue;
        text = 'Completed';
        break;
      case TimeRecordStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
      case TimeRecordStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
      case TimeRecordStatus.pendingApproval:
        color = Colors.orange;
        text = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withCustomOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Helper methods
  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  String _calculateDuration(DateTime start, [DateTime? end]) {
    final endTime = end ?? DateTime.now();
    final duration = endTime.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _calculateTodayHours(List<TimeRecord> records) {
    final totalMinutes = records.fold<int>(0, (sum, record) {
      final end = record.checkOutTime ?? DateTime.now();
      return sum + end.difference(record.checkInTime).inMinutes;
    });
    
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _calculateTotalHours(List<TimeRecord> records) {
    final totalMinutes = records.fold<int>(0, (sum, record) {
      if (record.checkOutTime != null) {
        return sum + record.checkOutTime!.difference(record.checkInTime).inMinutes;
      }
      return sum;
    });
    
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _calculateAverageHours(List<TimeRecord> records) {
    if (records.isEmpty) return '0h';
    
    final totalMinutes = records.fold<int>(0, (sum, record) {
      if (record.checkOutTime != null) {
        return sum + record.checkOutTime!.difference(record.checkInTime).inMinutes;
      }
      return sum;
    });
    
    final averageMinutes = totalMinutes ~/ records.length;
    final hours = averageMinutes ~/ 60;
    final minutes = averageMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  List<TimeRecord> _getRecordsForWeek(List<TimeRecord> records, DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday % 7));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return records.where((record) {
      return record.checkInTime.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
             record.checkInTime.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  List<TimeRecord> _getRecordsForMonth(List<TimeRecord> records, DateTime date) {
    return records.where((record) {
      return record.checkInTime.year == date.year && 
             record.checkInTime.month == date.month;
    }).toList();
  }

  // Action methods
  Future<void> _clockIn() async {
    try {
      final timekeepingProvider = context.read<TimekeepingProvider>();
      
      await timekeepingProvider.checkIn(
        'default_job', // TODO: Get from job selection
      );
      
      _showSuccessSnackBar('Clocked in successfully');
      await _loadTimekeepingData();
    } catch (e) {
      _showErrorSnackBar('Error clocking in: $e');
    }
  }

  Future<void> _clockOut(TimeRecord activeRecord) async {
    try {
      final timekeepingProvider = context.read<TimekeepingProvider>();
      
      await timekeepingProvider.checkOut();
      
      _showSuccessSnackBar('Clocked out successfully');
      await _loadTimekeepingData();
    } catch (e) {
      _showErrorSnackBar('Error clocking out: $e');
    }
  }

  void _showAddManualEntry() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Manual Entry'),
        content: const Text('Manual entry feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBreakDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Break'),
        content: const Text('Break tracking feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
