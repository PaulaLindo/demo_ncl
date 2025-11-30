// lib/screens/staff/timekeeping_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/timekeeping_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

import '../../theme/app_theme.dart';

import '../../widgets/nav_bar.dart';

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
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
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
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.1),
            context.watch<ThemeProvider>().secondaryColor.withCustomOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withCustomOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withCustomOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.pop(context),
                  color: context.watch<ThemeProvider>().primaryColor,
                  iconSize: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Header Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.watch<ThemeProvider>().primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: context.watch<ThemeProvider>().textColor.withOpacity(0.6),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dateTimeStr,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Logout Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withCustomOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.red.withCustomOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                  color: Colors.red,
                  iconSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, TimekeepingProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      color: context.watch<ThemeProvider>().cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            '${(provider.stats?.hoursToday ?? 0).toStringAsFixed(1)}h',
            'Hours Today',
            context.watch<ThemeProvider>().primaryColor,
            Icons.access_time_rounded,
          ),
          _buildStatCard(
            (provider.stats?.activeJobs ?? 0).toString(),
            'Active Jobs',
            context.watch<ThemeProvider>().primaryColor,
            Icons.work_outline_rounded,
          ),
          _buildStatCard(
            provider.stats?.status ?? 'Unknown',
            'Status',
            _getStatusColor(provider.stats?.status ?? 'Unknown'),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.watch<ThemeProvider>().cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withCustomOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withCustomOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withCustomOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withCustomOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.watch<ThemeProvider>().textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: context.watch<ThemeProvider>().textColor.withCustomOpacity(0.7),
                fontWeight: FontWeight.w600,
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
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().cardColor,
        border: Border(
          bottom: BorderSide(
            color: context.watch<ThemeProvider>().textColor.withCustomOpacity(0.2),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: context.watch<ThemeProvider>().primaryColor,
        indicatorWeight: 3,
        labelColor: context.watch<ThemeProvider>().primaryColor,
        unselectedLabelColor: context.watch<ThemeProvider>().textColor.withCustomOpacity(0.7),
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
      return context.watch<ThemeProvider>().primaryColor;
    }
    return context.watch<ThemeProvider>().textColor.withCustomOpacity(0.7);
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