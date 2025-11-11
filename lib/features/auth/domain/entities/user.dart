import 'package:equatable/equatable.dart';

/// Entidad de usuario (Domain layer)
class User extends Equatable {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final bool isVerified;
  final bool active;
  final List<String> roles;
  final int? workshopId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.isVerified,
    required this.active,
    required this.roles,
    this.workshopId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Nombre completo del usuario
  String get fullName => '$firstName $lastName';

  /// Verifica si el usuario es propietario de vehículo
  bool get isCarOwner => roles.contains('CAR_OWNER');

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    phoneNumber,
    isVerified,
    active,
    roles,
    workshopId,
    createdAt,
    updatedAt,
  ];
}
