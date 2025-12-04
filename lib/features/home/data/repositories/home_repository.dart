import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../models/models.dart';

/// Repositorio para datos del home
class HomeRepository {
  final http.Client _httpClient;
  final SecureStorageService _storage;

  HomeRepository({http.Client? httpClient, SecureStorageService? storage})
    : _httpClient = httpClient ?? http.Client(),
      _storage = storage ?? SecureStorageService();

  /// Obtener token de autenticación
  Future<String?> _getToken() async {
    return await _storage.getToken();
  }

  /// Obtener cita actual/próxima del usuario
  /// 
  /// Respuestas:
  /// - 200 OK: Retorna la cita actual
  /// - 204 No Content: No hay citas próximas (retorna null)
  /// - 401 Unauthorized: Token inválido
  /// - 500 Internal Server Error: Error del servidor
  Future<AppointmentModel?> getCurrentAppointment() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay sesión activa. Por favor inicia sesión nuevamente.');
      }

      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.getCurrentAppointmentEndpoint}',
      );

      final response = await _httpClient
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConstants.connectionTimeout);

      switch (response.statusCode) {
        case 200:
          // Cita encontrada
          final data = jsonDecode(response.body);
          return AppointmentModel.fromJson(data);
        
        case 204:
          // Sin contenido - no hay cita actual (esto es normal)
          return null;
        
        case 401:
          throw Exception('Tu sesión ha expirado. Por favor inicia sesión nuevamente.');
        
        case 403:
          throw Exception('No tienes permisos para acceder a esta información.');
        
        case 500:
          throw Exception('Error en el servidor. Intenta más tarde.');
        
        default:
          throw Exception('Error inesperado (${response.statusCode}). Intenta nuevamente.');
      }
    } on SocketException {
      throw Exception('Sin conexión a internet. Verifica tu conexión.');
    } on FormatException {
      throw Exception('Error al procesar la respuesta del servidor.');
    } on http.ClientException {
      throw Exception('Error de conexión con el servidor.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener cita actual: $e');
    }
  }

  /// Obtener horario/calendario de citas del mes
  /// 
  /// Parámetros:
  /// - month: Número del mes (1-12)
  /// - year: Año (ej: 2025)
  /// 
  /// Respuestas:
  /// - 200 OK: Retorna lista de citas (puede estar vacía)
  /// - 400 Bad Request: Parámetros inválidos
  /// - 401 Unauthorized: Token inválido
  Future<List<ScheduleSlotModel>> getSchedule({
    required String month,
    required String year,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay sesión activa. Por favor inicia sesión nuevamente.');
      }

      final url = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.getScheduleEndpoint}?month=$month&year=$year',
      );

      final response = await _httpClient
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConstants.connectionTimeout);

      switch (response.statusCode) {
        case 200:
          // Lista de citas (puede estar vacía)
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((slot) => ScheduleSlotModel.fromJson(slot)).toList();
        
        case 400:
          final errorBody = _parseErrorBody(response.body);
          throw Exception(errorBody ?? 'Parámetros de fecha inválidos.');
        
        case 401:
          throw Exception('Tu sesión ha expirado. Por favor inicia sesión nuevamente.');
        
        case 403:
          throw Exception('No tienes permisos para acceder al calendario.');
        
        case 500:
          throw Exception('Error en el servidor. Intenta más tarde.');
        
        default:
          throw Exception('Error inesperado (${response.statusCode}). Intenta nuevamente.');
      }
    } on SocketException {
      throw Exception('Sin conexión a internet. Verifica tu conexión.');
    } on FormatException {
      throw Exception('Error al procesar la respuesta del servidor.');
    } on http.ClientException {
      throw Exception('Error de conexión con el servidor.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener calendario: $e');
    }
  }

  /// Intentar parsear mensaje de error del body de respuesta
  String? _parseErrorBody(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        return data['message'] as String?;
      }
      if (data is String) {
        return data;
      }
    } catch (_) {
      // Si no se puede parsear, devolver el body como está si es corto
      if (body.length < 200) {
        return body;
      }
    }
    return null;
  }
}
