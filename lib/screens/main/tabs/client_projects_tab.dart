// lib/screens/main/tabs/client_projects_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/project.dart' as project_models;
import '../../../providers/project_provider.dart';
import '../../../shared/theme.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/dialogs/project_form_dialog.dart';

class ClientProjectsTab extends StatefulWidget {
  const ClientProjectsTab({super.key});

  @override
  State<ClientProjectsTab> createState() => _ClientProjectsTabState();
}

class _ClientProjectsTabState extends State<ClientProjectsTab> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  
  String _searchQuery = '';
  project_models.ProjectStatus? _selectedStatus;
  String _selectedOrdering = '-created_at';

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadProjects() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      context.read<ProjectProvider>().loadProjects();
    }
  }

  void _performSearch(String query) {
    setState(() => _searchQuery = query);
    if (query.isEmpty) {
      context.read<ProjectProvider>().loadProjects(refresh: true);
    } else {
      context.read<ProjectProvider>().searchProjects(query);
    }
  }

  void _applyFilters() {
    context.read<ProjectProvider>().applyFilters(
      search: _searchQuery.isEmpty ? null : _searchQuery,
      status: _selectedStatus?.value,
      ordering: _selectedOrdering,
    );
  }

  Future<void> _createProject() async {
    final result = await ProjectDialogs.showCreateDialog(context);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project "${result.name}" created successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _editProject(project_models.Project project) async {
    final result = await ProjectDialogs.showEditDialog(context, project);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project "${result.name}" updated successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _viewProject(project_models.Project project) async {
    await ProjectDialogs.showViewDialog(context, project);
  }

  Future<void> _changeProjectStatus(project_models.Project project) async {
    final result = await _showStatusChangeDialog(project);
    if (result != null) {
      final success = await context.read<ProjectProvider>().changeProjectStatus(
        project.id,
        result,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project status changed to ${result.displayName}'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  Future<void> _deleteProject(project_models.Project project) async {
    final confirmed = await _showDeleteConfirmation(project);
    if (confirmed == true) {
      final success = await context.read<ProjectProvider>().deleteProject(project.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${project.name}" deleted successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        final errorMessage = context.read<ProjectProvider>().errorMessage;
        if (errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Search and Create Button Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search projects...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _performSearch,
                ),
              ),
              const SizedBox(width: 16),
              
              // Status Filter
              Expanded(
                child: DropdownButtonFormField<project_models.ProjectStatus?>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<project_models.ProjectStatus?>(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...project_models.ProjectStatus.values.map((status) =>
                      DropdownMenuItem(
                        value: status,
                        child: Text(status.displayName),
                      ),
                    ),
                  ],
                  onChanged: (status) {
                    setState(() => _selectedStatus = status);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Create Button
              ElevatedButton.icon(
                onPressed: _createProject,
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
          
          // Projects Table
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
                    child: Consumer<ProjectProvider>(
                      builder: (context, projectProvider, child) {
                        if (projectProvider.projects.isEmpty && projectProvider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (projectProvider.projects.isEmpty) {
                          return _buildEmptyState();
                        }

                        return RefreshIndicator(
                          onRefresh: () => projectProvider.loadProjects(refresh: true),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: DataTable(
                              columnSpacing: 20,
                              columns: const [
                                DataColumn(label: Text('Project Name')),
                                DataColumn(label: Text('Client')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Samples')),
                                DataColumn(label: Text('Created')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: projectProvider.projects.map((project) => DataRow(
                                cells: [
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          project.name,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        if (project.description.isNotEmpty)
                                          Text(
                                            project.description,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(project.clientName ?? 'Unknown')),
                                  DataCell(_buildStatusChip(project.status)),
                                  DataCell(Text('${project.samplesCount}')),
                                  DataCell(Text(_formatDate(project.createdAt))),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () => _viewProject(project),
                                          icon: const Icon(Icons.visibility, size: 18),
                                          tooltip: 'View Details',
                                        ),
                                        IconButton(
                                          onPressed: () => _editProject(project),
                                          icon: const Icon(Icons.edit, size: 18),
                                          tooltip: 'Edit Project',
                                        ),
                                        IconButton(
                                          onPressed: () => _changeProjectStatus(project),
                                          icon: const Icon(Icons.swap_horiz, size: 18),
                                          tooltip: 'Change Status',
                                        ),
                                        IconButton(
                                          onPressed: () => _deleteProject(project),
                                          icon: const Icon(Icons.delete, size: 18),
                                          tooltip: 'Delete Project',
                                          color: AppTheme.errorColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )).toList(),
                            ),
                          ),
                        );
                      },
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty 
                ? 'No projects found matching your search'
                : 'No projects found',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty 
                ? 'Try adjusting your search terms'
                : 'Create your first project to get started',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createProject,
              icon: const Icon(Icons.add),
              label: const Text('Create Project'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(project_models.ProjectStatus status) {
    Color color;
    switch (status) {
      case project_models.ProjectStatus.active:
        color = AppTheme.successColor;
        break;
      case project_models.ProjectStatus.completed:
        color = AppTheme.primaryColor;
        break;
      case project_models.ProjectStatus.onHold:
        color = AppTheme.warningColor;
        break;
      case project_models.ProjectStatus.cancelled:
        color = AppTheme.errorColor;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<project_models.ProjectStatus?> _showStatusChangeDialog(project_models.Project project) async {
    return showDialog<project_models.ProjectStatus>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Project Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project: ${project.name}'),
            Text('Current Status: ${project.status.displayName}'),
            const SizedBox(height: 16),
            const Text('Select new status:'),
            const SizedBox(height: 8),
            ...project_models.ProjectStatus.values.where((s) => s != project.status).map(
              (status) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                ),
                title: Text(status.displayName),
                onTap: () => Navigator.of(context).pop(status),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(project_models.Project project) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${project.name}"?'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (project.samplesCount > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This project has ${project.samplesCount} samples. Deletion may fail.',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(project_models.ProjectStatus status) {
    switch (status) {
      case project_models.ProjectStatus.active:
        return Icons.play_circle;
      case project_models.ProjectStatus.completed:
        return Icons.check_circle;
      case project_models.ProjectStatus.onHold:
        return Icons.pause_circle;
      case project_models.ProjectStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(project_models.ProjectStatus status) {
    switch (status) {
      case project_models.ProjectStatus.active:
        return AppTheme.successColor;
      case project_models.ProjectStatus.completed:
        return AppTheme.primaryColor;
      case project_models.ProjectStatus.onHold:
        return AppTheme.warningColor;
      case project_models.ProjectStatus.cancelled:
        return AppTheme.errorColor;
    }
  }
}