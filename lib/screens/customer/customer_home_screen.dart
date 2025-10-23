// lib/screens/customer/customer_home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/customer_nav_bar.dart';

import '../../providers/booking_provider.dart';

import '../../theme/app_theme.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  String _currentRoute = 'home';

  // Mock next booking data
  final Map<String, dynamic> _nextBooking = {
    'id': 'B001',
    'title': 'Deep Cleaning',
    'date': 'Tomorrow at 10:00 AM',
    'duration': '~3 hours',
    'status': 'CONFIRMED',
    'icon': Icons.spa_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final services = bookingProvider.services.take(3).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        // **START: Changed from CustomScrollView to Column**
        child: Column(
          children: [
            // 1. Fixed Header (using the new _buildHeader method)
            _buildHeader(context),

            // 2. Scrollable Content (wrapped in Expanded)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20), // Apply padding here instead of SliverPadding
                children: [
                  // Next Booking Section
                  if (_nextBooking != null) ...[
                    _buildSectionHeader('Next Booking'),
                    const SizedBox(height: 12),
                    _buildNextBookingCard(),
                    const SizedBox(height: 32),
                  ],

                  // Quick Book Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionHeader('Quick Book'),
                      TextButton(
                        onPressed: () => context.push('/customer/services'),
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...services.map((s) => _buildServiceCard(s)),
                ],
              ),
            ),
          ],
        ),
        // **END: Changed from CustomScrollView to Column**
      ),
      bottomNavigationBar: CustomNavBar(
        items: _getNavItems(),
        selectedRoute: _currentRoute,
        onItemSelected: _handleNavigation,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const userName = 'James Doe'; // Placeholder for customer name
    final currentDate = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          // Logo (using a placeholder icon since SvgPicture is not imported)
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
                  currentDate,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGrey,
                  ),
                ),
              ],
            ),
          ),
          
          // Notifications with Badge (hardcoded '2' for mock data)
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications coming soon!')),
                  );
                },
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.secondaryColor,
      ),
    );
  }

  Widget _buildNextBookingCard() {
    if (_nextBooking == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Next Booking',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textGrey,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.greenStatus.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _nextBooking!['status'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.greenStatus,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _nextBooking!['title'] as String,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primaryPurple),
              const SizedBox(width: 8),
              Text(
                _nextBooking!['date'] as String,
                style: const TextStyle(fontSize: 15, color: AppTheme.textColor, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 18, color: AppTheme.textGrey),
              const SizedBox(width: 8),
              Text(
                _nextBooking!['duration'] as String,
                style: const TextStyle(fontSize: 15, color: AppTheme.textGrey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/customer/bookings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('View Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (service.isPopular)
            Container(
              height: 4,
              decoration: const BoxDecoration(
                color: AppTheme.primaryPurple,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGrey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      service.priceDisplay,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.containerBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        service.duration,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/customer/booking/${service.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<NavItem> _getNavItems() {
    return const [
      NavItem(label: 'Home', icon: Icons.home_rounded, route: 'home'),
      NavItem(label: 'Services', icon: Icons.grid_view_rounded, route: 'services'),
      NavItem(label: 'Bookings', icon: Icons.calendar_today_rounded, route: 'bookings'),
      NavItem(label: 'Profile', icon: Icons.person_rounded, route: 'profile'),
    ];
  }

  void _handleNavigation(String route) {
    setState(() => _currentRoute = route);
    
    switch (route) {
      case 'services':
        context.push('/customer/services');
        break;
      case 'bookings':
        context.push('/customer/bookings');
        break;
      case 'profile':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile feature coming soon!')),
        );
        break;
    }
  }
}