// lib/widgets/dialogs/client_selection_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/client.dart';
import '../../providers/client_provider.dart';
import '../../shared/theme.dart';
import '../glass_container.dart';
import 'client_form_dialog.dart';

class ClientSelectionDialog extends StatefulWidget {
  final String title;
  final bool allowCreate;
  final bool multiSelect;
  final List<Client>? excludeClients;

  const ClientSelectionDialog({
    super.key,
    this.title = 'Select Client',
    this.allowCreate = true,
    this.multiSelect = false,
    this.excludeClients,
  });

  @override
  State<ClientSelectionDialog> createState() => _ClientSelectionDialogState();
}

class _ClientSelectionDialogState extends State<ClientSelectionDialog> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  
  String _searchQuery = '';
  ClientType? _selectedClientType;
  bool? _selectedIsActive = true;
  Set<Client> _selectedClients = {};

  @override
  void initState() {
    super.initState();
    _loadClients();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadClients() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().loadClients(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      context.read<ClientProvider>().loadClients();
    }
  }

  void _performSearch(String query) {
    setState(() => _searchQuery = query);
    context.read<ClientProvider>().searchClients(query);
  }

  void _applyFilters() {
    context.read<ClientProvider>().applyFilters(
      search: _searchQuery.isEmpty ? null : _searchQuery,
      clientType: _selectedClientType?.value,
      isActive: _selectedIsActive,
    );
  }

  Future<void> _createNewClient() async {
    final result = await ClientDialogs.showCreateDialog(context);
    if (result != null) {
      if (widget.multiSelect) {
        setState(() {
          _selectedClients.add(result);
        });
      } else {
        Navigator.of(context).pop(result);
      }
    }
  }

  void _selectClient(Client client) {
    if (widget.multiSelect) {
      setState(() {
        if (_selectedClients.contains(client)) {
          _selectedClients.remove(client);
        } else {
          _selectedClients.add(client);
        }
      });
    } else {
      Navigator.of(context).pop(client);
    }
  }

  void _confirmMultiSelection() {
    Navigator.of(context).pop(_selectedClients.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(
          maxWidth: 900,
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
                  const Icon(
                    Icons.people_outline,
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
                  if (widget.allowCreate)
                    ElevatedButton.icon(
                      onPressed: _createNewClient,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('New Client'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const Divider(height: 32),

              // Search and Filters
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search clients...',
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: _performSearch,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<ClientType?>(
                      value: _selectedClientType,
                      decoration: InputDecoration(
                        labelText: 'Client Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<ClientType?>(
                          value: null,
                          child: Text('All Types'),
                        ),
                        ...ClientType.values.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedClientType = value);
                        _applyFilters();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<bool?>(
                      value: _selectedIsActive,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem<bool?>(
                          value: null,
                          child: Text('All Status'),
                        ),
                        DropdownMenuItem<bool?>(
                          value: true,
                          child: Text('Active'),
                        ),
                        DropdownMenuItem<bool?>(
                          value: false,
                          child: Text('Inactive'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedIsActive = value);
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Client List
              Expanded(
                child: Consumer<ClientProvider>(
                  builder: (context, clientProvider, child) {
                    if (clientProvider.isLoading && clientProvider.clients.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (clientProvider.errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppTheme.errorColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              clientProvider.errorMessage!,
                              style: const TextStyle(color: AppTheme.errorColor),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                clientProvider.clearError();
                                _loadClients();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final clients = clientProvider.clients.where((client) {
                      if (widget.excludeClients?.contains(client) == true) {
                        return false;
                      }
                      return true;
                    }).toList();

                    if (clients.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 48,
                              color: AppTheme.secondaryTextColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'No clients found matching "$_searchQuery"'
                                  : 'No clients available',
                              style: const TextStyle(color: AppTheme.secondaryTextColor),
                            ),
                            if (widget.allowCreate) ...[
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _createNewClient,
                                icon: const Icon(Icons.add),
                                label: const Text('Create First Client'),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: _scrollController,
                      itemCount: clients.length + (clientProvider.hasMore ? 1 : 0),
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        if (index >= clients.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final client = clients[index];
                        final isSelected = widget.multiSelect && _selectedClients.contains(client);

                        return ListTile(
                          leading: widget.multiSelect
                              ? Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => _selectClient(client),
                                )
                              : CircleAvatar(
                                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                  child: Text(
                                    client.name.isNotEmpty ? client.name[0].toUpperCase() : 'C',
                                    style: const TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                          title: Text(
                            client.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(client.email),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _buildStatusChip(client.isActive),
                                  const SizedBox(width: 8),
                                  _buildTypeChip(client.clientType),
                                  if (client.projectsCount > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.infoColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${client.projectsCount} projects',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppTheme.infoColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (client.contactPerson.isNotEmpty)
                                Tooltip(
                                  message: 'Contact: ${client.contactPerson}',
                                  child: const Icon(Icons.person_outline, size: 16),
                                ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                          selected: isSelected,
                          onTap: () => _selectClient(client),
                        );
                      },
                    );
                  },
                ),
              ),

              // Multi-select actions
              if (widget.multiSelect && _selectedClients.isNotEmpty) ...[
                const Divider(height: 32),
                Row(
                  children: [
                    Text(
                      '${_selectedClients.length} client${_selectedClients.length == 1 ? '' : 's'} selected',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() => _selectedClients.clear()),
                      child: const Text('Clear Selection'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _confirmMultiSelection,
                      child: const Text('Select Clients'),
                    ),
                  ],
                ),
              ],

              // Single select actions
              if (!widget.multiSelect) ...[
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
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

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isActive ? AppTheme.successColor : AppTheme.secondaryTextColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 10,
          color: isActive ? AppTheme.successColor : AppTheme.secondaryTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTypeChip(ClientType clientType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        clientType.displayName,
        style: const TextStyle(
          fontSize: 10,
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Helper functions to show the dialog
class ClientSelectionDialogs {
  // Show single client selection dialog
  static Future<Client?> showSingleSelection(
    BuildContext context, {
    String title = 'Select Client',
    bool allowCreate = true,
    List<Client>? excludeClients,
  }) {
    return showDialog<Client>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ClientSelectionDialog(
        title: title,
        allowCreate: allowCreate,
        multiSelect: false,
        excludeClients: excludeClients,
      ),
    );
  }

  // Show multi client selection dialog
  static Future<List<Client>?> showMultiSelection(
    BuildContext context, {
    String title = 'Select Clients',
    bool allowCreate = true,
    List<Client>? excludeClients,
  }) {
    return showDialog<List<Client>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ClientSelectionDialog(
        title: title,
        allowCreate: allowCreate,
        multiSelect: true,
        excludeClients: excludeClients,
      ),
    );
  }
}