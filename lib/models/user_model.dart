enum UserRole { patient, hospital, admin, driver }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phoneNumber;
  final String? address;
  final int? bedCount;
  final int? icuCount;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.address,
    this.bedCount,
    this.icuCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String name = json['name'] ?? '';
    if (name.isEmpty && json['first_name'] != null) {
      name = '${json['first_name']} ${json['last_name'] ?? ''}'.trim();
    }
    if (name.isEmpty && json['username'] != null) {
      name = json['username'];
    }

    return UserModel(
      id: json['id'].toString(),
      name: name,
      email: json['email'] ?? '',
      role: _parseRole(json['role']),
      phoneNumber: json['phone_number'] ?? json['phone'],
      address: json['address'],
      bedCount: json['bed_count'],
      icuCount: json['icu_count'],
    );
  }

  static UserRole _parseRole(String? role) {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'phone_number': phoneNumber,
      'address': address,
      'bed_count': bedCount,
      'icu_count': icuCount,
    };
  }
}
