/// Modelo para actualizar el perfil del usuario
class UpdateProfileRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  UpdateProfileRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}
