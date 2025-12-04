import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../models/models.dart';

/// Repositorio para gestión de solicitudes de servicio
class ServiceRequestRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storageService;

  ServiceRequestRepository({
    ApiClient? apiClient,
    SecureStorageService? storageService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _storageService = storageService ?? SecureStorageService();

  // ==================== CATÁLOGO DE SERVICIOS ====================

  /// Obtiene el catálogo completo de servicios
  /// 
  /// [category] - Filtro opcional por categoría
  Future<List<ServiceCatalogItem>> getServiceCatalog({String? category}) async {
    try {
      final queryParams = category != null ? {'category': category} : null;
      
      final response = await _apiClient.get(
        ApiConstants.servicesEndpoint,
        queryParams: queryParams,
        requiresAuth: false, // Endpoint público
      );

      if (response == null) {
        return [];
      }

      final List<dynamic> servicesList = response as List<dynamic>;
      return servicesList
          .map((json) => ServiceCatalogItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener catálogo de servicios: $e');
    }
  }

  /// Obtiene todas las categorías de servicios disponibles
  Future<List<ServiceCategoryModel>> getServiceCategories() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.serviceCategoriesEndpoint,
        requiresAuth: false, // Endpoint público
      );

      if (response == null) {
        return [];
      }

      final List<dynamic> categoriesList = response as List<dynamic>;
      return categoriesList
          .map((json) => ServiceCategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  // ==================== SOLICITUDES DE SERVICIO ====================

  /// Obtiene las solicitudes de servicio del usuario
  /// 
  /// [status] - Filtro opcional por estado (PENDING, MATCHED, CANCELLED)
  Future<List<ServiceRequestModel>> getMyServiceRequests({String? status}) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final uri = Uri.parse(ApiConstants.serviceRequestsFullUrl);
      final queryParams = <String, String>{};
      if (status != null) {
        queryParams['status'] = status;
      }
      
      final finalUri = queryParams.isNotEmpty 
          ? uri.replace(queryParameters: queryParams)
          : uri;

      final response = await http.get(
        finalUri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> requestsList = json.decode(response.body) as List<dynamic>;
        return requestsList
            .map((json) => ServiceRequestModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 204) {
        return [];
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicie sesión nuevamente');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } catch (e) {
      throw Exception('Error al obtener solicitudes: $e');
    }
  }

  /// Obtiene una solicitud de servicio por su ID
  Future<ServiceRequestModel> getServiceRequestById(int id) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await http.get(
        Uri.parse(ApiConstants.serviceRequestByIdFullUrl(id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        return ServiceRequestModel.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else if (response.statusCode == 404) {
        throw Exception('Solicitud no encontrada');
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } catch (e) {
      throw Exception('Error al obtener solicitud: $e');
    }
  }

  /// Crea una nueva solicitud de servicio
  Future<ServiceRequestModel> createServiceRequest(CreateServiceRequest request) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      if (!request.isValid) {
        throw Exception('Datos de solicitud incompletos');
      }

      final response = await http.post(
        Uri.parse(ApiConstants.serviceRequestsFullUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(request.toJson()),
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ServiceRequestModel.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        final message = errorBody['message'] ?? 'Datos de solicitud inválidos';
        throw Exception(message);
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al crear solicitud: $e');
    }
  }

  /// Cancela una solicitud de servicio
  Future<void> cancelServiceRequest(int id) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) {
        throw Exception('No se encontró token de autenticación');
      }

      final response = await http.delete(
        Uri.parse(ApiConstants.serviceRequestByIdFullUrl(id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Solicitud no encontrada');
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        final message = errorBody['message'] ?? 'No se puede cancelar la solicitud';
        throw Exception(message);
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al cancelar solicitud: $e');
    }
  }
}

