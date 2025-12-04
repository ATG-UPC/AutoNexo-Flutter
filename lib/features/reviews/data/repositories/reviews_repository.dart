import 'dart:async';
import 'dart:io';

import '../../../../core/services/api_client.dart';
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

  ReviewsRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Crea una nueva review
  Future<ReviewModel> createReview(CreateReviewRequest request) async {
    try {
      final response = await _apiClient.post(
        '/reviews',
        body: request.toJson(),
      );

      if (response == null) {
        throw Exception('Error al crear la reseña');
      }

      return ReviewModel.fromJson(response as Map<String, dynamic>);
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
      final response = await _apiClient.get(
        '/reviews/workshop/$workshopId?page=$page&size=$size',
      );

      if (response == null) {
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

      return PaginatedReviewsResponse.fromJson(response as Map<String, dynamic>);
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
      final response = await _apiClient.get(
        '/reviews/window-status/$bookingId',
      );

      if (response == null) {
        return const ReviewWindowStatusModel(
          canReview: false,
          daysRemaining: 0,
          hasReviewed: false,
        );
      }

      return ReviewWindowStatusModel.fromJson(response as Map<String, dynamic>);
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


