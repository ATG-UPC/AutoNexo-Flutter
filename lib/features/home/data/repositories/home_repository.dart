import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/models.dart';

/// Repositorio para datos del home
class HomeRepository {
  final http.Client _httpClient;
  final FlutterSecureStorage _secureStorage;

  HomeRepository({http.Client? httpClient, FlutterSecureStorage? secureStorage})
    : _httpClient = httpClient ?? http.Client(),
      _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Obtener token de autenticación
  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  /// Obtener cita actual del usuario
  Future<AppointmentModel?> getCurrentAppointment() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AppointmentModel.fromJson(data);
      } else if (response.statusCode == 404) {
        // No hay cita actual
        return null;
      } else {
        throw Exception('Error al obtener cita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener cita actual: $e');
    }
  }

  /// Obtener horario/calendario
  Future<List<ScheduleSlotModel>> getSchedule({
    required String month,
    required String year,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
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

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((slot) => ScheduleSlotModel.fromJson(slot)).toList();
      } else {
        throw Exception('Error al obtener horario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener horario: $e');
    }
  }
}
