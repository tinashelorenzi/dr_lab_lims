// lib/screens/main/tabs/clients_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/client.dart';
import '../../../providers/client_provider.dart';
import '../../../shared/theme.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/dialogs/client_form_dialog.dart';

class ClientsTab extends StatefulWidget {
  const ClientsTab({super.key});

  @override
  State<ClientsTab> createState() => _ClientsTabState();
}

class _ClientsTabState extends State<ClientsTab> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  
  String _searchQuery = '';
  ClientType? _selectedClientType;
  bool? _selectedIsActive;
  String _selectedOrdering = 'name';

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
    if (query.isEmpty) {
      context.read<ClientProvider>().loadClients(refresh: true);
    } else {
      context.read<ClientProvider>().searchClients(query);
    }
  }

  void _applyFilters() {
    context.read<ClientProvider>().applyFilters(
      search: _searchQuery.isEmpty ? null : _searchQuery,
      clientType: _selectedClientType?.value,
      isActive: _selectedIsActive,
      ordering: _selectedOrdering,
    );
  }

  Future<void> _createClient() async {
    final result = await ClientDialogs.showCreateDialog(context);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Client "${result.name}" created successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _editClient(Client client) async {
    final result = await ClientDialogs.showEditDialog(context, client);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Client "${result.name}" updated successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _viewClient(Client client) async {
    await ClientDialogs.showViewDialog(context, client);
  }

  Future<void> _toggleClientStatus(Client client) async {
    final success = await context.read<ClientProvider>().toggleClientStatus(client.id);
    if (success) {
      final status = client.isActive ? 'deactivated' : 'activated';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Client "${client.name}" $status successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _deleteClient(Client client) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Client'),
        content: Text('Are you sure you want to delete "${client.name}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await context.read<ClientProvider>().deleteClient(client.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Client "${client.name}" deleted successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        final errorMessage = context.read<ClientProvider>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Failed to delete client'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Header with Search and Filters
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _performSearch,
                ),
              ),
              const SizedBox(width: 16),
              
              // Client Type Filter
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<ClientType?>(
                  value: _selectedClientType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
              
              // Status Filter
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<bool?>(
                  value: _selectedIsActive,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem<bool?>(
                      value: null,
                      child: Text('All'),
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
              
              const SizedBox(width: 16),
              
              // Sort Order
              SizedBox(
                width: 140,
                child: DropdownButtonFormField<String>(
                  value: _selectedOrdering,
                  decoration: InputDecoration(
                    labelText: 'Sort By',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name A-Z')),
                    DropdownMenuItem(value: '-name', child: Text('Name Z-A')),
                    DropdownMenuItem(value: 'created_at', child: Text('Oldest')),
                    DropdownMenuItem(value: '-created_at', child: Text('Newest')),
                    DropdownMenuItem(value: 'client_type', child: Text('Type')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedOrdering = value);
                      _applyFilters();
                    }
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              ElevatedButton.icon(
                onPressed: _createClient,
                icon: const Icon(Icons.add),
                label: const Text('New Client'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Client List
          Expanded(
            child: GlassContainer(
              padding: EdgeInsets.zero,
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

                  if (clientProvider.clients.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppTheme.secondaryTextColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No clients found matching "$_searchQuery"'
                                : 'No clients available',
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppTheme.secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _createClient,
                            icon: const Icon(Icons.add),
                            label: const Text('Create First Client'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.withOpacity(0.2)),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Client Management',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${clientProvider.clients.length} client${clientProvider.clients.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                color: AppTheme.secondaryTextColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor.withOpacity(0.5),
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 2, child: Text('Client', style: TextStyle(fontWeight: FontWeight.w600))),
                            Expanded(child: Text('Contact', style: TextStyle(fontWeight: FontWeight.w600))),
                            Expanded(child: Text('Type', style: TextStyle(fontWeight: FontWeight.w600))),
                            Expanded(child: Text('Projects', style: TextStyle(fontWeight: FontWeight.w600))),
                            Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
                            SizedBox(width: 120, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600))),
                          ],
                        ),
                      ),
                      
                      // Client Rows
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          itemCount: clientProvider.clients.length + (clientProvider.hasMore ? 1 : 0),
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            if (index >= clientProvider.clients.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            final client = clientProvider.clients[index];
                            return _buildClientRow(client);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientRow(Client client) {
    return InkWell(
      onTap: () => _viewClient(client),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Client Info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    client.email,
                    style: const TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contact Person
            Expanded(
              child: Text(
                client.contactPerson.isEmpty ? '-' : client.contactPerson,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            
            // Client Type
            Expanded(
              child: _buildTypeChip(client.clientType),
            ),
            
            // Projects Count
            Expanded(
              child: Text(
                client.projectsCount.toString(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            
            // Status
            Expanded(
              child: _buildStatusChip(client.isActive),
            ),
            
            // Actions
            SizedBox(
              width: 120,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 18),
                    onPressed: () => _viewClient(client),
                    tooltip: 'View Details',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => _editClient(client),
                    tooltip: 'Edit Client',
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, size: 18),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => Future.delayed(Duration.zero, () => _toggleClientStatus(client)),
                        child: Row(
                          children: [
                            Icon(client.isActive ? Icons.block : Icons.check_circle),
                            const SizedBox(width: 8),
                            Text(client.isActive ? 'Deactivate' : 'Activate'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () => Future.delayed(Duration.zero, () => _deleteClient(client)),
                        child: const Row(
                          children: [
                            Icon(Icons.delete, color: AppTheme.errorColor),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? AppTheme.successColor : AppTheme.secondaryTextColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isActive ? AppTheme.successColor : AppTheme.secondaryTextColor).withOpacity(0.3),
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isActive ? AppTheme.successColor : AppTheme.secondaryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTypeChip(ClientType clientType) {
    Color color;
    switch (clientType) {
      case ClientType.contracted:
        color = AppTheme.primaryColor;
        break;
      case ClientType.longTerm:
        color = AppTheme.infoColor;
        break;
      case ClientType.oneTime:
        color = AppTheme.warningColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        clientType.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}