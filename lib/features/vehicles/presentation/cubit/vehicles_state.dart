import 'package:equatable/equatable.dart';
import '../../../../core/enums/status.dart';
import '../../data/models/models.dart';

/// Estado para la gestión de vehículos
class VehiclesState extends Equatable {
  /// Estado de la operación actual
  final Status status;

  /// Lista de vehículos del usuario
  final List<VehicleModel> vehicles;

  /// Vehículo seleccionado (para ver detalle)
  final VehicleModel? selectedVehicle;

  /// Lista de marcas disponibles
  final List<BrandModel> brands;

  /// Estado de carga de marcas
  final Status brandsStatus;

  /// Mensaje de error
  final String? errorMessage;

  /// Mensaje de éxito
  final String? successMessage;

  /// Indica si se está subiendo una imagen
  final bool isUploadingImage;

  const VehiclesState({
    this.status = Status.initial,
    this.vehicles = const [],
    this.selectedVehicle,
    this.brands = const [],
    this.brandsStatus = Status.initial,
    this.errorMessage,
    this.successMessage,
    this.isUploadingImage = false,
  });

  /// Verifica si hay vehículos
  bool get hasVehicles => vehicles.isNotEmpty;

  /// Obtiene el primer vehículo (vehículo principal)
  VehicleModel? get primaryVehicle => vehicles.isNotEmpty ? vehicles.first : null;

  /// Obtiene el nombre de la marca para un vehículo
  String getBrandName(int brandId) {
    final brand = brands.firstWhere(
      (b) => b.id == brandId,
      orElse: () => const BrandModel(id: 0, name: 'Marca'),
    );
    return brand.name;
  }

  /// Crea una copia del estado con campos actualizados
  VehiclesState copyWith({
    Status? status,
    List<VehicleModel>? vehicles,
    VehicleModel? selectedVehicle,
    bool clearSelectedVehicle = false,
    List<BrandModel>? brands,
    Status? brandsStatus,
    String? errorMessage,
    String? successMessage,
    bool? isUploadingImage,
  }) {
    return VehiclesState(
      status: status ?? this.status,
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle:
          clearSelectedVehicle ? null : (selectedVehicle ?? this.selectedVehicle),
      brands: brands ?? this.brands,
      brandsStatus: brandsStatus ?? this.brandsStatus,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        vehicles,
        selectedVehicle,
        brands,
        brandsStatus,
        errorMessage,
        successMessage,
        isUploadingImage,
      ];
}


