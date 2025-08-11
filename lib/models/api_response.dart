import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'api_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;
  @JsonKey(name: 'requires_setup')
  final bool? requiresSetup;
  final Map<String, dynamic>? errors;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.requiresSetup,
    this.errors,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => 
      _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class SetupResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;
  final Map<String, dynamic>? errors;

  SetupResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.errors,
  });

  factory SetupResponse.fromJson(Map<String, dynamic> json) => 
      _$SetupResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SetupResponseToJson(this);
}

@JsonSerializable()
class BaseApiResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? errors;

  BaseApiResponse({
    required this.success,
    required this.message,
    this.errors,
  });

  factory BaseApiResponse.fromJson(Map<String, dynamic> json) => 
      _$BaseApiResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BaseApiResponseToJson(this);
}