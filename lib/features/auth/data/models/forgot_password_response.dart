/// Respuesta de solicitud de OTP
class ForgotPasswordResponse {
  final String message;
  final String? otpToken;

  ForgotPasswordResponse({required this.message, this.otpToken});

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      message: json['message'] as String,
      otpToken: json['otpToken'] as String?,
    );
  }
}
