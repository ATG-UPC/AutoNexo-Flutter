/// Modelo para solicitud de OTP para recuperación de contraseña
class ForgotPasswordRequest {
  final String phoneNumber;

  ForgotPasswordRequest({required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {'phoneNumber': phoneNumber};
  }
}
