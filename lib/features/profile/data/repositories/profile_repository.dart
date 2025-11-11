import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/models.dart';

/// Repositorio para gestión de perfil
class ProfileRepository {
  final http.Client _httpClient;
  final FlutterSecureStorage _secureStorage;

  ProfileRepository({
    http.Client? httpClient,
    FlutterSecureStorage? secureStorage,
  }) : _httpClient = httpClient ?? http.Client(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Obtener token de autenticación
  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  /// Actualizar perfil del usuario
  Future<UserModel> updateProfile(UpdateProfileRequest request) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.updateProfileEndpoint}',
      );

      final response = await _httpClient
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedUser = UserModel.fromJson(data);

        // Actualizar usuario en storage
        await _secureStorage.write(
          key: 'user_data',
          value: jsonEncode(updatedUser.toJson()),
        );

        return updatedUser;
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al actualizar perfil');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  /// Cambiar contraseña
  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.changePasswordEndpoint}',
      );

      final response = await _httpClient
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        // Contraseña cambiada exitosamente
        return;
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al cambiar contraseña');
      } else if (response.statusCode == 401) {
        throw Exception('Contraseña actual incorrecta');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cambiar contraseña: $e');
    }
  }
}
