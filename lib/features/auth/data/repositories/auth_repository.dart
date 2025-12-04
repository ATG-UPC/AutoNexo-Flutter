import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../models/models.dart';

/// Repositorio de autenticación
class AuthRepository {
  final http.Client _httpClient;
  final SecureStorageService _storage;

  AuthRepository({http.Client? httpClient, SecureStorageService? storage})
    : _httpClient = httpClient ?? http.Client(),
      _storage = storage ?? SecureStorageService();

  /// Registrar nuevo usuario
  Future<void> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? invitationCode,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.signupEndpoint}',
      );

      // Construir el body del request
      // Según el Swagger, el backend NO acepta null para invitationCode
      // Debe ser un string vacío si no hay código
      final requestBody = {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'requestedRole': 'CAR_OWNER',
        'invitationCode': invitationCode ?? '', // String vacío en lugar de null
      };

      final response = await _httpClient
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registro exitoso (200 según Swagger, pero también aceptamos 201)
        return;
      } else if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(
            errorData['message'] ?? 'Datos de registro inválidos',
          );
        } catch (e) {
          throw Exception('Datos de registro inválidos');
        }
      } else if (response.statusCode == 500) {
        // Error del servidor - probablemente un problema con los datos
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(
            errorData['message'] ??
                'Error del servidor. Verifica que todos los campos estén completos.',
          );
        } catch (_) {
          throw Exception(
            'Error del servidor. Verifica que todos los campos estén completos.',
          );
        }
      } else {
        // Otros errores del servidor
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(
            errorData['message'] ??
                'Error del servidor: ${response.statusCode}',
          );
        } catch (_) {
          throw Exception('Error del servidor: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Si ya es una Exception con mensaje claro, relanzarla
      if (e is Exception && e.toString().contains('Exception:')) {
        rethrow;
      }
      // Si es un error de conexión o timeout
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception('Error de conexión. Verifica tu conexión a internet.');
      }
      throw Exception('Error al registrar usuario: $e');
    }
  }

  /// Iniciar sesión
  Future<AuthResponse> signin({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.signinEndpoint}',
      );

      final response = await _httpClient
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Verificar que la respuesta tenga el formato esperado
        if (data.isEmpty) {
          throw Exception('Respuesta vacía del servidor');
        }

        final authResponse = AuthResponse.fromJson(data);

        // Guardar token y datos del usuario
        await _saveAuthData(authResponse);

        return authResponse;
      } else if (response.statusCode == 401) {
        throw Exception('Email o contraseña incorrectos');
      } else if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(
            errorData['message'] ?? 'Error en el inicio de sesión',
          );
        } catch (_) {
          throw Exception('Error en el inicio de sesión');
        }
      } else {
        // Intentar parsear el error del servidor
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(
            errorData['message'] ??
                'Error del servidor: ${response.statusCode}',
          );
        } catch (_) {
          throw Exception('Error del servidor: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Si ya es una Exception con mensaje claro, relanzarla
      if (e is Exception && e.toString().contains('Exception:')) {
        rethrow;
      }
      // Si es un error de conexión o timeout
      if (e.toString().contains('TimeoutException') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception('Error de conexión. Verifica tu conexión a internet.');
      }
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  /// Guardar datos de autenticación
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    // Guardar token usando SecureStorageService (clave: 'auth_token')
    await _storage.saveToken(authResponse.token);
    // Guardar datos del usuario
    await _storage.saveUserData(jsonEncode(authResponse.user.toJson()));
  }

  /// Obtener token guardado
  Future<String?> getToken() async {
    return await _storage.getToken();
  }

  /// Obtener usuario guardado
  Future<UserModel?> getUser() async {
    final userJson = await _storage.getUserData();
    if (userJson != null && userJson.isNotEmpty) {
      try {
        return UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        // Si hay error al parsear, limpiar datos corruptos
        await _storage.deleteUserData();
        return null;
      }
    }
    return null;
  }

  /// Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    return await _storage.hasToken();
  }

  /// Cerrar sesión
  Future<void> logout() async {
    await _storage.clearSession();
  }

  // ========== FORGOT PASSWORD FLOW ==========

  /// Paso 1: Solicitar OTP para recuperación de contraseña
  Future<ForgotPasswordResponse> requestPasswordResetOtp({
    required String phoneNumber,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.forgotPasswordRequestOtpEndpoint}',
      );

      final response = await _httpClient
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phoneNumber': phoneNumber}),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ForgotPasswordResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Número de teléfono no registrado');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al solicitar OTP');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al solicitar OTP: $e');
    }
  }

  /// Paso 2: Verificar OTP
  Future<ForgotPasswordResponse> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.forgotPasswordVerifyOtpEndpoint}',
      );

      final response = await _httpClient
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ForgotPasswordResponse.fromJson(data);
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'OTP inválido o expirado');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al verificar OTP: $e');
    }
  }

  /// Paso 3: Resetear contraseña
  Future<void> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.forgotPasswordResetEndpoint}',
      );

      final response = await _httpClient
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phoneNumber': phoneNumber,
              'otp': otp,
              'newPassword': newPassword,
            }),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        // Contraseña reseteada exitosamente
        return;
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error al resetear contraseña');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al resetear contraseña: $e');
    }
  }
}
