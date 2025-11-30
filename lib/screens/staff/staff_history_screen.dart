import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/theme_provider.dart';
import '../../theme/theme_manager.dart';
import '../../utils/color_utils.dart';

class StaffHistoryScreen extends StatelessWidget {
  const StaffHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock completed gigs history data
    final completedGigs = [
      {
        'id': 'completed_1',
        'title': 'Office Deep Cleaning',
        'client': 'ABC Corporation',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'duration': '4 hours',
        'pay': 'R 1,200',
        'rating': 5.0,
        'location': 'Downtown Cape Town',
        'clientFeedback': 'Excellent work! Very thorough and professional.',
        'issues': [],
      },
      {
        'id': 'completed_2',
        'title': 'Home Cleaning Service',
        'client': 'Smith Family',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'duration': '2 hours',
        'pay': 'R 800',
        'rating': 4.5,
        'location': 'Suburbs',
        'clientFeedback': 'Great job, very satisfied with the service.',
        'issues': [],
      },
      {
        'id': 'completed_3',
        'title': 'Restaurant Kitchen Clean',
        'client': 'Italian Restaurant',
        'date': DateTime.now().subtract(const Duration(days: 8)),
        'duration': '3 hours',
        'pay': 'R 900',
        'rating': 4.0,
        'location': 'City Center',
        'clientFeedback': 'Good work, but could be more detailed next time.',
        'issues': ['Minor detail missed in corner area'],
      },
      {
        'id': 'completed_4',
        'title': 'Post-Construction Cleanup',
        'client': 'Construction Co',
        'date': DateTime.now().subtract(const Duration(days: 12)),
        'duration': '6 hours',
        'pay': 'R 1,500',
        'rating': 5.0,
        'location': 'New Development',
        'clientFeedback': 'Outstanding work! Handled difficult cleanup perfectly.',
        'issues': [],
      },
      {
        'id': 'completed_5',
        'title': 'Regular Maintenance',
        'client': 'Retail Store',
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'duration': '2.5 hours',
        'pay': 'R 750',
        'rating': 4.8,
        'location': 'Shopping Mall',
        'clientFeedback': 'Consistently good service. Very reliable.',
        'issues': [],
      },
    ];

    // Calculate statistics
    final totalEarnings = completedGigs.fold<double>(
      0, (sum, gig) => sum + double.parse((gig['pay'] as String).replaceAll('R ', '').replaceAll(',', '')),
    );
    final avgRating = completedGigs.fold<double>(
      0, (sum, gig) => sum + (gig['rating'] as double),
    ) / completedGigs.length;
    final totalHours = completedGigs.fold<double>(
      0, (sum, gig) => sum + double.parse((gig['duration'] as String).split(' ')[0]),
    );

    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.push('/staff/home');
          },
        ),
        title: const Text('History'),
      ),
      body: Column(
        children: [
          // Statistics Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.watch<ThemeProvider>().primaryColor,
                  context.watch<ThemeProvider>().secondaryColor,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Performance Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your completed gigs and earnings',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Total Earnings',
                        'R ${totalEarnings.toStringAsFixed(0)}',
                        Icons.attach_money,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Average Rating',
                        avgRating.toStringAsFixed(1),
                        Icons.star,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Total Hours',
                        '${totalHours.toStringAsFixed(1)}h',
                        Icons.access_time,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Filter and Sort Options
          Container(
            padding: const EdgeInsets.all(16),
            color: context.watch<ThemeProvider>().cardColor,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showFilterDialog(context);
                    },
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filter'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showSortDialog(context);
                    },
                    icon: const Icon(Icons.sort),
                    label: const Text('Sort'),
                  ),
                ),
              ],
            ),
          ),
          
          // History List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedGigs.length,
              itemBuilder: (context, index) {
                final gig = completedGigs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      _showGigDetails(context, gig);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  gig['title'] as String,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                gig['pay'] as String,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: context.watch<ThemeProvider>().secondaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Client and Date
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 16,
                                color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                gig['client'] as String,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM d, y').format(gig['date'] as DateTime),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Rating and Duration
                          Row(
                            children: [
                              Row(
                                children: List.generate(5, (index) {
                                  final rating = gig['rating'] as double;
                                  return Icon(
                                    index < rating ? Icons.star : Icons.star_border,
                                    size: 16,
                                    color: Colors.amber,
                                  );
                                }),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(gig['rating'] as double).toStringAsFixed(1)} • ${gig['duration']}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          
                          // Client Feedback Preview
                          if ((gig['clientFeedback'] as String).isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              '"${(gig['clientFeedback'] as String).length > 50 
                                  ? '${(gig['clientFeedback'] as String).substring(0, 50)}...'
                                  : gig['clientFeedback']}"',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          
                          // Issues (if any)
                          if ((gig['issues'] as List).isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withCustomOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${(gig['issues'] as List).length} issue(s) reported',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 12),
                          
                          // View Details Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                _showGigDetails(context, gig);
                              },
                              icon: const Icon(Icons.info_outline, size: 16),
                              label: const Text('View Details'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.white,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter History'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Last 7 days'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Last 30 days'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Last 3 months'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('5-star ratings only'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort History'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Most Recent'),
              value: 'recent',
              groupValue: 'recent',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Highest Pay'),
              value: 'pay',
              groupValue: 'recent',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Highest Rating'),
              value: 'rating',
              groupValue: 'recent',
              onChanged: (value) {},
            ),
            RadioListTile<String>(
              title: const Text('Longest Duration'),
              value: 'duration',
              groupValue: 'recent',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showGigDetails(BuildContext context, Map<String, dynamic> gig) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(gig['title'] as String),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Client', gig['client'] as String),
              _buildDetailRow('Date', DateFormat('MMMM d, y').format(gig['date'] as DateTime)),
              _buildDetailRow('Duration', gig['duration'] as String),
              _buildDetailRow('Pay', gig['pay'] as String),
              _buildDetailRow('Location', gig['location'] as String),
              _buildDetailRow('Rating', '${(gig['rating'] as double).toStringAsFixed(1)} ⭐'),
              
              if ((gig['clientFeedback'] as String).isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Client Feedback:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gig['clientFeedback'] as String,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              
              if ((gig['issues'] as List).isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Issues Reported:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                ...(gig['issues'] as List).map((issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text('• $issue'),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
