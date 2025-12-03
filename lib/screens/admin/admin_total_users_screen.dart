// lib/screens/admin/admin_total_users_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/theme_provider.dart';
import '../../providers/admin_provider_web.dart';

import '../../routes/app_routes.dart';

class AdminTotalUsersScreen extends StatefulWidget {
  const AdminTotalUsersScreen({super.key});

  @override
  State<AdminTotalUsersScreen> createState() => _AdminTotalUsersScreenState();
}

class _AdminTotalUsersScreenState extends State<AdminTotalUsersScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule the data loading after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProviderWeb>().loadAdminData();
    });
  }

  // Helper method to get a safe color with fallback
  Color _getSafeColor(Color? color, {Color fallback = Colors.blue}) {
    return color ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProviderWeb>();
    final themeProvider = context.watch<ThemeProvider>();
    final backgroundColor = themeProvider.backgroundColor;

    // Get filtered user lists
    final staffAndCustomerUsers = adminProvider.users
        .where((user) => user.role != 'Admin')
        .toList();
    final staffUsers = adminProvider.users
        .where((user) => user.role == 'Staff')
        .toList();
    final customerUsers = adminProvider.users
        .where((user) => user.role == 'Customer')
        .toList();

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.cardColor,
        foregroundColor: themeProvider.primaryColor,
        elevation: 0,
        title: const Text('Total Users'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminProvider.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${adminProvider.error}',
                        style: themeProvider.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => adminProvider.loadAdminData(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Stats Cards
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Users',
                              staffAndCustomerUsers.length.toString(),
                              Icons.people,
                              themeProvider.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Staff',
                              staffUsers.length.toString(),
                              Icons.badge,
                              themeProvider.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Customers',
                              customerUsers.length.toString(),
                              Icons.person_outline,
                              themeProvider.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // User List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: staffAndCustomerUsers.length,
                        itemBuilder: (context, index) {
                          final user = staffAndCustomerUsers[index];
                          final userColor = user.role == 'Staff' 
                              ? themeProvider.primaryColor 
                              : themeProvider.primaryColor.withOpacity(0.7);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: themeProvider.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: !user.isActive
                                  ? Border.all(color: Colors.red, width: 1)
                                  : null,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: !user.isActive 
                                    ? Colors.red.withOpacity(0.1)
                                    : userColor.withOpacity(0.1),
                                child: Icon(
                                  user.role == 'Staff' 
                                      ? Icons.badge_outlined 
                                      : Icons.person_outline,
                                  color: !user.isActive ? Colors.red : userColor,
                                ),
                              ),
                              title: Text(
                                '${user.firstName} ${user.lastName}',
                                style: themeProvider.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.email),
                                  if (user.rating > 0)
                                    Row(
                                      children: List.generate(
                                        5,
                                        (index) => Icon(
                                          index < user.rating.floor()
                                              ? Icons.star
                                              : (index < user.rating
                                                  ? Icons.star_half
                                                  : Icons.star_border),
                                          color: userColor,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'toggle_status') {
                                    _confirmStatusChange(context, adminProvider, user);
                                  } else if (value == 'update_details') {
                                    _updateUserDetails(context, user);
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem<String>(
                                    value: 'update_details',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: themeProvider.primaryColor, size: 20),
                                        const SizedBox(width: 12),
                                        const Text('Update Details'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'toggle_status',
                                    child: Row(
                                      children: [
                                        Icon(
                                          user.isActive 
                                              ? Icons.block 
                                              : Icons.check_circle_outline,
                                          color: user.isActive ? Colors.red : themeProvider.primaryColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                            user.isActive ? 'Deactivate User' : 'Activate User'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                // Handle user tap
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmStatusChange(
      BuildContext context, AdminProviderWeb provider, AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.isActive ? 'Deactivate' : 'Activate'} User?'),
        content: Text(
            'Are you sure you want to ${user.isActive ? 'deactivate' : 'activate'} ${user.firstName} ${user.lastName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateUserStatus(user.id, !user.isActive);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isActive ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(user.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _updateUserDetails(BuildContext context, AdminUser user) {
    // Implement update user details functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update User Details'),
        content: const Text('User details update form would go here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}