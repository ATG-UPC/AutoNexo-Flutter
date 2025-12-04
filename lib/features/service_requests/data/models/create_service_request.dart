import 'package:equatable/equatable.dart';

/// Request para crear una nueva solicitud de servicio
class CreateServiceRequest extends Equatable {
  /// ID del vehículo
  final int vehicleId;

  /// Lista de códigos de servicios solicitados
  final List<String> requestedServices;

  /// Descripción adicional (opcional)
  final String? description;

  /// Latitud de la ubicación
  final double latitude;

  /// Longitud de la ubicación
  final double longitude;

  /// Radio de búsqueda en kilómetros (1-50)
  final int searchRadiusKm;

  const CreateServiceRequest({
    required this.vehicleId,
    required this.requestedServices,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.searchRadiusKm,
  });

  /// Convierte a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'requestedServices': requestedServices,
      if (description != null && description!.isNotEmpty) 'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'searchRadiusKm': searchRadiusKm,
    };
  }

  /// Crea una copia con campos actualizados
  CreateServiceRequest copyWith({
    int? vehicleId,
    List<String>? requestedServices,
    String? description,
    double? latitude,
    double? longitude,
    int? searchRadiusKm,
  }) {
    return CreateServiceRequest(
      vehicleId: vehicleId ?? this.vehicleId,
      requestedServices: requestedServices ?? this.requestedServices,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
    );
  }

  /// Valida que la solicitud tenga datos mínimos
  /// Para solicitudes personalizadas (sin servicios), la descripción es obligatoria
  bool get isValid {
    final hasBasicData = vehicleId > 0 &&
        latitude != 0 &&
        longitude != 0 &&
        searchRadiusKm >= 1 &&
        searchRadiusKm <= 50;
    
    // Si tiene servicios, no necesita descripción obligatoria
    if (requestedServices.isNotEmpty) {
      return hasBasicData;
    }
    
    // Si no tiene servicios (personalizada), debe tener descripción
    return hasBasicData && description != null && description!.trim().isNotEmpty;
  }
  
  /// Indica si es una solicitud personalizada (sin servicios predefinidos)
  bool get isCustomRequest => requestedServices.isEmpty;

  @override
  List<Object?> get props => [
        vehicleId,
        requestedServices,
        description,
        latitude,
        longitude,
        searchRadiusKm,
      ];
}

