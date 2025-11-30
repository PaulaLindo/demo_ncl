// lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';
import '../admin/temp_card_management.dart';
import '../admin/proxy_time_management.dart';
import '../admin/quality_audit_management.dart';
import '../admin/b2b_lead_management.dart';
import '../admin/payroll_management.dart';
import '../admin/live_logistics.dart';
import '../admin/staff_restrictions.dart';
import '../admin/audit_logs.dart';
import '../admin/enhanced_job_assignment_tab.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminOverviewPage(),
    const EnhancedJobAssignmentTab(),
    const TempCardManagementPage(),
    const ProxyTimeManagementPage(),
    const QualityAuditManagementPage(),
    const B2BLeadManagementPage(),
    const PayrollManagementPage(),
    const LiveLogisticsPage(),
    const StaffRestrictionsPage(),
    const AuditLogsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            extended: false,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment),
                label: Text('Job Assignments'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.credit_card),
                label: Text('Temp Cards'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.access_time),
                label: Text('Proxy Time'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.flag),
                label: Text('Quality Audit'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business),
                label: Text('B2B Leads'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.attach_money),
                label: Text('Payroll'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.gps_fixed),
                label: Text('Logistics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.block),
                label: Text('Restrictions'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                label: Text('Audit Logs'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: context.watch<ThemeProvider>().primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage staff, timekeeping, quality, and business operations',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              
              // Quick Stats Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      context,
                      'Active Temp Cards',
                      '12',
                      Icons.credit_card,
                      AppTheme.primaryPurple,
                    ),
                    _buildStatCard(
                      context,
                      'Pending Proxy Hours',
                      '5',
                      Icons.access_time,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      context,
                      'Quality Flags',
                      '3',
                      Icons.flag,
                      Colors.red,
                    ),
                    _buildStatCard(
                      context,
                      'New B2B Leads',
                      '8',
                      Icons.business,
                      Colors.green,
                    ),
                    _buildStatCard(
                      context,
                      'Draft Payroll',
                      '2',
                      Icons.attach_money,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      context,
                      'Active Staff',
                      '24',
                      Icons.people,
                      AppTheme.primaryPurple,
                    ),
                    _buildStatCard(
                      context,
                      'Blocked Staff',
                      '2',
                      Icons.block,
                      Colors.red,
                    ),
                    _buildStatCard(
                      context,
                      'Live Jobs',
                      '7',
                      Icons.gps_fixed,
                      Colors.green,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Recent Activity
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 2,
                child: Card(
                  child: ListView.builder(
                    itemCount: provider.recentActivities.length,
                    itemBuilder: (context, index) {
                      final activity = provider.recentActivities[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.1),
                          child: Icon(
                            Icons.info,
                            color: context.watch<ThemeProvider>().primaryColor,
                            size: 20,
                          ),
                        ),
                        title: Text(activity.title),
                        subtitle: Text(activity.subtitle),
                        trailing: Text(
                          activity.timeAgo,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
