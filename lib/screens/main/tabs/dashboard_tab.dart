// lib/screens/main/tabs/dashboard_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../shared/theme.dart';
import '../../../widgets/glass_container.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats
            _buildQuickStats().animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: 24),
            
            // Recent Activity & Charts Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Activity
                Expanded(
                  flex: 2,
                  child: _buildRecentActivity().animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
                ),
                
                const SizedBox(width: 24),
                
                // Quick Actions
                Expanded(
                  flex: 1,
                  child: _buildQuickActions().animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2, end: 0),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Charts Section
            _buildChartsSection().animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Samples', '1,247', Icons.science_outlined, AppTheme.primaryColor)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Pending Tests', '32', Icons.pending_outlined, AppTheme.warningColor)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Completed Today', '18', Icons.check_circle_outlined, AppTheme.successColor)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Active Users', '12', Icons.people_outlined, AppTheme.infoColor)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              Icon(Icons.trending_up, size: 16, color: AppTheme.successColor),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ...List.generate(5, (index) => _buildActivityItem(
            'Sample S-${2024000 + index}',
            'Test completed successfully',
            '${index + 1} min ago',
            Icons.check_circle_outlined,
            AppTheme.successColor,
          )),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          Text(
            time,
            style: const TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildActionButton('New Sample', Icons.add_circle_outlined, AppTheme.primaryColor),
          const SizedBox(height: 12),
          _buildActionButton('Run Test', Icons.play_circle_outlined, AppTheme.successColor),
          const SizedBox(height: 12),
          _buildActionButton('Generate Report', Icons.description_outlined, AppTheme.infoColor),
          const SizedBox(height: 12),
          _buildActionButton('Send Message', Icons.message_outlined, AppTheme.warningColor),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Row(
      children: [
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Test Volume Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Chart Placeholder\n(Recharts integration coming soon)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.secondaryTextColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 24),
        
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sample Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Pie Chart Placeholder\n(Recharts integration coming soon)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.secondaryTextColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}