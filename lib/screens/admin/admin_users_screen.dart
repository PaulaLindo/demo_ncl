// lib/screens/admin/admin_users_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../providers/theme_provider.dart';
import '../../providers/admin_provider_web.dart';

import '../../utils/color_utils.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final String _currentRoute = 'users';

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProviderWeb>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: context.watch<ThemeProvider>().cardColor,
        foregroundColor: context.watch<ThemeProvider>().primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder(
        future: adminProvider.loadAdminData(),
        builder: (context, snapshot) {
          final staffUsers = adminProvider.users.where((user) => user.role == 'Staff').toList();
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: staffUsers.length,
            itemBuilder: (context, index) {
              final user = staffUsers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppTheme.cardShadow,
                  border: !user.isActive 
                      ? Border.all(color: AppTheme.redStatus, width: 1)
                      : null,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: !user.isActive 
                        ? AppTheme.redStatus.withCustomOpacity(0.1)
                        : (user.role == 'Staff' ? AppTheme.primaryPurple.withCustomOpacity(0.1) : AppTheme.goldAccent.withCustomOpacity(0.1)),
                    child: Icon(
                      user.role == 'Staff' ? Icons.badge_outlined : Icons.person_outline,
                      color: !user.isActive 
                          ? AppTheme.redStatus
                          : (user.role == 'Staff' ? AppTheme.primaryPurple : AppTheme.secondaryColor),
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
                                color: AppTheme.goldAccent,
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
                      } else if (value == 'update_details') {
                        _updateUserDetails(context, adminProvider, user);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      if (user.role == 'Staff')
                        PopupMenuItem<String>(
                          value: 'update_details',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: AppTheme.primaryPurple, size: 20),
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
                              color: user.isActive ? AppTheme.redStatus : AppTheme.greenStatus,
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
          );
        },
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
              backgroundColor: user.isActive ? AppTheme.redStatus : AppTheme.greenStatus,
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