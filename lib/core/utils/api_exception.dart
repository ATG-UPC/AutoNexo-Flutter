import 'dart:convert';
import 'package:http/http.dart' as http;

/// Excepción personalizada para errores de API.
/// 
/// Maneja diferentes tipos de errores del backend y proporciona
/// mensajes de error legibles para el usuario.
/// 
/// Ejemplo de uso:
/// ```dart
/// try {
///   final response = await apiClient.post(...);
/// } on ApiException catch (e) {
///   if (e.isUnauthorized) {
///     // Redirigir a login
///   } else {
///     // Mostrar error
///     ErrorDialog.show(context: context, message: e.message);
///   }
/// }
/// ```
class ApiException implements Exception {
  /// Código de estado HTTP
  final int statusCode;
  
  /// Mensaje de error principal
  final String message;
  
  /// Errores de validación por campo
  final Map<String, String>? fieldErrors;
  
  /// Respuesta original del servidor (para debugging)
  final String? rawResponse;

  ApiException({
    required this.statusCode,
    required this.message,
    this.fieldErrors,
    this.rawResponse,
  });

  /// Crea una ApiException a partir de una respuesta HTTP
  factory ApiException.fromResponse(http.Response response) {
    try {
      // Intentar parsear como JSON
      final dynamic body;
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        // Si no es JSON, usar el body como mensaje directo
        return ApiException(
          statusCode: response.statusCode,
          message: response.body.isNotEmpty 
              ? response.body 
              : _getDefaultMessage(response.statusCode),
          rawResponse: response.body,
        );
      }
      
      // Si es un Map (objeto JSON)
      if (body is Map<String, dynamic>) {
        // Extraer errores de validación si existen
        Map<String, String>? fieldErrors;
        if (body.containsKey('errors') && body['errors'] is List) {
          final errors = body['errors'] as List;
          fieldErrors = {};
          for (final error in errors) {
            if (error is Map && error.containsKey('field') && error.containsKey('message')) {
              fieldErrors[error['field'] as String] = error['message'] as String;
            }
          }
        }
        
        return ApiException(
          statusCode: response.statusCode,
          message: body['message'] as String? ?? _getDefaultMessage(response.statusCode),
          fieldErrors: fieldErrors?.isNotEmpty == true ? fieldErrors : null,
          rawResponse: response.body,
        );
      }
      
      // Si es un String directo
      if (body is String && body.isNotEmpty) {
        return ApiException(
          statusCode: response.statusCode,
          message: body,
          rawResponse: response.body,
        );
      }
      
      // Fallback
      return ApiException(
        statusCode: response.statusCode,
        message: _getDefaultMessage(response.statusCode),
        rawResponse: response.body,
      );
    } catch (e) {
      // Si el body es un string plano (no JSON)
      if (response.body.isNotEmpty) {
        return ApiException(
          statusCode: response.statusCode,
          message: response.body,
          rawResponse: response.body,
        );
      }
      return ApiException(
        statusCode: response.statusCode,
        message: _getDefaultMessage(response.statusCode),
        rawResponse: response.body,
      );
    }
  }

  /// Crea una ApiException para errores de red
  factory ApiException.networkError([String? message]) {
    return ApiException(
      statusCode: 0,
      message: message ?? 'Error de conexión. Verifica tu conexión a internet.',
    );
  }

  /// Crea una ApiException para errores de timeout
  factory ApiException.timeout() {
    return ApiException(
      statusCode: 0,
      message: 'La solicitud tardó demasiado. Intenta de nuevo.',
    );
  }

  /// Crea una ApiException para errores desconocidos
  factory ApiException.unknown([String? message]) {
    return ApiException(
      statusCode: 0,
      message: message ?? 'Ocurrió un error inesperado. Intenta de nuevo.',
    );
  }

  /// Verifica si es error de autenticación (401)
  bool get isUnauthorized => statusCode == 401;
  
  /// Verifica si es error de permisos (403)
  bool get isForbidden => statusCode == 403;
  
  /// Verifica si es error de validación (400)
  bool get isValidationError => statusCode == 400;
  
  /// Verifica si es error de recurso no encontrado (404)
  bool get isNotFound => statusCode == 404;
  
  /// Verifica si es error de conflicto/regla de negocio (409)
  bool get isConflict => statusCode == 409;
  
  /// Verifica si es error del servidor (5xx)
  bool get isServerError => statusCode >= 500 && statusCode < 600;
  
  /// Verifica si es error de red
  bool get isNetworkError => statusCode == 0;

  /// Obtiene el mensaje de error para un campo específico
  String? getFieldError(String field) => fieldErrors?[field];

  /// Verifica si hay error en un campo específico
  bool hasFieldError(String field) => fieldErrors?.containsKey(field) ?? false;

  static String _getDefaultMessage(int statusCode) {
    return switch (statusCode) {
      400 => 'Los datos enviados no son válidos.',
      401 => 'Sesión expirada. Por favor, inicia sesión nuevamente.',
      403 => 'No tienes permiso para realizar esta acción.',
      404 => 'No se encontró el recurso solicitado.',
      409 => 'La operación no puede completarse debido a un conflicto.',
      422 => 'Los datos enviados no son válidos.',
      429 => 'Demasiadas solicitudes. Espera un momento.',
      500 => 'Error interno del servidor. Intenta más tarde.',
      502 => 'Servidor no disponible. Intenta más tarde.',
      503 => 'Servicio temporalmente no disponible.',
      _ => 'Ocurrió un error inesperado.',
    };
  }

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

