import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../models/models.dart';

/// Respuesta paginada de reviews
class PaginatedReviewsResponse {
  final List<ReviewModel> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool isFirst;
  final bool isLast;

  PaginatedReviewsResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.isFirst,
    required this.isLast,
  });

  factory PaginatedReviewsResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedReviewsResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
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

/// Repositorio para gestionar reviews
class ReviewsRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storageService;

  ReviewsRepository({
    ApiClient? apiClient,
    SecureStorageService? storageService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _storageService = storageService ?? SecureStorageService();

  /// Crea una nueva review
  Future<ReviewModel> createReview(CreateReviewRequest request) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await http.post(
        Uri.parse(ApiConstants.reviewsCreateUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        return ReviewModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }

    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error al crear reseña: ${_parseError(e)}');
    }
  }

  /// Obtiene las reviews de un taller
  Future<PaginatedReviewsResponse> getWorkshopReviews(
    int workshopId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await http.get(
        Uri.parse(ApiConstants.reviewsReceivedWorkshopsUrl(workshopId, page: page, size: size)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return PaginatedReviewsResponse(
            content: [],
            totalElements: 0,
            totalPages: 0,
            currentPage: 0,
            pageSize: size,
            isFirst: true,
            isLast: true,
          );
        }
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        return PaginatedReviewsResponse.fromJson(responseData);
      } else if (response.statusCode == 204) {
        return PaginatedReviewsResponse(
          content: [],
          totalElements: 0,
          totalPages: 0,
          currentPage: 0,
          pageSize: size,
          isFirst: true,
          isLast: true,
        );
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error al obtener reseñas: ${_parseError(e)}');
    }
  }

  /// Verifica si la ventana de review está abierta para un booking
  Future<ReviewWindowStatusModel> getReviewWindowStatus(int bookingId) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await http.get(
        Uri.parse(ApiConstants.reviewsWindowStatusUrl(bookingId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return const ReviewWindowStatusModel(
            canReview: false,
            daysRemaining: 0,
            hasReviewed: false,
          );
        }
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        return ReviewWindowStatusModel.fromJson(responseData);
      } else if (response.statusCode == 204 || response.statusCode == 404) {
        return const ReviewWindowStatusModel(
          canReview: false,
          daysRemaining: 0,
          hasReviewed: false,
        );
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } catch (e) {
      throw Exception('Error al verificar estado de reseña: ${_parseError(e)}');
    }
  }

  /// Parsea el mensaje de error
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



