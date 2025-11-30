import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/staff_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/theme_manager.dart';
import '../../utils/color_utils.dart';

class StaffServicesScreen extends StatelessWidget {
  const StaffServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock available services data
    final availableServices = [
      {
        'id': 'service_1',
        'title': 'Emergency Deep Clean',
        'location': 'Cape Town CBD',
        'pay': 'R 1,500',
        'urgency': 'high',
        'time': 'Available Now',
        'duration': '4 hours',
        'client': 'Office Building A',
        'distance': '2.5 km',
        'description': 'Immediate deep cleaning required for office building after water damage.',
        'skills': ['Deep Cleaning', 'Water Damage', 'Commercial'],
        'equipment': ['Industrial Vacuum', 'Cleaning Chemicals', 'Safety Gear'],
      },
      {
        'id': 'service_2',
        'title': 'Regular Home Cleaning',
        'location': 'Suburbs',
        'pay': 'R 800',
        'urgency': 'medium',
        'time': 'Tomorrow 2PM',
        'duration': '2 hours',
        'client': 'Smith Family',
        'distance': '5.1 km',
        'description': 'Regular bi-weekly cleaning for 3-bedroom family home.',
        'skills': ['Residential Cleaning', 'Detail Oriented'],
        'equipment': ['Standard Cleaning Kit', 'Microfiber Cloths'],
      },
      {
        'id': 'service_3',
        'title': 'Post-Construction Clean',
        'location': 'New Development',
        'pay': 'R 2,000',
        'urgency': 'high',
        'time': 'Today 6PM',
        'duration': '6 hours',
        'client': 'Construction Co',
        'distance': '8.3 km',
        'description': 'Post-construction cleanup for new apartment complex.',
        'skills': ['Construction Cleanup', 'Heavy Duty', 'Safety Protocol'],
        'equipment': ['Heavy Duty Vacuum', 'Safety Equipment', 'Waste Disposal'],
      },
      {
        'id': 'service_4',
        'title': 'Kitchen Deep Clean',
        'location': 'Restaurant District',
        'pay': 'R 1,200',
        'urgency': 'medium',
        'time': 'Tonight 10PM',
        'duration': '3 hours',
        'client': 'Italian Restaurant',
        'distance': '3.7 km',
        'description': 'Commercial kitchen deep cleaning after business hours.',
        'skills': ['Commercial Kitchen', 'Food Safety', 'Degreasing'],
        'equipment': ['Degreasers', 'Steam Cleaner', 'Food Safe Chemicals'],
      },
      {
        'id': 'service_5',
        'title': 'Window Cleaning Service',
        'location': 'City Center',
        'pay': 'R 900',
        'urgency': 'low',
        'time': 'Next Week Monday',
        'duration': '2.5 hours',
        'client': 'Retail Store',
        'distance': '1.8 km',
        'description': 'Professional window cleaning for storefront windows.',
        'skills': ['Window Cleaning', 'Height Work', 'Attention to Detail'],
        'equipment': ['Squeegees', 'Ladders', 'Cleaning Solution'],
      },
    ];

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
        title: const Text('Available Services'),
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: context.watch<ThemeProvider>().cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search services...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    // Show filter options
                    _showFilterDialog(context);
                  },
                  icon: const Icon(Icons.filter_list),
                ),
              ],
            ),
          ),
          
          // Services List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableServices.length,
              itemBuilder: (context, index) {
                final service = availableServices[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Navigate to service details
                      context.push('/staff/service/${service['id']}');
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  service['title'] as String,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: context.watch<ThemeProvider>().textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: service['urgency'] == 'high' 
                                      ? Colors.red.withCustomOpacity(0.1)
                                      : service['urgency'] == 'medium'
                                          ? Colors.orange.withCustomOpacity(0.1)
                                          : Colors.green.withCustomOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  (service['urgency'] as String).toUpperCase(),
                                  style: TextStyle(
                                    color: service['urgency'] == 'high' 
                                        ? Colors.red
                                        : service['urgency'] == 'medium'
                                            ? Colors.orange
                                            : Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Description
                          Text(
                            service['description'] as String,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Details Grid
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                  context,
                                  Icons.location_on_outlined,
                                  '${service['location']} • ${service['distance']}',
                                ),
                              ),
                              Expanded(
                                child: _buildDetailItem(
                                  context,
                                  Icons.access_time,
                                  '${service['time']} • ${service['duration']}',
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                  context,
                                  Icons.person_outline,
                                  service['client'] as String,
                                ),
                              ),
                              Expanded(
                                child: _buildDetailItem(
                                  context,
                                  Icons.attach_money,
                                  service['pay'] as String,
                                  isPrice: true,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Skills Chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: (service['skills'] as List<String>)
                                .take(3)
                                .map((skill) => Chip(
                                      label: Text(
                                        skill,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      backgroundColor: context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.1),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ))
                                .toList(),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // View more details
                                    context.push('/staff/service/${service['id']}');
                                  },
                                  icon: const Icon(Icons.info_outline),
                                  label: const Text('Details'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Accept service
                                    context.push('/staff/confirm-service/${service['id']}');
                                  },
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text('Accept Service'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.watch<ThemeProvider>().primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildDetailItem(BuildContext context, IconData icon, String text, {bool isPrice = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isPrice ? context.watch<ThemeProvider>().secondaryColor : context.watch<ThemeProvider>().textColor.withOpacity(0.7),
              fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Services'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('High Urgency'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Available Now'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Within 5km'),
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
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}
