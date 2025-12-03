import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:autonexoowner/core/constants/api_constants.dart';
import 'package:autonexoowner/core/utils/api_exception.dart';
import 'package:autonexoowner/core/services/secure_storage_service.dart';

/// Cliente HTTP centralizado para la aplicación.
/// 
/// Proporciona métodos para realizar peticiones HTTP con:
/// - Autenticación automática (Bearer token)
/// - Manejo de errores centralizado
/// - Timeout configurable
/// - Headers comunes
/// 
/// Ejemplo de uso:
/// ```dart
/// final apiClient = ApiClient();
/// 
/// // GET request
/// final response = await apiClient.get('/vehicles/my-vehicles');
/// 
/// // POST request con body
/// final response = await apiClient.post(
///   '/service-requests',
///   body: {'vehicleId': 1, 'description': '...'},
/// );
/// ```
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  
  factory ApiClient() => _instance;
  
  ApiClient._internal();

  final http.Client _client = http.Client();
  final SecureStorageService _storage = SecureStorageService();

  /// Headers base para todas las peticiones
  Map<String, String> get _baseHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Construye la URL completa para un endpoint
  Uri _buildUri(String endpoint, {Map<String, dynamic>? queryParams}) {
    final baseUrl = ApiConstants.baseUrl;
    final fullUrl = endpoint.startsWith('/') ? '$baseUrl$endpoint' : '$baseUrl/$endpoint';
    
    if (queryParams != null && queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .where((e) => e.value != null)
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      return Uri.parse('$fullUrl?$queryString');
    }
    
    return Uri.parse(fullUrl);
  }

  /// Obtiene headers con autenticación
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.getToken();
    return {
      ..._baseHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Procesa la respuesta y maneja errores
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return response.body;
      }
    } else {
      throw ApiException.fromResponse(response);
    }
  }

  /// Realiza una petición GET
  /// 
  /// [endpoint] - Endpoint relativo (ej: '/vehicles/my-vehicles')
  /// [queryParams] - Parámetros de query opcionales
  /// [requiresAuth] - Si requiere autenticación (default: true)
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams: queryParams);
      final headers = requiresAuth ? await _getAuthHeaders() : _baseHeaders;
      
      final response = await _client
          .get(uri, headers: headers)
          .timeout(ApiConstants.connectionTimeout);
      
      return _processResponse(response);
    } on SocketException {
      throw ApiException.networkError();
    } on TimeoutException {
      throw ApiException.timeout();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.unknown(e.toString());
    }
  }

  /// Realiza una petición POST
  /// 
  /// [endpoint] - Endpoint relativo
  /// [body] - Cuerpo de la petición (será serializado a JSON)
  /// [requiresAuth] - Si requiere autenticación (default: true)
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = requiresAuth ? await _getAuthHeaders() : _baseHeaders;
      
      final response = await _client
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);
      
      return _processResponse(response);
    } on SocketException {
      throw ApiException.networkError();
    } on TimeoutException {
      throw ApiException.timeout();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.unknown(e.toString());
    }
  }

  /// Realiza una petición PUT
  /// 
  /// [endpoint] - Endpoint relativo
  /// [body] - Cuerpo de la petición
  /// [requiresAuth] - Si requiere autenticación (default: true)
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = requiresAuth ? await _getAuthHeaders() : _baseHeaders;
      
      final response = await _client
          .put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);
      
      return _processResponse(response);
    } on SocketException {
      throw ApiException.networkError();
    } on TimeoutException {
      throw ApiException.timeout();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.unknown(e.toString());
    }
  }

  /// Realiza una petición DELETE
  /// 
  /// [endpoint] - Endpoint relativo
  /// [requiresAuth] - Si requiere autenticación (default: true)
  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = requiresAuth ? await _getAuthHeaders() : _baseHeaders;
      
      final response = await _client
          .delete(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);
      
      return _processResponse(response);
    } on SocketException {
      throw ApiException.networkError();
    } on TimeoutException {
      throw ApiException.timeout();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.unknown(e.toString());
    }
  }

  /// Realiza una petición PATCH
  /// 
  /// [endpoint] - Endpoint relativo
  /// [body] - Cuerpo de la petición
  /// [requiresAuth] - Si requiere autenticación (default: true)
  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = requiresAuth ? await _getAuthHeaders() : _baseHeaders;
      
      final response = await _client
          .patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectionTimeout);
      
      return _processResponse(response);
    } on SocketException {
      throw ApiException.networkError();
    } on TimeoutException {
      throw ApiException.timeout();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.unknown(e.toString());
    }
  }

  /// Sube un archivo usando multipart request
  /// 
  /// [endpoint] - Endpoint relativo
  /// [file] - Archivo a subir
  /// [fieldName] - Nombre del campo (default: 'file')
  /// [additionalFields] - Campos adicionales
  Future<dynamic> uploadFile(
    String endpoint, {
    required File file,
    String fieldName = 'file',
    Map<String, String>? additionalFields,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final request = http.MultipartRequest('POST', uri);
      
      // Agregar headers
      if (requiresAuth) {
        final token = await _storage.getToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }
      
      // Agregar archivo
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      
      // Agregar campos adicionales
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }
      
      final streamedResponse = await request.send().timeout(ApiConstants.connectionTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      return _processResponse(response);
    } on SocketException {
      throw ApiException.networkError();
    } on TimeoutException {
      throw ApiException.timeout();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.unknown(e.toString());
    }
  }

  /// Cierra el cliente HTTP
  void dispose() {
    _client.close();
  }
}

