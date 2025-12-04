import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../data/models/models.dart';
import '../../data/repositories/vehicle_repository.dart';
import 'vehicles_state.dart';

/// Cubit para manejar el estado de vehículos
class VehiclesCubit extends Cubit<VehiclesState> {
  final VehicleRepository _vehicleRepository;
  bool _isLoading = false;

  VehiclesCubit(this._vehicleRepository) : super(const VehiclesState());

  /// Carga la lista de vehículos del usuario
  Future<void> loadVehicles({bool forceRefresh = false}) async {
    // Evitar cargas simultáneas
    if (_isLoading) return;
    
    // Si ya hay datos y no es refresh forzado, no recargar
    if (!forceRefresh && state.status == Status.success && state.vehicles.isNotEmpty) return;
    
    _isLoading = true;
    
    // Solo mostrar loading en la primera carga
    final isFirstLoad = state.status == Status.initial;
    if (isFirstLoad) {
      emit(state.copyWith(status: Status.loading));
    }

    try {
      final vehicles = await _vehicleRepository.getMyVehicles();

      // También cargar marcas si no están cargadas
      List<BrandModel> brands = state.brands;
      if (brands.isEmpty) {
        brands = await _vehicleRepository.getBrands();
      }

      // Enriquecer vehículos con nombre de marca
      final enrichedVehicles = vehicles.map((vehicle) {
        final brandName = brands
            .firstWhere(
              (b) => b.id == vehicle.brandId,
              orElse: () => const BrandModel(id: 0, name: 'Marca'),
            )
            .name;
        return vehicle.copyWith(brandName: brandName);
      }).toList();

      if (!isClosed) {
        emit(state.copyWith(
          status: Status.success,
          vehicles: enrichedVehicles,
          brands: brands,
          brandsStatus: Status.success,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        // Si ya hay datos, mantener success
        if (!isFirstLoad && state.vehicles.isNotEmpty) {
          emit(state.copyWith(
            errorMessage: e.toString().replaceAll('Exception: ', ''),
          ));
        } else {
          emit(state.copyWith(
            status: Status.failure,
            errorMessage: e.toString().replaceAll('Exception: ', ''),
          ));
        }
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Carga las marcas disponibles
  Future<void> loadBrands({bool popularOnly = false}) async {
    emit(state.copyWith(brandsStatus: Status.loading));

    try {
      final brands = await _vehicleRepository.getBrands(popularOnly: popularOnly);

      emit(state.copyWith(
        brands: brands,
        brandsStatus: Status.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        brandsStatus: Status.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  /// Selecciona un vehículo para ver detalle
  void selectVehicle(VehicleModel vehicle) {
    emit(state.copyWith(selectedVehicle: vehicle));
  }

  /// Limpia el vehículo seleccionado
  void clearSelectedVehicle() {
    emit(state.copyWith(clearSelectedVehicle: true));
  }

  /// Crea un nuevo vehículo
  Future<bool> createVehicle(CreateVehicleRequest request) async {
    emit(state.copyWith(status: Status.loading));

    try {
      final newVehicle = await _vehicleRepository.createVehicle(request);

      // Enriquecer con nombre de marca
      final brandName = state.getBrandName(newVehicle.brandId);
      final enrichedVehicle = newVehicle.copyWith(brandName: brandName);

      // Agregar a la lista
      final updatedVehicles = [...state.vehicles, enrichedVehicle];

      emit(state.copyWith(
        status: Status.success,
        vehicles: updatedVehicles,
        successMessage: 'Vehículo registrado exitosamente',
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  /// Actualiza un vehículo existente
  Future<bool> updateVehicle(int id, UpdateVehicleRequest request) async {
    emit(state.copyWith(status: Status.loading));

    try {
      final updatedVehicle =
          await _vehicleRepository.updateVehicle(id, request);

      // Enriquecer con nombre de marca
      final brandName = state.getBrandName(updatedVehicle.brandId);
      final enrichedVehicle = updatedVehicle.copyWith(brandName: brandName);

      // Actualizar en la lista
      final updatedVehicles = state.vehicles.map((v) {
        return v.id == id ? enrichedVehicle : v;
      }).toList();

      emit(state.copyWith(
        status: Status.success,
        vehicles: updatedVehicles,
        selectedVehicle: enrichedVehicle,
        successMessage: 'Vehículo actualizado exitosamente',
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  /// Elimina un vehículo
  Future<bool> deleteVehicle(int id) async {
    emit(state.copyWith(status: Status.loading));

    try {
      await _vehicleRepository.deleteVehicle(id);

      // Remover de la lista
      final updatedVehicles =
          state.vehicles.where((v) => v.id != id).toList();

      emit(state.copyWith(
        status: Status.success,
        vehicles: updatedVehicles,
        clearSelectedVehicle: true,
        successMessage: 'Vehículo eliminado exitosamente',
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    }
  }

  /// Resetea el estado
  void reset() {
    emit(const VehiclesState());
  }

  /// Limpia mensajes de error/éxito
  void clearMessages() {
    emit(state.copyWith(
      errorMessage: null,
      successMessage: null,
    ));
  }

  // ==================== IMÁGENES ====================

  /// Sube una imagen para el vehículo seleccionado
  /// 
  /// [imageFile] - Archivo de imagen a subir
  /// Retorna true si la imagen se subió exitosamente
  Future<bool> uploadVehicleImage(File imageFile) async {
    final vehicle = state.selectedVehicle;
    if (vehicle == null) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'No hay vehículo seleccionado'));
      }
      return false;
    }

    if (!isClosed) {
      emit(state.copyWith(isUploadingImage: true));
    }

    try {
      final imageUrl = await _vehicleRepository.uploadVehicleImage(
        vehicle.id,
        imageFile,
      );

      // Actualizar lista de imágenes del vehículo
      final updatedImageUrls = [...vehicle.imageUrls, imageUrl];
      final updatedVehicle = vehicle.copyWith(imageUrls: updatedImageUrls);

      // Actualizar en la lista de vehículos
      final updatedVehicles = state.vehicles.map((v) {
        return v.id == vehicle.id ? updatedVehicle : v;
      }).toList();

      if (!isClosed) {
        emit(state.copyWith(
          isUploadingImage: false,
          vehicles: updatedVehicles,
          selectedVehicle: updatedVehicle,
          successMessage: 'Imagen subida exitosamente',
        ));
      }

      return true;
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          isUploadingImage: false,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
      return false;
    }
  }

  // ==================== USUARIOS AUTORIZADOS ====================

  /// Agrega un usuario autorizado al vehículo seleccionado
  /// 
  /// [email] - Email del usuario a agregar
  /// Retorna un record con (success, error) - NO emite estado para evitar
  /// reconstrucciones del BlocBuilder que causan errores de contexto
  Future<({bool success, String? error})> addAuthorizedUser(String email) async {
    final vehicle = state.selectedVehicle;
    if (vehicle == null) {
      return (success: false, error: 'No hay vehículo seleccionado');
    }

    try {
      await _vehicleRepository.addAuthorizedUser(vehicle.id, email);
      return (success: true, error: null);
    } catch (e) {
      return (success: false, error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Elimina un usuario autorizado del vehículo seleccionado
  /// 
  /// [userId] - ID del usuario a eliminar
  /// Retorna true si se eliminó exitosamente
  Future<bool> removeAuthorizedUser(int userId) async {
    final vehicle = state.selectedVehicle;
    if (vehicle == null) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'No hay vehículo seleccionado'));
      }
      return false;
    }

    try {
      await _vehicleRepository.removeAuthorizedUser(vehicle.id, userId);

      if (!isClosed) {
        emit(state.copyWith(
          successMessage: 'Usuario autorizado eliminado exitosamente',
        ));
      }

      return true;
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
      return false;
    }
  }

  /// Transfiere la propiedad del vehículo seleccionado
  /// 
  /// [newOwnerEmail] - Email del nuevo propietario
  /// Retorna true si se transfirió exitosamente
  Future<bool> transferVehicle(String newOwnerEmail) async {
    final vehicle = state.selectedVehicle;
    if (vehicle == null) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'No hay vehículo seleccionado'));
      }
      return false;
    }

    try {
      await _vehicleRepository.transferVehicle(vehicle.id, newOwnerEmail);

      // Remover de la lista (ya no es nuestro)
      final updatedVehicles = state.vehicles.where((v) => v.id != vehicle.id).toList();

      if (!isClosed) {
        emit(state.copyWith(
          vehicles: updatedVehicles,
          clearSelectedVehicle: true,
          successMessage: 'Vehículo transferido exitosamente',
        ));
      }

      return true;
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
      return false;
    }
  }
}


