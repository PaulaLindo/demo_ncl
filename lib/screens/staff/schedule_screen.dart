import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

import '../../../models/gig_assignment.dart';
import '../../../providers/staff_provider.dart';
import '../../../providers/theme_provider.dart';

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final CalendarController _calendarController = CalendarController();
  bool _isLoading = true;
  final DateTime _selectedDate = DateTime.now();
  CalendarView _calendarView = CalendarView.week;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<StaffProvider>();
    await provider.loadJobs();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().primaryColor,
        foregroundColor: Colors.white,
        title: const Text('My Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              _calendarController.displayDate = DateTime.now();
            },
            tooltip: 'Today',
          ),
          PopupMenuButton<CalendarView>(
            icon: const Icon(Icons.calendar_view_day),
            onSelected: (view) {
              setState(() {
                _calendarView = view;
                _calendarController.view = view;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarView.day,
                child: Text('Day'),
              ),
              const PopupMenuItem(
                value: CalendarView.week,
                child: Text('Week'),
              ),
              const PopupMenuItem(
                value: CalendarView.workWeek,
                child: Text('Work Week'),
              ),
              const PopupMenuItem(
                value: CalendarView.month,
                child: Text('Month'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCalendarHeader(),
                Expanded(
                  child: Consumer<StaffProvider>(
                    builder: (context, provider, _) {
                      if (provider.error != null) {
                        return Center(child: Text('Error: ${provider.error}'));
                      }

                      return SfCalendar(
                        controller: _calendarController,
                        view: _calendarView,
                        dataSource: _GigDataSource(provider.upcomingGigs),
                        initialDisplayDate: _selectedDate,
                        initialSelectedDate: _selectedDate,
                        onViewChanged: (ViewChangedDetails details) {
                          // Handle view change if needed
                        },
                        onTap: (CalendarTapDetails details) {
                          if (details.targetElement ==
                              CalendarElement.calendarCell) {
                            _showDateDetails(details.date!);
                          } else if (details.targetElement ==
                              CalendarElement.appointment) {
                            final gig = details.appointments!.first as GigAssignment;
                            _showGigDetails(gig);
                          }
                        },
                        timeSlotViewSettings: const TimeSlotViewSettings(
                          timeFormat: 'h:mm a',
                          timeInterval: Duration(minutes: 30),
                          timeIntervalHeight: 60,
                          timeTextStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          timeRulerSize: 80,
                        ),
                        monthViewSettings: const MonthViewSettings(
                          showAgenda: true,
                          appointmentDisplayMode:
                              MonthAppointmentDisplayMode.appointment,
                        ),
                        appointmentBuilder: (context, details) {
                          final gig = details.appointments.first as GigAssignment;
                          return Container(
                            decoration: BoxDecoration(
                              color: _getGigColor(gig.status),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  gig.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${_formatTime(gig.startTime)} - ${_formatTime(gig.endTime)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withCustomOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              _navigateToPeriod(-1);
            },
          ),
          Consumer<StaffProvider>(
            builder: (context, provider, _) {
              return Text(
                _getHeaderTitle(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              _navigateToPeriod(1);
            },
          ),
        ],
      ),
    );
  }

  String _getHeaderTitle() {
    switch (_calendarView) {
      case CalendarView.day:
        return DateFormat('EEEE, MMMM d, y').format(_calendarController.displayDate!);
      case CalendarView.week:
      case CalendarView.workWeek:
        final startOfWeek = _calendarController.displayDate!;
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d, y').format(endOfWeek)}';
      case CalendarView.month:
        return DateFormat('MMMM y').format(_calendarController.displayDate!);
      case CalendarView.timelineDay:
      case CalendarView.timelineWeek:
      case CalendarView.timelineWorkWeek:
      case CalendarView.timelineMonth:
      case CalendarView.schedule:
        return DateFormat('MMMM y').format(_calendarController.displayDate!);
    }
  }

  void _navigateToPeriod(int delta) {
    switch (_calendarView) {
      case CalendarView.day:
        _calendarController.displayDate =
            _calendarController.displayDate!.add(Duration(days: delta));
        break;
      case CalendarView.week:
      case CalendarView.workWeek:
        _calendarController.displayDate =
            _calendarController.displayDate!.add(Duration(days: 7 * delta));
        break;
      case CalendarView.month:
        _calendarController.displayDate = DateTime(
          _calendarController.displayDate!.year,
          _calendarController.displayDate!.month + delta,
          1,
        );
        break;
      case CalendarView.timelineDay:
      case CalendarView.timelineWeek:
      case CalendarView.timelineWorkWeek:
      case CalendarView.timelineMonth:
      case CalendarView.schedule:
        // Handle other view types if needed
        break;
    }
  }

  void _showDateDetails(DateTime date) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _DateDetailsSheet(date: date),
    );
  }

  void _showGigDetails(GigAssignment gig) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(gig.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.calendar_today,
                DateFormat('EEEE, MMMM d, y').format(gig.startTime)),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.access_time,
                '${_formatTime(gig.startTime)} - ${_formatTime(gig.endTime)}'),
            if (gig.location.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.location_on, gig.location),
            ],
            if (gig.notes?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(gig.notes!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (gig.status == GigStatus.pending)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: Implement decline gig
                    Navigator.pop(context);
                  },
                  child: const Text('Decline', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement accept gig
                    Navigator.pop(context);
                  },
                  child: const Text('Accept'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  Color _getGigColor(GigStatus status) {
    switch (status) {
      case GigStatus.pending:
        return Colors.orange;
      case GigStatus.accepted:
        return Colors.green;
      case GigStatus.inProgress:
        return Colors.blue;
      case GigStatus.completed:
        return Colors.grey;
      case GigStatus.declined:
      case GigStatus.cancelled:
      case GigStatus.autoDeclined:
        return Colors.red;
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mma').format(time).toLowerCase();
  }
}

class _DateDetailsSheet extends StatelessWidget {
  final DateTime date;

  const _DateDetailsSheet({required this.date});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StaffProvider>(context);
    final gigs = provider.upcomingGigs.where((gig) =>
        isSameDay(gig.startTime, date) ||
        isSameDay(gig.endTime, date) ||
        (gig.startTime.isBefore(date) && gig.endTime.isAfter(date)));

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withCustomOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: gigs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No gigs scheduled',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You have no gigs scheduled for this day.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: gigs.length,
                        itemBuilder: (context, index) {
                          final gig = gigs.elementAt(index);
                          return _GigListItem(gig: gig);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GigListItem extends StatelessWidget {
  final GigAssignment gig;

  const _GigListItem({required this.gig});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Container(
          width: 4,
          decoration: BoxDecoration(
            color: _getStatusColor(gig.status),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          gig.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${_formatTime(gig.startTime)} - ${_formatTime(gig.endTime)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (gig.location.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                gig.location,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        trailing: _buildStatusChip(),
        onTap: () {
          Navigator.pop(context); // Close the bottom sheet
          _showGigDetails(context, gig);
        },
      ),
    );
  }

  Widget _buildStatusChip() {
    String statusText;
    Color backgroundColor;
    Color textColor;

    switch (gig.status) {
      case GigStatus.pending:
        statusText = 'Pending';
        backgroundColor = Colors.orange.withCustomOpacity(0.1);
        textColor = Colors.orange;
        break;
      case GigStatus.accepted:
        statusText = 'Accepted';
        backgroundColor = Colors.green.withCustomOpacity(0.1);
        textColor = Colors.green;
        break;
      case GigStatus.inProgress:
        statusText = 'In Progress';
        backgroundColor = Colors.blue.withCustomOpacity(0.1);
        textColor = Colors.blue;
        break;
      case GigStatus.completed:
        statusText = 'Completed';
        backgroundColor = Colors.grey.withCustomOpacity(0.1);
        textColor = Colors.grey;
        break;
      case GigStatus.declined:
        statusText = 'Declined';
        backgroundColor = Colors.red.withCustomOpacity(0.1);
        textColor = Colors.red;
        break;
      case GigStatus.cancelled:
        statusText = 'Cancelled';
        backgroundColor = Colors.red.withCustomOpacity(0.1);
        textColor = Colors.red;
        break;
      case GigStatus.autoDeclined:
        statusText = 'Auto Declined';
        backgroundColor = Colors.red.withCustomOpacity(0.1);
        textColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(GigStatus status) {
    switch (status) {
      case GigStatus.pending:
        return Colors.orange;
      case GigStatus.accepted:
        return Colors.green;
      case GigStatus.inProgress:
        return Colors.blue;
      case GigStatus.completed:
        return Colors.grey;
      case GigStatus.declined:
      case GigStatus.cancelled:
      case GigStatus.autoDeclined:
        return Colors.red;
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mma').format(time).toLowerCase();
  }

  void _showGigDetails(BuildContext context, GigAssignment gig) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(gig.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              context,
              Icons.calendar_today,
              DateFormat('EEEE, MMMM d, y').format(gig.startTime),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              Icons.access_time,
              '${_formatTime(gig.startTime)} - ${_formatTime(gig.endTime)} (${_formatDuration(gig.duration ?? Duration.zero)})',
            ),
            if (gig.location.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow(context, Icons.location_on, gig.location),
            ],
            if (gig.notes?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(gig.notes!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (gig.status == GigStatus.pending)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // TODO: Implement decline gig
                    Navigator.pop(context);
                  },
                  child: const Text('Decline', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement accept gig
                    Navigator.pop(context);
                  },
                  child: const Text('Accept'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}

class _GigDataSource extends CalendarDataSource {
  _GigDataSource(List<GigAssignment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getGigData(index).startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return _getGigData(index).endTime;
  }

  @override
  String getSubject(int index) {
    return _getGigData(index).title;
  }

  @override
  Color getColor(int index) {
    return _getStatusColor(_getGigData(index).status);
  }

  @override
  bool isAllDay(int index) {
    return false;
  }

  GigAssignment _getGigData(int index) {
    final gigData = appointments![index];
    GigAssignment gig;
    if (gigData is GigAssignment) {
      gig = gigData;
    } else {
      // TODO: Implement GigAssignment.fromMap factory
      // gig = GigAssignment.fromMap(gigData as Map<String, dynamic>);
      gig = gigData; // Temporary fix
    }
    return gig;
  }

  Color _getStatusColor(GigStatus status) {
    switch (status) {
      case GigStatus.pending:
        return Colors.orange;
      case GigStatus.accepted:
        return Colors.green;
      case GigStatus.inProgress:
        return Colors.blue;
      case GigStatus.completed:
        return Colors.grey;
      case GigStatus.declined:
      case GigStatus.cancelled:
      case GigStatus.autoDeclined:
        return Colors.red;
    }
  }
}
