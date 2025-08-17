// lib/screens/main/main_layout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../shared/theme.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/clients_tab.dart';
import 'tabs/client_projects_tab.dart';
import 'tabs/samples_tab.dart';
import 'tabs/test_entries_tab.dart';
import 'tabs/reports_tab.dart';
import 'tabs/messaging_tab.dart';
import 'tabs/ai_data_lab_tab.dart';
import 'tabs/settings_tab.dart';

class NavigationItem {
  final String id;
  final String label;
  final IconData icon;
  final Widget tab;
  
  const NavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.tab,
  });
}

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _sidebarExpanded = true;
  bool _sidebarHovered = false;
  
  late AnimationController _sidebarController;
  late Animation<double> _sidebarAnimation;
  
  final List<NavigationItem> _navigationItems = [
    const NavigationItem(
      id: 'dashboard',
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      tab: DashboardTab(),
    ),
    const NavigationItem(
      id: 'clients',
      label: 'Clients',
      icon: Icons.people_outlined,
      tab: ClientsTab(),
    ),
    const NavigationItem(
      id: 'client_projects',
      label: 'Client Projects',
      icon: Icons.work_outline,
      tab: ClientProjectsTab(),
    ),
    const NavigationItem(
      id: 'samples',
      label: 'Samples',
      icon: Icons.science_outlined,
      tab: SamplesTab(),
    ),
    const NavigationItem(
      id: 'test_entries',
      label: 'Test Entries',
      icon: Icons.assignment_outlined,
      tab: TestEntriesTab(),
    ),
    const NavigationItem(
      id: 'reports',
      label: 'Reports',
      icon: Icons.analytics_outlined,
      tab: ReportsTab(),
    ),
    const NavigationItem(
      id: 'messaging',
      label: 'Messaging',
      icon: Icons.message_outlined,
      tab: MessagingTab(),
    ),
    const NavigationItem(
      id: 'ai_data_lab',
      label: 'AI Data Lab',
      icon: Icons.psychology_outlined,
      tab: AIDataLabTab(),
    ),
    const NavigationItem(
      id: 'settings',
      label: 'Settings',
      icon: Icons.settings_outlined,
      tab: SettingsTab(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sidebarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeInOut,
    ));
    
    if (_sidebarExpanded) {
      _sidebarController.forward();
    }
    
    // Start heartbeat
    _startHeartbeat();
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  void _startHeartbeat() {
    // Ping every 30 seconds to keep session alive
    Stream.periodic(const Duration(seconds: 30)).listen((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.ping();
    });
  }

  void _toggleSidebar() {
    setState(() {
      _sidebarExpanded = !_sidebarExpanded;
      if (_sidebarExpanded) {
        _sidebarController.forward();
      } else {
        _sidebarController.reverse();
      }
    });
  }

  void _handleLogout(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  // Calculate responsive sidebar width based on screen size
  double _getSidebarWidth(BuildContext context, bool expanded) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (expanded) {
      // Expanded: 25% of screen width, but clamped between 250px and 320px
      return (screenWidth * 0.25).clamp(250.0, 320.0);
    } else {
      // Collapsed: Always 72px for icon + padding
      return 72.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine if we should auto-collapse on small screens
          final shouldAutoCollapse = constraints.maxWidth < 768;
          final effectiveExpanded = shouldAutoCollapse ? false : _sidebarExpanded;
          
          return Row(
            children: [
              // Sidebar - Responsive width
              _buildSidebar(context, effectiveExpanded),
              
              // Main Content - Takes remaining space
              Expanded(
                child: Column(
                  children: [
                    _buildAppBar(),
                    Expanded(
                      child: _buildContent(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool effectiveExpanded) {
    return MouseRegion(
      onEnter: (_) => setState(() => _sidebarHovered = true),
      onExit: (_) => setState(() => _sidebarHovered = false),
      child: AnimatedBuilder(
        animation: _sidebarAnimation,
        builder: (context, child) {
          final shouldShowLabels = effectiveExpanded || _sidebarHovered;
          final sidebarWidth = _getSidebarWidth(context, shouldShowLabels);
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: sidebarWidth,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.4, // Never more than 40% of screen
              minWidth: 72, // Always at least 72px for icons
            ),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceColor,
              border: Border(
                right: BorderSide(color: AppTheme.borderColor, width: 1),
              ),
            ),
            child: Column(
              children: [
                // App Header
                _buildSidebarHeader(shouldShowLabels),
                
                // Navigation Items
                Expanded(
                  child: _buildNavigationItems(shouldShowLabels),
                ),
                
                // User Profile Section
                _buildUserProfile(shouldShowLabels),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebarHeader(bool showLabels) {
    return Container(
      height: 80,
      padding: EdgeInsets.all(showLabels ? 20 : 16),
      child: Row(
        children: [
          // Toggle Button
          GestureDetector(
            onTap: _toggleSidebar,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.science_outlined,
                size: 20,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          
          if (showLabels) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'DR Lab LIMS',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    'Laboratory Management',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationItems(bool showLabels) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _navigationItems.length,
      itemBuilder: (context, index) {
        final item = _navigationItems[index];
        final isSelected = index == _selectedIndex;
        
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: showLabels ? 12 : 8, 
            vertical: 2
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _selectedIndex = index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 48,
                padding: EdgeInsets.symmetric(
                  horizontal: showLabels ? 16 : 12
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected 
                      ? Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: showLabels ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: isSelected 
                          ? AppTheme.primaryColor
                          : AppTheme.secondaryTextColor,
                    ),
                    
                    if (showLabels) ...[
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item.label,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected 
                                ? AppTheme.primaryColor
                                : AppTheme.primaryTextColor,
                            fontWeight: isSelected 
                                ? FontWeight.w600 
                                : FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserProfile(bool showLabels) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        
        return Container(
          padding: EdgeInsets.all(showLabels ? 16 : 12),
          child: showLabels 
              ? Row(
                  children: [
                    // User Avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        user?.email.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // User Info - Flexible to prevent overflow
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            user?.email ?? '',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.secondaryTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    
                    // Logout Button
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        size: 18,
                        color: AppTheme.secondaryTextColor,
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(Icons.person_outline, size: 18),
                              SizedBox(width: 12),
                              Text('Profile'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 18, color: AppTheme.errorColor),
                              SizedBox(width: 12),
                              Text('Sign Out', style: TextStyle(color: AppTheme.errorColor)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'logout') {
                          _handleLogout(authProvider);
                        }
                      },
                    ),
                  ],
                )
              : Center(
                  child: PopupMenuButton<String>(
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        user?.email.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'profile',
                        child: Row(
                          children: [
                            Icon(Icons.person_outline, size: 18),
                            SizedBox(width: 12),
                            Text('Profile'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, size: 18, color: AppTheme.errorColor),
                            SizedBox(width: 12),
                            Text('Sign Out', style: TextStyle(color: AppTheme.errorColor)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'logout') {
                        _handleLogout(authProvider);
                      }
                    },
                  ),
                ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Breadcrumb/Current Page
          Expanded(
            child: Text(
              _navigationItems[_selectedIndex].label,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          
          // Additional app bar actions
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
          
          const SizedBox(width: 8),
          
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      child: _navigationItems[_selectedIndex].tab,
    );
  }
}