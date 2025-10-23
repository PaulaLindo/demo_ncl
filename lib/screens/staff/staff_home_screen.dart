// lib/screens/staff/staff_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/job_service_models.dart';
import '../../providers/jobs_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/customer_nav_bar.dart';
import '../../theme/app_theme.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> with SingleTickerProviderStateMixin {
  String _currentRoute = 'home';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsProvider>().loadJobs(true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.currentUser?.name ?? 'Staff';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, userName),
            
            // Stats Cards
            _buildStatsRow(),
            
            // Tab Bar
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.cardBackground,
                border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryPurple,
                labelColor: AppTheme.primaryPurple,
                unselectedLabelColor: AppTheme.textGrey,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Today'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
            
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildJobList('today'),
                  _buildJobList('upcoming'),
                  _buildJobList('completed'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        items: _getNavItems(),
        selectedRoute: _currentRoute,
        onItemSelected: _handleNavigation,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Logo - Improved version
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/images/comprehensive_home_services.svg',
                  fit: BoxFit.contain,
                  // Remove the colorFilter to preserve original colors
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $userName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMM d').format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => _showNotifications(context),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.backgroundLight,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.redStatus,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.cardBackground,
      child: const Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.access_time_rounded,
              value: '8h',
              label: 'Scheduled',
              color: AppTheme.infoBlue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.work_outline_rounded,
              value: '2',
              label: 'Jobs Today',
              color: AppTheme.primaryPurple,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.star_rounded,
              value: '4.9',
              label: 'Rating',
              color: AppTheme.warningOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList(String filter) {
    return Consumer<JobsProvider>(
      builder: (context, jobsProvider, _) {
        if (jobsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter jobs based on tab
        List<Job> jobs;
        if (filter == 'today') {
          jobs = jobsProvider.jobs.where((j) => j.isToday && j.status != JobStatus.completed).toList();
        } else if (filter == 'upcoming') {
          jobs = jobsProvider.jobs.where((j) => !j.isToday && j.isUpcoming).toList();
        } else {
          jobs = jobsProvider.jobs.where((j) => j.status == JobStatus.completed).toList();
        }

        if (jobs.isEmpty) {
          return _buildEmptyState(filter);
        }

        return RefreshIndicator(
          onRefresh: () => jobsProvider.loadJobs(true),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              return _JobCard(
                job: jobs[index],
                onStartJob: () => _handleStartJob(jobs[index]),
                onCompleteJob: () => _handleCompleteJob(jobs[index]),
                onNavigate: () => _handleNavigate(jobs[index]),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String filter) {
    String message;
    if (filter == 'today') {
      message = 'No jobs scheduled for today';
    } else if (filter == 'upcoming') {
      message = 'No upcoming jobs';
    } else {
      message = 'No completed jobs';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 80,
              color: AppTheme.textGrey.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'New jobs will appear here',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(String route) {
    setState(() => _currentRoute = route);
    
    switch (route) {
      case 'clock':
        context.push('/staff/timekeeping');
        break;
      case 'earnings':
        _showComingSoon(context, 'Earnings');
        break;
      case 'profile':
        _showComingSoon(context, 'Profile');
        break;
    }
  }

  void _handleStartJob(Job job) {
    context.read<JobsProvider>().startJob(job);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Started: ${job.serviceType}'),
        backgroundColor: AppTheme.greenStatus,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleCompleteJob(Job job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Job'),
        content: Text('Mark "${job.serviceType}" as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<JobsProvider>().completeJob(job);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Completed: ${job.serviceType}'),
                  backgroundColor: AppTheme.greenStatus,
                ),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _handleNavigate(Job job) {
    // Open maps with job address
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to: ${job.address}'),
        action: SnackBarAction(
          label: 'Open Maps',
          onPressed: () {
            // TODO: Implement maps navigation
          },
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications feature coming soon!')),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature feature coming soon!')),
    );
  }

  List<NavItem> _getNavItems() {
    return const [
      NavItem(label: 'Jobs', icon: Icons.home_rounded, route: 'home', badgeCount: 2),
      NavItem(label: 'Clock', icon: Icons.access_time_rounded, route: 'clock'),
      NavItem(label: 'Earnings', icon: Icons.monetization_on_rounded, route: 'earnings'),
      NavItem(label: 'Profile', icon: Icons.person_rounded, route: 'profile'),
    ];
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.subtleText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Job Card Widget
class _JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onStartJob;
  final VoidCallback onCompleteJob;
  final VoidCallback onNavigate;

  const _JobCard({
    required this.job,
    required this.onStartJob,
    required this.onCompleteJob,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final isInProgress = job.status == JobStatus.inProgress;
    final isCompleted = job.status == JobStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isInProgress ? AppTheme.primaryPurple : AppTheme.borderGrey,
          width: isInProgress ? 2 : 1,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusBadge(status: job.status),
                const SizedBox(height: 12),
                Text(
                  job.serviceType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                _InfoRow(icon: Icons.person_outline_rounded, text: job.customerName),
                const SizedBox(height: 8),
                _InfoRow(icon: Icons.access_time_rounded, text: _formatTime(job)),
                const SizedBox(height: 8),
                _InfoRow(icon: Icons.location_on_outlined, text: job.address),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _buildActions(isInProgress, isCompleted),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool isInProgress, bool isCompleted) {
    if (isCompleted) {
      return OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.visibility_outlined, size: 18),
        label: const Text('View Details'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 44),
        ),
      );
    }

    if (isInProgress) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onCompleteJob,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: onNavigate,
              child: const Icon(Icons.navigation_rounded, size: 20),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: onStartJob,
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Start Job'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: onNavigate,
            child: const Icon(Icons.navigation_rounded, size: 20),
          ),
        ),
      ],
    );
  }

  String _formatTime(Job job) {
    final dateFormat = DateFormat('MMM d');
    final timeFormat = DateFormat('h:mm a');
    
    if (job.isToday) {
      return 'Today • ${timeFormat.format(job.startTime)} - ${timeFormat.format(job.endTime)}';
    }
    
    return '${dateFormat.format(job.startTime)} • ${timeFormat.format(job.startTime)}';
  }
}

class _StatusBadge extends StatelessWidget {
  final JobStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status.getColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            status.displayName.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppTheme.textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}