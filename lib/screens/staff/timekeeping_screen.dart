// lib/screens/staff/timekeeping_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/timekeeping_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/job_service_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/customer_nav_bar.dart';
import 'timer_tab.dart';
import 'schedule_tab.dart';
import 'history_tab.dart';

class TimekeepingScreen extends StatefulWidget {
  const TimekeepingScreen({super.key});

  @override
  State<TimekeepingScreen> createState() => _TimekeepingScreenState();
}

class _TimekeepingScreenState extends State<TimekeepingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentRoute = 'clock';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final timekeepingProvider = context.watch<TimekeepingProvider>();
    final userName = authProvider.currentUser?.name ?? 'Staff Member';

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and logout
            _buildHeader(context, userName, authProvider),
            
            // Quick Stats
            _buildQuickStats(context, timekeepingProvider),
            
            // Tab Bar
            _buildTabBar(context),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  TimerTab(),
                  ScheduleTab(),
                  HistoryTab(),
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

  Widget _buildHeader(BuildContext context, String userName, AuthProvider authProvider) {
    final now = DateTime.now();
    final dateTimeStr = DateFormat('EEE, d MMM • HH:mm').format(now);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: AppTheme.containerBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
              color: AppTheme.primaryPurple,
              iconSize: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Header Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $userName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                Text(
                  dateTimeStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.subtleText,
                  ),
                ),
              ],
            ),
          ),
          
          // Logout Button
          Container(
            decoration: BoxDecoration(
              color: AppTheme.containerBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
              color: AppTheme.redStatus,
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, TimekeepingProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: AppTheme.cardBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            '${provider.stats.hoursToday.toStringAsFixed(1)}h',
            'Hours Today',
            AppTheme.infoBlue,
            Icons.access_time_rounded,
          ),
          _buildStatCard(
            provider.stats.activeJobs.toString(),
            'Active Jobs',
            AppTheme.greenStatus,
            Icons.work_outline_rounded,
          ),
          _buildStatCard(
            provider.stats.status,
            'Status',
            _getStatusColor(provider.stats.status),
            Icons.info_outline_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // replaced withAlpha instead of withOpacity to avoid deprecation
                color: color.withAlpha((0.1 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardBackground,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primaryPurple,
        indicatorWeight: 3,
        labelColor: AppTheme.primaryPurple,
        unselectedLabelColor: AppTheme.subtleText,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Timer'),
          Tab(text: 'Schedule'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase().contains('on-duty') || status.toLowerCase().contains('proxy')) {
      return AppTheme.greenStatus;
    }
    return AppTheme.subtleText;
  }

  void _handleNavigation(String route) {
    setState(() => _currentRoute = route);
    
    switch (route) {
      case 'home':
        Navigator.pop(context);
        break;
      case 'earnings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Earnings feature coming soon!')),
        );
        break;
      case 'profile':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile feature coming soon!')),
        );
        break;
    }
  }

  List<NavItem> _getNavItems() {
    return [
      const NavItem(
        label: 'Jobs',
        icon: Icons.home_rounded,
        route: 'home',
        badgeCount: 2,
      ),
      const NavItem(
        label: 'Clock',
        icon: Icons.access_time_rounded,
        route: 'clock',
      ),
      const NavItem(
        label: 'Earnings',
        icon: Icons.monetization_on_rounded,
        route: 'earnings',
      ),
      const NavItem(
        label: 'Profile',
        icon: Icons.person_rounded,
        route: 'profile',
      ),
    ];
  }
}