import 'package:flutter/material.dart';
import '../../../shared/theme.dart';
import '../../../widgets/glass_container.dart';

class ClientProjectsTab extends StatelessWidget {
  const ClientProjectsTab({super.key});

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
                    hintText: 'Search projects...',
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
                label: const Text('New Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Client Projects Management',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Project ID')),
                        DataColumn(label: Text('Project Name')),
                        DataColumn(label: Text('Client')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Start Date')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: List.generate(10, (index) => DataRow(
                        cells: [
                          DataCell(Text('P-${2024000 + index}')),
                          DataCell(Text('Project ${index + 1}')),
                          DataCell(Text('Client ${(index % 3) + 1}')),
                          DataCell(_buildTypeChip(_getProjectType(index))),
                          DataCell(_buildStatusChip(_getProjectStatus(index))),
                          DataCell(Text('2024-08-${17 - index}')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {}, 
                                  icon: const Icon(Icons.visibility, size: 18),
                                  tooltip: 'View Details',
                                ),
                                IconButton(
                                  onPressed: () {}, 
                                  icon: const Icon(Icons.edit, size: 18),
                                  tooltip: 'Edit Project',
                                ),
                                IconButton(
                                  onPressed: () {}, 
                                  icon: const Icon(Icons.delete, size: 18),
                                  tooltip: 'Delete Project',
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getProjectType(int index) {
    final types = ['Research', 'Testing', 'Analysis', 'Consultation'];
    return types[index % types.length];
  }
  
  String _getProjectStatus(int index) {
    final statuses = ['Planning', 'In Progress', 'Review', 'Completed', 'On Hold'];
    return statuses[index % statuses.length];
  }
  
  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Planning':
        color = AppTheme.warningColor;
        break;
      case 'In Progress':
        color = AppTheme.infoColor;
        break;
      case 'Review':
        color = AppTheme.primaryColor;
        break;
      case 'Completed':
        color = AppTheme.successColor;
        break;
      case 'On Hold':
        color = AppTheme.secondaryTextColor;
        break;
      default:
        color = AppTheme.secondaryTextColor;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color, 
          fontSize: 12, 
          fontWeight: FontWeight.w500
        ),
      ),
    );
  }
  
  Widget _buildTypeChip(String type) {
    Color color;
    switch (type) {
      case 'Research':
        color = AppTheme.primaryColor;
        break;
      case 'Testing':
        color = AppTheme.infoColor;
        break;
      case 'Analysis':
        color = AppTheme.warningColor;
        break;
      case 'Consultation':
        color = AppTheme.successColor;
        break;
      default:
        color = AppTheme.secondaryTextColor;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: color, 
          fontSize: 12, 
          fontWeight: FontWeight.w500
        ),
      ),
    );
  }
}
