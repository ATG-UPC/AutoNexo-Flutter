import 'dart:async';
import 'dart:io';

import '../../../../core/services/api_client.dart';
import '../models/models.dart';

/// Respuesta paginada de mantenimientos
class PaginatedMaintenancesResponse {
  final List<MaintenanceModel> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool isFirst;
  final bool isLast;

  PaginatedMaintenancesResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.isFirst,
    required this.isLast,
  });

  factory PaginatedMaintenancesResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedMaintenancesResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => MaintenanceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['number'] as int? ?? 0,
      pageSize: json['size'] as int? ?? 20,
      isFirst: json['first'] as bool? ?? true,
      isLast: json['last'] as bool? ?? true,
    );
  }
}

/// Repositorio para gestionar mantenimientos
class MaintenancesRepository {
  final ApiClient _apiClient;

  MaintenancesRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Obtiene el historial de mantenimientos de un vehículo
  Future<PaginatedMaintenancesResponse> getVehicleMaintenances(
    int vehicleId, {
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };
      
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final response = await _apiClient.get(
        '/maintenances/vehicle/$vehicleId?$queryString',
      );

      if (response == null) {
        return PaginatedMaintenancesResponse(
          content: [],
          totalElements: 0,
          totalPages: 0,
          currentPage: 0,
          pageSize: size,
          isFirst: true,
          isLast: true,
        );
      }

      return PaginatedMaintenancesResponse.fromJson(response as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error al obtener mantenimientos: ${_parseError(e)}');
    }
  }

  /// Obtiene un mantenimiento por ID
  Future<MaintenanceModel> getMaintenanceById(int id) async {
    try {
      final response = await _apiClient.get('/maintenances/$id');

      if (response == null) {
        throw Exception('Mantenimiento no encontrado');
      }

      return MaintenanceModel.fromJson(response as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error al obtener mantenimiento: ${_parseError(e)}');
    }
  }

  /// Crea un mantenimiento manual
  Future<MaintenanceModel> createManualMaintenance(CreateManualMaintenanceRequest request) async {
    try {
      final response = await _apiClient.post(
        '/maintenances/manual',
        body: request.toJson(),
      );

      if (response == null) {
        throw Exception('Error al crear mantenimiento');
      }

      return MaintenanceModel.fromJson(response as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error al crear mantenimiento: ${_parseError(e)}');
    }
  }

  /// Confirma un mantenimiento creado por taller
  Future<MaintenanceModel> confirmMaintenance(int id) async {
    try {
      final response = await _apiClient.post(
        '/maintenances/$id/confirm',
        body: {},
      );

      if (response == null) {
        throw Exception('Error al confirmar mantenimiento');
      }

      return MaintenanceModel.fromJson(response as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error al confirmar mantenimiento: ${_parseError(e)}');
    }
  }

  /// Rechaza un mantenimiento
  Future<MaintenanceModel> rejectMaintenance(int id) async {
    try {
      final response = await _apiClient.post(
        '/maintenances/$id/reject',
        body: {},
      );

      if (response == null) {
        throw Exception('Error al rechazar mantenimiento');
      }

      return MaintenanceModel.fromJson(response as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error al rechazar mantenimiento: ${_parseError(e)}');
    }
  }

  String _parseError(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.startsWith('Exception: ')) {
      return errorStr.replaceFirst('Exception: ', '');
    }

    final messageMatch = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(errorStr);
    if (messageMatch != null) {
      return messageMatch.group(1) ?? errorStr;
    }

    return errorStr;
  }
}

