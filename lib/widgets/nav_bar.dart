// lib/screens/customer/customer_home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/job_model.dart';
import '../models/job_status.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

import 'package:demo_ncl/providers/auth_provider.dart';
import 'package:demo_ncl/utils/color_utils.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class NavItem {
  final String label;
  final IconData icon;
  final String route;
  final int badgeCount;

  const NavItem({
    required this.label,
    required this.icon,
    required this.route,
    this.badgeCount = 0,
  });
}

typedef NavItemCallback = void Function(String route);

class CustomNavBar extends StatelessWidget {
  final List<NavItem> items;
  final String selectedRoute;
  // final NavItemCallback onItemSelected;
  final void Function(String route) onItemSelected;

  const CustomNavBar({
    super.key,
    required this.items,
    required this.selectedRoute,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: AppTheme.cardShadow,
        border: const Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          final selected = item.route == selectedRoute;
          final iconColor = selected ? AppTheme.goldAccent : AppTheme.subtleText;
          final labelColor = selected ? AppTheme.goldAccent : AppTheme.subtleText;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onItemSelected(item.route),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(item.icon, color: iconColor, size: 22),
                        if (item.badgeCount > 0)
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.redStatus,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.cardBackground, width: 1.5),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                item.badgeCount > 99 ? '99+' : '${item.badgeCount}',
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
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12, 
                        color: labelColor,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  String _currentRoute = 'home';

  // Mock data
  final _mockUpcomingBooking = Job(
    id: 'J001',
    title: 'Home Cleaning',
    location: '47 NCL Lane, Apt 2B, Durban',
    startTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
    endTime: DateTime.now().add(const Duration(days: 1, hours: 13)),
    status: JobStatus.scheduled,
  );

  final _mockServices = const [
    ('Standard Cleaning', Icons.cleaning_services_rounded, 'R280', 'cleaning'),
    ('Deep Cleaning', Icons.spa_rounded, 'R600', 'cleaning'),
    ('Garden Maintenance', Icons.yard_rounded, 'R350', 'garden'),
    ('Elderly Care', Icons.elderly_rounded, 'R150/hr', 'care'),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.currentUser?.name ?? 'Customer';

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            _buildAppBar(context, userName),
            
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Next Appointment Section
                  _buildSectionHeader('Your Next Appointment'),
                  const SizedBox(height: 12),
                  _buildNextAppointmentCard(),
                  
                  const SizedBox(height: 32),
                  
                  // Quick Actions
                  _buildSectionHeader('Quick Actions'),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
                  
                  const SizedBox(height: 32),
                  
                  // Services Section
                  _buildSectionHeader('Our Services'),
                  const SizedBox(height: 12),
                  ..._buildServiceCards(),
                  
                  const SizedBox(height: 20),
                ]),
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

  Widget _buildAppBar(BuildContext context, String userName) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.cardBackground,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back!',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.subtleText,
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryPurple,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications coming soon!')),
                );
              },
              color: AppTheme.subtleText,
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.redStatus,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.secondaryColor,
      ),
    );
  }

  Widget _buildNextAppointmentCard() {
    final dateFormat = DateFormat('EEEE, MMMM d');
    final timeFormat = DateFormat('h:mm a');
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryPurple,
            Color(0xFF7B5A8A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withCustomOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _mockUpcomingBooking.description ?? _mockUpcomingBooking.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.goldAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'UPCOMING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAppointmentDetail(
            Icons.access_time_rounded,
            '${dateFormat.format(_mockUpcomingBooking.startTime)} • ${timeFormat.format(_mockUpcomingBooking.startTime)}',
          ),
          const SizedBox(height: 8),
          _buildAppointmentDetail(
            Icons.location_on_rounded,
            _mockUpcomingBooking.address ?? 'No address',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.customerBookings),
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryPurple,
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  // Call functionality
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.all(16),
                ),
                child: const Icon(Icons.phone_rounded, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.add_circle_outline_rounded,
            label: 'Book Service',
            color: AppTheme.primaryPurple,
            onTap: () => context.push(AppRoutes.customerServices),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.history_rounded,
            label: 'My Bookings',
            color: AppTheme.goldAccent,
            onTap: () => context.push(AppRoutes.customerBookings),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildServiceCards() {
    return _mockServices.map((service) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _ServiceCard(
          title: service.$1,
          icon: service.$2,
          price: service.$3,
          category: service.$4,
          onTap: () => context.push(AppRoutes.customerServices),
        ),
      );
    }).toList();
  }

  void _handleNavigation(String route) {
    setState(() {
      _currentRoute = route;
      });
    
    switch (route) {
      case 'services':
        context.push(AppRoutes.customerServices);
        break;
      case 'bookings':
        context.push(AppRoutes.customerBookings);
        break;
      case 'account':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account coming soon!')),
        );
        break;
    }
  }

  List<NavItem> _getNavItems() {
    return const [
      NavItem(
        label: 'Home',
        icon: Icons.home_rounded,
        route: 'home',
      ),
      NavItem(
        label: 'Services',
        icon: Icons.grid_view_rounded,
        route: 'services',
      ),
      NavItem(
        label: 'Bookings',
        icon: Icons.calendar_today_rounded,
        route: 'bookings',
        badgeCount: 2,
      ),
      NavItem(
        label: 'Account',
        icon: Icons.person_rounded,
        route: 'account',
      ),
    ];
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withCustomOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String price;
  final String category;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.icon,
    required this.price,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withCustomOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryPurple,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Starting from $price',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.subtleText,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

