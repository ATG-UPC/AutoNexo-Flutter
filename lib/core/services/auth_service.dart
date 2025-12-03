import 'dart:convert';
import 'package:autonexoowner/core/constants/api_constants.dart';
import 'package:autonexoowner/core/services/api_client.dart';
import 'package:autonexoowner/core/services/secure_storage_service.dart';
import 'package:autonexoowner/core/utils/api_exception.dart';

/// Servicio de autenticación.
/// 
/// Maneja login, registro, logout y gestión de sesión.
/// 
/// Ejemplo de uso:
/// ```dart
/// final authService = AuthService();
/// 
/// // Login
/// try {
///   final user = await authService.login('email@test.com', 'password');
///   // Usuario logueado
/// } on ApiException catch (e) {
///   // Manejar error
/// }
/// 
/// // Verificar autenticación
/// if (await authService.isAuthenticated()) {
///   // Usuario autenticado
/// }
/// 
/// // Logout
/// await authService.logout();
/// ```
class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() => _instance;
  
  AuthService._internal();

  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _storage = SecureStorageService();

  /// Inicia sesión con email y contraseña
  /// 
  /// Retorna los datos del usuario si el login es exitoso.
  /// Guarda el token automáticamente en SecureStorage.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiConstants.signinEndpoint,
      body: {
        'email': email,
        'password': password,
      },
      requiresAuth: false,
    );
    
    // Guardar token
    if (response['token'] != null) {
      await _storage.saveToken(response['token'] as String);
    }
    
    // Guardar datos de usuario
    if (response['user'] != null) {
      await _storage.saveUserData(jsonEncode(response['user']));
      if (response['user']['id'] != null) {
        await _storage.saveUserId(response['user']['id'].toString());
      }
    }
    
    return response as Map<String, dynamic>;
  }

  /// Registra un nuevo usuario
  /// 
  /// Retorna los datos del usuario si el registro es exitoso.
  /// Guarda el token automáticamente.
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String requestedRole = 'CAR_OWNER',
  }) async {
    final response = await _apiClient.post(
      ApiConstants.signupEndpoint,
      body: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'requestedRole': requestedRole,
        'invitationCode': null,
      },
      requiresAuth: false,
    );
    
    // Guardar token
    if (response['token'] != null) {
      await _storage.saveToken(response['token'] as String);
    }
    
    // Guardar datos de usuario
    if (response['user'] != null) {
      await _storage.saveUserData(jsonEncode(response['user']));
      if (response['user']['id'] != null) {
        await _storage.saveUserId(response['user']['id'].toString());
      }
    }
    
    return response as Map<String, dynamic>;
  }

  /// Cierra la sesión del usuario
  /// 
  /// Limpia todos los datos almacenados localmente.
  Future<void> logout() async {
    await _storage.clearSession();
  }

  /// Verifica si el usuario está autenticado
  /// 
  /// Retorna true si hay un token guardado.
  Future<bool> isAuthenticated() async {
    return await _storage.hasToken();
  }

  /// Obtiene el token de autenticación actual
  Future<String?> getToken() async {
    return await _storage.getToken();
  }

  /// Obtiene los datos del usuario almacenados localmente
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userData = await _storage.getUserData();
    if (userData != null) {
      try {
        return jsonDecode(userData) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Obtiene los datos del usuario desde el servidor
  Future<Map<String, dynamic>> fetchCurrentUser() async {
    final response = await _apiClient.get('/users/me');
    
    // Actualizar datos locales
    await _storage.saveUserData(jsonEncode(response));
    
    return response as Map<String, dynamic>;
  }

  /// Actualiza el perfil del usuario
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
    
    final response = await _apiClient.put(
      ApiConstants.updateProfileEndpoint,
      body: body,
    );
    
    // Actualizar datos locales
    await _storage.saveUserData(jsonEncode(response));
    
    return response as Map<String, dynamic>;
  }

  /// Cambia la contraseña del usuario
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.post(
      ApiConstants.changePasswordEndpoint,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  /// Solicita un código OTP para recuperar contraseña
  Future<void> requestPasswordReset(String phoneNumber) async {
    await _apiClient.post(
      ApiConstants.forgotPasswordRequestOtpEndpoint,
      body: {'phoneNumber': phoneNumber},
      requiresAuth: false,
    );
  }

  /// Verifica el código OTP de recuperación de contraseña
  Future<Map<String, dynamic>> verifyPasswordResetOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.forgotPasswordVerifyOtpEndpoint,
      body: {
        'phoneNumber': phoneNumber,
        'otp': otp,
      },
      requiresAuth: false,
    );
    return response as Map<String, dynamic>;
  }

  /// Restablece la contraseña con el token del OTP
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _apiClient.post(
      ApiConstants.forgotPasswordResetEndpoint,
      body: {
        'token': token,
        'newPassword': newPassword,
      },
      requiresAuth: false,
    );
  }

  /// Solicita verificación de email
  Future<void> requestEmailVerification() async {
    await _apiClient.post('/users/request-email-verification');
  }

  /// Verifica email con token
  Future<void> verifyEmail(String token) async {
    await _apiClient.post(
      '/users/verify-email',
      body: {'token': token},
    );
  }
}

