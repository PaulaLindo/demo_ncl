import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'nav_bar.dart';

class BaseTabLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> statsCards; // row of cards shown under header
  final List<Tab> tabs;
  final List<Widget> tabViews;
  final List<NavItem> navItems;
  final String selectedRoute;
  final ValueChanged<String>? onNavSelected;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const BaseTabLayout({
    super.key,
    required this.title,
    this.subtitle,
    this.statsCards = const [],
    this.tabs = const [],
    this.tabViews = const [],
    this.navItems = const [],
    this.selectedRoute = '',
    this.onNavSelected,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
  })  : assert(tabs.length == tabViews.length, 'tabs and tabViews length must match');

  @override
  Widget build(BuildContext context) {
    final hasTabs = tabs.isNotEmpty;
    final content = Column(
      children: [
        // Header
        Container(
          color: AppTheme.cardBackground,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              // Optional back button
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: onBackPressed ?? () => Navigator.maybePop(context),
                  color: AppTheme.subtleText,
                ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subtitle != null)
                    Text(
                      subtitle !,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              if (actions != null) Row(children: actions!),
            ],
          ),
        ),

        // Stats row (cards)
        if (statsCards.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: statsCards
                  .map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: w)))
                  .toList(),
            ),
          ),

        // Tabs (optional)
        if (hasTabs)
          TabBar(
            tabs: tabs,
            indicatorColor: AppTheme.primaryPurple,
            labelColor: AppTheme.primaryPurple,
            unselectedLabelColor: AppTheme.textGrey,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),

        // Content area
        Expanded(
          child: hasTabs
              ? TabBarView(children: tabViews)
              : Container(
                  color: AppTheme.backgroundLight,
                  child: const SizedBox.shrink(),
                ),
        ),
      ],
    );

    return DefaultTabController(
      length: hasTabs ? tabs.length : 1,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: SafeArea(child: content),
        bottomNavigationBar: navItems.isNotEmpty
            ? CustomNavBar(items: navItems, selectedRoute: selectedRoute, onItemSelected: (r) {
                if (onNavSelected != null) onNavSelected!(r);
              })
            : null,
      ),
    );
  }
}