import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:demo_ncl/models/gig_assignment.dart';
import 'package:demo_ncl/providers/staff_provider.dart';
import 'package:demo_ncl/providers/theme_provider.dart';

class GigManagementScreen extends StatefulWidget {
  const GigManagementScreen({super.key});

  @override
  State<GigManagementScreen> createState() => _GigManagementScreenState();
}

class _GigManagementScreenState extends State<GigManagementScreen> {
  final Map<GigStatus, bool> _filters = {
    GigStatus.pending: true,
    GigStatus.accepted: true,
    GigStatus.inProgress: true,
    GigStatus.completed: false,
    GigStatus.declined: false,
    GigStatus.cancelled: false,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<StaffProvider>();
    await provider.loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.watch<ThemeProvider>().backgroundColor,
        appBar: AppBar(
          backgroundColor: context.watch<ThemeProvider>().cardColor,
          foregroundColor: context.watch<ThemeProvider>().primaryColor,
          title: const Text('My Gigs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Pending'),
              Tab(text: 'History'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
          ],
        ),
        body: Consumer<StaffProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(child: Text('Error: ${provider.error}'));
            }

            return TabBarView(
              children: [
                _buildGigList(
                  provider.upcomingGigs
                      .where((gig) => _filters[gig.status] == true)
                      .toList(),
                ),
                _buildGigList(
                  provider.upcomingGigs
                      .where((gig) => gig.status == GigStatus.pending)
                      .toList(),
                ),
                _buildGigList(
                  provider.upcomingGigs
                      .where((gig) =>
                          gig.status == GigStatus.completed ||
                          gig.status == GigStatus.declined ||
                          gig.status == GigStatus.cancelled)
                      .toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGigList(List<GigAssignment> gigs) {
    if (gigs.isEmpty) {
      return const Center(
        child: Text('No gigs found'),
      );
    }

    return ListView.builder(
      itemCount: gigs.length,
      itemBuilder: (context, index) {
        final gig = gigs[index];
        return _GigCard(gig: gig);
      },
    );
  }

  Future<void> _showFilterDialog() async {
    final newFilters = Map<GigStatus, bool>.from(_filters);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Gigs'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: GigStatus.values.map((status) {
              return CheckboxListTile(
                title: Text(_formatStatus(status)),
                value: newFilters[status],
                onChanged: (value) {
                  newFilters[status] = value ?? false;
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _filters.clear();
                _filters.addAll(newFilters);
              });
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  String _formatStatus(GigStatus status) {
    return status.toString().split('.').last;
  }
}

class _GigCard extends StatelessWidget {
  final GigAssignment gig;

  const _GigCard({required this.gig});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: _buildStatusIndicator(),
        title: Text(
          gig.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDateRange()),
            if (gig.location.isNotEmpty) Text(gig.location),
          ],
        ),
        trailing: gig.status == GigStatus.pending
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _declineGig(context),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: () => _acceptGig(context),
                    child: const Text('Accept'),
                  ),
                ],
              )
            : null,
        onTap: () => _showGigDetails(context),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Color color;
    IconData icon;

    switch (gig.status) {
      case GigStatus.pending:
        color = Colors.orange;
        icon = Icons.access_time;
        break;
      case GigStatus.accepted:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case GigStatus.inProgress:
        color = Colors.blue;
        icon = Icons.timer_outlined;
        break;
      case GigStatus.completed:
        color = Colors.grey;
        icon = Icons.verified_outlined;
        break;
      case GigStatus.declined:
      case GigStatus.cancelled:
      case GigStatus.autoDeclined:
        color = Colors.red;
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withCustomOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _formatDateRange() {
    final dateFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat('h:mma');
    
    final startDate = dateFormat.format(gig.startTime);
    final endDate = dateFormat.format(gig.endTime);
    final startTime = timeFormat.format(gig.startTime);
    final endTime = timeFormat.format(gig.endTime);

    if (startDate == endDate) {
      return '$startDate • $startTime - $endTime';
    } else {
      return '$startDate $startTime - $endDate $endTime';
    }
  }

  Future<void> _acceptGig(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Gig'),
        content: const Text('Are you sure you want to accept this gig?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<StaffProvider>().acceptGig(gig.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gig accepted successfully')),
        );
      }
    }
  }

  Future<void> _declineGig(BuildContext context) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _DeclineGigDialog(),
    );

    if (reason != null) {
      final success = await context
          .read<StaffProvider>()
          .declineGig(gig.id, reason: reason);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gig declined')),
        );
      }
    }
  }

  void _showGigDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _GigDetailsSheet(gig: gig),
    );
  }
}

class _DeclineGigDialog extends StatefulWidget {
  @override
  State<_DeclineGigDialog> createState() => _DeclineGigDialogState();
}

class _DeclineGigDialogState extends State<_DeclineGigDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final List<String> _commonReasons = [
    'Not available',
    'Too far',
    'Conflict with another gig',
    'Other',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Decline Gig'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for declining this gig:'),
            const SizedBox(height: 16),
            ..._commonReasons.map((reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: OutlinedButton(
                    onPressed: () {
                      _reasonController.text = reason;
                      Navigator.pop(context, reason);
                    },
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(reason),
                  ),
                )),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Other reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a reason';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _reasonController.text);
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class _GigDetailsSheet extends StatelessWidget {
  final GigAssignment gig;

  const _GigDetailsSheet({required this.gig});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    _buildStatusChip(),
                    const Spacer(),
                    if (gig.status == GigStatus.pending)
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              // Implement decline
                              Navigator.pop(context);
                              // Show decline dialog
                            },
                            child: const Text('DECLINE',
                                style: TextStyle(color: Colors.red)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Implement accept
                              Navigator.pop(context);
                              // Show accept confirmation
                            },
                            child: const Text('ACCEPT'),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  gig.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.calendar_today,
                    DateFormat('EEEE, MMMM d, y').format(gig.startTime)),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.access_time,
                    '${_formatTimeRange(gig.startTime, gig.endTime)} (${_formatDuration(gig.duration ?? Duration.zero)})'),
                if (gig.location.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.location_on, gig.location),
                ],
                const SizedBox(height: 16),
                const Text('DETAILS',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                if (gig.notes?.isNotEmpty ?? false) ...[
                  Text(gig.notes!),
                  const SizedBox(height: 16),
                ],
                const Text('GIG STATUS',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                _buildStatusTimeline(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip() {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (gig.status) {
      case GigStatus.pending:
        backgroundColor = Colors.orange.withCustomOpacity(0.1);
        textColor = Colors.orange;
        statusText = 'Pending';
        break;
      case GigStatus.accepted:
        backgroundColor = Colors.green.withCustomOpacity(0.1);
        textColor = Colors.green;
        statusText = 'Accepted';
        break;
      case GigStatus.inProgress:
        backgroundColor = Colors.blue.withCustomOpacity(0.1);
        textColor = Colors.blue;
        statusText = 'In Progress';
        break;
      case GigStatus.completed:
        backgroundColor = Colors.grey.withCustomOpacity(0.1);
        textColor = Colors.grey;
        statusText = 'Completed';
        break;
      case GigStatus.declined:
      case GigStatus.cancelled:
      case GigStatus.autoDeclined:
        backgroundColor = Colors.red.withCustomOpacity(0.1);
        textColor = Colors.red;
        statusText = gig.status == GigStatus.declined ? 'Declined' : 
                    gig.status == GigStatus.cancelled ? 'Cancelled' : 'Auto Declined';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mma').format(time).toLowerCase();
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

  Widget _buildStatusTimeline() {
    final statuses = <_StatusItem>[];

    // Add all possible statuses in order
    statuses.add(_StatusItem(
      'Assigned',
      gig.createdAt,
      isCompleted: true,
    ));

    if (gig.status == GigStatus.pending) {
      statuses.add(_StatusItem(
        'Pending Acceptance',
        gig.createdAt,
        isCurrent: true,
      ));
    } else {
      statuses.add(_StatusItem(
        gig.status == GigStatus.declined || gig.status == GigStatus.cancelled
            ? 'Declined'
            : 'Accepted',
        gig.acceptedAt ?? DateTime.now(),
        isCompleted: gig.status != GigStatus.pending,
        isCurrent: gig.status == GigStatus.accepted,
      ));

      if (gig.status == GigStatus.inProgress ||
          gig.status == GigStatus.completed) {
        statuses.add(_StatusItem(
          'In Progress',
          gig.startTime,
          isCompleted: gig.status == GigStatus.completed,
          isCurrent: gig.status == GigStatus.inProgress,
        ));
      }

      if (gig.status == GigStatus.completed) {
        statuses.add(_StatusItem(
          'Completed',
          gig.endTime,
          isCompleted: true,
          isCurrent: false,
        ));
      }
    }

    return Column(
      children: List.generate(
        statuses.length,
        (index) {
          final isLast = index == statuses.length - 1;
          final status = statuses[index];
          final nextStatus = isLast ? null : statuses[index + 1];

          return _TimelineItem(
            status: status,
            isLast: isLast,
            hasGap: !isLast &&
                nextStatus != null &&
                nextStatus.date.difference(status.date).inHours > 24,
          );
        },
      ),
    );
  }
}

class _StatusItem {
  final String status;
  final DateTime date;
  final bool isCompleted;
  final bool isCurrent;

  _StatusItem(
    this.status,
    this.date, {
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

class _TimelineItem extends StatelessWidget {
  final _StatusItem status;
  final bool isLast;
  final bool hasGap;

  const _TimelineItem({
    required this.status,
    required this.isLast,
    required this.hasGap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: status.isCurrent
                        ? Theme.of(context).primaryColor
                        : status.isCompleted
                            ? Colors.green
                            : Colors.grey[300],
                    border: Border.all(
                      color: status.isCurrent || status.isCompleted
                          ? Colors.transparent
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: status.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: hasGap ? 60 : 40,
                    color: status.isCompleted ? Colors.green : Colors.grey[300],
                    margin: const EdgeInsets.only(top: 4, bottom: 4),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.status,
                    style: TextStyle(
                      fontWeight: status.isCurrent || status.isCompleted
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: status.isCurrent
                          ? Theme.of(context).primaryColor
                          : status.isCompleted
                              ? Colors.green
                              : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, y • h:mma').format(status.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (hasGap) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Waiting for next step...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (hasGap) const SizedBox(height: 16),
      ],
    );
  }
}
