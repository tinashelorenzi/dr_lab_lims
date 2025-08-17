import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../providers/client_provider.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  setupRequired,
  unauthenticated,
}

class AuthProvider extends ChangeNotifier {
  AuthState _authState = AuthState.initial;
  User? _user;
  String? _token;
  String? _errorMessage;
  bool _isLoading = false;
  
  final ApiService _apiService = ApiService();
  
  // Getters
  AuthState get authState => _authState;
  User? get user => _user;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get requiresSetup => _authState == AuthState.setupRequired;
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Sync token with client provider
  void _syncClientProviderToken(BuildContext? context) {
    if (context != null) {
      final clientProvider = Provider.of<ClientProvider>(context, listen: false);
      if (_token != null) {
        clientProvider.setAuthToken(_token!);
      } else {
        clientProvider.clearAuthToken();
      }
    }
  }
  
  // Initialize authentication state from stored token
  Future<void> initializeAuth() async {
    _setLoading(true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('auth_token');
      
      if (storedToken != null) {
        _token = storedToken;
        _apiService.setAuthToken(storedToken);
        
        // Verify token by fetching user profile
        final user = await _apiService.getProfile();
        if (user != null) {
          _user = user;
          _authState = user.setupRequired 
              ? AuthState.setupRequired 
              : AuthState.authenticated;
        } else {
          // Token is invalid, clear it
          await _clearAuthData();
          _authState = AuthState.unauthenticated;
        }
      } else {
        _authState = AuthState.unauthenticated;
      }
    } catch (e) {
      _setError('Failed to initialize authentication: ${e.toString()}');
      _authState = AuthState.unauthenticated;
    } finally {
      _setLoading(false);
    }
  }
  
  // Login with email and password
  Future<bool> login(String email, String password, {BuildContext? context}) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.login(email, password);
      
      if (response.success && response.token != null && response.user != null) {
        _token = response.token!;
        _user = response.user!;
        
        // Store token persistently
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        
        // Set token in API service
        _apiService.setAuthToken(_token!);
        
        // Sync client provider token
        _syncClientProviderToken(context);
        
        // Determine auth state based on setup requirement
        _authState = (response.requiresSetup == true || _user!.setupRequired)
            ? AuthState.setupRequired
            : AuthState.authenticated;
        
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  // Complete user setup
  Future<bool> completeSetup(String email, String password, String passwordConfirm) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final response = await _apiService.completeSetup(email, password, passwordConfirm);
      
      if (response.success && response.token != null && response.user != null) {
        _token = response.token!;
        _user = response.user!;
        
        // Store token persistently
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        
        // Set token in API service
        _apiService.setAuthToken(_token!);
        
        // User setup is complete, mark as authenticated
        _authState = AuthState.authenticated;
        
        _setLoading(false);
        return true;
      } else {
        _setError(response.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Setup failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }
  
  // Logout
  Future<void> logout({BuildContext? context}) async {
    _setLoading(true);
    
    try {
      // Call logout API
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
      debugPrint('Logout API call failed: $e');
    }
    
    // Clear local auth data
    await _clearAuthData();
    
    // Clear client provider token
    _syncClientProviderToken(context);
    
    _authState = AuthState.unauthenticated;
    _setLoading(false);
  }
  
  // Clear authentication data
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    
    _token = null;
    _user = null;
    _apiService.clearAuthToken();
  }
  
  // Ping server to keep session alive
  Future<void> ping() async {
    if (_token != null) {
      try {
        await _apiService.ping();
        
        // Update user profile to get latest data
        final user = await _apiService.getProfile();
        if (user != null) {
          _user = user;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Ping failed: $e');
      }
    }
  }
}