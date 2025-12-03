import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/theme_provider.dart';
import '../../routes/app_routes.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/gig_assignment.dart';
import '../../models/shift_swap_request.dart';

import '../../providers/staff_provider.dart';
import '../../providers/auth_provider.dart';

class StaffHome extends StatefulWidget {
  const StaffHome({super.key});

  @override
  State<StaffHome> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHome> {
  int _pendingRequestsCount = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Delay the data loading to after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load shift swap requests in the background
      await Future.delayed(Duration.zero, () {
        context.read<StaffProvider>().loadShiftSwapRequests();
      });

      if (!mounted) return;
      
      // Get pending requests count
      final provider = context.read<StaffProvider>();
      final pendingCount = provider.shiftSwapRequests
          .where((r) => r.status == ShiftSwapStatus.pending)
          .length;

      if (mounted) {
        setState(() {
          _pendingRequestsCount = pendingCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToGigSelection() async {
    if (!mounted) return;
    
    // Show available gigs for cancellation
    final cancellableGigs = [
      {
        'id': 'cancel_1',
        'title': 'Evening Office Clean',
        'location': 'City Center',
        'date': 'Dec 16, 2024',
        'time': '6:00 PM - 10:00 PM',
        'pay': 'R 1,000',
        'cancellationDeadline': 'Dec 2, 2024',
      },
      {
        'id': 'cancel_2',
        'title': 'Weekend Restaurant Clean',
        'location': 'Waterfront',
        'date': 'Dec 18, 2024',
        'time': '8:00 AM - 12:00 PM',
        'pay': 'R 1,200',
        'cancellationDeadline': 'Dec 4, 2024',
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Gig'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: cancellableGigs.length,
            itemBuilder: (context, index) {
              final gig = cancellableGigs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(gig['title'] as String),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${gig['location']} • ${gig['date']}'),
                      Text(gig['time'] as String),
                      Text(gig['pay'] as String),
                      Text(
                        'Cancel by: ${gig['cancellationDeadline']}',
                        style: TextStyle(
                          color: Colors.orange.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.cancelGig(gig['id'] as String));
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
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
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SvgPicture.asset(
                  'assets/images/comprehensive_home_services.svg',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
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
                    context.watch<ThemeProvider>().primaryColor,
                    context.watch<ThemeProvider>().secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Welcome back, ${context.watch<AuthProvider>()?.currentUser?.name ?? 'John'}!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Timekeeping Button
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push(AppRoutes.staffTimekeeping);
                    },
                    icon: const Icon(Icons.access_time),
                    label: const Text('Go to Timekeeping'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: context.watch<ThemeProvider>().primaryColor,
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
            _buildQuickActions(),
            
            const SizedBox(height: 16),
            
            // Account Section
            _buildAccountSection(),
            const SizedBox(height: 24),
            
            // Available Services Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.watch<ThemeProvider>().cardColor,
                border: Border(
                  bottom: BorderSide(
                    color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Available Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.watch<ThemeProvider>().primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildAvailableServices(),
            const SizedBox(height: 24),
            
            // Upcoming Shifts (Confirmed only)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.watch<ThemeProvider>().cardColor,
                border: Border(
                  bottom: BorderSide(
                    color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Upcoming Shifts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.watch<ThemeProvider>().primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildUpcomingShifts(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  Widget _buildAccountSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.watch<ThemeProvider>().primaryColor.withOpacity(0.1),
            context.watch<ThemeProvider>().primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_circle_outlined,
                color: context.watch<ThemeProvider>().primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Account',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: context.watch<ThemeProvider>().primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: context.watch<ThemeProvider>().primaryColor,
                child: Text(
                  'JD',
                  style: TextStyle(
                    color: context.watch<ThemeProvider>().textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Professional Cleaner',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '4.8 Rating',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(AppRoutes.staffProfile);
                  },
                  icon: const Icon(Icons.person_outline),
                  label: const Text('View Profile'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(AppRoutes.staffSettings);
                  },
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Settings'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.watch<ThemeProvider>().primaryColor,
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
            title: 'Completed',
            value: '12',
            icon: Icons.check_circle_outline,
            color: Colors.green,
            onTap: () {
              context.push(AppRoutes.staffHistory);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Earnings',
            value: 'R15.2k',
            icon: Icons.attach_money,
            color: context.watch<ThemeProvider>().primaryColor,
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
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
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
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade400,
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
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.cancel_outlined,
            label: 'Cancel Gig',
            onTap: _navigateToGigSelection,
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

  Widget _buildAvailableServices() {
    // Mock available services for staff
    final availableServices = [
      {
        'id': 'service_1',
        'title': 'Emergency Deep Clean',
        'location': 'Cape Town CBD',
        'pay': 'R 1,500',
        'urgency': 'high',
        'time': 'Available Now',
        'duration': '4 hours',
        'client': 'Office Building A',
        'distance': '2.5 km',
      },
      {
        'id': 'service_2',
        'title': 'Regular Home Cleaning',
        'location': 'Suburbs',
        'pay': 'R 800',
        'urgency': 'medium',
        'time': 'Tomorrow 2PM',
        'duration': '2 hours',
        'client': 'Smith Family',
        'distance': '5.1 km',
      },
      {
        'id': 'service_3',
        'title': 'Post-Construction Clean',
        'location': 'New Development',
        'pay': 'R 2,000',
        'urgency': 'high',
        'time': 'Today 6PM',
        'duration': '6 hours',
        'client': 'Construction Co',
        'distance': '8.3 km',
      },
    ];

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: availableServices.length,
          itemBuilder: (context, index) {
            final service = availableServices[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  // Navigate to service details
                  context.push('${AppRoutes.serviceDetails}/${service['id']}');
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
                              service['title'] as String,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: context.watch<ThemeProvider>().textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: service['urgency'] == 'high' 
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (service['urgency'] as String).toUpperCase(),
                              style: TextStyle(
                                color: service['urgency'] == 'high' 
                                    ? Colors.red
                                    : Colors.orange,
                                fontSize: 10,
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
                            color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${service['location']} • ${service['distance']}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${service['time']} • ${service['duration']}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Client: ${service['client']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            service['pay'] as String,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: context.watch<ThemeProvider>().primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Accept service - go to confirmation page
                              context.push(AppRoutes.acceptGig(service['id'] as String));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.watch<ThemeProvider>().primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: const Text('Accept'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              context.push(AppRoutes.staffServices);
            },
            icon: const Icon(Icons.view_list),
            label: const Text('View All Available Services'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingShifts() {
    // Mock upcoming gigs data (confirmed only)
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
              // Navigate to gig details with GPS map and transport options
              context.push(AppRoutes.gigDetailsById(gig['id'] as String));
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.watch<ThemeProvider>().textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'CONFIRMED',
                          style: TextStyle(
                            color: context.watch<ThemeProvider>().primaryColor,
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
                        color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          gig['location'] as String,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
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
                        color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        gig['date'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        gig['time'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: context.watch<ThemeProvider>().primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
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
