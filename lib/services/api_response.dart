import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/api_response.dart';
import '../models/user.dart';

class ApiService {
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
  
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      return LoginResponse.fromJson(responseData);
    } catch (e) {
      return LoginResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
  
  Future<SetupResponse> completeSetup(
    String email, 
    String password, 
    String passwordConfirm
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/setup/'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
        }),
      ).timeout(timeout);
      
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      
      return SetupResponse.fromJson(responseData);
    } catch (e) {
      return SetupResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
  
  Future<BaseApiResponse> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout/'),
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
  
  Future<User?> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile/'),
        headers: _headers,
      ).timeout(timeout);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['user'] != null) {
          return User.fromJson(responseData['user']);
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<BaseApiResponse> ping() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/ping/'),
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
}