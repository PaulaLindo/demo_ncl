// lib/screens/staff/schedule_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../models/timekeeping_exports.dart';
import '../../providers/timekeeping_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/color_utils.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimekeepingProvider>(context);
    final primaryColor = context.watch<ThemeProvider>().primaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'View your permanent job (Hotel) and platform shifts. Tap a green day to find new jobs!',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          
          // Calendar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withCustomOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: primaryColor),
                rightChevronIcon: Icon(Icons.chevron_right, color: primaryColor),
              ),
              
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEECB05), width: 2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                selectedDecoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
              ),
              
              eventLoader: (day) {
                return provider.getShiftsForDate(day);
              },
              
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showDayDetails(context, provider, selectedDay);
              },
              
              onPageChanged: (focusedDay) {
                setState(() => _focusedDay = focusedDay);
              },
              
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  final hasJob = provider.getJobsForDate(day).isNotEmpty;
                  if (hasJob) {
                    return const Positioned(
                      right: 1,
                      bottom: 1,
                      child: Icon(Icons.work, size: 16, color: Colors.green),
                    );
                  }
                  return null;
                },
                // Add special styling for days with events
                defaultBuilder: (context, day, focusedDay) {
                  final events = provider.getShiftsForDate(day);
                  if (events.isEmpty) return null;
                  
                  final shift = events.first;
                  Color bgColor;
                  
                  if (shift.isExternal) {
                    bgColor = Colors.orange.withCustomOpacity(0.1);
                  } else if (shift.isNCL) {
                    bgColor = primaryColor.withCustomOpacity(0.1);
                  } else {
                    bgColor = Colors.green.withCustomOpacity(0.1);
                  }
                  
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildLegend(primaryColor),
        ],
      ),
    );
  }

  Widget _buildLegend(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legend',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const _LegendItem(color: Colors.orange, label: 'External Job (Hotel)'),
          const SizedBox(height: 8),
          _LegendItem(color: primaryColor, label: 'NCL Platform Shift'),
          const SizedBox(height: 8),
          const _LegendItem(color: Colors.green, label: 'Available for Booking'),
        ],
      ),
    );
  }

  void _showDayDetails(BuildContext context, TimekeepingProvider provider, DateTime day) {
    final shifts = provider.getShiftsForDate(day);
    final isToday = isSameDay(day, DateTime.now());
    final dateStr = DateFormat('EEEE, MMMM d, y').format(day);

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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isToday)
                          const Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            Expanded(
              child: shifts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 64,
                            color: Colors.green.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No shifts scheduled',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'This day is available for booking!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Searching for available jobs...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.search),
                            label: const Text('Find Jobs'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: shifts.length,
                      itemBuilder: (context, index) {
                        final shift = shifts[index];
                        return _ShiftCard(shift: shift);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withCustomOpacity(0.4),
                blurRadius: 3,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}

class _ShiftCard extends StatelessWidget {
  final WorkShift shift;

  const _ShiftCard({required this.shift});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    
    if (shift.isExternal) {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade900;
    } else if (shift.isNCL) {
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue.shade900;
    } else {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade900;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withCustomOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  shift.name ?? 'Shift',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: textColor.withCustomOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  shift.type.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          if (shift.hours != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: textColor.withCustomOpacity(0.7)),
                const SizedBox(width: 4),
                Text(
                  shift.hours!.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withCustomOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
          if (shift.location != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: textColor.withCustomOpacity(0.7)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    shift.location!,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withCustomOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}