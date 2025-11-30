// lib/screens/staff/enhanced_mobile_schedule_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/staff_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/color_utils.dart';
import '../../../models/job_model.dart';

class EnhancedMobileScheduleTab extends StatefulWidget {
  const EnhancedMobileScheduleTab({super.key});

  @override
  State<EnhancedMobileScheduleTab> createState() => _EnhancedMobileScheduleTabState();
}

class _EnhancedMobileScheduleTabState extends State<EnhancedMobileScheduleTab>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _viewType = 'week'; // 'day', 'week', 'month'
  List<Job> _jobs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadJobs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    
    final staffProvider = context.read<StaffProvider>();
    await staffProvider.loadJobs();
    
    setState(() {
      _jobs = staffProvider.jobs;
      _isLoading = false;
    });
  }

  List<Job> get _jobsForSelectedDate {
    return _jobs.where((job) {
      return _isSameDay(job.startTime, _selectedDate);
    }).toList();
  }

  List<Job> get _upcomingJobs {
    return _jobs.where((job) => job.startTime.isAfter(DateTime.now())).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.currentUser?.firstName ?? 'Staff';

    return Column(
      children: [
        // Header
        _buildHeader(userName),
        
        // Date Selector and View Type
        _buildDateSelector(),
        
        // Tab Bar
        _buildTabBar(),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCalendarView(),
              _buildUpcomingView(),
              _buildAvailabilityView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String userName) {
    final todayJobs = _jobs.where((job) => _isSameDay(job.startTime, DateTime.now())).length;
    final totalJobs = _jobs.length;
    final completedJobs = _jobs.where((job) => job.status == 'completed').length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.watch<ThemeProvider>().secondaryColor,
            context.watch<ThemeProvider>().secondaryColor.withCustomOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withCustomOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Schedule',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Manage your work schedule and availability',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withCustomOpacity(0.8),
                      ),
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
                child: _buildHeaderStat('Today', '$todayJobs', Icons.today),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeaderStat('Total', '$totalJobs', Icons.list),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeaderStat('Done', '$completedJobs', Icons.check_circle),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withCustomOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withCustomOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeDate(-1),
                icon: const Icon(Icons.chevron_left),
                color: context.watch<ThemeProvider>().secondaryColor,
              ),
              Column(
                children: [
                  Text(
                    DateFormat('EEEE').format(_selectedDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _changeDate(1),
                icon: const Icon(Icons.chevron_right),
                color: context.watch<ThemeProvider>().secondaryColor,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // View Type Selector
          Row(
            children: [
              Expanded(
                child: _buildViewTypeButton('Day', 'day'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildViewTypeButton('Week', 'week'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildViewTypeButton('Month', 'month'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewTypeButton(String label, String type) {
    final isSelected = _viewType == type;
    
    return GestureDetector(
      onTap: () => setState(() => _viewType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.watch<ThemeProvider>().secondaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: context.watch<ThemeProvider>().secondaryColor,
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(text: 'Calendar'),
          Tab(text: 'Upcoming'),
          Tab(text: 'Availability'),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final jobsForDate = _jobsForSelectedDate;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini Calendar
          _buildMiniCalendar(),
          
          const SizedBox(height: 16),
          
          // Jobs for selected date
          Text(
            'Jobs for ${DateFormat('MMM dd').format(_selectedDate)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          if (jobsForDate.isEmpty)
            _buildEmptyState('No jobs scheduled for this date', 'Jobs will appear here when scheduled')
          else
            ...jobsForDate.map((job) => _buildJobCard(job)).toList(),
        ],
      ),
    );
  }

  Widget _buildMiniCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calendar Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.watch<ThemeProvider>().secondaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),
          
          // Calendar Grid
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Days of week
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                
                // Calendar days
                ...List.generate(6, (week) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (day) {
                      final dayNum = _getDayForPosition(week, day);
                      final hasJobs = dayNum > 0 && _hasJobsOnDay(dayNum);
                      final isSelected = dayNum == _selectedDate.day;
                      final isToday = dayNum == DateTime.now().day;
                      
                      return Expanded(
                        child: GestureDetector(
                          onTap: dayNum > 0 ? () => _selectDay(dayNum) : null,
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSelected ? context.watch<ThemeProvider>().secondaryColor : 
                                     isToday ? context.watch<ThemeProvider>().secondaryColor.withCustomOpacity(0.1) : 
                                     Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: isToday && !isSelected ? Border.all(color: context.watch<ThemeProvider>().secondaryColor) : null,
                            ),
                            child: Center(
                              child: Stack(
                                children: [
                                  Text(
                                    dayNum > 0 ? '$dayNum' : '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
                                      color: isSelected ? Colors.white : 
                                             isToday ? context.watch<ThemeProvider>().secondaryColor : Colors.grey[700],
                                    ),
                                  ),
                                  if (hasJobs)
                                    Positioned(
                                      bottom: 2,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Container(
                                          width: 4,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.white : context.watch<ThemeProvider>().secondaryColor,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingView() {
    final upcomingJobs = _upcomingJobs;
    
    if (upcomingJobs.isEmpty) {
      return _buildEmptyState('No upcoming jobs', 'Your scheduled jobs will appear here');
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingJobs.length,
      itemBuilder: (context, index) {
        final job = upcomingJobs[index];
        return _buildJobCard(job);
      },
    );
  }

  Widget _buildAvailabilityView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Your Availability',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          // Weekly Availability
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Weekly Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                
                ...['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].map((day) {
                  return _buildAvailabilityRow(day);
                }).toList(),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Request Time Off',
                  'Submit a time off request',
                  Icons.event_busy,
                  Colors.red,
                  () => _requestTimeOff(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  'Swap Shift',
                  'Find someone to swap with',
                  Icons.swap_horiz,
                  context.watch<ThemeProvider>().primaryColor,
                  () => _swapShift(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityRow(String day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        '9:00 AM',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('to'),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        '5:00 PM',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: true,
            onChanged: (value) {},
            activeColor: context.watch<ThemeProvider>().secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    final statusColor = _getJobStatusColor(job.status.name);
    final isToday = _isSameDay(job.startTime, DateTime.now());
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isToday ? Border.all(color: context.watch<ThemeProvider>().secondaryColor, width: 2) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withCustomOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    job.status.displayName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Job details
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('h:mm a').format(job.startTime),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.location ?? 'Location TBD',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  job.customerName ?? 'Customer',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${(150.0).toStringAsFixed(2)}', // Mock price
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            
            // Action buttons
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  'View',
                  Icons.visibility,
                  Colors.blue,
                  () => _viewJobDetails(job),
                ),
                const SizedBox(width: 8),
                if (isToday && job.status == 'scheduled')
                  _buildActionButton(
                    'Start',
                    Icons.play_arrow,
                    Colors.green,
                    () => _startJob(job),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  int _getDayForPosition(int week, int day) {
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    final dayNum = week * 7 + day - startWeekday + 1;
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    
    if (dayNum < 1 || dayNum > daysInMonth) return -1;
    return dayNum;
  }

  bool _hasJobsOnDay(int day) {
    final date = DateTime(_selectedDate.year, _selectedDate.month, day);
    return _jobs.any((job) => _isSameDay(job.startTime, date));
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  void _changeMonth(int months) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + months, 1);
    });
  }

  void _selectDay(int day) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, day);
    });
  }

  Color _getJobStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return context.watch<ThemeProvider>().primaryColor;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _viewJobDetails(Job job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(job.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${job.status}'),
              Text('Date: ${DateFormat('MMM dd, yyyy').format(job.startTime)}'),
              Text('Time: ${DateFormat('h:mm a').format(job.startTime)}'),
              Text('Location: ${job.location ?? 'TBD'}'),
              Text('Customer: ${job.customerName ?? 'N/A'}'),
              Text('Price: \$${(150.0).toStringAsFixed(2)}'), // Mock price
              if (job.description != null)
                Text('Description: ${job.description}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _startJob(Job job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${job.title}...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _requestTimeOff() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Time Off'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Reason for time off',
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
                const SnackBar(
                  content: Text('Time off request submitted!'),
                  backgroundColor: context.watch<ThemeProvider>().primaryColor,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _swapShift() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shift swap feature coming soon!'),
        backgroundColor: context.watch<ThemeProvider>().primaryColor,
      ),
    );
  }
}
