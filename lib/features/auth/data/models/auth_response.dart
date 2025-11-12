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
    // Manejar diferentes estructuras de respuesta del backend
    // El token puede estar en diferentes lugares según la estructura del backend
    final token =
        json['token'] as String? ??
        json['accessToken'] as String? ??
        json['jwt'] as String? ??
        (throw Exception('Token no encontrado en la respuesta del servidor'));

    // El expiresIn puede ser opcional o tener diferentes nombres
    final expiresIn =
        json['expiresIn'] as int? ??
        json['expires_in'] as int? ??
        json['expires'] as int? ??
        3600; // Valor por defecto: 1 hora

    // El usuario puede estar directamente o anidado
    final userData =
        json['user'] as Map<String, dynamic>? ??
        json['userData'] as Map<String, dynamic>? ??
        (throw Exception(
          'Datos de usuario no encontrados en la respuesta del servidor',
        ));

    return AuthResponse(
      token: token,
      expiresIn: expiresIn,
      user: UserModel.fromJson(userData),
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'expiresIn': expiresIn, 'user': user.toJson()};
  }
}
