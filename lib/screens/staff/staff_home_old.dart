import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/gig_assignment.dart';
import '../../models/shift_swap_request.dart';

import '../../providers/staff_provider.dart';

import '../../utils/color_utils.dart';
import '../../theme/theme_manager.dart';

// Extension for context
extension BuildContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  AppThemeColors get colors => theme.extension<AppThemeColors>()!;
}

class StaffHome extends StatefulWidget {
  const StaffHome({super.key});

  @override
  State<StaffHome> createState() => _StaffHomeState();
}

class _StaffHomeState extends State<StaffHome> {
  int _pendingRequestsCount = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load shift swap requests
      await context.read<StaffProvider>().loadShiftSwapRequests();
      
      // Get pending requests count
      final provider = context.read<StaffProvider>();
      _pendingRequestsCount = provider.shiftSwapRequests
          .where((r) => r.status == ShiftSwapStatus.pending)
          .length;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load data: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToGigSelection() async {
    if (!mounted) return;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select a Gig'),
        content: const Text('Gig selection will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      context.push(
        '/staff/shift-swap/request',
        extra: GigAssignment(
          id: 'sample-gig-id',
          gigId: 'sample-gig-id',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          jobId: 'sample-job-id',
          title: 'Sample Gig',
          location: 'Sample Location',
          staffId: 'sample-staff-id',
          startTime: DateTime.now().add(const Duration(days: 1)),
          endTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadInitialData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.colors.primary,
                    context.colors.accent,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withCustomOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Welcome back, John!',
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: context.colors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colors.onPrimary.withCustomOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Timekeeping Button
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/staff/timekeeping');
                    },
                    icon: const Icon(Icons.access_time),
                    label: const Text('Go to Timekeeping'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.onPrimary,
                      foregroundColor: context.colors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Stats Cards
            _buildStatsRow(),
            const SizedBox(height: 24),
            
            // Quick Actions
            _buildShiftSwapQuickActions(),
            const SizedBox(height: 24),
            
            // Upcoming Shifts
            _buildSectionHeader('Upcoming Shifts'),
            const SizedBox(height: 8),
            _buildUpcomingShifts(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Upcoming',
            value: '5',
            icon: Icons.calendar_today,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Pending',
            value: '2',
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Completed',
            value: '12',
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withCustomOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withCustomOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftSwapQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.add,
            label: 'Request Swap',
            onTap: _navigateToGigSelection,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.inbox,
            label: 'My Requests',
            badge: _pendingRequestsCount > 0 ? _pendingRequestsCount : null,
            onTap: () => context.push('/staff/shift-swap/inbox'),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    int? badge,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 24, color: Theme.of(context).primaryColor),
                  if (badge != null && badge > 0)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          badge > 9 ? '9+' : '$badge',
                          style: const TextStyle(
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
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingShifts() {
    // Mock upcoming gigs data
    final upcomingGigs = [
      {
        'id': 'gig_1',
        'title': 'Deep Cleaning - Downtown Office',
        'location': '123 Main St, Downtown',
        'date': 'Dec 15, 2024',
        'time': '10:00 AM - 2:00 PM',
        'status': 'confirmed',
        'pay': 'R 1,200',
      },
      {
        'id': 'gig_2',
        'title': 'Regular Cleaning - Suburban Home',
        'location': '456 Oak Ave, Suburbs',
        'date': 'Dec 17, 2024',
        'time': '2:00 PM - 6:00 PM',
        'status': 'pending',
        'pay': 'R 800',
      },
      {
        'id': 'gig_3',
        'title': 'Kitchen Cleaning - Restaurant',
        'location': '789 Food Court, City Center',
        'date': 'Dec 20, 2024',
        'time': '8:00 AM - 12:00 PM',
        'status': 'confirmed',
        'pay': 'R 1,500',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: upcomingGigs.length,
      itemBuilder: (context, index) {
        final gig = upcomingGigs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to gig details (recent/upcoming)
              context.push('/staff/gig/${gig['id']}');
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          gig['title'] as String,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.colors.text,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: gig['status'] == 'confirmed' 
                              ? context.colors.success.withCustomOpacity(0.1)
                              : context.colors.warning.withCustomOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          gig['status'] as String,
                          style: TextStyle(
                            color: gig['status'] == 'confirmed' 
                                ? context.colors.success
                                : context.colors.warning,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: context.colors.subtleText,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          gig['location'] as String,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.subtleText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: context.colors.subtleText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        gig['date'] as String,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.subtleText,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: context.colors.subtleText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        gig['time'] as String,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.subtleText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        gig['pay'] as String,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: context.colors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: context.colors.subtleText,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}