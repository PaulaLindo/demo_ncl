// lib/screens/staff/enhanced_mobile_timekeeping_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/timekeeping_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/staff_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/color_utils.dart';
import '../../../models/auth_model.dart';
import '../../../models/time_record_model.dart';
import '../../../models/qr_validation_model.dart';
import '../../../screens/staff/gig_details_screen.dart';
import '../../../widgets/qr_scanner_dialog.dart';
import '../../../widgets/quality_gate_dialog.dart';
import '../../../widgets/location_check_dialog.dart';

class EnhancedMobileTimekeepingTab extends StatefulWidget {
  const EnhancedMobileTimekeepingTab({super.key});

  @override
  State<EnhancedMobileTimekeepingTab> createState() => _EnhancedMobileTimekeepingTabState();
}

class _EnhancedMobileTimekeepingTabState extends State<EnhancedMobileTimekeepingTab>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _calendarView = 'Week'; // Add calendar view state
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Back to 3 tabs
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadTimekeepingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadTimekeepingData() async {
    final timekeepingProvider = context.read<TimekeepingProvider>();
    // Load timekeeping data
    // await timekeepingProvider.loadTodayTimeEntries();
    // await timekeepingProvider.loadWeeklyStats();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final timekeepingProvider = context.watch<TimekeepingProvider>();
    final staffProvider = context.watch<StaffProvider>();
    
    final userName = authProvider.currentUser?.firstName ?? 'Staff Member';
    final isCheckedIn = false; // Mock data since currentEntry is not available
    final currentJob = staffProvider.jobs.isNotEmpty ? staffProvider.jobs.first : null;

    return Column(
      children: [
        // Header with status
        _buildHeader(userName, isCheckedIn, currentJob),
        
        // Quick Stats
        _buildQuickStats(timekeepingProvider),
        
        // Tab Bar
        _buildTabBar(),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTimerTab(timekeepingProvider, isCheckedIn, currentJob),
              _buildScheduleTab(),
              _buildHistoryTab(timekeepingProvider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String userName, bool isCheckedIn, dynamic currentJob) {
    final now = DateTime.now();
    final timeStr = DateFormat('h:mm a').format(now);
    final dateStr = DateFormat('EEEE, MMM d').format(now);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCheckedIn 
            ? [Colors.green, Colors.green.withCustomOpacity(0.8)]
            : [context.watch<ThemeProvider>().primaryColor, context.watch<ThemeProvider>().secondaryColor],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: (isCheckedIn ? Colors.green : context.watch<ThemeProvider>().primaryColor).withCustomOpacity(0.3),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withCustomOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withCustomOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  isCheckedIn ? Icons.work : Icons.access_time,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCheckedIn ? 'Currently Working' : 'Ready to Work',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome back, $userName',
                      style: TextStyle(
                        color: Colors.white.withCustomOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Move time/date to the right corner
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: Colors.white.withCustomOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isCheckedIn)
            const SizedBox(height: 16),
          if (isCheckedIn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withCustomOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ON SHIFT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(TimekeepingProvider timekeepingProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withCustomOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Today', '8.5h', Icons.access_time, Colors.blue),
          _buildStatItem('Week', '42.3h', Icons.date_range, Colors.green),
          _buildStatItem('Rate', 'R150/h', Icons.attach_money, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withCustomOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.black87,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Timer'),
          Tab(text: 'Schedule'),
          Tab(text: 'History'),
        ],
      ),
    );
  }

  Widget _buildClockButton(bool isCheckedIn, dynamic currentJob, TimekeepingProvider timekeepingProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => isCheckedIn 
            ? _handleClockOut(timekeepingProvider)
            : _handleStandardClockIn(currentJob, timekeepingProvider),
        icon: Icon(isCheckedIn ? Icons.logout : Icons.login, size: 24),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            isCheckedIn ? 'CLOCK OUT' : 'CLOCK IN',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCheckedIn 
              ? Colors.red[400] 
              : context.watch<ThemeProvider>().primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildTimerTab(TimekeepingProvider timekeepingProvider, bool isCheckedIn, dynamic currentJob) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isCheckedIn) ...[
            // Clock Out Button
            _buildClockButton(isCheckedIn, currentJob, timekeepingProvider),
            const SizedBox(height: 24),
            // Current Session Info
            _buildCurrentSessionInfo(null), // Mock data since currentEntry is not available
          ] else ...[
            // Clock In Options
            _buildClockInOptions(currentJob, timekeepingProvider),
          ],
          const SizedBox(height: 24),
          // Quick Actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildClockInOptions(dynamic currentJob, TimekeepingProvider timekeepingProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // QR Code Clock In Button
        ElevatedButton.icon(
          onPressed: () => _handleClockInWithQR(currentJob, timekeepingProvider),
          icon: const Icon(Icons.qr_code_scanner, size: 24),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'SCAN QR CODE TO CLOCK IN',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.watch<ThemeProvider>().primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 2,
          ),
        ),
        
        if (currentJob != null) ...[
          const SizedBox(height: 16),
          // Job Details Card
          GestureDetector(
            onTap: () {
              // Navigate to gig details
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GigDetailsScreen(gig: currentJob),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.work_outline,
                    color: context.watch<ThemeProvider>().primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentJob.title ?? 'Current Job',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to view job details and clock-in options',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCurrentSessionInfo(dynamic currentEntry) {
    if (currentEntry == null) return const SizedBox.shrink();
    
    final startTime = DateFormat('h:mm a').format(currentEntry.checkIn);
    final duration = DateTime.now().difference(currentEntry.checkIn);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withCustomOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withCustomOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.play_circle,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Session',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Started',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    startTime,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${hours}h ${minutes}m',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildActionCard(
              'Break Time',
              Icons.free_breakfast,
              Colors.orange,
              () => _handleBreakTime(),
            ),
            _buildActionCard(
              'Location',
              Icons.location_on,
              Colors.green,
              () => _handleLocationCheck(),
            ),
            _buildActionCard(
              'Notes',
              Icons.note_add,
              context.watch<ThemeProvider>().secondaryColor,
              () => _handleAddNotes(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
                color: color.withCustomOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Schedule Overview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.1),
                  context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: context.watch<ThemeProvider>().primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'My Schedule',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context.watch<ThemeProvider>().primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'View your upcoming gigs, availability, and time off requests',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildScheduleStatCard(
                  title: 'This Week',
                  value: '3',
                  icon: Icons.work_outline,
                  color: context.watch<ThemeProvider>().primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScheduleStatCard(
                  title: 'Available',
                  value: '2',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScheduleStatCard(
                  title: 'Time Off',
                  value: '1',
                  icon: Icons.beach_access,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Schedule Sections
          _buildScheduleSection(
            'Today\'s Gigs',
            [
              _buildScheduleItem(
                'Office Cleaning - ABC Corp',
                '09:00 - 17:00',
                '123 Main St, CBD',
                'Confirmed',
                Colors.green,
                'gig', // Type for color coding
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildScheduleSection(
            'Schedule Calendar',
            [_buildCalendarView()],
          ),
          
          const SizedBox(height: 16),
          
          _buildScheduleSection(
            'Time Off Requests',
            [
              _buildTimeOffItem(
                'Dec 15-17, 2024',
                'Annual Leave',
                'Approved',
                Colors.green,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Add Time Off Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddTimeOffDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Time Off Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.watch<ThemeProvider>().primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleStatCard({
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
        border: Border.all(color: color.withCustomOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withCustomOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildAvailableGigItem(
    String title,
    String time,
    String location,
    String status,
    Color statusColor,
    String gigId,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withCustomOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.watch<ThemeProvider>().primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
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
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _acceptGig(gigId, title),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.watch<ThemeProvider>().primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Accept Gig'),
            ),
          ),
        ],
      ),
    );
  }

  void _acceptGig(String gigId, String gigTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Accept Gig: $gigTitle'),
        content: const Text('Are you sure you want to accept this gig? Once accepted, it will be removed from the available list and added to your schedule.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gig "$gigTitle" accepted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.watch<ThemeProvider>().primaryColor,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withCustomOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: context.watch<ThemeProvider>().primaryColor),
              const SizedBox(width: 8),
              Text(
                'Schedule Calendar',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _calendarView,
                items: ['Week', 'Month'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _calendarView = newValue!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Calendar with color coding
          _buildColorCodedCalendar(),
        ],
      ),
    );
  }

  Widget _buildColorCodedCalendar() {
    if (_calendarView == 'Week') {
      return _buildWeekView();
    } else {
      return _buildMonthView();
    }
  }

  Widget _buildWeekView() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return Column(
      children: [
        // Days of week header
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Week view with color coding
        Row(
          children: List.generate(7, (index) {
            final currentDate = startOfWeek.add(Duration(days: index));
            final isToday = currentDate.day == now.day && currentDate.month == now.month;
            
            // Determine schedule type for this day
            String scheduleType = _getScheduleTypeForDay(currentDate);
            Color dayColor = _getScheduleColor(scheduleType);
            
            return Expanded(
              child: Container(
                margin: const EdgeInsets.all(2),
                height: 40,
                decoration: BoxDecoration(
                  color: isToday 
                    ? context.watch<ThemeProvider>().primaryColor 
                    : (scheduleType == 'none' ? Colors.transparent : dayColor.withCustomOpacity(0.2)),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isToday 
                      ? context.watch<ThemeProvider>().primaryColor 
                      : Colors.grey[300]!,
                    width: isToday ? 2 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        currentDate.day.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: isToday 
                            ? Colors.white 
                            : Colors.black87,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (scheduleType != 'none')
                      Positioned(
                        bottom: 2,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: dayColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        // Legend
        Row(
          children: [
            _buildLegendItem('Gig', context.watch<ThemeProvider>().primaryColor),
            const SizedBox(width: 16),
            _buildLegendItem('Original Job', Colors.green),
            const SizedBox(width: 16),
            _buildLegendItem('Time Off', Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthView() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfWeek = DateTime(now.year, now.month, 1).weekday;
    
    return Column(
      children: [
        // Days of week header
        Row(
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Month calendar grid
        ...List.generate(6, (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final dayNumber = weekIndex * 7 + dayIndex - firstDayOfWeek + 1;
              final isCurrentMonth = dayNumber > 0 && dayNumber <= daysInMonth;
              final isToday = isCurrentMonth && dayNumber == now.day;
              
              // Determine schedule type for this day
              DateTime currentDate = DateTime(now.year, now.month, dayNumber);
              String scheduleType = _getScheduleTypeForDay(currentDate);
              Color dayColor = _getScheduleColor(scheduleType);
              
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2),
                  height: 32,
                  decoration: BoxDecoration(
                    color: isToday 
                      ? context.watch<ThemeProvider>().primaryColor 
                      : (scheduleType == 'none' ? Colors.transparent : dayColor.withCustomOpacity(0.2)),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isToday 
                        ? context.watch<ThemeProvider>().primaryColor 
                        : (isCurrentMonth ? Colors.grey[300]! : Colors.grey[200]!),
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          isCurrentMonth ? dayNumber.toString() : '',
                          style: TextStyle(
                            fontSize: 12,
                            color: isToday 
                              ? Colors.white 
                              : (isCurrentMonth ? Colors.black87 : Colors.grey[400]),
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (scheduleType != 'none' && isCurrentMonth)
                        Positioned(
                          bottom: 2,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: dayColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          );
        }),
        const SizedBox(height: 16),
        // Legend
        Row(
          children: [
            _buildLegendItem('Gig', context.watch<ThemeProvider>().primaryColor),
            const SizedBox(width: 16),
            _buildLegendItem('Original Job', Colors.green),
            const SizedBox(width: 16),
            _buildLegendItem('Time Off', Colors.orange),
          ],
        ),
      ],
    );
  }

  String _getScheduleTypeForDay(DateTime date) {
    // Mock schedule data - in real app this would come from backend
    final today = DateTime.now();
    
    // Check if it's today
    if (date.day == today.day && date.month == today.month && date.year == today.year) {
      return 'gig'; // Today has a gig
    }
    
    // Check if it's tomorrow
    final tomorrow = today.add(const Duration(days: 1));
    if (date.day == tomorrow.day && date.month == tomorrow.month && date.year == tomorrow.year) {
      return 'original'; // Tomorrow is original job
    }
    
    // Check if it's day after tomorrow
    final dayAfter = today.add(const Duration(days: 2));
    if (date.day == dayAfter.day && date.month == dayAfter.month && date.year == dayAfter.year) {
      return 'timeoff'; // Day after is time off
    }
    
    // Add some more specific dates for testing
    if (date.day == 15 && date.month == today.month) {
      return 'gig'; // 15th of current month has a gig
    }
    if (date.day == 20 && date.month == today.month) {
      return 'original'; // 20th of current month has original job
    }
    if (date.day == 25 && date.month == today.month) {
      return 'timeoff'; // 25th of current month has time off
    }
    
    return 'none';
  }

  Color _getScheduleColor(String scheduleType) {
    switch (scheduleType) {
      case 'gig':
        return context.watch<ThemeProvider>().primaryColor;
      case 'original':
        return Colors.green;
      case 'timeoff':
        return Colors.orange;
      default:
        return Colors.transparent;
    }
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(
    String title,
    String time,
    String location,
    String status,
    Color statusColor,
    String type, // 'gig', 'original', 'timeoff'
  ) {
    Color itemColor = Colors.white;
    Color borderColor = statusColor.withCustomOpacity(0.2);
    
    // Color coding based on type
    switch (type) {
      case 'gig':
        itemColor = context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.05);
        borderColor = context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.3);
        break;
      case 'original':
        itemColor = Colors.green.withCustomOpacity(0.05);
        borderColor = Colors.green.withCustomOpacity(0.3);
        break;
      case 'timeoff':
        itemColor = Colors.orange.withCustomOpacity(0.05);
        borderColor = Colors.orange.withCustomOpacity(0.3);
        break;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: itemColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withCustomOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
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
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityItem(
    String day,
    String status,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withCustomOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withCustomOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            status == 'Available' ? Icons.check_circle : Icons.cancel,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              day,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOffItem(
    String dates,
    String type,
    String status,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withCustomOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withCustomOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.beach_access, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dates,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  type,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTimeOffDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Time Off Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Start Date',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'End Date',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Time off request submitted!')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(TimekeepingProvider timekeepingProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Time Entries',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          // Mock history data
          _buildHistoryEntry(
            'Nov 27, 2025',
            '8:00 AM - 4:30 PM',
            '8.5 hours',
            'Regular Shift',
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildHistoryEntry(
            'Nov 26, 2025',
            '2:00 PM - 10:15 PM',
            '8.25 hours',
            'Evening Shift',
            context.watch<ThemeProvider>().primaryColor,
          ),
          const SizedBox(height: 12),
          _buildHistoryEntry(
            'Nov 25, 2025',
            '9:00 AM - 5:30 PM',
            '8.5 hours',
            'Morning Shift',
            context.watch<ThemeProvider>().secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryEntry(String date, String time, String duration, String type, Color color) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                duration,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withCustomOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              type,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleClockOut(TimekeepingProvider timekeepingProvider) async {
    // Show quality gate dialog before clocking out
    final activeRecord = timekeepingProvider.timeRecords
        .where((r) => r.checkOutTime == null)
        .firstOrNull;

    if (activeRecord != null) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => QualityGateDialog(
          timeRecord: activeRecord,
          onApproved: () => Navigator.pop(context, true),
          onRejected: () => Navigator.pop(context, false),
        ),
      );

      if (result == true) {
        // Clock out with quality data
        await timekeepingProvider.checkOut(
          qualityData: {
            'checks_completed': true,
            'customer_satisfied': true,
            'timestamp': DateTime.now().toIso8601String(),
          },
          customerRating: 5,
        );
        _pulseController.stop();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Clocked out successfully! Quality check passed.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (result == false) {
        // Report issue
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Issue reported. Please contact your supervisor.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleStandardClockIn(dynamic currentJob, TimekeepingProvider timekeepingProvider) async {
    try {
      if (currentJob == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No job selected for check-in')),
          );
        }
        return;
      }

      // Verify location before check-in
      final locationVerified = await showDialog<bool>(
        context: context,
        builder: (context) => LocationCheckDialog(
          targetLat: 40.7128, // Example coordinates
          targetLon: -74.0060,
          jobAddress: currentJob.location ?? 'Job Location',
          onVerified: () => Navigator.pop(context, true),
        ),
      ) ?? false;

      if (!locationVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location verification required for check-in')),
          );
        }
        return;
      }

      // Proceed with check-in using the current job
      await timekeepingProvider.checkIn(currentJob.id);
      _pulseController.repeat(reverse: true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checked in to ${currentJob.title} successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleClockInWithQR(dynamic currentJob, TimekeepingProvider timekeepingProvider) async {
    try {
      // Show QR scanner for job verification first
      final qrResult = await showDialog<String>(
        context: context,
        builder: (context) => QRScannerDialog(
          title: 'Scan Job QR Code',
          subtitle: 'Scan the QR code at the job location',
          allowManualInput: true,
          onQRCodeScanned: (code) => Navigator.of(context).pop(code),
        ),
      );

      if (qrResult == null || qrResult.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR code scan cancelled or failed')),
          );
        }
        return;
      }

      // Validate the scanned QR code
      final validation = await timekeepingProvider.validateQRCode(qrResult);

      if (!validation.isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid QR code: ${validation.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Then verify location
      final locationVerified = await showDialog<bool>(
        context: context,
        builder: (context) => LocationCheckDialog(
          targetLat: 40.7128, // Example coordinates
          targetLon: -74.0060,
          jobAddress: validation.job?.location ?? currentJob?.location ?? 'Job Location',
          onVerified: () => Navigator.pop(context, true),
        ),
      ) ?? false;

      if (!locationVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location verification required for check-in')),
          );
        }
        return;
      }

      // Proceed with check-in using the validated job ID
      String jobId = validation.jobId ?? currentJob?.id;
      
      if (jobId == null || jobId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No valid job ID found')),
          );
        }
        return;
      }

      await timekeepingProvider.checkIn(jobId);
      _pulseController.repeat(reverse: true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checked in to ${validation.job?.title ?? 'job'} successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleBreakTime() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Break Time'),
        content: const Text('Start your break? You can clock back in when you return.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Break started!')),
              );
            },
            child: const Text('Start Break'),
          ),
        ],
      ),
    );
  }

  void _handleLocationCheck() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Check'),
        content: const Text('Your location has been verified.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleAddNotes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Notes'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter any notes for this session...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notes saved!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
