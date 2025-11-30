import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:demo_ncl/models/staff_availability.dart';
import 'package:demo_ncl/providers/staff_provider.dart';
import 'package:demo_ncl/providers/theme_provider.dart';
import 'package:demo_ncl/utils/color_utils.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<TimeOfDay>> _availabilityMap = {};
  bool _isLoading = false;
  bool _showWeeklyView = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    final startDate = DateTime.now().subtract(const Duration(days: 7));
    final endDate = DateTime.now().add(const Duration(days: 30));
    
    // TODO: Implement loadAvailability method in StaffProvider
    // await context.read<StaffProvider>().loadAvailability(startDate, endDate: endDate);
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('My Availability'),
        actions: [
          IconButton(
            icon: Icon(_showWeeklyView ? Icons.calendar_today : Icons.view_week),
            onPressed: () {
              setState(() => _showWeeklyView = !_showWeeklyView);
            },
            tooltip: _showWeeklyView ? 'Switch to Monthly View' : 'Switch to Weekly View',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCalendar(),
                const Divider(height: 1),
                Expanded(
                  child: _selectedDay == null
                      ? const Center(child: Text('Select a date to set availability'))
                      : _buildAvailabilityEditor(),
                ),
              ],
            ),
      floatingActionButton: _selectedDay != null
          ? FloatingActionButton.extended(
              onPressed: _saveAvailability,
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
            )
          : null,
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: _showWeeklyView
          ? _buildWeekView()
          : TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
    );
  }

  Widget _buildWeekView() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            DateFormat('MMMM yyyy').format(_focusedDay),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Row(
          children: days.map((day) {
            final isSelected = isSameDay(_selectedDay, day);
            final isToday = isSameDay(day, DateTime.now());
            final hasAvailability = _hasAvailability(day);
            
            return Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedDay = day;
                    _focusedDay = day;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : isToday
                            ? Theme.of(context).primaryColor.withCustomOpacity(0.1)
                            : null,
                    borderRadius: BorderRadius.circular(8),
                    border: hasAvailability
                        ? Border.all(color: Colors.green, width: 2)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E').format(day),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        day.day.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isToday
                                  ? Theme.of(context).primaryColor
                                  : null,
                          fontWeight: isToday ? FontWeight.bold : null,
                        ),
                      ),
                      if (hasAvailability) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _hasAvailability(DateTime date) {
    final provider = context.read<StaffProvider>();
    final availability = provider.availability.where((a) => 
        (a as StaffAvailability).date.year == date.year && 
        (a as StaffAvailability).date.month == date.month && 
        (a as StaffAvailability).date.day == date.day
    ).toList();
    return availability.any((a) => (a as StaffAvailability).status == AvailabilityStatus.available);
  }

  Widget _buildAvailabilityEditor() {
    if (_selectedDay == null) return const SizedBox.shrink();

    final provider = context.watch<StaffProvider>();
    final availabilities = provider.availability.where((a) => 
        (a as StaffAvailability).date.year == _selectedDay!.year && 
        (a as StaffAvailability).date.month == _selectedDay!.month && 
        (a as StaffAvailability).date.day == _selectedDay!.day
    ).toList();
    final availableSlots = availabilities
        .where((a) => (a as StaffAvailability).status == AvailabilityStatus.available)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            DateFormat('EEEE, MMMM d, y').format(_selectedDay!),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Available Times', style: TextStyle(fontSize: 16)),
              TextButton.icon(
                onPressed: _addTimeSlot,
                icon: const Icon(Icons.add),
                label: const Text('Add Time'),
              ),
            ],
          ),
        ),
        Expanded(
          child: availableSlots.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No availability set for this day',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _addTimeSlot,
                        child: const Text('Add Availability'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: availableSlots.length,
                  itemBuilder: (context, index) {
                    final slot = availableSlots[index];
                    return _buildTimeSlotCard(slot);
                  },
                ),
        ),
        if (availableSlots.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _markAsUnavailable,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Mark as Unavailable'),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeSlotCard(StaffAvailability slot) {
    final startTime = TimeOfDay(hour: slot.startTime.hour, minute: slot.startTime.minute);
    final endTime = TimeOfDay(hour: slot.endTime.hour, minute: slot.endTime.minute);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.access_time, color: Colors.green),
        title: Text(
          '${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${_calculateDuration(startTime, endTime)} hours',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _removeTimeSlot(slot.id),
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dateTime);
  }

  String _calculateDuration(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final duration = (endMinutes - startMinutes) / 60.0;
    return duration.toStringAsFixed(1);
  }

  Future<void> _addTimeSlot() async {
    if (_selectedDay == null) return;

    final timeRange = await showTimeRangePicker(
      context: context,
      start: const TimeOfDay(hour: 9, minute: 0),
      end: const TimeOfDay(hour: 17, minute: 0),
      minDuration: const Duration(minutes: 30),
    );

    if (timeRange != null) {
      final provider = context.read<StaffProvider>();
      await provider.setAvailability(
        StaffAvailability(
          id: '',
          staffId: 'current_user_id', // TODO: Get from auth provider
          date: _selectedDay!,
          startTime: timeRange.start,
          endTime: timeRange.end,
          status: AvailabilityStatus.available,
        ),
      );
    }
  }

  Future<void> _removeTimeSlot(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Time Slot'),
        content: const Text('Are you sure you want to remove this time slot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implement removeAvailability method in StaffProvider
      // await context.read<StaffProvider>().removeAvailability(id);
    }
  }

  Future<void> _markAsUnavailable() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Unavailable'),
        content: const Text('Mark this day as completely unavailable?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark Unavailable'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = context.read<StaffProvider>();
      final availability = StaffAvailability(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        staffId: 'current_staff_id', // This should come from auth
        date: _selectedDay!,
        startTime: const TimeOfDay(hour: 0, minute: 0),
        endTime: const TimeOfDay(hour: 23, minute: 59),
        status: AvailabilityStatus.unavailable,
      );
      await provider.setAvailability(availability);
    }
  }

  Future<void> _saveAvailability() async {
    if (_selectedDay == null) return;

    final provider = context.read<StaffProvider>();
    final availability = StaffAvailability(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      staffId: 'current_staff_id', // This should come from auth
      date: _selectedDay!,
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 17, minute: 0),
      status: AvailabilityStatus.available,
    );
    final success = await provider.setAvailability(availability);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Availability updated successfully')),
      );
    } else if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update availability')),
      );
    }
  }
}

class TimeRangePicker extends StatefulWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ValueChanged<TimeRange> onTimeRangeChanged;
  final Duration minDuration;

  const TimeRangePicker({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onTimeRangeChanged,
    this.minDuration = const Duration(minutes: 30),
  });

  @override
  State<TimeRangePicker> createState() => _TimeRangePickerState();
}

class _TimeRangePickerState extends State<TimeRangePicker> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = widget.startTime;
    _endTime = widget.endTime;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text('Start Time'),
          trailing: Text(_formatTimeOfDay(_startTime)),
          onTap: () => _selectTime(context, isStartTime: true),
        ),
        ListTile(
          title: const Text('End Time'),
          trailing: Text(_formatTimeOfDay(_endTime)),
          onTap: () => _selectTime(context, isStartTime: false),
        ),
      ],
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dateTime);
  }

  Future<void> _selectTime(BuildContext context, {required bool isStartTime}) async {
    final initialTime = isStartTime ? _startTime : _endTime;
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = selectedTime;
          // Ensure end time is after start time
          if (_endTime.hour < _startTime.hour || 
              (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
            _endTime = TimeOfDay(
              hour: _startTime.hour,
              minute: (_startTime.minute + widget.minDuration.inMinutes) % 60,
            );
          }
        } else {
          _endTime = selectedTime;
          // Ensure end time is after start time
          if (_endTime.hour < _startTime.hour || 
              (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
            _startTime = TimeOfDay(
              hour: _endTime.hour - 1,
              minute: _endTime.minute,
            );
          }
        }
      });

      widget.onTimeRangeChanged(TimeRange(_startTime, _endTime));
    }
  }
}

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeRange(this.start, this.end);
}

Future<TimeRange?> showTimeRangePicker({
  required BuildContext context,
  required TimeOfDay start,
  required TimeOfDay end,
  Duration minDuration = const Duration(minutes: 30),
}) async {
  TimeRange? result;
  
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Select Time Range'),
      content: StatefulBuilder(
        builder: (context, setState) {
          return TimeRangePicker(
            startTime: start,
            endTime: end,
            minDuration: minDuration,
            onTimeRangeChanged: (range) {
              result = range;
              setState(() {});
            },
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  
  return result;
}
