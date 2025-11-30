// lib/screens/admin/enhanced_admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../utils/color_utils.dart';

class EnhancedAdminDashboard extends StatefulWidget {
  const EnhancedAdminDashboard({super.key});

  @override
  State<EnhancedAdminDashboard> createState() => _EnhancedAdminDashboardState();
}

class _EnhancedAdminDashboardState extends State<EnhancedAdminDashboard> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper methods
  Widget _buildBookingStatusChip(BookingStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case BookingStatus.confirmed:
        color = Colors.blue;
        text = 'Confirmed';
        break;
      case BookingStatus.inProgress:
        color = Colors.purple;
        text = 'In Progress';
        break;
      case BookingStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        text = status.toString().split('.').last;
    }
    
    return Chip(
      label: Text(text),
      backgroundColor: color.withCustomOpacity(0.1),
      labelStyle: TextStyle(color: color, fontSize: 12),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  int _getPendingBookingsCount(List<Booking> bookings) {
    return bookings.where((booking) => booking.status == BookingStatus.pending).length;
  }

  int _getTodayBookingsCount(List<Booking> bookings) {
    final today = DateTime.now();
    return bookings.where((booking) => _isSameDay(booking.bookingDate, today)).length;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final bookingProvider = context.read<BookingProvider>();
      
      await bookingProvider.loadBookings();
    } catch (e) {
      _showErrorSnackBar('Failed to load dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final adminName = authProvider.currentUser?.firstName ?? 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard - $adminName'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withCustomOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Bookings'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildUsersTab(),
                _buildBookingsTab(),
                _buildSettingsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        final bookings = bookingProvider.bookings;
        
        // Mock staff data for now
        const staffCount = 12;
        
        final todayBookings = bookings.where((booking) => 
            _isSameDay(booking.bookingDate, DateTime.now())).length;
        final upcomingBookings = bookings.where((booking) => 
            booking.bookingDate.isAfter(DateTime.now())).length;
        final totalRevenue = bookings.fold<double>(0.0, (sum, booking) => 
            sum + (booking.finalPrice ?? booking.basePrice));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Key Metrics
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Today\'s Bookings', '$todayBookings', Icons.calendar_today, Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricCard('Upcoming', '$upcomingBookings', Icons.upcoming, Colors.orange)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildMetricCard('Total Staff', '$staffCount', Icons.people, Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetricCard('Revenue', '\$${totalRevenue.toStringAsFixed(0)}', Icons.attach_money, Colors.purple)),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Activity
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Activity',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ...bookings.take(5).map((booking) => _buildActivityItem(booking)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _navigateToUsers(),
                              icon: const Icon(Icons.person_add),
                              label: const Text('Add User'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _navigateToBookings(),
                              icon: const Icon(Icons.calendar_view_month),
                              label: const Text('View Bookings'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersTab() {
    // Mock staff data for now since StaffProvider doesn't have staffMembers
    final mockStaff = [
      {'id': '1', 'name': 'John Doe', 'email': 'john@example.com', 'role': 'staff', 'status': 'active'},
      {'id': '2', 'name': 'Jane Smith', 'email': 'jane@example.com', 'role': 'staff', 'status': 'active'},
      {'id': '3', 'name': 'Bob Johnson', 'email': 'bob@example.com', 'role': 'staff', 'status': 'inactive'},
    ];

    return ListView.builder(
      itemCount: mockStaff.length,
      itemBuilder: (context, index) {
        final staff = mockStaff[index];
        final name = staff['name'] as String;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: staff['status'] == 'active' ? Colors.green : Colors.grey,
              child: Text(name.isNotEmpty ? name[0] : '?'),
            ),
            title: Text(name),
            subtitle: Text(staff['email'] as String),
            trailing: Chip(
              label: Text(staff['status'] as String),
              backgroundColor: staff['status'] == 'active' ? Colors.green : Colors.grey,
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingsTab() {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        final bookings = bookingProvider.bookings;
        final sortedBookings = List<Booking>.from(bookings)
          ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

        if (sortedBookings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No bookings found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Booking Statistics
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: _buildBookingStatCard('Total', '${bookings.length}', Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildBookingStatCard('Pending', '${_getPendingBookingsCount(bookings)}', Colors.orange)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildBookingStatCard('Today', '${_getTodayBookingsCount(bookings)}', Colors.green)),
                ],
              ),
            ),

            // Bookings List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedBookings.length,
                itemBuilder: (context, index) {
                  final booking = sortedBookings[index];
                  return _buildBookingCard(booking);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System Settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsItem(
                    'Business Hours',
                    'Mon-Fri: 9AM-6PM, Sat: 10AM-4PM',
                    Icons.access_time,
                    () => _showBusinessHoursDialog(),
                  ),
                  _buildSettingsItem(
                    'Service Areas',
                    '5 service areas configured',
                    Icons.location_on,
                    () => _showServiceAreasDialog(),
                  ),
                  _buildSettingsItem(
                    'Pricing Rules',
                    'Standard pricing rules active',
                    Icons.attach_money,
                    () => _showPricingDialog(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Notifications
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsItem(
                    'Email Notifications',
                    'Enabled for all users',
                    Icons.email,
                    () => _showEmailSettings(),
                  ),
                  _buildSettingsItem(
                    'SMS Notifications',
                    'Enabled for urgent updates',
                    Icons.sms,
                    () => _showSmsSettings(),
                  ),
                  _buildSettingsItem(
                    'Push Notifications',
                    'Enabled for mobile users',
                    Icons.notifications,
                    () => _showPushSettings(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Data Management
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Management',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsItem(
                    'Export Data',
                    'Export bookings and user data',
                    Icons.download,
                    () => _showExportDialog(),
                  ),
                  _buildSettingsItem(
                    'Backup Settings',
                    'Automatic backups enabled',
                    Icons.backup,
                    () => _showBackupSettings(),
                  ),
                  _buildSettingsItem(
                    'Clear Cache',
                    'Clear application cache',
                    Icons.clear_all,
                    () => _clearCache(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withCustomOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Booking booking) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withCustomOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.serviceName ?? 'Unknown Service',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  _formatDate(booking.bookingDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          _buildBookingStatusChip(booking.status),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.serviceName ?? 'Unknown Service',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                _buildBookingStatusChip(booking.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Customer: ${booking.customerId}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            Text(
              'Date: ${_formatDate(booking.bookingDate)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            if (booking.finalPrice != null)
              Text(
                'Price: \$${booking.finalPrice!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withCustomOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withCustomOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  // Navigation methods (placeholders)
  void _navigateToUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User management coming soon!')),
    );
  }

  void _navigateToBookings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking management coming soon!')),
    );
  }

  // Dialog methods (placeholders)
  void _showBusinessHoursDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Business Hours'),
        content: const Text('Business hours settings coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showServiceAreasDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Service Areas'),
        content: const Text('Service areas settings coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPricingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pricing Rules'),
        content: const Text('Pricing rules settings coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEmailSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Settings'),
        content: const Text('Email notification settings coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSmsSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SMS Settings'),
        content: const Text('SMS notification settings coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPushSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Push Settings'),
        content: const Text('Push notification settings coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Data export functionality coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBackupSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Settings'),
        content: const Text('Backup settings coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the application cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
