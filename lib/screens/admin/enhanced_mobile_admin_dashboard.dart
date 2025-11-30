// lib/screens/admin/enhanced_mobile_admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/color_utils.dart';
import '../../../models/booking_model.dart';
import 'enhanced_mobile_bookings_tab.dart';
import 'enhanced_mobile_users_tab.dart';
import 'enhanced_mobile_staff_tab.dart';
import 'enhanced_mobile_reports_tab.dart';

class EnhancedMobileAdminDashboard extends StatefulWidget {
  const EnhancedMobileAdminDashboard({super.key});

  @override
  State<EnhancedMobileAdminDashboard> createState() => _EnhancedMobileAdminDashboardState();
}

class _EnhancedMobileAdminDashboardState extends State<EnhancedMobileAdminDashboard>
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
    final bookingProvider = context.read<BookingProvider>();
    await bookingProvider.loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bookingProvider = context.watch<BookingProvider>();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF1E293B),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Admin Panel',
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
                        const Color(0xFF1E293B),
                        const Color(0xFF334155),
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
                            color: Colors.white.withCustomOpacity(0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        top: 60,
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 100,
                          color: Colors.white.withCustomOpacity(0.1),
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
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Bookings'),
                  Tab(text: 'Users'),
                  Tab(text: 'Staff'),
                  Tab(text: 'Reports'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildBookingsTab(),
            _buildUsersTab(),
            _buildStaffTab(),
            _buildReportsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAdminActions,
        backgroundColor: const Color(0xFF1E293B),
        icon: const Icon(Icons.admin_panel_settings),
        label: const Text('Admin Actions'),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final bookingProvider = context.watch<BookingProvider>();
    final todayBookings = bookingProvider.bookings
        .where((b) => _isToday(b.bookingDate))
        .length;
    final totalBookings = bookingProvider.bookings.length;
    final pendingBookings = bookingProvider.bookings
        .where((b) => b.status == BookingStatus.pending)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System Health
          _buildSystemHealth(),
          const SizedBox(height: 24),
          
          // Key Metrics
          _buildKeyMetrics(todayBookings, totalBookings, pendingBookings),
          const SizedBox(height: 24),
          
          // Recent Activity
          _buildRecentActivity(),
          const SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActionsGrid(),
        ],
      ),
    );
  }

  Widget _buildSystemHealth() {
    final healthMetrics = [
      {'label': 'System Status', 'value': 'Online', 'status': 'healthy', 'icon': Icons.check_circle, 'color': AppTheme.greenStatus},
      {'label': 'Database', 'value': 'Connected', 'status': 'healthy', 'icon': Icons.storage, 'color': AppTheme.greenStatus},
      {'label': 'API Response', 'value': '120ms', 'status': 'good', 'icon': Icons.speed, 'color': AppTheme.goldAccent},
      {'label': 'Error Rate', 'value': '0.2%', 'status': 'good', 'icon': Icons.error_outline, 'color': AppTheme.goldAccent},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B),
            const Color(0xFF334155),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withCustomOpacity(0.3),
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
                Icons.monitor_heart,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'System Health',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: healthMetrics.length,
            itemBuilder: (context, index) {
              final metric = healthMetrics[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withCustomOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      metric['icon'] as IconData,
                      color: metric['color'] as Color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            metric['label'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withCustomOpacity(0.7),
                            ),
                          ),
                          Text(
                            metric['value'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(int todayBookings, int totalBookings, int pendingBookings) {
    final metrics = [
      {'label': 'Today\'s Bookings', 'value': '$todayBookings', 'icon': Icons.calendar_today, 'color': AppTheme.primaryPurple, 'change': '+12%'},
      {'label': 'Total Bookings', 'value': '$totalBookings', 'icon': Icons.book_online, 'color': AppTheme.secondaryColor, 'change': '+8%'},
      {'label': 'Pending', 'value': '$pendingBookings', 'icon': Icons.pending_actions, 'color': AppTheme.goldAccent, 'change': '-5%'},
      {'label': 'Revenue', 'value': '\$12,450', 'icon': Icons.attach_money, 'color': AppTheme.greenStatus, 'change': '+15%'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
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
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final metric = metrics[index];
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
                    metric['icon'] as IconData,
                    color: metric['color'] as Color,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    metric['value'] as String,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    metric['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 14,
                        color: AppTheme.greenStatus,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        metric['change'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.greenStatus,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'title': 'New Booking Created', 'subtitle': 'Customer: John Doe - Deep Cleaning', 'time': '5 min ago', 'icon': Icons.add_circle, 'color': AppTheme.primaryPurple},
      {'title': 'Staff Member Clock In', 'subtitle': 'Jane Smith - Morning Shift', 'time': '15 min ago', 'icon': Icons.login, 'color': AppTheme.greenStatus},
      {'title': 'Payment Processed', 'subtitle': '\$240.00 - Booking #1234', 'time': '1 hour ago', 'icon': Icons.payment, 'color': AppTheme.goldAccent},
      {'title': 'System Alert', 'subtitle': 'High booking volume detected', 'time': '2 hours ago', 'icon': Icons.warning, 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(4),
              child: Text(
                'View All',
                style: TextStyle(color: const Color(0xFF1E293B)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: activities.map((activity) => _buildActivityCard(activity)).toList(),
        ),
      ],
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withCustomOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  activity['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'] as String,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      {'icon': Icons.person_add, 'label': 'Add User', 'color': AppTheme.primaryPurple},
      {'icon': Icons.calendar_today, 'label': 'Schedule', 'color': AppTheme.secondaryColor},
      {'icon': Icons.assessment, 'label': 'Reports', 'color': AppTheme.greenStatus},
      {'icon': Icons.settings, 'label': 'Settings', 'color': AppTheme.goldAccent},
      {'icon': Icons.notifications, 'label': 'Notifications', 'color': Colors.orange},
      {'icon': Icons.help, 'label': 'Help Center', 'color': Colors.blue},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return GestureDetector(
              onTap: () => _handleQuickAction(action['label'] as String),
              child: Container(
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (action['color'] as Color).withCustomOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        size: 24,
                        color: action['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBookingsTab() {
    return const EnhancedMobileBookingsTab();
  }

  Widget _buildUsersTab() {
    return const EnhancedMobileUsersTab();
  }

  Widget _buildStaffTab() {
    return const EnhancedMobileStaffTab();
  }

  Widget _buildReportsTab() {
    return const EnhancedMobileReportsTab();
  }

  bool _isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'Add User':
        _tabController.animateTo(2);
        break;
      case 'Schedule':
        _tabController.animateTo(1);
        break;
      case 'Reports':
        _tabController.animateTo(4);
        break;
      case 'Settings':
        // Navigate to settings
        break;
      case 'Notifications':
        // Navigate to notifications
        break;
      case 'Help Center':
        // Navigate to help
        break;
    }
  }

  void _showAdminActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Admin Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.refresh, color: const Color(0xFF1E293B)),
              title: const Text('Refresh Data'),
              onTap: () {
                Navigator.of(context).pop();
                _loadData();
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: AppTheme.primaryPurple),
              title: const Text('Export Reports'),
              onTap: () {
                Navigator.of(context).pop();
                _tabController.animateTo(4);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications_active, color: AppTheme.goldAccent),
              title: const Text('Send Notifications'),
              onTap: () {
                Navigator.of(context).pop();
                // Send notifications
              },
            ),
            ListTile(
              leading: Icon(Icons.security, color: AppTheme.greenStatus),
              title: const Text('Security Settings'),
              onTap: () {
                Navigator.of(context).pop();
                // Navigate to security
              },
            ),
          ],
        ),
      ),
    );
  }
}
