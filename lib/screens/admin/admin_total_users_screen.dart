// lib/screens/admin/admin_total_users_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_provider_web.dart';
import '../../providers/theme_provider.dart';

class AdminTotalUsersScreen extends StatefulWidget {
  const AdminTotalUsersScreen({super.key});

  @override
  State<AdminTotalUsersScreen> createState() => _AdminTotalUsersScreenState();
}

class _AdminTotalUsersScreenState extends State<AdminTotalUsersScreen> {
  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProviderWeb>();

    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      appBar: AppBar(
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        title: const Text('Total Users'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder(
        future: adminProvider.loadAdminData(),
        builder: (context, snapshot) {
          final staffAndCustomerUsers = adminProvider.users.where((user) => user.role != 'Admin').toList();
          final staffUsers = adminProvider.users.where((user) => user.role == 'Staff').toList();
          final customerUsers = adminProvider.users.where((user) => user.role == 'Customer').toList();
          
          return Column(
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
                        context.watch<ThemeProvider>().primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Staff',
                        staffUsers.length.toString(),
                        Icons.badge,
                        context.watch<ThemeProvider>().primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Customers',
                        customerUsers.length.toString(),
                        Icons.person_outline,
                        context.watch<ThemeProvider>().secondaryColor,
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
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: !user.isActive 
                              ? Colors.red.withOpacity(0.1)
                              : (user.role == 'Staff' ? context.watch<ThemeProvider>().primaryColor.withOpacity(0.1) : context.watch<ThemeProvider>().secondaryColor.withOpacity(0.1)),
                          child: Icon(
                            user.role == 'Staff' ? Icons.badge_outlined : Icons.person_outline,
                            color: !user.isActive 
                                ? Colors.red
                                : (user.role == 'Staff' ? context.watch<ThemeProvider>().primaryColor : context.watch<ThemeProvider>().secondaryColor),
                          ),
                        ),
                        title: Text(
                          user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${user.role} • ID: ${user.id}'),
                            const SizedBox(height: 4),
                            if (user.role == 'Staff')
                              Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    return Icon(
                                      index < user.rating.floor() 
                                        ? Icons.star 
                                        : (index < user.rating ? Icons.star_half : Icons.star_border),
                                      color: context.watch<ThemeProvider>().secondaryColor,
                                      size: 14,
                                    );
                                  }),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user.rating.toStringAsFixed(1)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'toggle_status') {
                              _confirmStatusToggle(context, adminProvider, user);
                            } else if (value == 'update_details' && user.role == 'Staff') {
                              _updateUserDetails(context, adminProvider, user);
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            if (user.role == 'Staff')
                              PopupMenuItem<String>(
                                value: 'update_details',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: context.watch<ThemeProvider>().primaryColor, size: 20),
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
                                    user.isActive ? Icons.block : Icons.check_circle_outline,
                                    color: user.isActive ? Colors.red : context.watch<ThemeProvider>().primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(user.isActive ? 'Deactivate User' : 'Activate User'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _confirmStatusToggle(BuildContext context, AdminProviderWeb provider, AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.isActive ? 'Deactivate User?' : 'Activate User?'),
        content: Text(
          user.isActive 
            ? 'This will revoke access for ${user.fullName}.' 
            : 'This will restore access for ${user.fullName}. Are you sure?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.updateUserStatus(user.id, !user.isActive);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User ${user.isActive ? 'deactivated' : 'activated'} successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isActive ? Colors.red : context.watch<ThemeProvider>().primaryColor,
            ),
            child: Text(user.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }
  
  void _updateUserDetails(BuildContext context, AdminProviderWeb provider, AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Staff Details - ${user.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Staff details updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
