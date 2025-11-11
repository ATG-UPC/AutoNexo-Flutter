/// Modelo para resetear contraseña
class ResetPasswordRequest {
  final String phoneNumber;
  final String otp;
  final String newPassword;

  ResetPasswordRequest({
    required this.phoneNumber,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'phoneNumber': phoneNumber, 'otp': otp, 'newPassword': newPassword};
  }
}
