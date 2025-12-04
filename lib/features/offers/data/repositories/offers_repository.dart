import 'dart:async';
import 'dart:io';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_client.dart';
import '../models/models.dart';

/// Repositorio para gestionar ofertas de talleres
class OffersRepository {
  final ApiClient _apiClient;

  OffersRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Obtiene las ofertas para una solicitud de servicio
  Future<List<OfferModel>> getOffersForRequest(int requestId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.offersForRequest(requestId),
      );

      if (response == null) {
        return [];
      }

      final List<dynamic> offersJson = response as List<dynamic>;
      return offersJson
          .map((json) => OfferModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error al obtener ofertas: ${_parseError(e)}');
    }
  }

  /// Acepta una oferta (esto crea un booking automáticamente)
  Future<void> acceptOffer(int offerId) async {
    try {
      await _apiClient.post(
        ApiConstants.acceptOffer(offerId),
        body: {},
      );
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error al aceptar oferta: ${_parseError(e)}');
    }
  }

  /// Rechaza una oferta
  Future<void> rejectOffer(int offerId) async {
    try {
      await _apiClient.post(
        ApiConstants.rejectOffer(offerId),
        body: {},
      );
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error al rechazar oferta: ${_parseError(e)}');
    }
  }

  /// Obtiene información pública de un taller
  Future<WorkshopPublicModel> getWorkshopPublicInfo(int workshopId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.workshopPublic(workshopId),
      );

      if (response == null) {
        throw Exception('Taller no encontrado');
      }

      return WorkshopPublicModel.fromJson(response as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error al obtener información del taller: ${_parseError(e)}');
    }
  }

  /// Obtiene el trust score de un taller
  Future<TrustScore> getWorkshopTrustScore(int workshopId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.workshopTrustScore(workshopId),
      );

      if (response == null) {
        throw Exception('Trust score no encontrado');
      }

      return TrustScore.fromJson(response as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error al obtener trust score: ${_parseError(e)}');
    }
  }

  /// Parsea el mensaje de error
  String _parseError(dynamic error) {
    final errorStr = error.toString();
    
    // Remover prefijos comunes
    if (errorStr.startsWith('Exception: ')) {
      return errorStr.replaceFirst('Exception: ', '');
    }
    
    // Buscar mensaje en formato JSON
    final messageMatch = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(errorStr);
    if (messageMatch != null) {
      return messageMatch.group(1) ?? errorStr;
    }
    
    return errorStr;
  }
}

