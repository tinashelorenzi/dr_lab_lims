import 'package:flutter/material.dart';
import '../../../shared/theme.dart';
import '../../../widgets/glass_container.dart';

class SamplesTab extends StatelessWidget {
  const SamplesTab({super.key});

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
                    hintText: 'Search samples...',
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
                label: const Text('New Sample'),
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
                    'Sample Management',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Sample ID')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: List.generate(10, (index) => DataRow(
                        cells: [
                          DataCell(Text('S-${2024000 + index}')),
                          DataCell(Text('Type ${index % 3 + 1}')),
                          DataCell(_buildStatusChip(index % 3 == 0 ? 'Pending' : index % 3 == 1 ? 'Processing' : 'Complete')),
                          DataCell(Text('2024-08-${17 - index}')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(onPressed: () {}, icon: const Icon(Icons.edit, size: 18)),
                                IconButton(onPressed: () {}, icon: const Icon(Icons.delete, size: 18)),
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
  
  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Pending':
        color = AppTheme.warningColor;
        break;
      case 'Processing':
        color = AppTheme.infoColor;
        break;
      case 'Complete':
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
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}