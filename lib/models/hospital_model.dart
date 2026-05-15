import 'package:latlong2/latlong.dart';

class HospitalModel {
  final String id;
  final String name;
  final String address;
  final LatLng location;
  final String phoneNumber;
  final int bedCount;
  final int icuCount;
  /// Server-computed straight-line distance (meters); only set for patient/nearby list.
  final double? distanceMeters;

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    required this.phoneNumber,
    this.bedCount = 0,
    this.icuCount = 0,
    this.distanceMeters,
  });

  double get distanceKm => (distanceMeters ?? 0) / 1000.0;

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown Hospital',
      address: json['address'] ?? '',
      location: LatLng(
        (json['latitude'] as num?)?.toDouble() ?? 0.0,
        (json['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      phoneNumber: json['phone_number']?.toString() ?? json['phone']?.toString() ?? '',
      bedCount: (json['bed_count'] as num?)?.toInt() ?? 0,
      icuCount: (json['icu_count'] as num?)?.toInt() ?? 0,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'phone_number': phoneNumber,
      'bed_count': bedCount,
      'icu_count': icuCount,
    };
  }
}
