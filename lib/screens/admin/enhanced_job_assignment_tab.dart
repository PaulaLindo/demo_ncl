// lib/screens/admin/enhanced_job_assignment_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/scheduler_provider.dart';
import '../../providers/staff_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';
import '../../models/scheduler_models.dart';

class EnhancedJobAssignmentTab extends StatefulWidget {
  const EnhancedJobAssignmentTab({super.key});

  @override
  State<EnhancedJobAssignmentTab> createState() => _EnhancedJobAssignmentTabState();
}

class _EnhancedJobAssignmentTabState extends State<EnhancedJobAssignmentTab> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _selectedView = 'day'; // day, week, month
  String _searchQuery = '';
  JobAssignmentStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final schedulerProvider = context.read<SchedulerProvider>();
    await schedulerProvider.initializeScheduler();
  }

  @override
  Widget build(BuildContext context) {
    final schedulerProvider = context.watch<SchedulerProvider>();
    final staffProvider = context.watch<StaffProvider>();
    
    final allAssignments = schedulerProvider.jobAssignments;
    final filteredAssignments = _filterAssignments(allAssignments);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Column(
        children: [
          // Header with filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.assignment, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Job Assignment Management',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Manage staff assignments and schedules',
                            style: TextStyle(
                              color: Colors.white.withCustomOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _createNewAssignment,
                      icon: const Icon(Icons.add, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withCustomOpacity(0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search and filters
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search assignments...',
                          hintStyle: TextStyle(color: Colors.white.withCustomOpacity(0.6)),
                          prefixIcon: Icon(Icons.search, color: Colors.white.withCustomOpacity(0.6)),
                          filled: true,
                          fillColor: Colors.white.withCustomOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    PopupMenuButton<JobAssignmentStatus>(
                      icon: Icon(Icons.filter_list, color: Colors.white.withCustomOpacity(0.8)),
                      color: const Color(0xFF1E293B),
                      onSelected: (status) => setState(() => _statusFilter = status),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withCustomOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.filter_list, color: Colors.white.withCustomOpacity(0.8)),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: null,
                          child: Text('All Status', style: TextStyle(color: Colors.white)),
                        ),
                        ...JobAssignmentStatus.values.map((status) => PopupMenuItem(
                          value: status,
                          child: Text(_getStatusText(status), style: const TextStyle(color: Colors.white)),
                        )),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _buildSummaryCard('Total', filteredAssignments.length.toString(), Icons.assignment)),
                const SizedBox(width: 8),
                Expanded(child: _buildSummaryCard('Today', _getTodayAssignments(filteredAssignments).length.toString(), Icons.today)),
                const SizedBox(width: 8),
                Expanded(child: _buildSummaryCard('Pending', _getPendingAssignments(filteredAssignments).length.toString(), Icons.pending)),
                const SizedBox(width: 8),
                Expanded(child: _buildSummaryCard('In Progress', _getInProgressAssignments(filteredAssignments).length.toString(), Icons.play_arrow)),
              ],
            ),
          ),
          
          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF1E293B),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF1E293B),
            tabs: const [
              Tab(text: 'Assignments'),
              Tab(text: 'Schedule'),
              Tab(text: 'Staff'),
              Tab(text: 'Analytics'),
            ],
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAssignmentsView(filteredAssignments),
                _buildScheduleView(filteredAssignments),
                _buildStaffView(),
                _buildAnalyticsView(filteredAssignments),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsView(List<JobAssignment> assignments) {
    if (assignments.isEmpty) {
      return _buildEmptyState('No assignments found');
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

  Widget _buildScheduleView(List<JobAssignment> assignments) {
    return Column(
      children: [
        // Date selector
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _changeDate(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _changeDate(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        
        // Schedule timeline
        Expanded(
          child: _buildScheduleTimeline(assignments),
        ),
      ],
    );
  }

  Widget _buildStaffView() {
    final staffProvider = context.watch<StaffProvider>();
    final schedulerProvider = context.watch<SchedulerProvider>();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: staffProvider.staff.length,
      itemBuilder: (context, index) {
        final staff = staffProvider.staff[index];
        final staffAssignments = schedulerProvider.staffSchedule[staff.id] ?? [];
        
        return _buildStaffCard(staff, staffAssignments);
      },
    );
  }

  Widget _buildAnalyticsView(List<JobAssignment> assignments) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analytics cards
          Row(
            children: [
              Expanded(child: _buildAnalyticsCard('Completion Rate', '${_getCompletionRate(assignments)}%', Icons.trending_up)),
              const SizedBox(width: 8),
              Expanded(child: _buildAnalyticsCard('Avg Duration', '${_getAverageDuration(assignments)}h', Icons.schedule)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildAnalyticsCard('Revenue', 'R${_getTotalRevenue(assignments)}', Icons.attach_money)),
              const SizedBox(width: 8),
              Expanded(child: _buildAnalyticsCard('Staff Utilization', '${_getStaffUtilization(assignments)}%', Icons.people)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Status distribution
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status Distribution',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...JobAssignmentStatus.values.map((status) {
                    final count = assignments.where((a) => a.status == status).length;
                    final percentage = assignments.isNotEmpty ? (count / assignments.length * 100).round() : 0;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_getStatusText(status)),
                              Text('$count ($percentage%)'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: assignments.isNotEmpty ? count / assignments.length : 0,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(status)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(JobAssignment assignment) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getServiceName(assignment.serviceId),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Staff: ${assignment.staffId} • Customer: ${assignment.customerId}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
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
                _buildDetailRow('Service ID', assignment.serviceId),
                _buildDetailRow('Staff ID', assignment.staffId),
                _buildDetailRow('Customer ID', assignment.customerId),
                _buildDetailRow('Duration', '${assignment.estimatedDuration.inHours} hours'),
                _buildDetailRow('Base Price', 'R${assignment.basePrice.toInt()}'),
                _buildDetailRow('Status', _getStatusText(assignment.status)),
                _buildDetailRow('Created', DateFormat('MMM d, y h:mm a').format(assignment.createdAt)),
                if (assignment.customizations.isNotEmpty)
                  _buildDetailRow('Customizations', '${assignment.customizations.length} items'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _editAssignment(assignment),
                      child: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    if (assignment.status == JobAssignmentStatus.scheduled)
                      ElevatedButton(
                        onPressed: () => _assignStaff(assignment),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                        ),
                        child: const Text('Assign Staff'),
                      ),
                    const SizedBox(width: 8),
                    if (assignment.status == JobAssignmentStatus.scheduled)
                      OutlinedButton(
                        onPressed: () => _cancelAssignment(assignment),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Cancel'),
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

  Widget _buildStaffCard(User staff, List<JobAssignment> assignments) {
    final todayAssignments = assignments.where((a) => _isToday(a.scheduledDate)).length;
    final upcomingAssignments = assignments.where((a) => a.scheduledDate.isAfter(DateTime.now())).length;
    
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
                CircleAvatar(
                  backgroundColor: AppTheme.primaryPurple.withCustomOpacity(0.1),
                  child: Icon(Icons.person, color: AppTheme.primaryPurple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.firstName ?? 'Staff',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        staff.email ?? 'No email',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (action) => _handleStaffAction(staff.id, action),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view_schedule', child: Text('View Schedule')),
                    const PopupMenuItem(value: 'assign_job', child: Text('Assign Job')),
                    const PopupMenuItem(value: 'view_profile', child: Text('View Profile')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStaffStat('Today', todayAssignments.toString()),
                _buildStaffStat('Upcoming', upcomingAssignments.toString()),
                _buildStaffStat('Total', assignments.length.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleTimeline(List<JobAssignment> assignments) {
    final todayAssignments = assignments.where((a) => _isToday(a.scheduledDate)).toList();
    
    if (todayAssignments.isEmpty) {
      return _buildEmptyState('No assignments scheduled for today');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todayAssignments.length,
      itemBuilder: (context, index) {
        final assignment = todayAssignments[index];
        return _buildTimelineItem(assignment);
      },
    );
  }

  Widget _buildTimelineItem(JobAssignment assignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time indicator
          SizedBox(
            width: 60,
            child: Text(
              DateFormat('h:mm a').format(assignment.scheduledDate),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          
          // Timeline line
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _getStatusColor(assignment.status),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(assignment.status),
              color: Colors.white,
              size: 12,
            ),
          ),
          
          // Assignment details
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getServiceName(assignment.serviceId),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Staff: ${assignment.staffId}'),
                    Text('Customer: ${assignment.customerId}'),
                    Text('Duration: ${assignment.estimatedDuration.inHours}h'),
                  ],
                ),
              ),
            ),
          ),
        ],
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
          Icon(icon, color: const Color(0xFF1E293B), size: 20),
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

  Widget _buildAnalyticsCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.secondaryColor, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
            width: 100,
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
            Icons.assignment_outlined,
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
        ],
      ),
    );
  }

  // Helper methods
  List<JobAssignment> _filterAssignments(List<JobAssignment> assignments) {
    var filtered = assignments;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((assignment) =>
          assignment.serviceId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          assignment.staffId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          assignment.customerId.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    if (_statusFilter != null) {
      filtered = filtered.where((assignment) => assignment.status == _statusFilter).toList();
    }
    
    return filtered;
  }

  List<JobAssignment> _getTodayAssignments(List<JobAssignment> assignments) {
    return assignments.where((assignment) => _isToday(assignment.scheduledDate)).toList();
  }

  List<JobAssignment> _getPendingAssignments(List<JobAssignment> assignments) {
    return assignments.where((assignment) => assignment.status == JobAssignmentStatus.scheduled).toList();
  }

  List<JobAssignment> _getInProgressAssignments(List<JobAssignment> assignments) {
    return assignments.where((assignment) => assignment.status == JobAssignmentStatus.inProgress).toList();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _getServiceName(String serviceId) {
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

  double _getCompletionRate(List<JobAssignment> assignments) {
    if (assignments.isEmpty) return 0.0;
    final completed = assignments.where((a) => a.status == JobAssignmentStatus.completed).length;
    return (completed / assignments.length * 100).roundToDouble();
  }

  double _getAverageDuration(List<JobAssignment> assignments) {
    if (assignments.isEmpty) return 0.0;
    final totalDuration = assignments.fold<Duration>(
      Duration.zero,
      (sum, assignment) => sum + assignment.estimatedDuration,
    );
    return (totalDuration.inHours / assignments.length).roundToDouble();
  }

  double _getTotalRevenue(List<JobAssignment> assignments) {
    return assignments.fold<double>(
      0.0,
      (sum, assignment) => sum + assignment.basePrice,
    ).roundToDouble();
  }

  double _getStaffUtilization(List<JobAssignment> assignments) {
    // Simplified calculation - in real app would consider staff availability
    if (assignments.isEmpty) return 0.0;
    return 75.0; // Mock value
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

  void _createNewAssignment() {
    // Implementation for creating new assignment
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Assignment'),
        content: const Text('Assignment creation dialog would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _editAssignment(JobAssignment assignment) {
    // Implementation for editing assignment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit assignment functionality')),
    );
  }

  void _assignStaff(JobAssignment assignment) {
    // Implementation for assigning staff
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assign staff functionality')),
    );
  }

  void _cancelAssignment(JobAssignment assignment) {
    // Implementation for canceling assignment
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Assignment'),
        content: const Text('Are you sure you want to cancel this assignment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Assignment cancelled')),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _handleStaffAction(String staffId, String action) {
    switch (action) {
      case 'view_schedule':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('View schedule for $staffId')),
        );
        break;
      case 'assign_job':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Assign job to $staffId')),
        );
        break;
      case 'view_profile':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('View profile for $staffId')),
        );
        break;
    }
  }
}
