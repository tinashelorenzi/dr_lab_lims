import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String? tel;
  final String role;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'setup_required')
  final bool setupRequired;
  @JsonKey(name: 'setup_completed_at')
  final String? setupCompletedAt;
  @JsonKey(name: 'date_joined')
  final String dateJoined;
  @JsonKey(name: 'last_login')
  final String? lastLogin;
  @JsonKey(name: 'has_keys')
  final bool hasKeys;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.tel,
    required this.role,
    required this.isActive,
    required this.setupRequired,
    this.setupCompletedAt,
    required this.dateJoined,
    this.lastLogin,
    required this.hasKeys,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get fullName => '$firstName $lastName'.trim();
  
  String get displayName => fullName.isEmpty ? email : fullName;
  
  String get roleDisplay {
    switch (role) {
      case 'ADMIN':
        return 'Administrator';
      case 'MANAGER':
        return 'Lab Manager';
      case 'TECHNICIAN':
        return 'Lab Technician';
      case 'OPERATOR':
        return 'Lab Operator';
      case 'VIEWER':
        return 'Viewer';
      default:
        return role;
    }
  }
}