import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/gig_assignment.dart';

import '../../../providers/staff_provider.dart';

import '../../utils/color_utils.dart';

import 'gig_management_screen.dart';
import 'availability_screen.dart';
import 'schedule_screen.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<StaffProvider>();
    await provider.loadJobs();
    // TODO: Implement loadAvailability method in StaffProvider
    // await provider.loadAvailability(DateTime.now());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          _DashboardHome(),
          GigManagementScreen(),
          ScheduleScreen(),
          AvailabilityScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'My Gigs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Availability',
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return Consumer<StaffProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(context, provider),
              const SizedBox(height: 16),
              _buildUpcomingGigs(context, provider),
              const SizedBox(height: 16),
              _buildQuickActions(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(BuildContext context, StaffProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              context,
              icon: Icons.work_outline,
              label: 'Active Gigs',
              value: provider.upcomingGigs.length.toString(),
              color: Colors.blue,
            ),
            _buildStatRow(
              context,
              icon: Icons.access_time,
              label: 'Hours This Week',
              value: '24', // TODO: Replace with actual hours
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingGigs(BuildContext context, StaffProvider provider) {
    if (provider.upcomingGigs.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No upcoming gigs'),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Upcoming Gigs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.upcomingGigs.length > 3 ? 3 : provider.upcomingGigs.length,
            itemBuilder: (context, index) {
              final gig = provider.upcomingGigs[index];
              return _buildGigItem(context, gig);
            },
          ),
          if (provider.upcomingGigs.length > 3)
            TextButton(
              onPressed: () {
                // Navigate to full gigs list
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GigManagementScreen(),
                  ),
                );
              },
              child: const Text('View All Gigs'),
            ),
        ],
      ),
    );
  }

  Widget _buildGigItem(BuildContext context, GigAssignment gig) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getStatusColor(gig.status).withCustomOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getStatusIcon(gig.status),
          color: _getStatusColor(gig.status),
        ),
      ),
      title: Text(gig.title),
      subtitle: Text(
        '${DateFormat('MMM d, y').format(gig.startTime)} • ${_formatTimeRange(gig.startTime, gig.endTime)}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Show gig details
        _showGigDetails(context, gig);
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, StaffProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.add_circle_outline,
                  label: 'Request Time Off',
                  onTap: () {
                    // TODO: Implement request time off
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.swap_horiz,
                  label: 'Swap Shift',
                  onTap: () {
                    // TODO: Implement shift swap
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Set Availability',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AvailabilityScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withCustomOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    return '${DateFormat('h:mma').format(start)} - ${DateFormat('h:mma').format(end)}';
  }

  Color _getStatusColor(GigStatus status) {
    switch (status) {
      case GigStatus.pending:
        return Colors.orange;
      case GigStatus.accepted:
        return Colors.green;
      case GigStatus.declined:
        return Colors.red;
      case GigStatus.completed:
        return Colors.blue;
      case GigStatus.cancelled:
        return Colors.grey;
      case GigStatus.inProgress:
        return Colors.purple;
      case GigStatus.autoDeclined:
        return Colors.red[300] ?? Colors.red;
    }
  }

  IconData _getStatusIcon(GigStatus status) {
    switch (status) {
      case GigStatus.pending:
        return Icons.access_time;
      case GigStatus.accepted:
        return Icons.check_circle_outline;
      case GigStatus.declined:
        return Icons.cancel_outlined;
      case GigStatus.completed:
        return Icons.verified_outlined;
      case GigStatus.cancelled:
        return Icons.cancel_outlined;
      case GigStatus.inProgress:
        return Icons.timer_outlined;
      case GigStatus.autoDeclined:
        return Icons.error_outline;
    }
  }

  void _showGigDetails(BuildContext context, GigAssignment gig) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(gig.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.calendar_today,
                DateFormat('EEEE, MMMM d, y').format(gig.startTime)),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.access_time,
                '${_formatTimeRange(gig.startTime, gig.endTime)} (${gig.duration?.inHours ?? 0}h ${(gig.duration?.inMinutes ?? 0) % 60}m)'),
            if (gig.location.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.location_on, gig.location),
            ],
            if (gig.notes?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(gig.notes!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (gig.status == GigStatus.pending)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: Implement decline gig
                    Navigator.pop(context);
                  },
                  child: const Text('Decline', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement accept gig
                    Navigator.pop(context);
                  },
                  child: const Text('Accept'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
