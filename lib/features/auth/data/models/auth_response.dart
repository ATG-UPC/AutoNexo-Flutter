import 'user_model.dart';

/// Respuesta del login del backend
class AuthResponse {
  final String token;
  final int expiresIn;
  final UserModel user;

  const AuthResponse({
    required this.token,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      expiresIn: json['expiresIn'] as int,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'expiresIn': expiresIn, 'user': user.toJson()};
  }
}
