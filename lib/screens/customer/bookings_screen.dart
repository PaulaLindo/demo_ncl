// lib/screens/customer/bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/customer_nav_bar.dart';
import '../../providers/booking_provider.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentRoute = 'bookings';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load bookings when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().loadBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter coming soon!')),
              );
            },
            color: AppTheme.primaryPurple,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryPurple,
          labelColor: AppTheme.primaryPurple,
          unselectedLabelColor: AppTheme.textGrey,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList(bookingProvider, isUpcoming: true),
          _buildBookingsList(bookingProvider, isUpcoming: false),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        items: _getNavItems(),
        selectedRoute: _currentRoute,
        onItemSelected: _handleNavigation,
      ),
    );
  }

  Widget _buildBookingsList(BookingProvider provider, {required bool isUpcoming}) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final bookings = isUpcoming
        ? provider.bookings.where((b) => b.isUpcoming).toList()
        : provider.bookings.where((b) => b.isCompleted).toList();

    if (bookings.isEmpty) {
      return _buildEmptyState(isUpcoming);
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking, isUpcoming: isUpcoming);
        },
      ),
    );
  }

  Widget _buildBookingCard(booking, {required bool isUpcoming}) {
    final statusColor = booking.status == 'confirmed' || booking.status.toString().contains('confirmed')
        ? AppTheme.greenStatus
        : booking.status == 'completed' || booking.status.toString().contains('completed')
            ? Colors.grey.shade600
            : AppTheme.warningOrange;

    final statusText = booking.status.toString().split('.').last.toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.cardShadow,
      ),
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.serviceName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Date
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.textGrey),
                  const SizedBox(width: 8),
                  Text(
                    '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}',
                    style: const TextStyle(fontSize: 14, color: AppTheme.textColor),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Duration & Price
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.textGrey),
                  const SizedBox(width: 8),
                  Text(
                    booking.preferredTime.replaceFirst(booking.preferredTime[0], booking.preferredTime[0].toUpperCase()),
                    style: const TextStyle(fontSize: 14, color: AppTheme.textColor),
                  ),
                  const Spacer(),
                  Text(
                    'R${booking.estimatedPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                ],
              ),
              
              if (isUpcoming) ...[
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppTheme.borderColor),
                const SizedBox(height: 12),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _rescheduleBooking(booking),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryPurple,
                          side: const BorderSide(color: AppTheme.primaryPurple),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Reschedule'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _cancelBooking(booking),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                          side: BorderSide(color: Colors.red.shade600),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isUpcoming) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUpcoming ? Icons.calendar_today_rounded : Icons.history_rounded,
            size: 80,
            color: AppTheme.textGrey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            isUpcoming ? 'No Upcoming Bookings' : 'No Past Bookings',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isUpcoming
                ? 'Book a service to get started'
                : 'Your completed bookings will appear here',
            style: const TextStyle(fontSize: 14, color: AppTheme.textGrey),
          ),
          if (isUpcoming) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/customer/services'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('Browse Services'),
            ),
          ],
        ],
      ),
    );
  }

  void _showBookingDetails(booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.serviceName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(Icons.calendar_today_rounded, 'Date', 
                    '${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}'),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.access_time_rounded, 'Time', 
                    booking.preferredTime.replaceFirst(booking.preferredTime[0], booking.preferredTime[0].toUpperCase())),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.attach_money_rounded, 'Price', 
                    'R${booking.estimatedPrice.toStringAsFixed(0)}'),
                  if (booking.assignedStaffName != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.person_rounded, 'Staff', 
                      booking.assignedStaffName),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryPurple),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _rescheduleBooking(booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reschedule feature coming soon')),
    );
  }

  void _cancelBooking(booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel "${booking.serviceName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = context.read<BookingProvider>();
              final success = await provider.cancelBooking(booking.id);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking cancelled successfully'),
                    backgroundColor: AppTheme.greenStatus,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to cancel booking'),
                    backgroundColor: AppTheme.redStatus,
                  ),
                );
              }
            },
            child: Text('Yes, Cancel', style: TextStyle(color: Colors.red.shade600)),
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
      case 'home':
        context.go('/customer/home');
        break;
      case 'services':
        context.push('/customer/services');
        break;
      case 'profile':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile feature coming soon!')),
        );
        break;
    }
  }
}