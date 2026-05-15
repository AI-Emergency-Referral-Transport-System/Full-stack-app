import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Restores session in the background. Does **not** set [_isLoading] so the landing
  /// UI can paint immediately; avoid waiting on secure storage + long profile timeouts.
  Future<void> checkAuth() async {
    if (_user != null) return;

    try {
      final token = await _apiService.token;
      if (token == null || token.isEmpty) return;

      final profile = await _apiService.get(
        'auth/profile/',
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
      );
      if (profile != null) {
        _user = UserModel.fromJson(profile);
        ApiService.currentUserRole = _user?.role.toString().split('.').last;
      }
    } catch (e) {
      debugPrint('Auth check failed: $e');
      await _apiService.clearToken();
      _user = null;
    }

    notifyListeners();
  }

  Future<bool> login(String email, String password, [UserRole? requestedRole]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final trimmedEmail = email.trim();

    try {
      final response = await _apiService.post('auth/login/', {
        'username': trimmedEmail,
        'password': password,
      });

      debugPrint('Login Response: $response');

      if (response != null && response['token'] != null) {
        final role = _parseRole(response['role']);

        if (requestedRole != null && role != requestedRole) {
          _errorMessage =
              'Incorrect role selected. This account is a ${_roleLabel(role)} account — choose ${_roleLabel(role)} in Account Role.';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        await _apiService.saveToken(response['token']);
        ApiService.currentUserRole = response['role'];

        final idFromApi = (role == UserRole.driver && response['driver_id'] != null)
            ? response['driver_id']?.toString()
            : (response['user_id']?.toString() ?? response['id']?.toString());

        final resolvedEmail = (response['email'] as String?)?.trim().isNotEmpty == true
            ? response['email'] as String
            : trimmedEmail;

        _user = UserModel(
          id: idFromApi ?? 'unknown',
          name: (response['name'] as String?)?.trim().isNotEmpty == true
              ? response['name'] as String
              : resolvedEmail.split('@').first,
          email: resolvedEmail,
          role: role,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Incorrect email or password.';
    } catch (e) {
      debugPrint('Login error: $e');
      _errorMessage = _normalizeLoginError(e.toString().replaceFirst('Exception: ', ''));
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  String _normalizeLoginError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid credentials') ||
        lower.contains('incorrect email or password') ||
        lower.contains('authentication failed')) {
      return 'Incorrect email or password.';
    }
    return raw;
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.hospital:
        return 'Hospital';
      case UserRole.admin:
        return 'Admin';
      case UserRole.driver:
        return 'Driver';
    }
  }

  UserRole _parseRole(String? role) {
    if (role == null) return UserRole.patient;
    switch (role.toUpperCase()) {
      case 'PATIENT':
        return UserRole.patient;
      case 'HOSPITAL':
        return UserRole.hospital;
      case 'ADMIN':
        return UserRole.admin;
      case 'DRIVER':
        return UserRole.driver;
      default:
        return UserRole.patient;
    }
  }

  Future<bool> register(String name, String email, String password, String phone, [UserRole role = UserRole.patient]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Split name into first and last for Django
      final nameParts = name.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final response = await _apiService.post('auth/patient/register/', {
        'username': email,
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      });

      if (response != null && response['id'] != null) {
        _user = UserModel.fromJson(response);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Registration failed';
    } catch (e) {
      debugPrint('Registration error: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nameParts = updatedUser.name.trim().split(RegExp(r'\s+'));
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final response = await _apiService.post('auth/profile/update/', {
        'first_name': firstName,
        'last_name': lastName,
        'email': updatedUser.email,
        'phone_number': updatedUser.phoneNumber,
      });
      if (response != null) {
        _user = UserModel.fromJson(response);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      // For mock purposes, update locally if backend fails
      _user = updatedUser;
    }

    _isLoading = false;
    notifyListeners();
    return true; // Return true anyway for demo if we updated locally
  }

  Future<void> logout() async {
    await _apiService.clearToken();
    _user = null;
    notifyListeners();
  }
}
