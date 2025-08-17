// lib/providers/client_provider.dart
import 'package:flutter/foundation.dart';
import '../models/client.dart';
import '../services/client_service.dart';

class ClientProvider with ChangeNotifier {
  final ClientService _clientService = ClientService();
  
  List<Client> _clients = [];
  Client? _selectedClient;
  ClientStats? _clientStats;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _currentSearch;
  String? _currentClientType;
  bool? _currentIsActive;
  String _currentOrdering = 'name';
  String? _errorMessage;

  // Getters
  List<Client> get clients => _clients;
  Client? get selectedClient => _selectedClient;
  ClientStats? get clientStats => _clientStats;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  String? get errorMessage => _errorMessage;

  void setAuthToken(String token) {
    _clientService.setAuthToken(token);
  }

  void clearAuthToken() {
    _clientService.clearAuthToken();
  }

  // Load clients with optional filtering
  Future<void> loadClients({
    bool refresh = false,
    String? search,
    String? clientType,
    bool? isActive,
    String? ordering,
  }) async {
    if (refresh) {
      _clients.clear();
      _currentPage = 1;
      _hasMore = true;
      _currentSearch = search;
      _currentClientType = clientType;
      _currentIsActive = isActive;
      _currentOrdering = ordering ?? 'name';
    }

    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _clientService.getClients(
        search: _currentSearch,
        clientType: _currentClientType,
        isActive: _currentIsActive,
        ordering: _currentOrdering,
        page: _currentPage,
        pageSize: 20,
      );

      if (response.success) {
        if (_currentPage == 1) {
          _clients = response.results;
        } else {
          _clients.addAll(response.results);
        }

        _hasMore = response.next != null;
        _currentPage++;
      } else {
        _errorMessage = response.message ?? 'Failed to load clients';
      }
    } catch (e) {
      _errorMessage = 'Error loading clients: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Search clients
  Future<void> searchClients(String query) async {
    if (query.isEmpty) {
      await loadClients(refresh: true);
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _clientService.searchClients(query);

      if (response.success) {
        _clients = response.results;
        _hasMore = false; // Search results don't paginate
        _currentPage = 1;
      } else {
        _errorMessage = response.message ?? 'Search failed';
      }
    } catch (e) {
      _errorMessage = 'Error searching clients: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get a specific client
  Future<Client?> getClient(String clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _clientService.getClient(clientId);

      if (response.success && response.data != null) {
        _selectedClient = response.data;
        notifyListeners();
        return response.data;
      } else {
        _errorMessage = response.message;
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error loading client: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new client
  Future<Client?> createClient(Client client) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _clientService.createClient(client);

      if (response.success && response.data != null) {
        // Add the new client to the beginning of the list
        _clients.insert(0, response.data!);
        notifyListeners();
        return response.data;
      } else {
        _errorMessage = response.message;
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error creating client: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing client
  Future<Client?> updateClient(String clientId, Client client) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _clientService.updateClient(clientId, client);

      if (response.success && response.data != null) {
        // Update the client in the list
        final index = _clients.indexWhere((c) => c.id == clientId);
        if (index != -1) {
          _clients[index] = response.data!;
        }
        
        // Update selected client if it's the same one
        if (_selectedClient?.id == clientId) {
          _selectedClient = response.data!;
        }
        
        notifyListeners();
        return response.data;
      } else {
        _errorMessage = response.message;
        return null;
      }
    } catch (e) {
      _errorMessage = 'Error updating client: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a client
  Future<bool> deleteClient(String clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _clientService.deleteClient(clientId);

      if (response.success) {
        // Remove the client from the list
        _clients.removeWhere((c) => c.id == clientId);
        
        // Clear selected client if it was the deleted one
        if (_selectedClient?.id == clientId) {
          _selectedClient = null;
        }
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error deleting client: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle client status
  Future<bool> toggleClientStatus(String clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _clientService.toggleClientStatus(clientId);

      if (response.success && response.data != null) {
        // Update the client in the list
        final index = _clients.indexWhere((c) => c.id == clientId);
        if (index != -1) {
          _clients[index] = response.data!;
        }
        
        // Update selected client if it's the same one
        if (_selectedClient?.id == clientId) {
          _selectedClient = response.data!;
        }
        
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error toggling client status: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load client statistics
  Future<void> loadClientStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _clientService.getClientStats();

      if (response.success && response.data != null) {
        _clientStats = response.data;
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = 'Error loading client stats: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Apply filters
  Future<void> applyFilters({
    String? search,
    String? clientType,
    bool? isActive,
    String? ordering,
  }) async {
    await loadClients(
      refresh: true,
      search: search,
      clientType: clientType,
      isActive: isActive,
      ordering: ordering,
    );
  }

  // Clear filters
  Future<void> clearFilters() async {
    await loadClients(refresh: true);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set selected client
  void setSelectedClient(Client? client) {
    _selectedClient = client;
    notifyListeners();
  }
}