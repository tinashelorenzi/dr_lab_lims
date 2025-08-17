import 'package:flutter/material.dart';
import '../../../shared/theme.dart';
import '../../../widgets/glass_container.dart';

class AIDataLabTab extends StatelessWidget {
  const AIDataLabTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // AI Tools Header
          GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.psychology, color: AppTheme.primaryColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Data Laboratory',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Advanced analytics and machine learning tools for laboratory data',
                            style: TextStyle(color: AppTheme.secondaryTextColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Tools
                Expanded(
                  flex: 1,
                  child: GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Tools',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        _buildAIToolCard('Predictive Analysis', Icons.trending_up, 'Predict test outcomes and trends'),
                        const SizedBox(height: 12),
                        _buildAIToolCard('Anomaly Detection', Icons.warning, 'Detect unusual patterns in data'),
                        const SizedBox(height: 12),
                        _buildAIToolCard('Quality Assessment', Icons.verified, 'AI-powered quality control'),
                        const SizedBox(height: 12),
                        _buildAIToolCard('Data Insights', Icons.lightbulb, 'Generate intelligent insights'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 24),
                
                // Analysis Results
                Expanded(
                  flex: 2,
                  child: GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Analysis Workspace',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.psychology_outlined, size: 48, color: AppTheme.secondaryTextColor),
                                  SizedBox(height: 16),
                                  Text(
                                    'AI Data Analysis Workspace',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Select an AI tool to begin analysis',
                                    style: TextStyle(color: AppTheme.secondaryTextColor),
                                  ),
                                ],
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
  
  Widget _buildAIToolCard(String title, IconData icon, String description) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}