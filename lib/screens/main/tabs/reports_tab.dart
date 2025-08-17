import 'package:flutter/material.dart';
import '../../../shared/theme.dart';
import '../../../widgets/glass_container.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search reports...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Generate Report'),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report Types
                Expanded(
                  flex: 1,
                  child: GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Report Types',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        _buildReportTypeCard('Sample Analysis', Icons.science, AppTheme.primaryColor),
                        const SizedBox(height: 12),
                        _buildReportTypeCard('Quality Control', Icons.verified, AppTheme.successColor),
                        const SizedBox(height: 12),
                        _buildReportTypeCard('Performance Metrics', Icons.analytics, AppTheme.infoColor),
                        const SizedBox(height: 12),
                        _buildReportTypeCard('Compliance Report', Icons.rule, AppTheme.warningColor),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 24),
                
                // Recent Reports
                Expanded(
                  flex: 2,
                  child: GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Reports',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 10,
                            itemBuilder: (context, index) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.infoColor.withOpacity(0.1),
                                  child: Icon(Icons.description, color: AppTheme.infoColor),
                                ),
                                title: Text('Report R-${2024000 + index}'),
                                subtitle: Text('Generated on 2024-08-${17 - index}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.download),
                                      tooltip: 'Download',
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.share),
                                      tooltip: 'Share',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReportTypeCard(String title, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}