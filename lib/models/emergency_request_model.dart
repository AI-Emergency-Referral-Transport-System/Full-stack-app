import 'package:latlong2/latlong.dart';

enum RequestStatus { pending, accepted, rejected, failed, completed }

class EmergencyRequestModel {
  final String id;
  final String patientId;
  final LatLng patientLocation;
  final String? emergencyType;
  final RequestStatus status;
  final String? assignedHospitalId;
  final String? assignedDriverId;
  final List<String> rejectedByHospitalIds;
  final DateTime createdAt;

  EmergencyRequestModel({
    required this.id,
    required this.patientId,
    required this.patientLocation,
    this.emergencyType,
    required this.status,
    this.assignedHospitalId,
    this.assignedDriverId,
    this.rejectedByHospitalIds = const [],
    required this.createdAt,
  });

  factory EmergencyRequestModel.fromJson(Map<String, dynamic> json) {
    return EmergencyRequestModel(
      id: json['id'].toString(),
      patientId: json['patient'].toString(),
      patientLocation: LatLng(
        json['patient_latitude'] ?? 0.0,
        json['patient_longitude'] ?? 0.0,
      ),
      emergencyType: json['emergency_type'],
      status: _parseStatus(json['status']),
      assignedHospitalId: json['accepted_hospital']?.toString(),
      assignedDriverId: json['assigned_driver'] is Map 
          ? json['assigned_driver']['id']?.toString() 
          : json['assigned_driver']?.toString(),
      rejectedByHospitalIds: [], // Not directly in the main serializer fields I saw
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static RequestStatus _parseStatus(String? status) {
    if (status == null) return RequestStatus.pending;
    switch (status.toUpperCase()) {
      case 'PENDING':
        return RequestStatus.pending;
      case 'ACCEPTED':
        return RequestStatus.accepted;
      case 'ASSIGNED':
        return RequestStatus.accepted; // In Flutter accepted/assigned might be same
      case 'FAILED':
        return RequestStatus.failed;
      case 'COMPLETED':
        return RequestStatus.completed;
      default:
        return RequestStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'latitude': patientLocation.latitude,
      'longitude': patientLocation.longitude,
      'emergency_type': emergencyType,
      'status': status.toString().split('.').last,
      'assigned_hospital_id': assignedHospitalId,
      'assigned_driver_id': assignedDriverId,
      'rejected_by_hospitals': rejectedByHospitalIds,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
