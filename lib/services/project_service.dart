// lib/services/project_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/project.dart';

class ProjectService {
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

  // Get all projects with optional filtering
  Future<ProjectListResponse> getProjects({
    String? clientId,
    String? status,
    String? search,
    String? createdAfter,
    String? createdBefore,
    String? ordering,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'page_size': pageSize.toString(),
      };
      
      if (clientId != null) queryParams['client'] = clientId;
      if (status != null) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (createdAfter != null) queryParams['created_after'] = createdAfter;
      if (createdBefore != null) queryParams['created_before'] = createdBefore;
      if (ordering != null) queryParams['ordering'] = ordering;
      
      final uri = Uri.parse('$baseUrl/projects/').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _headers).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ProjectListResponse.fromJson(responseData);
      } else {
        return ProjectListResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to load projects',
          count: 0,
          results: [],
        );
      }
    } catch (e) {
      return ProjectListResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        count: 0,
        results: [],
      );
    }
  }

  // Get project by ID
  Future<ProjectResponse> getProject(String projectId) async {
    try {
      final uri = Uri.parse('$baseUrl/projects/$projectId/');
      
      final response = await http.get(uri, headers: _headers).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ProjectResponse.fromJson(responseData);
      } else {
        return ProjectResponse(
          success: false,
          message: responseData['message'] ?? 'Project not found',
        );
      }
    } catch (e) {
      return ProjectResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Create new project
  Future<ProjectResponse> createProject(Project project) async {
    try {
      final uri = Uri.parse('$baseUrl/projects/');
      
      print('Creating project with data: ${project.toCreateJson()}'); // Debug log
      
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(project.toCreateJson()),
      ).timeout(timeout);
      
      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log
      
      // Check if response is empty or not JSON
      if (response.body.isEmpty) {
        return ProjectResponse(
          success: false,
          message: 'Empty response from server',
        );
      }
      
      // Try to parse JSON
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        print('JSON decode error: $e'); // Debug log
        return ProjectResponse(
          success: false,
          message: 'Invalid JSON response: ${response.body}',
        );
      }
      
      return ProjectResponse.fromJson(responseData);
    } catch (e) {
      print('Create project error: $e'); // Debug log
      return ProjectResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Update project
  Future<ProjectResponse> updateProject(String projectId, Project project) async {
    try {
      final uri = Uri.parse('$baseUrl/projects/$projectId/');
      
      final response = await http.patch(
        uri,
        headers: _headers,
        body: jsonEncode(project.toCreateJson()),
      ).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      return ProjectResponse.fromJson(responseData);
    } catch (e) {
      return ProjectResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Delete project
  Future<ProjectResponse> deleteProject(String projectId) async {
    try {
      final uri = Uri.parse('$baseUrl/projects/$projectId/');
      
      final response = await http.delete(uri, headers: _headers).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      return ProjectResponse.fromJson(responseData);
    } catch (e) {
      return ProjectResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Change project status
  Future<ProjectResponse> changeProjectStatus(String projectId, ProjectStatus status) async {
    try {
      final uri = Uri.parse('$baseUrl/projects/$projectId/change-status/');
      
      final response = await http.patch(
        uri,
        headers: _headers,
        body: jsonEncode({'status': status.value}),
      ).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      return ProjectResponse.fromJson(responseData);
    } catch (e) {
      return ProjectResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Search projects
  Future<ProjectListResponse> searchProjects(String query) async {
    try {
      final uri = Uri.parse('$baseUrl/projects/search/').replace(
        queryParameters: {'q': query},
      );
      
      final response = await http.get(uri, headers: _headers).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Convert search response to standard list response format
        return ProjectListResponse(
          success: responseData['success'] ?? true,
          message: responseData['message'],
          count: responseData['count'] ?? 0,
          results: responseData['results'] != null
              ? (responseData['results'] as List)
                  .map((p) => Project.fromJson(p))
                  .toList()
              : [],
        );
      } else {
        return ProjectListResponse(
          success: false,
          message: responseData['message'] ?? 'Search failed',
          count: 0,
          results: [],
        );
      }
    } catch (e) {
      return ProjectListResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        count: 0,
        results: [],
      );
    }
  }

  // Get project statistics
  Future<ProjectStatsResponse> getProjectStats() async {
    try {
      final uri = Uri.parse('$baseUrl/projects/stats/');
      
      final response = await http.get(uri, headers: _headers).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ProjectStatsResponse(
          success: true,
          data: ProjectStats.fromJson(responseData['data']),
        );
      } else {
        return ProjectStatsResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to load statistics',
        );
      }
    } catch (e) {
      return ProjectStatsResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Get projects by client
  Future<ProjectsByClientResponse> getProjectsByClient(String clientId, {String? status}) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      
      final uri = Uri.parse('$baseUrl/clients/$clientId/projects/')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      
      final response = await http.get(uri, headers: _headers).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ProjectsByClientResponse.fromJson(responseData);
      } else {
        return ProjectsByClientResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to load client projects',
          count: 0,
          projects: [],
        );
      }
    } catch (e) {
      return ProjectsByClientResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        count: 0,
        projects: [],
      );
    }
  }
}

class ProjectStatsResponse {
  final bool success;
  final String? message;
  final ProjectStats? data;

  ProjectStatsResponse({
    required this.success,
    this.message,
    this.data,
  });
}

class ProjectsByClientResponse {
  final bool success;
  final String? message;
  final ClientInfo? client;
  final int count;
  final List<Project> projects;

  ProjectsByClientResponse({
    required this.success,
    this.message,
    this.client,
    required this.count,
    required this.projects,
  });

  factory ProjectsByClientResponse.fromJson(Map<String, dynamic> json) {
    return ProjectsByClientResponse(
      success: json['success'] ?? false,
      message: json['message'],
      client: json['client'] != null ? ClientInfo.fromJson(json['client']) : null,
      count: json['count'] ?? 0,
      projects: json['projects'] != null
          ? (json['projects'] as List).map((p) => Project.fromJson(p)).toList()
          : [],
    );
  }
}

class ClientInfo {
  final String id;
  final String name;
  final bool isActive;

  ClientInfo({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}