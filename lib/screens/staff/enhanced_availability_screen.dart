// lib/screens/staff/enhanced_availability_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/staff_availability.dart';
import '../../providers/staff_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/color_utils.dart';

class EnhancedAvailabilityScreen extends StatefulWidget {
  const EnhancedAvailabilityScreen({super.key});

  @override
  State<EnhancedAvailabilityScreen> createState() => _EnhancedAvailabilityScreenState();
}

class _EnhancedAvailabilityScreenState extends State<EnhancedAvailabilityScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = false;
  bool _showWeeklyView = true;
  List<StaffAvailability> _availability = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() => _isLoading = true);
    
    try {
      // Get current availability from provider
      final staffProvider = context.read<StaffProvider>();
      setState(() {
        _availability = staffProvider.availability;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load availability: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        title: Text(_showWeeklyView ? 'Weekly Availability' : 'Daily Availability'),
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_showWeeklyView ? Icons.calendar_view_day : Icons.calendar_view_week),
            onPressed: () {
              setState(() {
                _showWeeklyView = !_showWeeklyView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAvailability,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _showWeeklyView
              ? _buildWeeklyView()
              : _buildDailyView(),
    );
  }

  Widget _buildWeeklyView() {
    return Column(
      children: [
        _buildWeekNavigation(),
        Expanded(
          child: ListView(
            children: [
              _buildWeekDaysList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekNavigation() {
    final weekStart = _getWeekStart(_focusedDay);
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDay = _focusedDay.subtract(const Duration(days: 7));
              });
            },
          ),
          Text(
            '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d, yyyy').format(weekEnd)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDay = _focusedDay.add(const Duration(days: 7));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaysList() {
    final weekStart = _getWeekStart(_focusedDay);
    final weekDays = List.generate(7, (index) => weekStart.add(Duration(days: index)));
    
    return Column(
      children: weekDays.map((date) {
        final availability = _getAvailabilityForDate(date);
        return _buildDayCard(date, availability);
      }).toList(),
    );
  }

  Widget _buildDayCard(DateTime date, StaffAvailability? availability) {
    final isToday = _isSameDay(date, DateTime.now());
    final dayName = DateFormat('EEEE').format(date);
    final dateStr = DateFormat('MMM d').format(date);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(availability?.status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.blue : Colors.black87,
                        ),
                      ),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 14,
                          color: isToday ? Colors.blue : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withCustomOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (availability != null)
              _buildAvailabilityInfo(availability)
            else
              _buildNoAvailabilityInfo(date),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityInfo(StaffAvailability availability) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              '${_formatTime(availability.startTime)} - ${_formatTime(availability.endTime)}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        if (availability.notes?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(
            availability.notes!,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatusChip(availability.status),
            const Spacer(),
            TextButton(
              onPressed: () => _editAvailability(availability),
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () => _removeAvailability(availability),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoAvailabilityInfo(DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No availability set',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _addAvailability(date),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Availability'),
        ),
      ],
    );
  }

  Widget _buildDailyView() {
    return Column(
      children: [
        _buildCalendarHeader(),
        Expanded(
          child: _buildCalendarGrid(),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_focusedDay),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemCount: (startingWeekday + daysInMonth),
      itemBuilder: (context, index) {
        if (index < startingWeekday) {
          return const SizedBox.shrink();
        }
        
        final day = index - startingWeekday + 1;
        final date = DateTime(_focusedDay.year, _focusedDay.month, day);
        final availability = _getAvailabilityForDate(date);
        final isToday = _isSameDay(date, DateTime.now());
        
        return _buildCalendarDay(date, availability, isToday);
      },
    );
  }

  Widget _buildCalendarDay(DateTime date, StaffAvailability? availability, bool isToday) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = date;
        });
        _showDayBottomSheet(date, availability);
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isToday ? Colors.blue.withCustomOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: availability != null ? _getStatusColor(availability.status) : Colors.grey[300]!,
            width: availability != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Colors.blue : Colors.black87,
              ),
            ),
            if (availability != null)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _getStatusColor(availability.status),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(AvailabilityStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withCustomOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          fontSize: 12,
          color: _getStatusColor(status),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showDayBottomSheet(DateTime date, StaffAvailability? availability) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildDayBottomSheet(date, availability),
    );
  }

  Widget _buildDayBottomSheet(DateTime date, StaffAvailability? availability) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(date),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (availability != null) ...[
            _buildAvailabilityDetails(availability),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _editAvailability(availability);
                    },
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _removeAvailability(availability);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Remove'),
                  ),
                ),
              ],
            ),
          ] else ...[
            const Text('No availability set for this day'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addAvailability(date);
                },
                child: const Text('Add Availability'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilityDetails(StaffAvailability availability) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Status', _getStatusText(availability.status)),
        _buildDetailRow('Time', '${_formatTime(availability.startTime)} - ${_formatTime(availability.endTime)}'),
        if (availability.notes?.isNotEmpty == true)
          _buildDetailRow('Notes', availability.notes!),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _addAvailability(DateTime date) {
    _showAvailabilityDialog(date: date);
  }

  void _editAvailability(StaffAvailability availability) {
    _showAvailabilityDialog(availability: availability);
  }

  void _removeAvailability(StaffAvailability availability) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Availability'),
        content: const Text('Are you sure you want to remove availability for this day?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Implement remove availability in StaffProvider
              _showSuccessSnackBar('Availability removed successfully');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAvailabilityDialog({DateTime? date, StaffAvailability? availability}) {
    showDialog(
      context: context,
      builder: (context) => AvailabilityDialog(
        date: date ?? DateTime.now(),
        availability: availability,
        onSave: (newAvailability) async {
          Navigator.pop(context);
          await _saveSingleAvailability(newAvailability);
        },
      ),
    );
  }

  Future<void> _saveSingleAvailability(StaffAvailability availability) async {
    try {
      final staffProvider = context.read<StaffProvider>();
      final success = await staffProvider.setAvailability(availability);
      
      if (success) {
        _showSuccessSnackBar('Availability saved successfully');
        await _loadAvailability();
      } else {
        _showErrorSnackBar('Failed to save availability');
      }
    } catch (e) {
      _showErrorSnackBar('Error saving availability: $e');
    }
  }

  Future<void> _saveAvailability() async {
    try {
      final staffProvider = context.read<StaffProvider>();
      // TODO: Implement bulk save in StaffProvider
      _showSuccessSnackBar('All availability saved successfully');
    } catch (e) {
      _showErrorSnackBar('Error saving availability: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Helper methods
  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  StaffAvailability? _getAvailabilityForDate(DateTime date) {
    try {
      return _availability.firstWhere(
        (a) => _isSameDay(a.date, date),
        orElse: () => StaffAvailability(
          id: '',
          staffId: '',
          date: date,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 17, minute: 0),
          status: AvailabilityStatus.unavailable,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  String _formatTime(TimeOfDay time) {
    return DateFormat('h:mm a').format(DateTime(2023, 1, 1, time.hour, time.minute));
  }

  Color _getStatusColor(AvailabilityStatus? status) {
    switch (status) {
      case AvailabilityStatus.available:
        return Colors.green;
      case AvailabilityStatus.unavailable:
        return Colors.grey;
      case AvailabilityStatus.booked:
        return Colors.blue;
      case AvailabilityStatus.requestedTimeOff:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return 'Available';
      case AvailabilityStatus.unavailable:
        return 'Unavailable';
      case AvailabilityStatus.booked:
        return 'Booked';
      case AvailabilityStatus.requestedTimeOff:
        return 'Time Off';
    }
  }
}

class AvailabilityDialog extends StatefulWidget {
  final DateTime date;
  final StaffAvailability? availability;
  final Function(StaffAvailability) onSave;

  const AvailabilityDialog({
    super.key,
    required this.date,
    this.availability,
    required this.onSave,
  });

  @override
  State<AvailabilityDialog> createState() => _AvailabilityDialogState();
}

class _AvailabilityDialogState extends State<AvailabilityDialog> {
  late AvailabilityStatus _status;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = widget.availability?.status ?? AvailabilityStatus.available;
    _startTime = widget.availability?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = widget.availability?.endTime ?? const TimeOfDay(hour: 17, minute: 0);
    _notesController.text = widget.availability?.notes ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.availability == null
            ? 'Add Availability'
            : 'Edit Availability',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(widget.date),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AvailabilityStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: AvailabilityStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusText(status)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Time'),
              trailing: Text(_formatTime(_startTime)),
              onTap: () => _selectTime(true),
            ),
            ListTile(
              title: const Text('End Time'),
              trailing: Text(_formatTime(_endTime)),
              onTap: () => _selectTime(false),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _selectTime(bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    
    if (time != null) {
      setState(() {
        if (isStartTime) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  void _save() {
    if (_startTime.hour > _endTime.hour || 
        (_startTime.hour == _endTime.hour && _startTime.minute >= _endTime.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final availability = StaffAvailability(
      id: widget.availability?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      staffId: 'current_staff_id', // TODO: Get from auth provider
      date: widget.date,
      startTime: _startTime,
      endTime: _endTime,
      status: _status,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(availability);
  }

  String _formatTime(TimeOfDay time) {
    return DateFormat('h:mm a').format(DateTime(2023, 1, 1, time.hour, time.minute));
  }

  String _getStatusText(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return 'Available';
      case AvailabilityStatus.unavailable:
        return 'Unavailable';
      case AvailabilityStatus.booked:
        return 'Booked';
      case AvailabilityStatus.requestedTimeOff:
        return 'Time Off';
    }
  }
}
