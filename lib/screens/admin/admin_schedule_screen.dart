// lib/screens/admin/admin_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/theme_manager.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';

class AdminScheduleScreen extends StatefulWidget {
  const AdminScheduleScreen({super.key});

  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen> {
  String _calendarView = 'Week';
  DateTime _selectedDate = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Schedule'),
      ),
      body: SingleChildScrollView(
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
                        'Schedule Management',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: context.watch<ThemeProvider>().primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Manage staff schedules, gig assignments, and availability',
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
                  child: _buildStatCard(
                    'Active Staff',
                    '12',
                    Icons.people,
                    AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Gigs Today',
                    '8',
                    Icons.work,
                    AppTheme.greenStatus,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Available',
                    '4',
                    Icons.person_add,
                    AppTheme.goldAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Calendar View
            _buildCalendarSection(),
            const SizedBox(height: 24),
            
            // Recent Assignments
            _buildRecentAssignments(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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

  Widget _buildCalendarSection() {
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
              Icon(Icons.calendar_month, color: AppTheme.primaryPurple),
              const SizedBox(width: 8),
              Text(
                'Schedule Calendar',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Month/Week selector
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
              const SizedBox(width: 8),
              // Date navigation
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    if (_calendarView == 'Week') {
                      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                    } else {
                      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    if (_calendarView == 'Week') {
                      _selectedDate = _selectedDate.add(const Duration(days: 7));
                    } else {
                      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getSelectedDateText(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          _buildAdminCalendar(),
        ],
      ),
    );
  }

  String _getSelectedDateText() {
    if (_calendarView == 'Week') {
      final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d, yyyy').format(endOfWeek)}';
    } else {
      return DateFormat('MMMM yyyy').format(_selectedDate);
    }
  }

  Widget _buildAdminCalendar() {
    if (_calendarView == 'Week') {
      return _buildAdminWeekView();
    } else {
      return _buildAdminMonthView();
    }
  }

  Widget _buildAdminWeekView() {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    
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
            final isToday = currentDate.day == DateTime.now().day && 
                           currentDate.month == DateTime.now().month && 
                           currentDate.year == DateTime.now().year;
            
            // Use same schedule logic as staff
            String scheduleType = _getScheduleTypeForDay(currentDate);
            Color dayColor = _getScheduleColor(scheduleType);
            
            return Expanded(
              child: Container(
                margin: const EdgeInsets.all(2),
                height: 60,
                decoration: BoxDecoration(
                  color: isToday 
                    ? AppTheme.primaryPurple 
                    : (scheduleType == 'none' ? Colors.transparent : dayColor.withCustomOpacity(0.2)),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isToday 
                      ? AppTheme.primaryPurple 
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
                    // Staff count for admin
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                        decoration: BoxDecoration(
                          color: context.watch<ThemeProvider>().primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_getStaffCountForDay(currentDate)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
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
            _buildLegendItem('Gig', AppTheme.primaryPurple),
            const SizedBox(width: 16),
            _buildLegendItem('Original Job', AppTheme.greenStatus),
            const SizedBox(width: 16),
            _buildLegendItem('Time Off', AppTheme.goldAccent),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminMonthView() {
    final daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    final firstDayOfWeek = DateTime(_selectedDate.year, _selectedDate.month, 1).weekday;
    
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
              final isToday = isCurrentMonth && 
                             dayNumber == DateTime.now().day && 
                             _selectedDate.month == DateTime.now().month && 
                             _selectedDate.year == DateTime.now().year;
              
              // Determine schedule type for this day
              DateTime currentDate = DateTime(_selectedDate.year, _selectedDate.month, dayNumber);
              String scheduleType = _getScheduleTypeForDay(currentDate);
              Color dayColor = _getScheduleColor(scheduleType);
              
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.all(2),
                  height: 32,
                  decoration: BoxDecoration(
                    color: isToday 
                      ? AppTheme.primaryPurple 
                      : (scheduleType == 'none' ? Colors.transparent : dayColor.withCustomOpacity(0.2)),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isToday 
                        ? AppTheme.primaryPurple 
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
            _buildLegendItem('Gig', AppTheme.primaryPurple),
            const SizedBox(width: 16),
            _buildLegendItem('Original Job', AppTheme.greenStatus),
            const SizedBox(width: 16),
            _buildLegendItem('Time Off', AppTheme.goldAccent),
          ],
        ),
      ],
    );
  }

  String _getScheduleTypeForDay(DateTime date) {
    // Same logic as staff calendar - sync with staff data
    final today = DateTime.now();
    
    // Check if it's today
    if (date.day == today.day && date.month == today.month && date.year == today.year) {
      return 'gig';
    }
    
    // Check if it's tomorrow
    final tomorrow = today.add(const Duration(days: 1));
    if (date.day == tomorrow.day && date.month == tomorrow.month && date.year == tomorrow.year) {
      return 'original';
    }
    
    // Check if it's day after tomorrow
    final dayAfter = today.add(const Duration(days: 2));
    if (date.day == dayAfter.day && date.month == dayAfter.month && date.year == dayAfter.year) {
      return 'timeoff';
    }
    
    // Add some more specific dates for testing
    if (date.day == 15 && date.month == today.month) {
      return 'gig';
    }
    if (date.day == 20 && date.month == today.month) {
      return 'original';
    }
    if (date.day == 25 && date.month == today.month) {
      return 'timeoff';
    }
    
    return 'none';
  }

  Color _getScheduleColor(String scheduleType) {
    switch (scheduleType) {
      case 'gig':
        return AppTheme.primaryPurple;
      case 'original':
        return AppTheme.greenStatus;
      case 'timeoff':
        return AppTheme.goldAccent;
      default:
        return Colors.transparent;
    }
  }

  int _getStaffCountForDay(DateTime date) {
    // Mock staff count - in real app this would come from backend
    String scheduleType = _getScheduleTypeForDay(date);
    if (scheduleType == 'none') return 0;
    return scheduleType == 'gig' ? 2 : 1; // 2 staff for gigs, 1 for others
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

  Widget _buildRecentAssignments() {
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
          Text(
            'Recent Assignments',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Get assignments from calendar data
          ..._getRecentAssignmentsFromCalendar(),
        ],
      ),
    );
  }

  List<Widget> _getRecentAssignmentsFromCalendar() {
    final now = DateTime.now();
    final assignments = <Widget>[];
    
    // Today - Gig
    assignments.add(_buildAssignmentItem('John Doe', 'Downtown Office Cleaning', 'Today, 09:00', 'gig'));
    
    // Tomorrow - Original Job
    assignments.add(_buildAssignmentItem('Jane Smith', 'Regular Maintenance', 'Tomorrow, 14:00', 'original'));
    
    // Day after tomorrow - Time Off (not shown in assignments)
    
    // 15th - Gig
    assignments.add(_buildAssignmentItem('Mike Johnson', 'Restaurant Deep Clean', 'Nov 15, 22:00', 'gig'));
    
    // 20th - Original Job
    assignments.add(_buildAssignmentItem('Sarah Williams', 'Medical Facility', 'Nov 20, 19:00', 'original'));
    
    return assignments;
  }

  Widget _buildAssignmentItem(String staff, String location, String time, String type) {
    Color typeColor = _getScheduleColor(type);
    String typeText = type == 'gig' ? 'Gig' : 'Original Job';
    IconData typeIcon = type == 'gig' ? Icons.work : Icons.business;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: typeColor.withCustomOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: typeColor.withCustomOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: typeColor.withCustomOpacity(0.1),
            child: Icon(typeIcon, size: 16, color: typeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: typeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  typeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
