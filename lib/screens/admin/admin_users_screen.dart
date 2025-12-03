// lib/screens/admin/admin_users_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/theme_provider.dart';
import '../../providers/admin_provider_web.dart';

import '../../routes/app_routes.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final String _currentRoute = 'users';
  late ThemeProvider themeProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProviderWeb>().loadAdminData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProviderWeb>();
    themeProvider = context.watch<ThemeProvider>();
    final backgroundColor = themeProvider.backgroundColor;

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: themeProvider.cardColor,
        foregroundColor: themeProvider.primaryColor,
        elevation: 0,
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
              : Consumer<AdminProviderWeb>(
                  builder: (context, provider, _) {
                    final staffUsers = provider.users
                        .where((user) => user.role == 'Staff')
                        .toList();
                        
                    if (staffUsers.isEmpty) {
                      return Center(
                        child: Text(
                          'No staff members found',
                          style: themeProvider.titleMedium,
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: staffUsers.length,
                      itemBuilder: (context, index) {
                        final user = staffUsers[index];
                        final statusColor = user.isActive 
                            ? themeProvider.primaryColor 
                            : themeProvider.errorColor;
                            
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: user.isActive 
                                  ? themeProvider.borderColor 
                                  : statusColor.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              backgroundColor: user.isActive
                                  ? themeProvider.primaryColor.withOpacity(0.1)
                                  : themeProvider.errorColor.withOpacity(0.1),
                              child: Icon(
                                Icons.person_outline,
                                color: user.isActive
                                    ? themeProvider.primaryColor
                                    : themeProvider.errorColor,
                              ),
                            ),
                            title: Text(
                              user.fullName,
                              style: themeProvider.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: themeProvider.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: user.isActive 
                                          ? themeProvider.primaryColor  
                                          : themeProvider.errorColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      user.isActive ? 'Active' : 'Inactive',
                                      style: themeProvider.bodySmall?.copyWith(
                                        color: user.isActive 
                                            ? themeProvider.primaryColor 
                                            : themeProvider.errorColor,
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
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem<String>(
                                  value: 'update_details',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: themeProvider.primaryColor,
                                        size: 20,
                                      ),
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
                                        color: user.isActive 
                                            ? themeProvider.errorColor 
                                            : themeProvider.primaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(user.isActive 
                                          ? 'Deactivate User' 
                                          : 'Activate User'
                                      ),
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
                    );
                  },
                ),
    );
  }

  void _confirmStatusToggle(BuildContext context, AdminProviderWeb provider, AdminUser user) {
    final theme = Theme.of(context);
    final isActivating = !user.isActive;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isActivating ? 'Activate User?' : 'Deactivate User?'),
        content: Text(
          isActivating
              ? 'This will restore access for ${user.fullName}.'
              : 'This will revoke access for ${user.fullName}.',
          style: themeProvider.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await provider.updateUserStatus(user.id, isActivating);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'User ${isActivating ? 'activated' : 'deactivated'} successfully',
                      ),
                      backgroundColor: isActivating 
                          ? themeProvider.primaryColor 
                          : themeProvider.errorColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to update user status: $e',
                        style: TextStyle(color: themeProvider.errorColor),
                      ),
                      backgroundColor: themeProvider.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isActivating 
                  ? themeProvider.primaryColor 
                  : themeProvider.errorColor,
              foregroundColor: isActivating
                  ? themeProvider.onPrimaryColor
                  : themeProvider.onErrorColor,
            ),
            child: Text(isActivating ? 'Activate' : 'Deactivate'),
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