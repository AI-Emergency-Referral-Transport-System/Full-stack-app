enum DriverStatus { available, unavailable }

class DriverModel {
  final String id;
  final String name;
  final String hospitalId;
  final DriverStatus status;
  final String phoneNumber;

  DriverModel({
    required this.id,
    required this.name,
    required this.hospitalId,
    required this.status,
    required this.phoneNumber,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    final hospitalRaw = json['hospital_id'] ?? json['hospital'];
    return DriverModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      hospitalId: hospitalRaw?.toString() ?? '',
      status: _parseStatus(json['status']),
      phoneNumber: json['phone_number']?.toString() ?? json['phone']?.toString() ?? '',
    );
  }

  static DriverStatus _parseStatus(dynamic raw) {
    final s = raw?.toString().toUpperCase() ?? '';
    if (s.contains('UNAVAILABLE')) return DriverStatus.unavailable;
    return DriverStatus.available;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hospital_id': hospitalId,
      'status': status.toString().split('.').last,
      'phone_number': phoneNumber,
    };
  }
}
