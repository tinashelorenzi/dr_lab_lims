// lib/screens/main/main_layout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/auth_provider.dart';
import '../../shared/theme.dart';
import '../../widgets/glass_container.dart';
import 'tabs/dashboard_tab.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          
          // Main Content
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
      ),
    );
  }

  Widget _buildSidebar() {
    return MouseRegion(
      onEnter: (_) => setState(() => _sidebarHovered = true),
      onExit: (_) => setState(() => _sidebarHovered = false),
      child: AnimatedBuilder(
        animation: _sidebarAnimation,
        builder: (context, child) {
          final shouldShowLabels = _sidebarExpanded || _sidebarHovered;
          final sidebarWidth = shouldShowLabels ? 280.0 : 80.0;
          
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: sidebarWidth,
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
      padding: const EdgeInsets.all(20),
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
                  ),
                  Text(
                    'Laboratory Management',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _navigationItems.length,
      itemBuilder: (context, index) {
        final item = _navigationItems[index];
        final isSelected = _selectedIndex == index;
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _selectedIndex = index),
              child: Container(
                height: 48,
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
                  children: [
                    const SizedBox(width: 16),
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
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                          ),
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
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppTheme.borderColor, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  user?.firstName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              if (showLabels) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user?.email ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Page Title
          Text(
            _navigationItems[_selectedIndex].label,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const Spacer(),
          
          // Search
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
                filled: true,
                fillColor: AppTheme.surfaceColor,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Notifications
          IconButton(
            onPressed: () {
              // TODO: Implement notifications
            },
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
          ),
          
          const SizedBox(width: 8),
          
          // Help
          IconButton(
            onPressed: () {
              // TODO: Implement help
            },
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _navigationItems[_selectedIndex].tab,
    );
  }
}