// lib/screens/customer/customer_home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../widgets/nav_bar.dart';
import '../../providers/booking_provider.dart';
import '../../providers/theme_provider.dart';
import '../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  String _currentRoute = 'home';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update current route based on GoRouter location
    final location = GoRouterState.of(context).uri.toString();
    if (location.contains('/customer/services')) {
      _currentRoute = 'services';
    } else if (location.contains('/customer/bookings')) {
      _currentRoute = 'bookings';
    } else if (location.contains('/customer/profile') || location.contains('/customer/settings')) {
      _currentRoute = 'profile';
    } else {
      _currentRoute = 'home';
    }
  }

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
      body: ListView(
        padding: const EdgeInsets.all(20),
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
                  'Welcome back, ${context.watch<AuthProvider>()?.currentUser?.name ?? 'James'}!',
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
                // Quick Book Button
                ElevatedButton.icon(
                  onPressed: () {
                    context.push(AppRoutes.customerServices);
                  },
                  icon: const Icon(Icons.spa_rounded),
                  label: const Text('Book Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: context.watch<ThemeProvider>().primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Next Booking Section
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
                  'Next Booking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.watch<ThemeProvider>().primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildNextBookingCard(),
          const SizedBox(height: 32),

          // Quick Book Section
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Book',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.watch<ThemeProvider>().primaryColor,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.customerServices),
                  child: Text(
                    'See All',
                    style: TextStyle(
                      color: context.watch<ThemeProvider>().primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...services.map((s) => _buildServiceCard(s)),
          
          const SizedBox(height: 32),
          
          // Account Section
          _buildAccountSection(),
        ],
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
                  '${context.watch<AuthProvider>()?.currentUser?.name?.substring(0, 2).toUpperCase() ?? 'JD'}',
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
                      context.watch<AuthProvider>()?.currentUser?.name ?? 'James Doe',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Customer',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          'Member since 2024',
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
                    context.push(AppRoutes.customerProfile);
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
                    context.push(AppRoutes.customerSettings);
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
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: context.watch<ThemeProvider>().primaryColor,
      ),
    );
  }

  Widget _buildNextBookingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.watch<ThemeProvider>().cardColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next Booking',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _nextBooking['status'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: context.watch<ThemeProvider>().primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _nextBooking['title'] as String,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.watch<ThemeProvider>().textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: context.watch<ThemeProvider>().primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                _nextBooking['date'] as String,
                style: TextStyle(
                  fontSize: 15,
                  color: context.watch<ThemeProvider>().textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 18,
                color: context.watch<ThemeProvider>().textColor.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Text(
                _nextBooking['duration'] as String,
                style: TextStyle(
                  fontSize: 15,
                  color: context.watch<ThemeProvider>().textColor.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push(AppRoutes.customerBookings),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.watch<ThemeProvider>().primaryColor,
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
        color: context.watch<ThemeProvider>().cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.watch<ThemeProvider>().cardColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppRoutes.bookingFormForService(service.id)),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.watch<ThemeProvider>().textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      service.priceDisplay,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.watch<ThemeProvider>().textColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        service.duration,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.watch<ThemeProvider>().primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
