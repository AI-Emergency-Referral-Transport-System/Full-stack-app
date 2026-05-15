import 'package:flutter/material.dart';
import '../models/hospital_model.dart';
import '../models/driver_model.dart';
import '../services/api_service.dart';

class HospitalProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<HospitalModel> _hospitals = [];
  List<DriverModel> _drivers = [];
  HospitalModel? myHospitalProfile;
  bool _isLoading = false;

  List<HospitalModel> get hospitals => _hospitals;
  List<DriverModel> get drivers => _drivers;
  bool get isLoading => _isLoading;

  Future<void> fetchHospitals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('admin/hospitals/');
      if (response != null && response is List) {
        _hospitals = (response).map((e) => HospitalModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
    } catch (e) {
      debugPrint('Fetch hospitals error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> adminUpdateHospital(HospitalModel hospital) async {
    _isLoading = true;
    notifyListeners();
    try {
      final body = {
        'name': hospital.name,
        'address': hospital.address,
        'phone_number': hospital.phoneNumber,
        'latitude': hospital.location.latitude,
        'longitude': hospital.location.longitude,
        'bed_count': hospital.bedCount,
        'icu_count': hospital.icuCount,
      };
      final response = await _apiService.patch('admin/hospitals/${hospital.id}/', body);
      if (response != null && response is Map) {
        final updated = HospitalModel.fromJson(Map<String, dynamic>.from(response));
        final idx = _hospitals.indexWhere((h) => h.id == updated.id);
        if (idx != -1) _hospitals[idx] = updated;
      }
    } catch (e) {
      debugPrint('Admin update hospital error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> adminDeleteHospital(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.delete('admin/hospitals/$id/');
      _hospitals.removeWhere((h) => h.id == id);
    } catch (e) {
      debugPrint('Admin delete hospital error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  /// All registered hospitals for the patient, ordered nearest → farthest (backend sort).
  Future<void> fetchNearbyHospitalsForPatient(double latitude, double longitude) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        'patient/hospitals/nearby/?lat=$latitude&lng=$longitude',
      );
      if (response != null && response is List) {
        _hospitals = (response)
            .map((e) => HospitalModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      } else {
        _hospitals = [];
      }
    } catch (e) {
      debugPrint('Fetch nearby hospitals error: $e');
      _hospitals = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Logged-in hospital facility record (beds, ICU, address, coords).
  Future<void> fetchMyHospitalProfile() async {
    try {
      final response = await _apiService.get('hospital/profile/');
      if (response != null && response is Map<String, dynamic>) {
        myHospitalProfile = HospitalModel.fromJson(Map<String, dynamic>.from(response));
      } else if (response != null && response is Map) {
        myHospitalProfile = HospitalModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('Fetch hospital profile error: $e');
    }
    notifyListeners();
  }

  Future<void> fetchDrivers(String hospitalId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('hospital/drivers/');
      if (response != null) {
        _drivers = (response as List).map((e) => DriverModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
    } catch (e) {
      debugPrint('Fetch drivers error: $e');
      _drivers = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHospital(HospitalModel hospital, {String? email, String? password}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final loginEmail = (email ?? '').trim();
      final data = {
        'username': loginEmail,
        'name': hospital.name,
        'email': loginEmail,
        'password': password,
        'address': hospital.address,
        'latitude': hospital.location.latitude,
        'longitude': hospital.location.longitude,
        'phone_number': hospital.phoneNumber,
        'bed_count': hospital.bedCount,
        'icu_count': hospital.icuCount,
      };

      final response = await _apiService.post('admin/hospitals/', data);
      if (response != null && response is Map) {
        _hospitals.add(HospitalModel.fromJson(Map<String, dynamic>.from(response)));
      } else {
        _hospitals.add(hospital);
      }
    } catch (e) {
      debugPrint('Add hospital error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> registerDriver({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.post('hospital/drivers/', {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'phone': phone.trim(),
      });
      await fetchDrivers('');
      return null;
    } catch (e) {
      debugPrint('Register driver error: $e');
      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateHospital(HospitalModel hospital) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = {
        'name': hospital.name,
        'address': hospital.address,
        'phone_number': hospital.phoneNumber,
        'latitude': hospital.location.latitude,
        'longitude': hospital.location.longitude,
        'bed_count': hospital.bedCount,
        'icu_count': hospital.icuCount,
      };

      final response = await _apiService.post('hospital/profile/update/', data);
      if (response != null && response is Map) {
        myHospitalProfile = HospitalModel.fromJson(Map<String, dynamic>.from(response));
      }

      final index = _hospitals.indexWhere((h) => h.id == hospital.id);
      if (index != -1) {
        _hospitals[index] = hospital;
      }
    } catch (e) {
      debugPrint('Update hospital error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteHospital(String id) async {
    await adminDeleteHospital(id);
  }
}
