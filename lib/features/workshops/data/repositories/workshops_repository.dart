import 'dart:async';
import 'dart:io';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_client.dart';
import '../models/models.dart';

/// Parámetros de búsqueda de talleres
class WorkshopSearchParams {
  final double? latitude;
  final double? longitude;
  final int radiusKm;
  final List<String>? services;
  final List<String>? tags;
  final double? minRating;

  const WorkshopSearchParams({
    this.latitude,
    this.longitude,
    this.radiusKm = 50,
    this.services,
    this.tags,
    this.minRating,
  });

  /// Convertir a query string
  String toQueryString() {
    final params = <String, String>{};
    
    if (latitude != null) {
      params['latitude'] = latitude.toString();
    }
    if (longitude != null) {
      params['longitude'] = longitude.toString();
    }
    params['radiusKm'] = radiusKm.toString();
    
    if (services != null && services!.isNotEmpty) {
      params['services'] = services!.join(',');
    }
    if (tags != null && tags!.isNotEmpty) {
      params['tags'] = tags!.join(',');
    }
    if (minRating != null) {
      params['minRating'] = minRating.toString();
    }
    
    if (params.isEmpty) return '';
    return '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
  }
}

/// Repositorio para gestionar la búsqueda y consulta de talleres
class WorkshopsRepository {
  final ApiClient _apiClient;

  WorkshopsRepository({ApiClient? apiClient}) 
      : _apiClient = apiClient ?? ApiClient();

  /// Buscar talleres con filtros
  Future<List<WorkshopSearchResultModel>> searchWorkshops(
      WorkshopSearchParams params) async {
    try {
      final queryString = params.toQueryString();
      final response = await _apiClient.get(
        '${ApiConstants.workshopSearchEndpoint}$queryString',
      );

      if (response == null) {
        return [];
      }

      return (response as List)
          .map((e) => WorkshopSearchResultModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception('Error de conexión. Verifica tu conexión a internet.');
    } on TimeoutException {
      throw Exception('La solicitud tardó demasiado. Intenta de nuevo.');
    } catch (e) {
      throw Exception('Error al buscar talleres: ${_parseErrorMessage(e)}');
    }
  }

  /// Obtener perfil público de un taller
  Future<WorkshopProfileModel> getWorkshopProfile(int workshopId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.workshopPublicEndpoint(workshopId),
      );

      if (response == null) {
        throw Exception('No se encontró el taller');
      }

      return WorkshopProfileModel.fromJson(response as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Error de conexión. Verifica tu conexión a internet.');
    } on TimeoutException {
      throw Exception('La solicitud tardó demasiado. Intenta de nuevo.');
    } catch (e) {
      throw Exception('Error al obtener taller: ${_parseErrorMessage(e)}');
    }
  }

  /// Obtener servicios de un taller
  Future<List<ServiceTemplateModel>> getWorkshopServices(int workshopId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.workshopServicesEndpoint(workshopId),
      );

      if (response == null) {
        return [];
      }

      return (response as List)
          .map((e) => ServiceTemplateModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception('Error de conexión. Verifica tu conexión a internet.');
    } on TimeoutException {
      throw Exception('La solicitud tardó demasiado. Intenta de nuevo.');
    } catch (e) {
      throw Exception('Error al obtener servicios: ${_parseErrorMessage(e)}');
    }
  }

  /// Parsear mensaje de error
  String _parseErrorMessage(dynamic error) {
    final errorString = error.toString();
    
    if (errorString.startsWith('Exception: ')) {
      return errorString.replaceFirst('Exception: ', '');
    }
    
    if (errorString.contains('message')) {
      final messageMatch = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(errorString);
      if (messageMatch != null) {
        return messageMatch.group(1) ?? 'Error desconocido';
      }
    }
    
    return 'Error desconocido';
  }
}


