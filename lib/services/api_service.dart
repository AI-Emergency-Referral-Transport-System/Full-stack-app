import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Use 127.0.0.1 instead of localhost for better compatibility across browsers
  // For Android Emulators, you would use 10.0.2.2
  static const String baseUrl = 'http://127.0.0.1:8000/api/';
  
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  static String? currentUserRole;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptor for JWT token and error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Token $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        String errorMessage = 'Network error occurred';
        
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Connection timed out. Please check your local backend.';
        } else if (e.response != null) {
          final data = e.response?.data;
          if (data is Map) {
            final statusFallback = 'Error ${e.response?.statusCode}';
            errorMessage = data['detail']?.toString() ??
                data['message']?.toString() ??
                data['error']?.toString() ??
                statusFallback;
            final nonField = data['non_field_errors'];
            if (nonField is List && nonField.isNotEmpty) {
              errorMessage = nonField.first.toString();
            }
            if (errorMessage == statusFallback) {
              for (final entry in data.entries) {
                final v = entry.value;
                if (v is List && v.isNotEmpty) {
                  errorMessage = v.first.toString();
                  break;
                }
              }
            }
          } else {
            errorMessage = 'Server error: ${e.response?.statusCode}';
          }
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Cannot connect to local backend at http://localhost:8000. Ensure your Django server is running.';
        }

        debugPrint('API Error: $errorMessage');
        return handler.next(DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: errorMessage,
        ));
      },
    ));
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Request failed');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<dynamic> patch(String endpoint, dynamic data) async {
    try {
      final response = await _dio.patch(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Request failed');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> delete(String endpoint) async {
    try {
      await _dio.delete(endpoint);
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Request failed');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<dynamic> get(
    String endpoint, {
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) async {
    try {
      final Options? requestOptions =
          (connectTimeout != null || receiveTimeout != null)
              ? Options(
                  connectTimeout: connectTimeout,
                  receiveTimeout: receiveTimeout,
                )
              : null;

      final response = await _dio.get(endpoint, options: requestOptions);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Request failed');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<String?> get token async => await _storage.read(key: 'jwt_token');

  // ----------------------------
  // Local-only patient home location (no backend)
  // ----------------------------
  static const _homeLatKey = 'patient_home_lat';
  static const _homeLngKey = 'patient_home_lng';

  Future<void> savePatientHomeLocation({required double lat, required double lng}) async {
    await _storage.write(key: _homeLatKey, value: lat.toString());
    await _storage.write(key: _homeLngKey, value: lng.toString());
  }

  Future<({double lat, double lng})?> getPatientHomeLocation() async {
    final latRaw = await _storage.read(key: _homeLatKey);
    final lngRaw = await _storage.read(key: _homeLngKey);
    final lat = double.tryParse(latRaw ?? '');
    final lng = double.tryParse(lngRaw ?? '');
    if (lat == null || lng == null) return null;
    return (lat: lat, lng: lng);
  }
}
