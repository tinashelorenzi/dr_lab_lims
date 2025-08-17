// lib/services/client_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/client.dart';
import '../models/api_response.dart';

class ClientService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';
  static const Duration timeout = Duration(seconds: 30);
  
  String? _authToken;
  
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  void clearAuthToken() {
    _authToken = null;
  }
  
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Token $_authToken';
    }
    
    return headers;
  }

  // Get all clients with optional filtering
  Future<ClientListResponse> getClients({
    String? clientType,
    bool? isActive,
    String? search,
    String? ordering,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };
      
      if (clientType != null) queryParams['client_type'] = clientType;
      if (isActive != null) queryParams['is_active'] = isActive.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (ordering != null) queryParams['ordering'] = ordering;
      
      final uri = Uri.parse('$baseUrl/clients/').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ClientListResponse.fromJson(responseData);
      } else {
        return ClientListResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to fetch clients',
          count: 0,
          results: [],
        );
      }
    } catch (e) {
      return ClientListResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        count: 0,
        results: [],
      );
    }
  }

  // Get a specific client by ID
  Future<ClientResponse> getClient(String clientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clients/$clientId/'),
        headers: _headers,
      ).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      return ClientResponse.fromJson(responseData);
    } catch (e) {
      return ClientResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Create a new client
  Future<ClientResponse> createClient(Client client) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/clients/'),
        headers: _headers,
        body: jsonEncode(client.toCreateJson()),
      ).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      return ClientResponse.fromJson(responseData);
    } catch (e) {
      return ClientResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Update an existing client
  Future<ClientResponse> updateClient(String clientId, Client client) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/clients/$clientId/'),
        headers: _headers,
        body: jsonEncode(client.toCreateJson()),
      ).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      return ClientResponse.fromJson(responseData);
    } catch (e) {
      return ClientResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Partially update a client
  Future<ClientResponse> patchClient(String clientId, Map<String, dynamic> updates) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/clients/$clientId/'),
        headers: _headers,
        body: jsonEncode(updates),
      ).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      return ClientResponse.fromJson(responseData);
    } catch (e) {
      return ClientResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Delete a client
  Future<BaseApiResponse> deleteClient(String clientId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/clients/$clientId/'),
        headers: _headers,
      ).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      return BaseApiResponse.fromJson(responseData);
    } catch (e) {
      return BaseApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Toggle client active status
  Future<ClientResponse> toggleClientStatus(String clientId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/clients/$clientId/toggle-status/'),
        headers: _headers,
      ).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      return ClientResponse.fromJson(responseData);
    } catch (e) {
      return ClientResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Get client statistics
  Future<ClientStatsResponse> getClientStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clients/stats/'),
        headers: _headers,
      ).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        return ClientStatsResponse(
          success: true,
          message: 'Stats retrieved successfully',
          data: ClientStats.fromJson(responseData['data']),
        );
      } else {
        return ClientStatsResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to get stats',
        );
      }
    } catch (e) {
      return ClientStatsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Search clients
  Future<ClientListResponse> searchClients(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clients/search/').replace(queryParameters: {
          'q': query,
        }),
        headers: _headers,
      ).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ClientListResponse(
          success: responseData['success'] ?? false,
          message: responseData['message'],
          count: responseData['count'] ?? 0,
          results: responseData['results'] != null
              ? (responseData['results'] as List).map((c) => Client.fromJson(c)).toList()
              : [],
        );
      } else {
        return ClientListResponse(
          success: false,
          message: responseData['message'] ?? 'Search failed',
          count: 0,
          results: [],
        );
      }
    } catch (e) {
      return ClientListResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        count: 0,
        results: [],
      );
    }
  }
}

class ClientStatsResponse {
  final bool success;
  final String message;
  final ClientStats? data;

  ClientStatsResponse({
    required this.success,
    required this.message,
    this.data,
  });
}