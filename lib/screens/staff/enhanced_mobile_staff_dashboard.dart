// lib/screens/staff/enhanced_mobile_staff_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/staff_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/color_utils.dart';
import '../../../models/job_model.dart';
import 'enhanced_mobile_timekeeping_tab.dart';
import 'enhanced_mobile_schedule_tab.dart';
import 'enhanced_mobile_profile_tab.dart';
import 'enhanced_scheduler_tab.dart';

class EnhancedMobileStaffDashboard extends StatefulWidget {
  const EnhancedMobileStaffDashboard({super.key});

  @override
  State<EnhancedMobileStaffDashboard> createState() => _EnhancedMobileStaffDashboardState();
}

class _EnhancedMobileStaffDashboardState extends State<EnhancedMobileStaffDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final staffProvider = context.read<StaffProvider>();
    await staffProvider.loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final staffProvider = context.watch<StaffProvider>();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.secondaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Hi, ${authProvider.currentUser?.firstName ?? 'Staff'}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.secondaryColor,
                        AppTheme.secondaryColor.withCustomOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withCustomOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        top: 60,
                        child: Icon(
                          Icons.work_rounded,
                          size: 100,
                          color: Colors.white.withCustomOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withCustomOpacity(0.7),
                tabs: const [
                  Tab(text: 'Dashboard'),
                  Tab(text: 'Schedule'),
                  Tab(text: 'Scheduler'),
                  Tab(text: 'Timekeeping'),
                  Tab(text: 'Profile'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDashboardTab(),
            _buildScheduleTab(),
            const EnhancedSchedulerTab(),
            _buildTimekeepingTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickActions,
        backgroundColor: AppTheme.secondaryColor,
        icon: const Icon(Icons.flash_on),
        label: const Text('Quick Actions'),
      ),
    );
  }

  Widget _buildDashboardTab() {
    final staffProvider = context.watch<StaffProvider>();
    final todayJobs = staffProvider.jobs
        .where((job) => _isToday(job.startTime))
        .toList();
    final upcomingJobs = staffProvider.jobs
        .where((job) => job.startTime.isAfter(DateTime.now()))
        .take(3)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Overview
          _buildTodayOverview(todayJobs),
          const SizedBox(height: 24),
          
          // Quick Stats
          _buildQuickStats(),
          const SizedBox(height: 24),
          
          // Today's Jobs
          _buildTodayJobs(todayJobs),
          const SizedBox(height: 24),
          
          // Upcoming Jobs
          _buildUpcomingJobs(upcomingJobs),
        ],
      ),
    );
  }

  Widget _buildTodayOverview(List<dynamic> todayJobs) {
    final now = DateTime.now();
    final nextJob = todayJobs.isNotEmpty
        ? todayJobs.where((job) => job.startTime.isAfter(now)).firstOrNull
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondaryColor,
            AppTheme.secondaryColor.withCustomOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryColor.withCustomOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.today,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Today\'s Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${todayJobs.length}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Jobs Today',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withCustomOpacity(0.8),
                    ),
                  ),
                ],
              ),
              if (nextJob != null)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withCustomOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Job',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withCustomOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('h:mm a').format(nextJob.startTime),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          nextJob.location ?? 'Location TBD',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withCustomOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      {'label': 'This Week', 'value': '8', 'icon': Icons.calendar_view_week, 'color': AppTheme.primaryPurple},
      {'label': 'Completed', 'value': '24', 'icon': Icons.check_circle, 'color': AppTheme.greenStatus},
      {'label': 'Earnings', 'value': '\$1,240', 'icon': Icons.attach_money, 'color': AppTheme.goldAccent},
      {'label': 'Rating', 'value': '4.8', 'icon': Icons.star, 'color': AppTheme.secondaryColor},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stat['value'] as String,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    stat['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTodayJobs(List<dynamic> todayJobs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Jobs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: Text(
                'View Schedule',
                style: TextStyle(color: AppTheme.secondaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (todayJobs.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.beach_access,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No jobs scheduled for today',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enjoy your day off!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: todayJobs.map((job) => _buildJobCard(job, isToday: true)).toList(),
          ),
      ],
    );
  }

  Widget _buildUpcomingJobs(List<dynamic> upcomingJobs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Jobs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: upcomingJobs.map((job) => _buildJobCard(job, isToday: false)).toList(),
        ),
      ],
    );
  }

  Widget _buildJobCard(dynamic job, {required bool isToday}) {
    final now = DateTime.now();
    final isPast = job.startTime.isBefore(now);
    final isCurrent = _isCurrentJob(job.startTime);
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (isPast) {
      statusColor = AppTheme.greenStatus;
      statusText = 'Completed';
      statusIcon = Icons.check_circle;
    } else if (isCurrent) {
      statusColor = AppTheme.goldAccent;
      statusText = 'In Progress';
      statusIcon = Icons.play_circle;
    } else {
      statusColor = AppTheme.primaryPurple;
      statusText = 'Scheduled';
      statusIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withCustomOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title ?? 'Cleaning Service',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy • h:mm a').format(job.startTime),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withCustomOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                job.location ?? 'Location TBD',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const Spacer(),
              Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                job.duration ?? '~2 hours',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          if (!isPast)
            Container(
              margin: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _startJob(job),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Start Job'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _viewJobDetails(job),
                    icon: const Icon(Icons.info_outline),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return const EnhancedMobileScheduleTab();
  }

  Widget _buildTimekeepingTab() {
    return const EnhancedMobileTimekeepingTab();
  }

  Widget _buildProfileTab() {
    return const EnhancedMobileProfileTab();
  }

  bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }

  bool _isCurrentJob(DateTime startTime) {
    final now = DateTime.now();
    final endTime = startTime.add(const Duration(hours: 2)); // Assume 2-hour jobs
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.calendar_today, color: AppTheme.secondaryColor),
              title: const Text('View Schedule'),
              onTap: () {
                Navigator.of(context).pop();
                _tabController.animateTo(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.access_time, color: AppTheme.primaryPurple),
              title: const Text('Clock In/Out'),
              onTap: () {
                Navigator.of(context).pop();
                _tabController.animateTo(2);
              },
            ),
            ListTile(
              leading: Icon(Icons.message, color: AppTheme.greenStatus),
              title: const Text('Contact Support'),
              onTap: () {
                Navigator.of(context).pop();
                // Navigate to support
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: AppTheme.goldAccent),
              title: const Text('Job History'),
              onTap: () {
                Navigator.of(context).pop();
                // Navigate to history
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startJob(dynamic job) {
    // Handle starting a job
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting job: ${job.title ?? 'Cleaning Service'}'),
        backgroundColor: AppTheme.greenStatus,
      ),
    );
  }

  void _viewJobDetails(dynamic job) {
    // Show job details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(job.title ?? 'Job Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('MMM dd, yyyy').format(job.startTime)}'),
            Text('Time: ${DateFormat('h:mm a').format(job.startTime)}'),
            Text('Location: ${job.location ?? 'TBD'}'),
            Text('Duration: ${job.endTime.difference(job.startTime).inHours} hours'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
