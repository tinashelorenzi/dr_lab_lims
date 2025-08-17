// lib/widgets/dialogs/project_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart' as project_models;
import '../../models/client.dart';
import '../../providers/project_provider.dart';
import '../../shared/theme.dart';
import '../glass_container.dart';
import 'client_selection_dialog.dart';

class ProjectFormDialog extends StatefulWidget {
  final project_models.Project? project;
  final String title;
  final bool isReadOnly;

  const ProjectFormDialog({
    super.key,
    this.project,
    required this.title,
    this.isReadOnly = false,
  });

  @override
  State<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<ProjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  project_models.ProjectStatus _selectedStatus = project_models.ProjectStatus.active;
  Client? _selectedClient;
  DateTime? _completedAt;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description;
      _selectedStatus = widget.project!.status;
      _completedAt = widget.project!.completedAt;
      
      // Create a basic client object if we have client data
      if (widget.project!.client != null) {
        _selectedClient = widget.project!.client;
      } else if (widget.project!.clientId.isNotEmpty) {
        // Create a minimal client object for display
        _selectedClient = Client(
          id: widget.project!.clientId,
          name: widget.project!.clientName ?? 'Unknown Client',
          contactPerson: '',
          email: '',
          phone: '',
          address: '',
          clientType: ClientType.oneTime,
          isActive: true,
          defaultSlaHours: 72,
          billingContact: '',
          billingEmail: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: '',
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectClient() async {
    if (widget.isReadOnly) return;

    final client = await ClientSelectionDialogs.showSingleSelection(
      context,
      title: 'Select Client for Project',
    );

    if (client != null) {
      setState(() {
        _selectedClient = client;
      });
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a client'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final projectProvider = context.read<ProjectProvider>();

      final projectData = project_models.Project(
        id: widget.project?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        clientId: _selectedClient!.id,
        clientName: _selectedClient!.name,
        status: _selectedStatus,
        createdAt: widget.project?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        completedAt: _completedAt,
        createdBy: widget.project?.createdBy ?? '',
      );

      project_models.Project? result;
      if (widget.project == null) {
        // Create new project
        result = await projectProvider.createProject(projectData);
      } else {
        // Update existing project
        result = await projectProvider.updateProject(widget.project!.id, projectData);
      }

      if (result != null) {
        if (mounted) {
          Navigator.of(context).pop(result);
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(projectProvider.errorMessage ?? 'Failed to save project'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(
          maxWidth: 700,
          maxHeight: 600,
        ),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    widget.project == null 
                        ? Icons.add_business 
                        : widget.isReadOnly 
                            ? Icons.visibility 
                            : Icons.edit,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppTheme.secondaryTextColor,
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Form Content
              Expanded(
                child: widget.isReadOnly ? _buildReadOnlyView() : _buildFormView(),
              ),
              
              // Action Buttons
              if (!widget.isReadOnly) ...[
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProject,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.project == null ? 'Create Project' : 'Update Project'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Information Section
            _buildSectionHeader('Project Information'),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _nameController,
              label: 'Project Name',
              hint: 'Enter project name',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Project name is required';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Enter project description',
              maxLines: 3,
            ),
            
            const SizedBox(height: 24),
            
            // Client Selection Section
            _buildSectionHeader('Client'),
            const SizedBox(height: 16),
            
            _buildClientSelection(),
            
            const SizedBox(height: 24),
            
            // Status Section
            _buildSectionHeader('Project Status'),
            const SizedBox(height: 16),
            
            _buildStatusDropdown(),
            
            if (_selectedStatus == project_models.ProjectStatus.completed) ...[
              const SizedBox(height: 16),
              _buildCompletedAtInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Project Information'),
          const SizedBox(height: 16),
          _buildInfoRow('Name', widget.project?.name ?? ''),
          _buildInfoRow('Description', widget.project?.description ?? 'No description'),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Client'),
          const SizedBox(height: 16),
          _buildInfoRow('Client Name', widget.project?.clientName ?? 'Unknown'),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Status & Timeline'),
          const SizedBox(height: 16),
          _buildInfoRow('Status', widget.project?.status.displayName ?? ''),
          _buildInfoRow('Created', _formatDateTime(widget.project?.createdAt ?? DateTime.now())),
          _buildInfoRow('Last Updated', _formatDateTime(widget.project?.updatedAt ?? DateTime.now())),
          if (widget.project?.completedAt != null)
            _buildInfoRow('Completed', _formatDateTime(widget.project!.completedAt!)),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Statistics'),
          const SizedBox(height: 16),
          _buildInfoRow('Samples Count', '${widget.project?.samplesCount ?? 0}'),
          _buildInfoRow('Created By', widget.project?.createdByName ?? 'Unknown'),
          
          // Recent Samples
          if (widget.project?.recentSamples?.isNotEmpty == true) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Recent Samples'),
            const SizedBox(height: 16),
            ...widget.project!.recentSamples!.map((sample) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.science, size: 20),
                    title: Text(sample.sampleNumber),
                    subtitle: Text('Batch: ${sample.batchNumber}'),
                    trailing: Chip(
                      label: Text(sample.status),
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildClientSelection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(Icons.business, color: AppTheme.primaryColor),
        title: Text(_selectedClient?.name ?? 'Select Client'),
        subtitle: _selectedClient != null 
            ? Text(_selectedClient!.email)
            : const Text('Tap to select a client'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _selectClient,
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<project_models.ProjectStatus>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: project_models.ProjectStatus.values.map((status) => 
        DropdownMenuItem(
          value: status,
          child: Row(
            children: [
              _buildStatusIcon(status),
              const SizedBox(width: 8),
              Text(status.displayName),
            ],
          ),
        ),
      ).toList(),
      onChanged: (status) {
        if (status != null) {
          setState(() {
            _selectedStatus = status;
            if (status == project_models.ProjectStatus.completed && _completedAt == null) {
              _completedAt = DateTime.now();
            } else if (status != project_models.ProjectStatus.completed) {
              _completedAt = null;
            }
          });
        }
      },
    );
  }

  Widget _buildStatusIcon(project_models.ProjectStatus status) {
    IconData icon;
    Color color;
    
    switch (status) {
      case project_models.ProjectStatus.active:
        icon = Icons.play_circle;
        color = AppTheme.successColor;
        break;
      case project_models.ProjectStatus.completed:
        icon = Icons.check_circle;
        color = AppTheme.primaryColor;
        break;
      case project_models.ProjectStatus.onHold:
        icon = Icons.pause_circle;
        color = Colors.orange;
        break;
      case project_models.ProjectStatus.cancelled:
        icon = Icons.cancel;
        color = AppTheme.errorColor;
        break;
    }
    
    return Icon(icon, color: color, size: 20);
  }

  Widget _buildCompletedAtInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _completedAt != null 
                  ? 'Completion date: ${_formatDateTime(_completedAt!)}'
                  : 'Completion date will be set automatically',
              style: const TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.primaryTextColor),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Helper functions to show the dialog
class ProjectDialogs {
  // Show create project dialog
  static Future<project_models.Project?> showCreateDialog(BuildContext context) {
    return showDialog<project_models.Project>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ProjectFormDialog(
        title: 'Create New Project',
      ),
    );
  }

  // Show edit project dialog
  static Future<project_models.Project?> showEditDialog(BuildContext context, project_models.Project project) {
    return showDialog<project_models.Project>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProjectFormDialog(
        project: project,
        title: 'Edit Project',
      ),
    );
  }

  // Show view project dialog (read-only)
  static Future<void> showViewDialog(BuildContext context, project_models.Project project) {
    return showDialog<void>(
      context: context,
      builder: (context) => ProjectFormDialog(
        project: project,
        title: 'Project Details',
        isReadOnly: true,
      ),
    );
  }
}