import '../../domain/entities/user.dart';

/// Modelo de usuario para serialización JSON (Data layer)
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.phoneNumber,
    required super.isVerified,
    required super.active,
    required super.roles,
    super.workshopId,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Crea un UserModel desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      isVerified: json['isVerified'] as bool,
      active: json['active'] as bool,
      roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
      workshopId: json['workshopId'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convierte el UserModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'isVerified': isVerified,
      'active': active,
      'roles': roles,
      'workshopId': workshopId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convierte a entidad de dominio
  User toEntity() {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      isVerified: isVerified,
      active: active,
      roles: roles,
      workshopId: workshopId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
