import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/customer_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _currentRoute = 'profile';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primaryPurple,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  user?.name ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryPurple,
                        AppTheme.primaryPurple.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          user?.name.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Account Info
                  _buildSection('Account Information', [
                    _buildInfoTile(
                      Icons.person_rounded,
                      'Name',
                      user?.name ?? 'Not set',
                      onTap: () => _editName(context),
                    ),
                    _buildInfoTile(
                      Icons.email_rounded,
                      'Email',
                      user?.email ?? 'Not set',
                      onTap: () => _editEmail(context),
                    ),
                    _buildInfoTile(
                      Icons.phone_rounded,
                      'Phone',
                      '+27 82 123 4567',
                      onTap: () => _editPhone(context),
                    ),
                    _buildInfoTile(
                      Icons.location_on_rounded,
                      'Address',
                      '47 NCL Lane, Apt 2B, Durban',
                      onTap: () => _editAddress(context),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Preferences
                  _buildSection('Preferences', [
                    _buildSwitchTile(
                      Icons.notifications_rounded,
                      'Push Notifications',
                      true,
                      onChanged: (value) {},
                    ),
                    _buildSwitchTile(
                      Icons.email_rounded,
                      'Email Notifications',
                      true,
                      onChanged: (value) {},
                    ),
                    _buildInfoTile(
                      Icons.language_rounded,
                      'Language',
                      'English',
                      onTap: () {},
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Support
                  _buildSection('Support & Legal', [
                    _buildInfoTile(
                      Icons.help_rounded,
                      'Help Center',
                      'Get help and support',
                      onTap: () {},
                    ),
                    _buildInfoTile(
                      Icons.description_rounded,
                      'Terms & Conditions',
                      'Read our terms',
                      onTap: () {},
                    ),
                    _buildInfoTile(
                      Icons.privacy_tip_rounded,
                      'Privacy Policy',
                      'How we protect your data',
                      onTap: () {},
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Logout Button
                  ElevatedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Log Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.redStatus,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Version Info
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        items: _getNavItems(),
        selectedRoute: _currentRoute,
        onItemSelected: _handleNavigation,
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryPurple, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textGrey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, {required ValueChanged<bool> onChanged}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryPurple, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primaryPurple,
      ),
    );
  }

  void _editName(BuildContext context) {
    // Show edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit name coming soon!')),
    );
  }

  void _editEmail(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit email coming soon!')),
    );
  }

  void _editPhone(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit phone coming soon!')),
    );
  }

  void _editAddress(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit address coming soon!')),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                context.go('/');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.redStatus),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(String route) {
    setState(() => _currentRoute = route);
    switch (route) {
      case 'home':
        context.go('/customer/home');
        break;
      case 'services':
        context.push('/customer/services');
        break;
      case 'bookings':
        context.push('/customer/bookings');
        break;
    }
  }

  List<NavItem> _getNavItems() {
    return const [
      NavItem(label: 'Home', icon: Icons.home_rounded, route: 'home'),
      NavItem(label: 'Services', icon: Icons.grid_view_rounded, route: 'services'),
      NavItem(label: 'Bookings', icon: Icons.calendar_today_rounded, route: 'bookings'),
      NavItem(label: 'Profile', icon: Icons.person_rounded, route: 'profile'),
    ];
  }
}