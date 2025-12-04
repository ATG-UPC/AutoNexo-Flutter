import 'package:equatable/equatable.dart';

/// Estados posibles de una solicitud de servicio
enum ServiceRequestStatus {
  pending('PENDING', 'Pendiente'),
  matched('MATCHED', 'Emparejado'),
  cancelled('CANCELLED', 'Cancelado'),
  expired('EXPIRED', 'Expirado');

  final String value;
  final String displayName;

  const ServiceRequestStatus(this.value, this.displayName);

  static ServiceRequestStatus fromString(String value) {
    return ServiceRequestStatus.values.firstWhere(
      (status) => status.value == value.toUpperCase(),
      orElse: () => ServiceRequestStatus.pending,
    );
  }
}

/// Modelo de solicitud de servicio
class ServiceRequestModel extends Equatable {
  /// ID único de la solicitud
  final int id;

  /// ID del usuario que creó la solicitud
  final int userId;

  /// ID del vehículo
  final int vehicleId;

  /// Lista de códigos de servicios solicitados
  final List<String> requestedServices;

  /// Descripción adicional
  final String? description;

  /// Latitud de la ubicación
  final double latitude;

  /// Longitud de la ubicación
  final double longitude;

  /// Radio de búsqueda en kilómetros
  final int searchRadiusKm;

  /// Estado de la solicitud
  final ServiceRequestStatus status;

  /// Fecha de creación
  final DateTime createdAt;

  /// Fecha de cancelación (si aplica)
  final DateTime? cancelledAt;

  const ServiceRequestModel({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.requestedServices,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.searchRadiusKm,
    required this.status,
    required this.createdAt,
    this.cancelledAt,
  });

  /// Crea un ServiceRequestModel desde JSON
  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      vehicleId: json['vehicleId'] as int,
      requestedServices: (json['requestedServices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      searchRadiusKm: json['searchRadiusKm'] as int? ?? 10,
      status: ServiceRequestStatus.fromString(json['status'] as String? ?? 'PENDING'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'requestedServices': requestedServices,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'searchRadiusKm': searchRadiusKm,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }

  /// Verifica si la solicitud está pendiente
  bool get isPending => status == ServiceRequestStatus.pending;

  /// Verifica si la solicitud fue cancelada
  bool get isCancelled => status == ServiceRequestStatus.cancelled;

  /// Verifica si la solicitud fue emparejada
  bool get isMatched => status == ServiceRequestStatus.matched;

  /// Obtiene la fecha formateada
  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  /// Obtiene el número de servicios solicitados
  int get servicesCount => requestedServices.length;

  @override
  List<Object?> get props => [
        id,
        userId,
        vehicleId,
        requestedServices,
        description,
        latitude,
        longitude,
        searchRadiusKm,
        status,
        createdAt,
        cancelledAt,
      ];
}

