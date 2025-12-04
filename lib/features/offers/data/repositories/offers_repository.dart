import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../models/models.dart';

/// Repositorio para gestionar ofertas de talleres
class OffersRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storageService;

  OffersRepository({ApiClient? apiClient, SecureStorageService? storageService})
    : _apiClient = apiClient ?? ApiClient(),
      _storageService = storageService ?? SecureStorageService();

  /// Obtiene todas las ofertas del usuario autenticado
  Future<List<OfferModel>> getMyOffers({String? status}) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      var uri = Uri.parse(ApiConstants.myOffersFullUrl);

      // Agregar parámetro de status si se proporciona
      if (status != null && status.isNotEmpty) {
        uri = uri.replace(queryParameters: {'status': status});
      }

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }

        final List<dynamic> offersJson =
            json.decode(response.body) as List<dynamic>;
        return offersJson
            .map((json) => OfferModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 204) {
        return [];
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicie sesión nuevamente');
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al obtener ofertas: ${_parseError(e)}');
    }
  }

  /// Obtiene las ofertas para una solicitud de servicio específica (legacy)
  /// Filtra las ofertas obtenidas por myOffers
  Future<List<OfferModel>> getOffersForRequest(int requestId) async {
    try {
      final allOffers = await getMyOffers();
      return allOffers
          .where((offer) => offer.serviceRequestId == requestId)
          .toList();
    } catch (e) {
      throw Exception('Error al obtener ofertas: ${_parseError(e)}');
    }
  }

  /// Acepta una oferta (esto crea un booking automáticamente)
  Future<void> acceptOffer(int offerId) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await http
          .post(
            Uri.parse(ApiConstants.acceptOfferFullUrl(offerId)),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({}),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else if (response.statusCode == 404) {
        throw Exception('Oferta no encontrada');
      } else {
        final errorBody = response.body.isNotEmpty
            ? json.decode(response.body)
            : null;
        final message = errorBody?['message'] ?? 'Error al aceptar oferta';
        throw Exception(message);
      }
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al aceptar oferta: ${_parseError(e)}');
    }
  }

  /// Rechaza una oferta
  Future<void> rejectOffer(int offerId) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await http
          .post(
            Uri.parse(ApiConstants.rejectOfferFullUrl(offerId)),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode({}),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else if (response.statusCode == 404) {
        throw Exception('Oferta no encontrada');
      } else {
        final errorBody = response.body.isNotEmpty
            ? json.decode(response.body)
            : null;
        final message = errorBody?['message'] ?? 'Error al rechazar oferta';
        throw Exception(message);
      }
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      if (e is Exception) rethrow;
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
      throw Exception(
        'Error al obtener información del taller: ${_parseError(e)}',
      );
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
    final messageMatch = RegExp(
      r'"message"\s*:\s*"([^"]+)"',
    ).firstMatch(errorStr);
    if (messageMatch != null) {
      return messageMatch.group(1) ?? errorStr;
    }

    return errorStr;
  }
}
