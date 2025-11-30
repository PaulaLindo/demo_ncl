// lib/screens/staff/enhanced_scheduler_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/scheduler_provider.dart';
import '../../providers/timekeeping_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';
import '../../models/scheduler_models.dart';

class EnhancedSchedulerTab extends StatefulWidget {
  const EnhancedSchedulerTab({super.key});

  @override
  State<EnhancedSchedulerTab> createState() => _EnhancedSchedulerTabState();
}

class _EnhancedSchedulerTabState extends State<EnhancedSchedulerTab> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _selectedView = 'day'; // day, week, month

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSchedulerData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedulerData() async {
    final schedulerProvider = context.read<SchedulerProvider>();
    await schedulerProvider.initializeScheduler();
  }

  @override
  Widget build(BuildContext context) {
    final schedulerProvider = context.watch<SchedulerProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    final currentUser = authProvider.currentUser;
    final staffId = currentUser?.id ?? '';
    
    // Get staff's job assignments
    final staffAssignments = schedulerProvider.staffSchedule[staffId] ?? [];
    final todayAssignments = staffAssignments.where((assignment) => 
        _isSameDay(assignment.scheduledDate, DateTime.now())).toList();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [
          // Header with date selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _changeDate(-1),
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _changeDate(1),
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // View selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildViewChip('Day', 'day'),
                    const SizedBox(width: 8),
                    _buildViewChip('Week', 'week'),
                    const SizedBox(width: 8),
                    _buildViewChip('Month', 'month'),
                  ],
                ),
              ],
            ),
          ),
          
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.secondaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.secondaryColor,
            tabs: const [
              Tab(text: 'Schedule'),
              Tab(text: 'Assignments'),
              Tab(text: 'Transport'),
            ],
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildScheduleView(todayAssignments),
                _buildAssignmentsView(staffAssignments),
                _buildTransportView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewChip(String label, String value) {
    final isSelected = _selectedView == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedView = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withCustomOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.secondaryColor : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleView(List<JobAssignment> assignments) {
    if (assignments.isEmpty) {
      return _buildEmptyState('No assignments scheduled for this day');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return _buildAssignmentCard(assignment);
      },
    );
  }

  Widget _buildAssignmentsView(List<JobAssignment> assignments) {
    final schedulerProvider = context.watch<SchedulerProvider>();
    
    return Column(
      children: [
        // Summary cards
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(child: _buildSummaryCard('Today', assignments.where((a) => _isSameDay(a.scheduledDate, DateTime.now())).length.toString(), Icons.today)),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('This Week', _getWeekAssignments(assignments).length.toString(), Icons.date_range)),
              const SizedBox(width: 8),
              Expanded(child: _buildSummaryCard('Pending', assignments.where((a) => a.status == JobAssignmentStatus.scheduled).length.toString(), Icons.pending)),
            ],
          ),
        ),
        
        // Assignments list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              return _buildDetailedAssignmentCard(assignment);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransportView() {
    final schedulerProvider = context.watch<SchedulerProvider>();
    final authProvider = context.watch<AuthProvider>();
    final staffId = authProvider.currentUser?.id ?? '';
    
    final transportRequests = schedulerProvider.transportRequests
        .where((request) => request.staffId == staffId)
        .toList();

    if (transportRequests.isEmpty) {
      return _buildEmptyState('No transport requests found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transportRequests.length,
      itemBuilder: (context, index) {
        final request = transportRequests[index];
        return _buildTransportCard(request);
      },
    );
  }

  Widget _buildAssignmentCard(JobAssignment assignment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(assignment.status).withCustomOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(assignment.status),
                    color: _getStatusColor(assignment.status),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getServiceName(assignment.serviceId),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(assignment.scheduledDate),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'R${assignment.basePrice.toInt()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Duration: ${assignment.estimatedDuration.inHours}h',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [
                    if (assignment.status == JobAssignmentStatus.scheduled)
                      TextButton(
                        onPressed: () => _startAssignment(assignment),
                        child: const Text('Start'),
                      ),
                    if (assignment.status == JobAssignmentStatus.inProgress)
                      TextButton(
                        onPressed: () => _completeAssignment(assignment),
                        child: const Text('Complete'),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedAssignmentCard(JobAssignment assignment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _getStatusColor(assignment.status).withCustomOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                _getStatusIcon(assignment.status),
                color: _getStatusColor(assignment.status),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getServiceName(assignment.serviceId),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              DateFormat('MMM d').format(assignment.scheduledDate),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        subtitle: Text(
          '${DateFormat('h:mm a').format(assignment.scheduledDate)} • R${assignment.basePrice.toInt()}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Duration', '${assignment.estimatedDuration.inHours} hours'),
                _buildDetailRow('Status', _getStatusText(assignment.status)),
                _buildDetailRow('Customer ID', assignment.customerId),
                if (assignment.customizations.isNotEmpty)
                  _buildDetailRow('Customizations', '${assignment.customizations.length} items'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _viewAssignmentDetails(assignment),
                      child: const Text('View Details'),
                    ),
                    const SizedBox(width: 8),
                    if (assignment.status == JobAssignmentStatus.scheduled)
                      ElevatedButton(
                        onPressed: () => _requestTransport(assignment),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                        ),
                        child: const Text('Request Transport'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportCard(TransportRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTransportStatusColor(request.status).withCustomOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTransportStatusIcon(request.status),
                    color: _getTransportStatusColor(request.status),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transport Request',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getTransportStatusText(request.status),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (request.cost != null)
                  Text(
                    'R${request.cost!.toInt()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Pickup', request.pickupLocation),
            _buildDetailRow('Destination', request.destinationLocation),
            _buildDetailRow('Time', DateFormat('h:mm a').format(request.pickupTime)),
            if (request.uberDriverId != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Driver: ${request.uberDriverId}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (request.uberVehicleInfo != null)
                      Text(
                        request.uberVehicleInfo!,
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
            if (request.trackingUrl != null)
              const SizedBox(height: 8),
            if (request.trackingUrl != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openTracking(request.trackingUrl!),
                  icon: const Icon(Icons.gps_fixed),
                  label: const Text('Track Driver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withCustomOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.secondaryColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later or contact your manager',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  List<JobAssignment> _getWeekAssignments(List<JobAssignment> assignments) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return assignments.where((assignment) {
      final date = assignment.scheduledDate;
      return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
             date.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  Color _getStatusColor(JobAssignmentStatus status) {
    switch (status) {
      case JobAssignmentStatus.scheduled:
        return Colors.blue;
      case JobAssignmentStatus.inProgress:
        return Colors.orange;
      case JobAssignmentStatus.completed:
        return Colors.green;
      case JobAssignmentStatus.needsReview:
        return Colors.red;
      case JobAssignmentStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(JobAssignmentStatus status) {
    switch (status) {
      case JobAssignmentStatus.scheduled:
        return Icons.schedule;
      case JobAssignmentStatus.inProgress:
        return Icons.play_arrow;
      case JobAssignmentStatus.completed:
        return Icons.check_circle;
      case JobAssignmentStatus.needsReview:
        return Icons.warning;
      case JobAssignmentStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(JobAssignmentStatus status) {
    switch (status) {
      case JobAssignmentStatus.scheduled:
        return 'Scheduled';
      case JobAssignmentStatus.inProgress:
        return 'In Progress';
      case JobAssignmentStatus.completed:
        return 'Completed';
      case JobAssignmentStatus.needsReview:
        return 'Needs Review';
      case JobAssignmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getTransportStatusColor(TransportStatus status) {
    switch (status) {
      case TransportStatus.requested:
        return Colors.orange;
      case TransportStatus.confirmed:
        return Colors.blue;
      case TransportStatus.inTransit:
        return Colors.purple;
      case TransportStatus.completed:
        return Colors.green;
      case TransportStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getTransportStatusIcon(TransportStatus status) {
    switch (status) {
      case TransportStatus.requested:
        return Icons.pending;
      case TransportStatus.confirmed:
        return Icons.check_circle;
      case TransportStatus.inTransit:
        return Icons.local_taxi;
      case TransportStatus.completed:
        return Icons.done_all;
      case TransportStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getTransportStatusText(TransportStatus status) {
    switch (status) {
      case TransportStatus.requested:
        return 'Requested';
      case TransportStatus.confirmed:
        return 'Confirmed';
      case TransportStatus.inTransit:
        return 'In Transit';
      case TransportStatus.completed:
        return 'Completed';
      case TransportStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getServiceName(String serviceId) {
    // Map service IDs to readable names
    switch (serviceId) {
      case 'cleaning_basic':
        return 'Basic Cleaning';
      case 'cleaning_deep':
        return 'Deep Cleaning';
      case 'carpet_cleaning':
        return 'Carpet Cleaning';
      default:
        return 'Service';
    }
  }

  // Action methods
  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _startAssignment(JobAssignment assignment) {
    // Implementation for starting assignment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting assignment...')),
    );
  }

  void _completeAssignment(JobAssignment assignment) {
    // Implementation for completing assignment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Completing assignment...')),
    );
  }

  void _viewAssignmentDetails(JobAssignment assignment) {
    // Implementation for viewing assignment details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assignment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${_getServiceName(assignment.serviceId)}'),
            Text('Date: ${DateFormat('MMM d, y').format(assignment.scheduledDate)}'),
            Text('Time: ${DateFormat('h:mm a').format(assignment.scheduledDate)}'),
            Text('Duration: ${assignment.estimatedDuration.inHours} hours'),
            Text('Price: R${assignment.basePrice.toInt()}'),
            Text('Status: ${_getStatusText(assignment.status)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _requestTransport(JobAssignment assignment) {
    // Implementation for requesting transport
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Requesting transport...')),
    );
  }

  void _openTracking(String trackingUrl) {
    // Implementation for opening tracking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening tracking...')),
    );
  }
}
