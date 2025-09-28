// Core types for ASHA EHR system

enum UserRole { asha, anm, phc }

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.asha:
        return 'ASHA';
      case UserRole.anm:
        return 'ANM';
      case UserRole.phc:
        return 'PHC';
    }
  }
  
  String get description {
    switch (this) {
      case UserRole.asha:
        return 'Accredited Social Health Activist';
      case UserRole.anm:
        return 'Auxiliary Nurse Midwife';
      case UserRole.phc:
        return 'Primary Health Centre';
    }
  }
}

class User {
  final String id;
  final String name;
  final UserRole role;
  final String? village;
  final String? phoneNumber;
  final String pin;
  final DateTime? lastSync;
  final bool isOnline;

  User({
    required this.id,
    required this.name,
    required this.role,
    this.village,
    this.phoneNumber,
    required this.pin,
    this.lastSync,
    required this.isOnline,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.asha,
      ),
      village: json['village'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      pin: json['pin'] as String,
      lastSync: json['lastSync'] != null 
          ? DateTime.parse(json['lastSync'] as String)
          : null,
      isOnline: json['isOnline'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
      'village': village,
      'phoneNumber': phoneNumber,
      'pin': pin,
      'lastSync': lastSync?.toIso8601String(),
      'isOnline': isOnline,
    };
  }

  User copyWith({
    String? id,
    String? name,
    UserRole? role,
    String? village,
    String? phoneNumber,
    String? pin,
    DateTime? lastSync,
    bool? isOnline,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      village: village ?? this.village,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pin: pin ?? this.pin,
      lastSync: lastSync ?? this.lastSync,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}