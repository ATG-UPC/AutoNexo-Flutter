import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio para almacenamiento seguro de datos sensibles.
/// 
/// Utiliza flutter_secure_storage para guardar datos de forma encriptada.
/// Ideal para tokens, credenciales y otros datos sensibles.
/// 
/// Ejemplo de uso:
/// ```dart
/// final storage = SecureStorageService();
/// 
/// // Guardar token
/// await storage.saveToken('jwt_token_here');
/// 
/// // Leer token
/// final token = await storage.getToken();
/// 
/// // Eliminar token
/// await storage.deleteToken();
/// ```
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  
  factory SecureStorageService() => _instance;
  
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';

  // === Token Methods ===
  
  /// Guarda el token de autenticación
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Obtiene el token de autenticación
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Elimina el token de autenticación
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Verifica si hay un token guardado
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // === Refresh Token Methods ===
  
  /// Guarda el refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Obtiene el refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Elimina el refresh token
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  // === User ID Methods ===
  
  /// Guarda el ID del usuario
  Future<void> saveUserId(String id) async {
    await _storage.write(key: _userIdKey, value: id);
  }

  /// Obtiene el ID del usuario
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Elimina el ID del usuario
  Future<void> deleteUserId() async {
    await _storage.delete(key: _userIdKey);
  }

  // === User Data Methods ===
  
  /// Guarda los datos del usuario (JSON string)
  Future<void> saveUserData(String userData) async {
    await _storage.write(key: _userDataKey, value: userData);
  }

  /// Obtiene los datos del usuario
  Future<String?> getUserData() async {
    return await _storage.read(key: _userDataKey);
  }

  /// Elimina los datos del usuario
  Future<void> deleteUserData() async {
    await _storage.delete(key: _userDataKey);
  }

  // === Generic Methods ===
  
  /// Guarda un valor con una clave personalizada
  Future<void> saveString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Obtiene un valor por clave
  Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  /// Elimina un valor por clave
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Verifica si existe una clave
  Future<bool> containsKey(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }

  // === Session Management ===
  
  /// Limpia todos los datos de sesión (logout)
  Future<void> clearSession() async {
    await Future.wait([
      deleteToken(),
      deleteRefreshToken(),
      deleteUserId(),
      deleteUserData(),
    ]);
  }

  /// Limpia todo el almacenamiento
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

