import 'dart:async';
import 'dart:io';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_client.dart';
import '../models/models.dart';

/// Respuesta paginada de bookings
class PaginatedBookingsResponse {
  final List<ServiceBookingModel> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool isFirst;
  final bool isLast;

  PaginatedBookingsResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.isFirst,
    required this.isLast,
  });

  factory PaginatedBookingsResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedBookingsResponse(
      content: (json['content'] as List<dynamic>)
          .map((e) => ServiceBookingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      currentPage: json['number'] as int,
      pageSize: json['size'] as int,
      isFirst: json['first'] as bool,
      isLast: json['last'] as bool,
    );
  }
}

/// Repositorio para gestionar reservas de servicio
class BookingsRepository {
  final ApiClient _apiClient;

  BookingsRepository({ApiClient? apiClient}) 
      : _apiClient = apiClient ?? ApiClient();

  /// Obtener mis reservas de servicio (paginado)
  Future<PaginatedBookingsResponse> getMyBookings({
    int page = 0,
    int size = 20,
    String? status,
    String? sort,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final response = await _apiClient.get(
        '${ApiConstants.myBookingsEndpoint}?$queryString',
      );

      if (response == null) {
        return PaginatedBookingsResponse(
          content: [],
          totalElements: 0,
          totalPages: 0,
          currentPage: 0,
          pageSize: size,
          isFirst: true,
          isLast: true,
        );
      }

      return PaginatedBookingsResponse.fromJson(response as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Error de conexión. Verifica tu conexión a internet.');
    } on TimeoutException {
      throw Exception('La solicitud tardó demasiado. Intenta de nuevo.');
    } catch (e) {
      throw Exception('Error al obtener reservas: ${_parseErrorMessage(e)}');
    }
  }

  /// Obtener detalle de una reserva por ID
  Future<ServiceBookingModel> getBookingById(int id) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.bookingByIdEndpoint(id),
      );

      if (response == null) {
        throw Exception('No se encontró la reserva');
      }

      return ServiceBookingModel.fromJson(response as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Error de conexión. Verifica tu conexión a internet.');
    } on TimeoutException {
      throw Exception('La solicitud tardó demasiado. Intenta de nuevo.');
    } catch (e) {
      throw Exception('Error al obtener la reserva: ${_parseErrorMessage(e)}');
    }
  }

  /// Confirmar recogida del vehículo
  Future<ServiceBookingModel> confirmPickup(int id) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.confirmPickupEndpoint(id),
        body: {},
      );

      if (response == null) {
        throw Exception('Error al confirmar la recogida');
      }

      return ServiceBookingModel.fromJson(response as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Error de conexión. Verifica tu conexión a internet.');
    } on TimeoutException {
      throw Exception('La solicitud tardó demasiado. Intenta de nuevo.');
    } catch (e) {
      throw Exception('Error al confirmar recogida: ${_parseErrorMessage(e)}');
    }
  }

  /// Cancelar una reserva
  Future<ServiceBookingModel> cancelBooking(int id, {String? reason}) async {
    try {
      final body = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      final response = await _apiClient.post(
        ApiConstants.cancelBookingEndpoint(id),
        body: body,
      );

      if (response == null) {
        throw Exception('Error al cancelar la reserva');
      }

      return ServiceBookingModel.fromJson(response as Map<String, dynamic>);
    } on SocketException {
      throw Exception('Error de conexión. Verifica tu conexión a internet.');
    } on TimeoutException {
      throw Exception('La solicitud tardó demasiado. Intenta de nuevo.');
    } catch (e) {
      throw Exception('Error al cancelar reserva: ${_parseErrorMessage(e)}');
    }
  }

  /// Parsear mensaje de error
  String _parseErrorMessage(dynamic error) {
    final errorString = error.toString();
    
    // Si ya es un mensaje de Exception limpio
    if (errorString.startsWith('Exception: ')) {
      return errorString.replaceFirst('Exception: ', '');
    }
    
    // Intentar extraer mensaje del body si es un error HTTP
    if (errorString.contains('message')) {
      final messageMatch = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(errorString);
      if (messageMatch != null) {
        return messageMatch.group(1) ?? 'Error desconocido';
      }
    }
    
    return 'Error desconocido';
  }
}

