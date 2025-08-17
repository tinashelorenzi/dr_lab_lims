// lib/models/client.dart
class Client {
  final String id;
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final String address;
  final ClientType clientType;
  final bool isActive;
  final int defaultSlaHours;
  final String billingContact;
  final String billingEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? createdByName;
  final String? createdByEmail;
  final int projectsCount;
  final List<Project>? projects;

  Client({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
    required this.clientType,
    required this.isActive,
    required this.defaultSlaHours,
    required this.billingContact,
    required this.billingEmail,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.createdByName,
    this.createdByEmail,
    this.projectsCount = 0,
    this.projects,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '', // Not in API response - default to empty
      clientType: ClientType.fromString(json['client_type'] ?? 'ONE_TIME'),
      isActive: json['is_active'] ?? true,
      defaultSlaHours: json['default_sla_hours'] ?? 72,
      billingContact: json['billing_contact'] ?? '', // Not in API response - default to empty
      billingEmail: json['billing_email'] ?? '', // Not in API response - default to empty
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(), // Not in API response - default to now
      createdBy: json['created_by'] ?? '', // Not in API response - default to empty
      createdByName: json['created_by_name'], // This can be null - that's fine
      createdByEmail: json['created_by_email'], // Not in API response - can be null
      projectsCount: json['projects_count'] ?? 0,
      projects: json['projects'] != null
          ? (json['projects'] as List).map((p) => Project.fromJson(p)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact_person': contactPerson,
      'email': email,
      'phone': phone,
      'address': address,
      'client_type': clientType.value,
      'is_active': isActive,
      'default_sla_hours': defaultSlaHours,
      'billing_contact': billingContact,
      'billing_email': billingEmail,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'created_by_name': createdByName,
      'created_by_email': createdByEmail,
      'projects_count': projectsCount,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'contact_person': contactPerson,
      'email': email,
      'phone': phone,
      'address': address,
      'client_type': clientType.value,
      'is_active': isActive,
      'default_sla_hours': defaultSlaHours,
      'billing_contact': billingContact,
      'billing_email': billingEmail,
    };
  }

  Client copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? email,
    String? phone,
    String? address,
    ClientType? clientType,
    bool? isActive,
    int? defaultSlaHours,
    String? billingContact,
    String? billingEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? createdByName,
    String? createdByEmail,
    int? projectsCount,
    List<Project>? projects,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      clientType: clientType ?? this.clientType,
      isActive: isActive ?? this.isActive,
      defaultSlaHours: defaultSlaHours ?? this.defaultSlaHours,
      billingContact: billingContact ?? this.billingContact,
      billingEmail: billingEmail ?? this.billingEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdByEmail: createdByEmail ?? this.createdByEmail,
      projectsCount: projectsCount ?? this.projectsCount,
      projects: projects ?? this.projects,
    );
  }
}

enum ClientType {
  contracted('CONTRACTED', 'Contracted Client'),
  oneTime('ONE_TIME', 'One-time Client'),
  longTerm('LONG_TERM', 'Long-term Client');

  const ClientType(this.value, this.displayName);

  final String value;
  final String displayName;

  static ClientType fromString(String value) {
    switch (value) {
      case 'CONTRACTED':
        return ClientType.contracted;
      case 'ONE_TIME':
        return ClientType.oneTime;
      case 'LONG_TERM':
        return ClientType.longTerm;
      default:
        return ClientType.oneTime;
    }
  }
}

class Project {
  final String id;
  final String name;
  final String description;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '', // Handle null
      status: ProjectStatus.fromString(json['status'] ?? 'ACTIVE'),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
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
    switch (value) {
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

class ClientListResponse {
  final bool success;
  final String? message;
  final int count;
  final String? next;
  final String? previous;
  final List<Client> results;

  ClientListResponse({
    required this.success,
    this.message,
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory ClientListResponse.fromJson(Map<String, dynamic> json) {
    // Handle Django REST Framework pagination format
    return ClientListResponse(
      success: true, // DRF doesn't include success field, assume true if we get here
      message: json['message'], // Usually null for successful responses
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: json['results'] != null
          ? (json['results'] as List).map((c) => Client.fromJson(c)).toList()
          : [],
    );
  }
}

class ClientResponse {
  final bool success;
  final String message;
  final Client? data;
  final Map<String, dynamic>? errors;

  ClientResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ClientResponse.fromJson(Map<String, dynamic> json) {
    return ClientResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? Client.fromJson(json['data']) : null,
      errors: json['errors'],
    );
  }
}

class ClientStats {
  final int totalClients;
  final int activeClients;
  final int inactiveClients;
  final int recentClients;
  final List<ClientTypeCount> clientTypes;

  ClientStats({
    required this.totalClients,
    required this.activeClients,
    required this.inactiveClients,
    required this.recentClients,
    required this.clientTypes,
  });

  factory ClientStats.fromJson(Map<String, dynamic> json) {
    return ClientStats(
      totalClients: json['total_clients'] ?? 0,
      activeClients: json['active_clients'] ?? 0,
      inactiveClients: json['inactive_clients'] ?? 0,
      recentClients: json['recent_clients'] ?? 0,
      clientTypes: json['client_types'] != null
          ? (json['client_types'] as List)
              .map((ct) => ClientTypeCount.fromJson(ct))
              .toList()
          : [],
    );
  }
}

class ClientTypeCount {
  final String clientType;
  final int count;

  ClientTypeCount({
    required this.clientType,
    required this.count,
  });

  factory ClientTypeCount.fromJson(Map<String, dynamic> json) {
    return ClientTypeCount(
      clientType: json['client_type'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}