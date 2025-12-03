// lib/screens/customer/customer_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_manager.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_utils.dart';

class CustomerBookingsScreen extends StatelessWidget {
  const CustomerBookingsScreen({super.key});

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
            context.go(AppRoutes.customerHome);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.watch<ThemeProvider>().primaryColor,
                    context.watch<ThemeProvider>().secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'My Bookings',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track your upcoming and completed services',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Active',
                    '2',
                    Colors.green,
                    Icons.play_circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Completed',
                    '8',
                    context.watch<ThemeProvider>().primaryColor,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Pending',
                    '1',
                    Colors.orange,
                    Icons.pending,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Bookings List
            Text(
              'Recent Bookings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: context.watch<ThemeProvider>().textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                final bookings = [
                  {
                    'service': 'Deep Cleaning',
                    'date': 'Dec 15, 2024',
                    'time': '10:00 AM',
                    'status': 'active',
                    'price': 'R 3,750',
                    'id': 'booking_1',
                  },
                  {
                    'service': 'Regular Cleaning',
                    'date': 'Dec 18, 2024',
                    'time': '2:00 PM',
                    'status': 'pending',
                    'price': 'R 1,800',
                    'id': 'booking_2',
                  },
                  {
                    'service': 'Kitchen Cleaning',
                    'date': 'Dec 10, 2024',
                    'time': '9:00 AM',
                    'status': 'completed',
                    'price': 'R 2,250',
                    'id': 'booking_3',
                  },
                  {
                    'service': 'Bathroom Cleaning',
                    'date': 'Dec 5, 2024',
                    'time': '11:00 AM',
                    'status': 'completed',
                    'price': 'R 1,200',
                    'id': 'booking_4',
                  },
                  {
                    'service': 'Window Cleaning',
                    'date': 'Dec 1, 2024',
                    'time': '3:00 PM',
                    'status': 'completed',
                    'price': 'R 1,125',
                    'id': 'booking_5',
                  },
                ];
                
                final booking = bookings[index];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      final status = booking['status'] as String;
                      
                      // Only allow navigation for completed bookings
                      if (status == 'completed') {
                        final serviceId = booking['id'] as String;
                        // Navigate to service details for re-booking
                        context.push(AppRoutes.bookingFormForService(serviceId));
                      }
                      // Active and pending bookings are not clickable
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                booking['service'] as String,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: context.watch<ThemeProvider>().textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _buildStatusChip(
                                context,
                                booking['status'] as String,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                booking['date'] as String,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                booking['time'] as String,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                booking['price'] as String,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: context.watch<ThemeProvider>().secondaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Only show "Book Again" button for completed bookings
                              if (booking['status'] == 'completed')
                                TextButton(
                                  onPressed: () {
                                    // Navigate to booking screen for re-booking this service
                                    context.push('/customer/booking/1');
                                  },
                                  child: Text(
                                    'Book Again',
                                    style: TextStyle(color: context.watch<ThemeProvider>().primaryColor),
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
            
            const SizedBox(height: 32),
            
            // CTA Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.watch<ThemeProvider>().primaryColor,
                    context.watch<ThemeProvider>().secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Need to Book a Service?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: context.watch<ThemeProvider>().secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Schedule your next cleaning service with ease',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withCustomOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push(AppRoutes.customerServices);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Book New Service'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: context.watch<ThemeProvider>().primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withCustomOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withCustomOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status) {
      case 'active':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        displayText = 'Active';
        break;
      case 'confirmed':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        displayText = 'Confirmed';
        break;
      case 'completed':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        displayText = 'Completed';
        break;
      case 'pending':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        displayText = 'Pending';
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
