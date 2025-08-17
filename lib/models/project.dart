// lib/models/project.dart
import 'client.dart';

class Project {
  final String id;
  final String name;
  final String description;
  final String clientId;
  final String? clientName;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String createdBy;
  final String? createdByName;
  final String? createdByEmail;
  final int samplesCount;
  final Client? client;
  final List<RecentSample>? recentSamples;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.clientId,
    this.clientName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    required this.createdBy,
    this.createdByName,
    this.createdByEmail,
    this.samplesCount = 0,
    this.client,
    this.recentSamples,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
  return Project(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    clientId: json['client_id'] ?? json['client'] ?? '',
    clientName: json['client_name'],
    status: ProjectStatus.fromString(json['status'] ?? 'ACTIVE'),
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'])
        : DateTime.now(),
    completedAt: json['completed_at'] != null
        ? DateTime.parse(json['completed_at'])
        : null,
    createdBy: json['created_by'] ?? '',
    createdByName: json['created_by_name'],
    createdByEmail: json['created_by_email'],
    samplesCount: json['samples_count'] ?? 0,
    // FIXED: Check if client is a Map or String
    client: json['client'] != null && json['client'] is Map<String, dynamic>
        ? Client.fromJson(json['client'])
        : null,
    recentSamples: json['recent_samples'] != null
        ? (json['recent_samples'] as List)
            .map((s) => RecentSample.fromJson(s))
            .toList()
        : null,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'client': clientId,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_by': createdBy,
      'created_by_name': createdByName,
      'created_by_email': createdByEmail,
      'samples_count': samplesCount,
    };
  }

  Map<String, dynamic> toCreateJson() {
    final json = {
      'name': name,
      'description': description,
      'client': clientId,
      'status': status.value,
    };
    
    // Only include completed_at if it's not null
    if (completedAt != null) {
      json['completed_at'] = completedAt!.toIso8601String();
    }
    
    print('Project toCreateJson: $json'); // Debug log
    return json;
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? clientId,
    String? clientName,
    ProjectStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? createdBy,
    String? createdByName,
    String? createdByEmail,
    int? samplesCount,
    Client? client,
    List<RecentSample>? recentSamples,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdByEmail: createdByEmail ?? this.createdByEmail,
      samplesCount: samplesCount ?? this.samplesCount,
      client: client ?? this.client,
      recentSamples: recentSamples ?? this.recentSamples,
    );
  }
}

enum ProjectStatus {
  active('ACTIVE', 'Active'),
  completed('COMPLETED', 'Completed'),
  onHold('ON_HOLD', 'On Hold'),
  cancelled('CANCELLED', 'Cancelled');

  const ProjectStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static ProjectStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ACTIVE':
        return ProjectStatus.active;
      case 'COMPLETED':
        return ProjectStatus.completed;
      case 'ON_HOLD':
        return ProjectStatus.onHold;
      case 'CANCELLED':
        return ProjectStatus.cancelled;
      default:
        return ProjectStatus.active;
    }
  }
}

class RecentSample {
  final String id;
  final String sampleNumber;
  final String batchNumber;
  final DateTime receivedAt;
  final String status;

  RecentSample({
    required this.id,
    required this.sampleNumber,
    required this.batchNumber,
    required this.receivedAt,
    required this.status,
  });

  factory RecentSample.fromJson(Map<String, dynamic> json) {
    return RecentSample(
      id: json['id'] ?? '',
      sampleNumber: json['sample_number'] ?? '',
      batchNumber: json['batch_number'] ?? '',
      receivedAt: json['received_at'] != null
          ? DateTime.parse(json['received_at'])
          : DateTime.now(),
      status: json['status'] ?? '',
    );
  }
}

class ProjectListResponse {
  final bool success;
  final String? message;
  final int count;
  final String? next;
  final String? previous;
  final List<Project> results;

  ProjectListResponse({
    required this.success,
    this.message,
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory ProjectListResponse.fromJson(Map<String, dynamic> json) {
    return ProjectListResponse(
      success: json['success'] ?? true,
      message: json['message'],
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List).map((p) => Project.fromJson(p)).toList()
          : [],
    );
  }
}

class ProjectResponse {
  final bool success;
  final String message;
  final Project? data;
  final Map<String, dynamic>? errors;

  ProjectResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) {
    return ProjectResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? Project.fromJson(json['data']) : null,
      errors: json['errors'],
    );
  }
}

class ProjectStats {
  final int totalProjects;
  final double completionRate;
  final int recentProjects;
  final List<ProjectStatusCount> projectStatuses;
  final List<TopClient> topClients;

  ProjectStats({
    required this.totalProjects,
    required this.completionRate,
    required this.recentProjects,
    required this.projectStatuses,
    required this.topClients,
  });

  factory ProjectStats.fromJson(Map<String, dynamic> json) {
    return ProjectStats(
      totalProjects: json['total_projects'] ?? 0,
      completionRate: (json['completion_rate'] ?? 0).toDouble(),
      recentProjects: json['recent_projects'] ?? 0,
      projectStatuses: json['project_statuses'] != null
          ? (json['project_statuses'] as List)
              .map((ps) => ProjectStatusCount.fromJson(ps))
              .toList()
          : [],
      topClients: json['top_clients'] != null
          ? (json['top_clients'] as List)
              .map((tc) => TopClient.fromJson(tc))
              .toList()
          : [],
    );
  }
}

class ProjectStatusCount {
  final String status;
  final int count;

  ProjectStatusCount({
    required this.status,
    required this.count,
  });

  factory ProjectStatusCount.fromJson(Map<String, dynamic> json) {
    return ProjectStatusCount(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class TopClient {
  final String clientName;
  final String clientId;
  final int projectCount;

  TopClient({
    required this.clientName,
    required this.clientId,
    required this.projectCount,
  });

  factory TopClient.fromJson(Map<String, dynamic> json) {
    return TopClient(
      clientName: json['client__name'] ?? '',
      clientId: json['client__id'] ?? '',
      projectCount: json['project_count'] ?? 0,
    );
  }
}