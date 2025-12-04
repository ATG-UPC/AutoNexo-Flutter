import 'package:equatable/equatable.dart';

/// Modelo para representar un usuario autorizado de un vehículo
class AuthorizedUserModel extends Equatable {
  final int userId;
  final String email;
  final String firstName;
  final String lastName;
  final String ownershipType;
  final DateTime? addedAt;

  const AuthorizedUserModel({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.ownershipType,
    this.addedAt,
  });

  /// Nombre completo del usuario
  String get fullName => '$firstName $lastName';

  /// Si es propietario principal
  bool get isPrimaryOwner => ownershipType == 'PRIMARY';

  /// Si es usuario autorizado
  bool get isAuthorized => ownershipType == 'AUTHORIZED';

  factory AuthorizedUserModel.fromJson(Map<String, dynamic> json) {
    return AuthorizedUserModel(
      userId: json['userId'] as int,
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      ownershipType: json['ownershipType'] as String? ?? 'AUTHORIZED',
      addedAt: json['addedAt'] != null 
          ? DateTime.tryParse(json['addedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'ownershipType': ownershipType,
      'addedAt': addedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [userId, email, firstName, lastName, ownershipType, addedAt];
}

