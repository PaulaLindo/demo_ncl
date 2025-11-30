// lib/screens/staff/enhanced_mobile_profile_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/staff_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/color_utils.dart';

class EnhancedMobileProfileTab extends StatefulWidget {
  const EnhancedMobileProfileTab({super.key});

  @override
  State<EnhancedMobileProfileTab> createState() => _EnhancedMobileProfileTabState();
}

class _EnhancedMobileProfileTabState extends State<EnhancedMobileProfileTab>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    
    if (user != null) {
      _nameController.text = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _skillsController.text = 'Deep Cleaning, Window Cleaning, Carpet Cleaning'; // Mock skills
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final staffProvider = context.watch<StaffProvider>();
    final user = authProvider.currentUser;
    final userName = user?.firstName ?? 'Staff';

    return Column(
      children: [
        // Header
        _buildHeader(userName),
        
        // Tab Bar
        _buildTabBar(),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPersonalTab(authProvider),
              _buildPerformanceTab(staffProvider),
              _buildSettingsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String userName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondaryColor,
            AppTheme.secondaryColor.withCustomOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withCustomOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Profile',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Manage your professional profile',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withCustomOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: AppTheme.secondaryColor,
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(text: 'Personal'),
          Tab(text: 'Performance'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildPersonalTab(AuthProvider authProvider) {
    final user = authProvider.currentUser;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _isEditing = !_isEditing),
                icon: Icon(
                  _isEditing ? Icons.save : Icons.edit,
                  color: AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Profile Form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProfileField(
                  'Full Name',
                  _nameController,
                  Icons.person,
                  _isEditing,
                ),
                const SizedBox(height: 16),
                _buildProfileField(
                  'Email',
                  _emailController,
                  Icons.email,
                  false, // Email should not be editable
                ),
                const SizedBox(height: 16),
                _buildProfileField(
                  'Phone Number',
                  _phoneController,
                  Icons.phone,
                  _isEditing,
                ),
                const SizedBox(height: 16),
                _buildProfileField(
                  'Skills & Services',
                  _skillsController,
                  Icons.work,
                  _isEditing,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Professional Stats
          Text(
            'Professional Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Employee Since',
                  user != null ? DateFormat('MMM yyyy').format(user.createdAt!) : 'N/A',
                  Icons.calendar_today,
                  AppTheme.secondaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Jobs',
                  '156', // Mock data
                  Icons.work,
                  AppTheme.greenStatus,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Avg Rating',
                  '4.8',
                  Icons.star,
                  AppTheme.goldAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'On-Time Rate',
                  '98%',
                  Icons.timer,
                  AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Certifications
          Text(
            'Certifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildCertificationItem(
                  'Professional Cleaning Certification',
                  'Valid until Dec 2025',
                  Icons.verified,
                  AppTheme.greenStatus,
                ),
                const Divider(),
                _buildCertificationItem(
                  'Safety Training Certificate',
                  'Valid until Jun 2025',
                  Icons.security,
                  AppTheme.primaryPurple,
                ),
                const Divider(),
                _buildCertificationItem(
                  'Customer Service Excellence',
                  'Valid until Mar 2025',
                  Icons.emoji_events,
                  AppTheme.goldAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(StaffProvider staffProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          // Performance Metrics
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildPerformanceMetric(
                  'Customer Satisfaction',
                  '4.8 / 5.0',
                  'Based on 45 reviews',
                  Icons.sentiment_very_satisfied,
                  AppTheme.greenStatus,
                ),
                const Divider(),
                _buildPerformanceMetric(
                  'Job Completion Rate',
                  '98%',
                  '156 of 159 jobs completed',
                  Icons.task_alt,
                  AppTheme.primaryPurple,
                ),
                const Divider(),
                _buildPerformanceMetric(
                  'Average Response Time',
                  '2.5 hours',
                  'Time to accept job assignments',
                  Icons.access_time,
                  AppTheme.goldAccent,
                ),
                const Divider(),
                _buildPerformanceMetric(
                  'Punctuality Score',
                  '99%',
                  'On-time arrival rate',
                  Icons.schedule,
                  AppTheme.secondaryColor,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent Achievements
          Text(
            'Recent Achievements',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          _buildAchievementCard(
            'Top Performer of the Month',
            'October 2025',
            'Completed 25 jobs with 5-star rating',
            Icons.emoji_events,
            AppTheme.goldAccent,
          ),
          const SizedBox(height: 12),
          _buildAchievementCard(
            '100 Jobs Milestone',
            'September 2025',
            'Successfully completed 100 cleaning jobs',
            Icons.military_tech,
            AppTheme.primaryPurple,
          ),
          const SizedBox(height: 12),
          _buildAchievementCard(
            'Perfect Attendance',
            'Q3 2025',
            'No missed shifts for 3 months',
            Icons.calendar_today,
            AppTheme.greenStatus,
          ),
          
          const SizedBox(height: 24),
          
          // Customer Feedback
          Text(
            'Recent Customer Feedback',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFeedbackCard(
            'Sarah Johnson',
            'Excellent service! Very thorough and professional.',
            5,
            '2 days ago',
          ),
          const SizedBox(height: 12),
          _buildFeedbackCard(
            'Mike Chen',
            'Great attention to detail. Would definitely book again.',
            5,
            '1 week ago',
          ),
          const SizedBox(height: 12),
          _buildFeedbackCard(
            'Emily Davis',
            'Friendly and efficient. House looks amazing!',
            5,
            '2 weeks ago',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  'Change Password',
                  'Update your password for security',
                  Icons.lock,
                  AppTheme.secondaryColor,
                  () => _changePassword(),
                ),
                const Divider(),
                _buildSettingItem(
                  'Notification Preferences',
                  'Configure job alerts and notifications',
                  Icons.notifications,
                  AppTheme.primaryPurple,
                  () => _configureNotifications(),
                ),
                const Divider(),
                _buildSettingItem(
                  'Privacy Settings',
                  'Manage your privacy and data',
                  Icons.security,
                  AppTheme.goldAccent,
                  () => _managePrivacy(),
                ),
                const Divider(),
                _buildSettingItem(
                  'Payment Information',
                  'Update payment details and bank info',
                  Icons.payment,
                  AppTheme.greenStatus,
                  () => _managePaymentInfo(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'App Preferences',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSwitchTile(
                  'Push Notifications',
                  'Receive job alerts and updates',
                  true,
                  (value) {},
                ),
                const Divider(),
                _buildSwitchTile(
                  'Email Notifications',
                  'Get daily job summaries',
                  true,
                  (value) {},
                ),
                const Divider(),
                _buildSwitchTile(
                  'Location Services',
                  'Allow app to track location during work',
                  true,
                  (value) {},
                ),
                const Divider(),
                _buildSwitchTile(
                  'Dark Mode',
                  'Use dark theme (coming soon)',
                  false,
                  (value) {},
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Support
          Text(
            'Support & Help',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          _buildActionCard(
            'Contact Support',
            'Get help with any issues',
            Icons.support_agent,
            AppTheme.primaryPurple,
            () => _contactSupport(),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            'FAQ & Documentation',
            'Find answers to common questions',
            Icons.help,
            AppTheme.secondaryColor,
            () => _openFAQ(),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            'Report an Issue',
            'Report bugs or problems',
            Icons.bug_report,
            AppTheme.redStatus,
            () => _reportIssue(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller, IconData icon, bool enabled, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.secondaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            fillColor: enabled ? Colors.white : Colors.grey[50],
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationItem(String title, String validity, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(validity),
      trailing: const Icon(Icons.verified, color: AppTheme.greenStatus),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildPerformanceMetric(String title, String value, String subtitle, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _getPercentageFromValue(value),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(String title, String date, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withCustomOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(String customer, String feedback, int rating, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                customer,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  size: 16,
                  color: AppTheme.goldAccent,
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            feedback,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.secondaryColor,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withCustomOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  double _getPercentageFromValue(String value) {
    if (value.contains('/')) {
      final parts = value.split('/');
      final current = double.tryParse(parts[0].trim()) ?? 0;
      final total = double.tryParse(parts[1].trim()) ?? 1;
      return (current / total).clamp(0.0, 1.0);
    } else if (value.contains('%')) {
      final percentage = double.tryParse(value.replaceAll('%', '')) ?? 0;
      return (percentage / 100).clamp(0.0, 1.0);
    }
    return 0.8; // Default
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password changed successfully!'),
                  backgroundColor: AppTheme.greenStatus,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _configureNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings updated!'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  void _managePrivacy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy settings management coming soon!'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  void _managePaymentInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment information management coming soon!'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening support chat...'),
        backgroundColor: AppTheme.primaryPurple,
      ),
    );
  }

  void _openFAQ() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening FAQ section...'),
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  void _reportIssue() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening issue report form...'),
        backgroundColor: AppTheme.redStatus,
      ),
    );
  }
}
