// lib/widgets/dialogs/client_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/client.dart';
import '../../providers/client_provider.dart';
import '../../shared/theme.dart';
import '../glass_container.dart';

class ClientFormDialog extends StatefulWidget {
  final Client? client; // null for create, existing client for edit
  final String title;
  final bool isReadOnly;

  const ClientFormDialog({
    super.key,
    this.client,
    this.title = 'Client Details',
    this.isReadOnly = false,
  });

  @override
  State<ClientFormDialog> createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends State<ClientFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _billingContactController = TextEditingController();
  final _billingEmailController = TextEditingController();
  final _slaHoursController = TextEditingController();

  ClientType _selectedClientType = ClientType.oneTime;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.client != null) {
      final client = widget.client!;
      _nameController.text = client.name;
      _contactPersonController.text = client.contactPerson;
      _emailController.text = client.email;
      _phoneController.text = client.phone;
      _addressController.text = client.address;
      _billingContactController.text = client.billingContact;
      _billingEmailController.text = client.billingEmail;
      _slaHoursController.text = client.defaultSlaHours.toString();
      _selectedClientType = client.clientType;
      _isActive = client.isActive;
    } else {
      _slaHoursController.text = '72'; // Default SLA
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _billingContactController.dispose();
    _billingEmailController.dispose();
    _slaHoursController.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final clientProvider = context.read<ClientProvider>();
      
      final clientData = Client(
        id: widget.client?.id ?? '',
        name: _nameController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        clientType: _selectedClientType,
        isActive: _isActive,
        defaultSlaHours: int.tryParse(_slaHoursController.text) ?? 72,
        billingContact: _billingContactController.text.trim(),
        billingEmail: _billingEmailController.text.trim(),
        createdAt: widget.client?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: widget.client?.createdBy ?? '',
      );

      Client? result;
      if (widget.client == null) {
        // Create new client
        result = await clientProvider.createClient(clientData);
      } else {
        // Update existing client
        result = await clientProvider.updateClient(widget.client!.id, clientData);
      }

      if (result != null) {
        if (mounted) {
          Navigator.of(context).pop(result); // Return the created/updated client
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(clientProvider.errorMessage ?? 'Failed to save client'),
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
        height: MediaQuery.of(context).size.height * 0.9,
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 700,
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
                    widget.client == null ? Icons.person_add : Icons.person,
                    size: 24,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                  ),
                  if (!widget.isReadOnly)
                    Consumer<ClientProvider>(
                      builder: (context, provider, child) {
                        if (provider.errorMessage != null) {
                          return IconButton(
                            icon: const Icon(Icons.error_outline, color: AppTheme.errorColor),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Error'),
                                  content: Text(provider.errorMessage!),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        provider.clearError();
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              
              const Divider(height: 32),
              
              // Form Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information Section
                        _buildSectionHeader('Basic Information'),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                controller: _nameController,
                                label: 'Client Name *',
                                hint: 'Enter client company name',
                                validator: (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'Client name is required';
                                  }
                                  return null;
                                },
                                readOnly: widget.isReadOnly,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _contactPersonController,
                                label: 'Contact Person',
                                hint: 'Primary contact name',
                                readOnly: widget.isReadOnly,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _emailController,
                                label: 'Email Address *',
                                hint: 'client@example.com',
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'Email is required';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                                readOnly: widget.isReadOnly,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _phoneController,
                                label: 'Phone Number',
                                hint: '+27 123 456 789',
                                keyboardType: TextInputType.phone,
                                readOnly: widget.isReadOnly,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildTextField(
                          controller: _addressController,
                          label: 'Address',
                          hint: 'Client address',
                          maxLines: 3,
                          readOnly: widget.isReadOnly,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Client Settings Section
                        _buildSectionHeader('Client Settings'),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                value: _selectedClientType,
                                label: 'Client Type',
                                items: ClientType.values,
                                onChanged: widget.isReadOnly ? null : (value) {
                                  setState(() => _selectedClientType = value!);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _slaHoursController,
                                label: 'Default SLA (Hours)',
                                hint: '72',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  final hours = int.tryParse(value ?? '');
                                  if (hours == null || hours <= 0) {
                                    return 'Enter a valid number of hours';
                                  }
                                  return null;
                                },
                                readOnly: widget.isReadOnly,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        if (!widget.isReadOnly)
                          CheckboxListTile(
                            title: const Text('Active Client'),
                            subtitle: const Text('Inactive clients are hidden from most lists'),
                            value: _isActive,
                            onChanged: (value) => setState(() => _isActive = value ?? true),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        
                        if (widget.isReadOnly && widget.client != null)
                          _buildInfoRow('Status', widget.client!.isActive ? 'Active' : 'Inactive'),
                        
                        const SizedBox(height: 24),
                        
                        // Billing Information Section
                        _buildSectionHeader('Billing Information'),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _billingContactController,
                                label: 'Billing Contact',
                                hint: 'Billing contact person',
                                readOnly: widget.isReadOnly,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _billingEmailController,
                                label: 'Billing Email',
                                hint: 'billing@example.com',
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value?.isNotEmpty == true && 
                                      !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                                readOnly: widget.isReadOnly,
                              ),
                            ),
                          ],
                        ),
                        
                        // Additional Info for Read-Only Mode
                        if (widget.isReadOnly && widget.client != null) ...[
                          const SizedBox(height: 24),
                          _buildSectionHeader('Additional Information'),
                          const SizedBox(height: 16),
                          _buildInfoRow('Created', _formatDateTime(widget.client!.createdAt)),
                          _buildInfoRow('Last Updated', _formatDateTime(widget.client!.updatedAt)),
                          if (widget.client!.createdByName != null)
                            _buildInfoRow('Created By', widget.client!.createdByName!),
                          _buildInfoRow('Projects', widget.client!.projectsCount.toString()),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
              // Action Buttons
              const Divider(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  
                  if (!widget.isReadOnly) ...[
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveClient,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.client == null ? 'Create Client' : 'Update Client'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
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
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.withOpacity(0.1) : null,
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
    );
  }

  Widget _buildDropdownField({
    required ClientType value,
    required String label,
    required List<ClientType> items,
    required ValueChanged<ClientType?>? onChanged,
  }) {
    return DropdownButtonFormField<ClientType>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: items.map((type) => DropdownMenuItem(
        value: type,
        child: Text(type.displayName),
      )).toList(),
      onChanged: onChanged,
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
class ClientDialogs {
  // Show create client dialog
  static Future<Client?> showCreateDialog(BuildContext context) {
    return showDialog<Client>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ClientFormDialog(
        title: 'Create New Client',
      ),
    );
  }

  // Show edit client dialog
  static Future<Client?> showEditDialog(BuildContext context, Client client) {
    return showDialog<Client>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ClientFormDialog(
        client: client,
        title: 'Edit Client',
      ),
    );
  }

  // Show view client dialog (read-only)
  static Future<void> showViewDialog(BuildContext context, Client client) {
    return showDialog<void>(
      context: context,
      builder: (context) => ClientFormDialog(
        client: client,
        title: 'Client Details',
        isReadOnly: true,
      ),
    );
  }
}