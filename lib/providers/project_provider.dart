// lib/providers/project_provider.dart
import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../services/project_service.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  List<Project> _projects = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _errorMessage;
  ProjectStats? _projectStats;

  // Current filters
  String? _currentSearch;
  String? _currentClientId;
  String? _currentStatus;
  String? _currentOrdering = '-created_at';

  // Getters
  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  ProjectStats? get projectStats => _projectStats;

  // Auth token management
  void updateAuthToken(String? token) {
    if (token != null) {
      _projectService.setAuthToken(token);
    } else {
      _projectService.clearAuthToken();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load projects with pagination
  Future<void> loadProjects({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _projects.clear();
    } else if (!_hasMore) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _projectService.getProjects(
        clientId: _currentClientId,
        status: _currentStatus,
        search: _currentSearch,
        ordering: _currentOrdering,
        page: _currentPage,
        pageSize: 20,
      );

      if (response.success) {
        if (refresh) {
          _projects = response.results;
        } else {
          _projects.addAll(response.results);
        }

        _hasMore = response.next != null;
        _currentPage++;
      } else {
        _errorMessage = response.message ?? 'Failed to load projects';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply filters and refresh
  Future<void> applyFilters({
    String? search,
    String? clientId,
    String? status,
    String? ordering,
  }) async {
    _currentSearch = search;
    _currentClientId = clientId;
    _currentStatus = status;
    _currentOrdering = ordering ?? '-created_at';
    
    await loadProjects(refresh: true);
  }

  // Search projects
  Future<void> searchProjects(String query) async {
    if (query.isEmpty) {
      await loadProjects(refresh: true);
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _projectService.searchProjects(query);

      if (response.success) {
        _projects = response.results;
        _hasMore = false; // Search doesn't support pagination
      } else {
        _errorMessage = response.message ?? 'Search failed';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new project
  Future<Project?> createProject(Project project) async {
    _errorMessage = null;

    try {
      final response = await _projectService.createProject(project);

      if (response.success && response.data != null) {
        // Add to the beginning of the list
        _projects.insert(0, response.data!);
        notifyListeners();
        return response.data;
      } else {
        _errorMessage = response.message ?? 'Failed to create project';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Update project
  Future<Project?> updateProject(String projectId, Project project) async {
    _errorMessage = null;

    try {
      final response = await _projectService.updateProject(projectId, project);

      if (response.success && response.data != null) {
        // Update project in the list
        final index = _projects.indexWhere((p) => p.id == projectId);
        if (index != -1) {
          _projects[index] = response.data!;
          notifyListeners();
        }
        return response.data;
      } else {
        _errorMessage = response.message ?? 'Failed to update project';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Delete project
  Future<bool> deleteProject(String projectId) async {
    _errorMessage = null;

    try {
      final response = await _projectService.deleteProject(projectId);

      if (response.success) {
        // Remove project from the list
        _projects.removeWhere((p) => p.id == projectId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to delete project';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Change project status
  Future<bool> changeProjectStatus(String projectId, ProjectStatus status) async {
    _errorMessage = null;

    try {
      final response = await _projectService.changeProjectStatus(projectId, status);

      if (response.success) {
        // Update project status in the list
        final index = _projects.indexWhere((p) => p.id == projectId);
        if (index != -1) {
          _projects[index] = _projects[index].copyWith(
            status: status,
            completedAt: status == ProjectStatus.completed ? DateTime.now() : null,
          );
          notifyListeners();
        }
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to change project status';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Get project by ID (from cache or API)
  Future<Project?> getProject(String projectId) async {
    // Try to find in cache first
    final cachedProject = _projects.where((p) => p.id == projectId).firstOrNull;
    if (cachedProject != null) {
      return cachedProject;
    }

    // Fetch from API
    try {
      final response = await _projectService.getProject(projectId);
      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (e) {
      // Handle error silently for this method
    }

    return null;
  }

  // Load project statistics
  Future<void> loadProjectStats() async {
    try {
      final response = await _projectService.getProjectStats();

      if (response.success && response.data != null) {
        _projectStats = response.data;
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently for stats
    }
  }

  // Get projects by client
  Future<List<Project>> getProjectsByClient(String clientId, {String? status}) async {
    try {
      final response = await _projectService.getProjectsByClient(clientId, status: status);

      if (response.success) {
        return response.projects;
      }
    } catch (e) {
      // Handle error silently
    }

    return [];
  }

  // Clear all data
  void clear() {
    _projects.clear();
    _isLoading = false;
    _hasMore = true;
    _currentPage = 1;
    _errorMessage = null;
    _projectStats = null;
    _currentSearch = null;
    _currentClientId = null;
    _currentStatus = null;
    _currentOrdering = '-created_at';
    notifyListeners();
  }
}