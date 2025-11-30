import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/client_theme_config.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        backgroundColor: context.watch<ThemeProvider>().primaryColor,
        foregroundColor: Colors.white,
      ),
      backgroundColor: context.watch<ThemeProvider>().backgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Client Theme Configuration',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.watch<ThemeProvider>().textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a theme for the entire application',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          
          // Client Theme Options
          ...ClientThemeMode.values.map((theme) => _buildClientThemeOption(
            context,
            theme,
            context.watch<ThemeProvider>().currentTheme == theme,
          )),
          
          const SizedBox(height: 32),
          
          // Preview Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.watch<ThemeProvider>().cardColor,
              borderRadius: BorderRadius.circular(12),
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
                Text(
                  'Theme Preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.watch<ThemeProvider>().textColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Sample Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.watch<ThemeProvider>().cardColor,
                    border: Border.all(
                      color: context.watch<ThemeProvider>().primaryColor.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sample Service Card',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.watch<ThemeProvider>().textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This is how your service cards will look',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: context.watch<ThemeProvider>().primaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '4.8 (124 reviews)',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.watch<ThemeProvider>().textColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'R 1,200-2,000',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.watch<ThemeProvider>().primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientThemeOption(BuildContext context, ClientThemeMode theme, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<ThemeProvider>().setTheme(theme);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? context.watch<ThemeProvider>().primaryColor.withOpacity(0.1) : context.watch<ThemeProvider>().cardColor,
              border: Border.all(
                color: isSelected ? context.watch<ThemeProvider>().primaryColor : Colors.grey.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Theme Color Preview
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getClientThemeColor(theme),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Theme Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getClientThemeName(theme),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.watch<ThemeProvider>().textColor,
                        ),
                      ),
                      Text(
                        _getClientThemeDescription(theme),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.watch<ThemeProvider>().textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Selection Indicator
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: context.watch<ThemeProvider>().primaryColor,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getClientThemeColor(ClientThemeMode theme) {
    switch (theme) {
      case ClientThemeMode.currentTheme:
        return ClientThemeConfig.currentTheme['primary']!;
      case ClientThemeMode.navyGold:
        return ClientThemeConfig.navyGoldTheme['primary']!;
      case ClientThemeMode.greenOrange:
        return ClientThemeConfig.greenOrangeTheme['primary']!;
    }
  }

  String _getClientThemeName(ClientThemeMode theme) {
    switch (theme) {
      case ClientThemeMode.currentTheme:
        return 'Purple & Gold (Current)';
      case ClientThemeMode.navyGold:
        return 'Navy & Gold';
      case ClientThemeMode.greenOrange:
        return 'Green & Orange';
    }
  }

  String _getClientThemeDescription(ClientThemeMode theme) {
    switch (theme) {
      case ClientThemeMode.currentTheme:
        return 'Your current purple and gold theme';
      case ClientThemeMode.navyGold:
        return 'Professional navy blue with gold accents';
      case ClientThemeMode.greenOrange:
        return 'Modern green with orange highlights';
    }
  }
}
