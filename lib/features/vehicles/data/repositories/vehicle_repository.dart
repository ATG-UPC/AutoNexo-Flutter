import 'dart:io';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_client.dart';
import '../models/models.dart';

/// Repositorio para gestión de vehículos
class VehicleRepository {
  final ApiClient _apiClient;

  VehicleRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Obtiene la lista de vehículos del usuario actual
  Future<List<VehicleModel>> getMyVehicles() async {
    try {
      final response = await _apiClient.get(ApiConstants.myVehiclesEndpoint);

      if (response == null) {
        return [];
      }

      final List<dynamic> vehiclesList = response as List<dynamic>;
      return vehiclesList
          .map((json) => VehicleModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener vehículos: $e');
    }
  }

  /// Obtiene un vehículo por su ID
  Future<VehicleModel> getVehicleById(int id) async {
    try {
      final response =
          await _apiClient.get(ApiConstants.vehicleByIdEndpoint(id));

      return VehicleModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al obtener vehículo: $e');
    }
  }

  /// Crea un nuevo vehículo
  Future<VehicleModel> createVehicle(CreateVehicleRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.vehiclesEndpoint,
        body: request.toJson(),
      );

      return VehicleModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al crear vehículo: $e');
    }
  }

  /// Actualiza un vehículo existente
  Future<VehicleModel> updateVehicle(
      int id, UpdateVehicleRequest request) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.vehicleByIdEndpoint(id),
        body: request.toJson(),
      );

      return VehicleModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al actualizar vehículo: $e');
    }
  }

  /// Desactiva (elimina lógicamente) un vehículo
  Future<void> deleteVehicle(int id) async {
    try {
      await _apiClient.delete(ApiConstants.vehicleByIdEndpoint(id));
    } catch (e) {
      throw Exception('Error al eliminar vehículo: $e');
    }
  }

  /// Obtiene el catálogo de marcas de vehículos
  Future<List<BrandModel>> getBrands({bool popularOnly = false}) async {
    try {
      final queryParams = popularOnly ? {'popularOnly': 'true'} : null;

      final response = await _apiClient.get(
        ApiConstants.brandsEndpoint,
        queryParams: queryParams,
        requiresAuth: false, // Endpoint público
      );

      if (response == null) {
        return [];
      }

      final List<dynamic> brandsList = response as List<dynamic>;
      return brandsList
          .map((json) => BrandModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener marcas: $e');
    }
  }

  /// Obtiene el nombre de una marca por su ID
  Future<String?> getBrandName(int brandId, List<BrandModel> brands) async {
    try {
      final brand = brands.firstWhere(
        (b) => b.id == brandId,
        orElse: () => const BrandModel(id: 0, name: 'Desconocido'),
      );
      return brand.name;
    } catch (e) {
      return null;
    }
  }

  // ==================== IMÁGENES ====================

  /// Sube una imagen para un vehículo
  /// 
  /// [vehicleId] - ID del vehículo
  /// [imageFile] - Archivo de imagen a subir
  /// 
  /// Retorna la URL de la imagen subida
  Future<String> uploadVehicleImage(int vehicleId, File imageFile) async {
    try {
      final response = await _apiClient.uploadFile(
        ApiConstants.vehicleImagesEndpoint(vehicleId),
        file: imageFile,
        fieldName: 'file',
      );

      // El backend retorna { "imageUrl": "https://..." }
      if (response is Map<String, dynamic> && response.containsKey('imageUrl')) {
        return response['imageUrl'] as String;
      }
      
      throw Exception('Respuesta inesperada del servidor');
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  // ==================== USUARIOS AUTORIZADOS ====================

  /// Obtiene la lista de usuarios autorizados de un vehículo
  /// 
  /// [vehicleId] - ID del vehículo
  /// Retorna lista de usuarios con acceso al vehículo (incluye propietario principal)
  Future<List<AuthorizedUserModel>> getAuthorizedUsers(int vehicleId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.vehicleAuthorizedUsersEndpoint(vehicleId),
      );

      if (response == null) {
        return [];
      }

      final List<dynamic> usersList = response as List<dynamic>;
      return usersList
          .map((json) => AuthorizedUserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios autorizados: $e');
    }
  }

  /// Agrega un usuario autorizado (propietario secundario) a un vehículo
  /// 
  /// [vehicleId] - ID del vehículo
  /// [email] - Email del usuario a agregar
  Future<void> addAuthorizedUser(int vehicleId, String email) async {
    try {
      await _apiClient.post(
        ApiConstants.vehicleAuthorizedUsersEndpoint(vehicleId),
        body: {'email': email},
      );
    } catch (e) {
      throw Exception('Error al agregar usuario autorizado: $e');
    }
  }

  /// Elimina un usuario autorizado de un vehículo
  /// 
  /// [vehicleId] - ID del vehículo
  /// [userId] - ID del usuario a eliminar
  Future<void> removeAuthorizedUser(int vehicleId, int userId) async {
    try {
      await _apiClient.delete(
        ApiConstants.removeAuthorizedUserEndpoint(vehicleId, userId),
      );
    } catch (e) {
      throw Exception('Error al eliminar usuario autorizado: $e');
    }
  }

  /// Transfiere la propiedad de un vehículo a otro usuario
  /// 
  /// [vehicleId] - ID del vehículo
  /// [newOwnerEmail] - Email del nuevo propietario
  Future<void> transferVehicle(int vehicleId, String newOwnerEmail) async {
    try {
      await _apiClient.put(
        ApiConstants.transferVehicleEndpoint(vehicleId),
        body: {'newOwnerEmail': newOwnerEmail},
      );
    } catch (e) {
      throw Exception('Error al transferir vehículo: $e');
    }
  }
}


