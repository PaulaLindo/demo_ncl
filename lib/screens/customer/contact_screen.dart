// lib/screens/customer/contact_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/theme_provider.dart';
import '../../utils/color_utils.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        title: Text(
          'Contact Support',
          style: TextStyle(
            color: context.watch<ThemeProvider>().primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: context.watch<ThemeProvider>().primaryColor,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.watch<ThemeProvider>().primaryColor,
                    context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We\'re here to help!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get in touch with our support team for any assistance.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withCustomOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Contact Methods
            Text(
              'Contact Methods',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.watch<ThemeProvider>().primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Phone Contact
            _buildContactCard(
              context,
              icon: Icons.phone,
              title: 'Phone Support',
              subtitle: 'Call us for immediate assistance',
              value: '+27 10 123 4567',
              onTap: () {
                // In a real app, this would open the phone dialer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Phone: +27 10 123 4567'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            
            // Email Contact
            _buildContactCard(
              context,
              icon: Icons.email,
              title: 'Email Support',
              subtitle: 'Send us an email for detailed queries',
              value: 'support@ncl.co.za',
              onTap: () {
                // In a real app, this would open email client
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email: support@ncl.co.za'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
            
            // WhatsApp Contact
            _buildContactCard(
              context,
              icon: Icons.message,
              title: 'WhatsApp Support',
              subtitle: 'Chat with us on WhatsApp',
              value: '+27 83 456 7890',
              onTap: () {
                // In a real app, this would open WhatsApp
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('WhatsApp: +27 83 456 7890'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            
            // Live Chat
            _buildContactCard(
              context,
              icon: Icons.chat,
              title: 'Live Chat',
              subtitle: 'Chat with our support team online',
              value: 'Available 24/7',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Live chat feature coming soon!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Office Hours
            Text(
              'Office Hours',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.watch<ThemeProvider>().primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.watch<ThemeProvider>().cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOfficeHoursRow(
                    context,
                    'Monday - Friday:',
                    '08:00 - 18:00',
                  ),
                  _buildOfficeHoursRow(
                    context,
                    'Saturday:',
                    '09:00 - 15:00',
                  ),
                  _buildOfficeHoursRow(
                    context,
                    'Sunday:',
                    '10:00 - 14:00',
                  ),
                  _buildOfficeHoursRow(
                    context,
                    'Public Holidays:',
                    '09:00 - 13:00',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Emergency Contact
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withCustomOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withCustomOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.emergency,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Emergency Contact',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'For urgent issues outside office hours:',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.watch<ThemeProvider>().textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+27 82 999 9999',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
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

  Widget _buildContactCard(
    BuildContext context,
    {
      required IconData icon,
      required String title,
      required String subtitle,
      required String value,
      required VoidCallback onTap,
    }
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.watch<ThemeProvider>().cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.watch<ThemeProvider>().primaryColor.withCustomOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: context.watch<ThemeProvider>().primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: context.watch<ThemeProvider>().textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: context.watch<ThemeProvider>().textColor.withCustomOpacity(0.7),
          ),
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: context.watch<ThemeProvider>().primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: context.watch<ThemeProvider>().primaryColor,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildOfficeHoursRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: context.watch<ThemeProvider>().textColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.watch<ThemeProvider>().primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
