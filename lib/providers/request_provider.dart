import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/emergency_request_model.dart';
import '../services/api_service.dart';

class RequestProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<EmergencyRequestModel> _requests = [];
  EmergencyRequestModel? _activeRequest;
  bool _isLoading = false;

  List<EmergencyRequestModel> get requests => _requests;
  EmergencyRequestModel? get activeRequest => _activeRequest;
  bool get isLoading => _isLoading;

  Future<void> fetchRequests() async {
    _isLoading = true;
    notifyListeners();
    try {
      String endpoint = 'patient/requests/list/';
      
      final response = await _apiService.get(endpoint);
      if (response != null) {
        _requests = (response as List).map((e) => EmergencyRequestModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Fetch requests error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchHospitalRequests() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get('hospital/requests/incoming/');
      if (response != null) {
        _requests = (response as List).map((e) => EmergencyRequestModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Fetch hospital requests error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createRequest(String patientId, LatLng location, String? type, {String? targetHospitalId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final payload = <String, dynamic>{
        'patient_latitude': location.latitude,
        'patient_longitude': location.longitude,
        'emergency_type': type ?? '',
      };
      final hid = int.tryParse(targetHospitalId ?? '');
      if (hid != null) {
        payload['target_hospital_id'] = hid;
      }

      final response = await _apiService.post('patient/requests/', payload);

      if (response != null) {
        final newRequest = EmergencyRequestModel.fromJson(response);
        _requests.add(newRequest);
        _activeRequest = newRequest;
      }
    } catch (e) {
      debugPrint('Create request error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateRequestStatus(String requestId, RequestStatus status, {String? hospitalId, String? driverId}) async {
    try {
      final body = <String, dynamic>{
        'decision': status == RequestStatus.accepted ? 'ACCEPT' : 'REJECT',
      };
      final parsedDriverId = int.tryParse(driverId ?? '');
      if (status == RequestStatus.accepted && parsedDriverId != null) {
        body['driver_id'] = parsedDriverId;
      }

      await _apiService.post('hospital/requests/$requestId/decision/', body);
    } catch (e) {
      debugPrint('Update status error: $e');
    }

    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final updatedRequest = EmergencyRequestModel(
        id: _requests[index].id,
        patientId: _requests[index].patientId,
        patientLocation: _requests[index].patientLocation,
        emergencyType: _requests[index].emergencyType,
        status: status,
        assignedHospitalId: hospitalId ?? _requests[index].assignedHospitalId,
        assignedDriverId: driverId ?? _requests[index].assignedDriverId,
        rejectedByHospitalIds: _requests[index].rejectedByHospitalIds,
        createdAt: _requests[index].createdAt,
      );
      _requests[index] = updatedRequest;
      if (_activeRequest?.id == requestId) {
        _activeRequest = updatedRequest;
      }
      notifyListeners();
    }
  }

  void setActiveRequest(EmergencyRequestModel? request) {
    _activeRequest = request;
    notifyListeners();
  }
}
