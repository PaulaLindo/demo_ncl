import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class CustomerServicesScreen extends StatelessWidget {
  const CustomerServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.watch<ThemeProvider>().cardColor,
                border: Border(
                  bottom: BorderSide(
                    color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Available Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.watch<ThemeProvider>().primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Fixed 2-column grid like quick actions (no overflow)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85, // Increased height to prevent overflow
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                final services = [
                  {
                    'title': 'Deep Cleaning', 
                    'price': 'R 2,500-5,000', 
                    'description': 'Comprehensive deep cleaning service',
                    'rating': 4.8,
                    'reviews': 124,
                    'duration': '3-4 hours',
                    'category': 'Cleaning',
                    'isPopular': true,
                  },
                  {
                    'title': 'Regular Cleaning', 
                    'price': 'R 800-1,500', 
                    'description': 'Standard home cleaning service',
                    'rating': 4.6,
                    'reviews': 89,
                    'duration': '2-3 hours',
                    'category': 'Cleaning',
                    'isPopular': false,
                  },
                  {
                    'title': 'Office Cleaning', 
                    'price': 'R 1,200-2,000', 
                    'description': 'Professional office cleaning',
                    'rating': 4.7,
                    'reviews': 67,
                    'duration': '2-3 hours',
                    'category': 'Commercial',
                    'isPopular': false,
                  },
                  {
                    'title': 'Window Cleaning', 
                    'price': 'R 500-800', 
                    'description': 'Interior and exterior window cleaning',
                    'rating': 4.5,
                    'reviews': 45,
                    'duration': '1-2 hours',
                    'category': 'Specialized',
                    'isPopular': false,
                  },
                  {
                    'title': 'Carpet Cleaning', 
                    'price': 'R 600-1,200', 
                    'description': 'Deep carpet cleaning service',
                    'rating': 4.9,
                    'reviews': 156,
                    'duration': '2-3 hours',
                    'category': 'Specialized',
                    'isPopular': true,
                  },
                  {
                    'title': 'Post-Construction', 
                    'price': 'R 3,000-6,000', 
                    'description': 'Construction site cleanup',
                    'rating': 4.8,
                    'reviews': 78,
                    'duration': '4-6 hours',
                    'category': 'Specialized',
                    'isPopular': false,
                  },
                ];
                
                final service = services[index];
                
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      // Navigate to booking screen for this service with correct service ID
                      final serviceIds = ['s1', 's2', 's3', 's4', 's5', 's6'];
                      context.push('/customer/booking/${serviceIds[index]}');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(14), // More balanced padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Left-align content
                        children: [
                          // Title
                          Text(
                            service['title'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: context.watch<ThemeProvider>().textColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left, // Left-align text
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // Category
                          Text(
                            service['category'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.left, // Left-align text
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Description
                          Text(
                            service['description'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.watch<ThemeProvider>().textColor.withOpacity(0.6),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left, // Left-align text
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Duration
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: context.watch<ThemeProvider>().primaryColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                service['duration'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: context.watch<ThemeProvider>().primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Rating
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: context.watch<ThemeProvider>().primaryColor,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${service['rating']}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: context.watch<ThemeProvider>().textColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${service['reviews']})',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.watch<ThemeProvider>().textColor.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Spacer to push price to bottom
                          const Spacer(),
                          
                          // Price
                          Text(
                            service['price'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: context.watch<ThemeProvider>().primaryColor,
                            ),
                            textAlign: TextAlign.left, // Left-align text
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
                    'Need Help Choosing?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our experts can help you find the perfect service for your needs',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to help or contact
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat with Expert'),
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
}
