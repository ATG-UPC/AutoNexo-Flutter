import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Estados de mantenimiento
enum MaintenanceStatus {
  pendingConfirmation('PENDING_CONFIRMATION'),
  confirmed('CONFIRMED'),
  rejected('REJECTED'),
  manual('MANUAL');

  const MaintenanceStatus(this.value);
  final String value;

  static MaintenanceStatus fromString(String value) {
    return MaintenanceStatus.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => MaintenanceStatus.pendingConfirmation,
    );
  }

  String get displayName {
    switch (this) {
      case MaintenanceStatus.pendingConfirmation:
        return 'Pendiente de confirmación';
      case MaintenanceStatus.confirmed:
        return 'Confirmado';
      case MaintenanceStatus.rejected:
        return 'Rechazado';
      case MaintenanceStatus.manual:
        return 'Registro manual';
    }
  }
}

/// Modelo de servicio de mantenimiento
class MaintenanceServiceModel extends Equatable {
  final String serviceType;
  final String? description;
  final double cost;

  const MaintenanceServiceModel({
    required this.serviceType,
    this.description,
    required this.cost,
  });

  factory MaintenanceServiceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceServiceModel(
      serviceType: json['serviceType'] as String,
      description: json['description'] as String?,
      cost: (json['cost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceType': serviceType,
      if (description != null) 'description': description,
      'cost': cost,
    };
  }

  /// Nombre formateado del servicio
  String get formattedServiceType {
    return serviceType
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  /// Costo formateado
  String get formattedCost {
    return NumberFormat.currency(symbol: 'S/', decimalDigits: 2).format(cost);
  }

  @override
  List<Object?> get props => [serviceType, description, cost];
}

/// Modelo de Mantenimiento
class MaintenanceModel extends Equatable {
  final int id;
  final int vehicleId;
  final DateTime maintenanceDate;
  final int mileage;
  final int? workshopId;
  final bool createdByWorkshop;
  final MaintenanceStatus status;
  final String? observations;
  final List<String> imageUrls;
  final List<MaintenanceServiceModel> services;
  final double totalCost;

  const MaintenanceModel({
    required this.id,
    required this.vehicleId,
    required this.maintenanceDate,
    required this.mileage,
    this.workshopId,
    required this.createdByWorkshop,
    required this.status,
    this.observations,
    this.imageUrls = const [],
    this.services = const [],
    required this.totalCost,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      id: json['id'] as int,
      vehicleId: json['vehicleId'] as int,
      maintenanceDate: DateTime.parse(json['maintenanceDate'] as String),
      mileage: json['mileage'] as int,
      workshopId: json['workshopId'] as int?,
      createdByWorkshop: json['createdByWorkshop'] as bool? ?? false,
      status: MaintenanceStatus.fromString(json['status'] as String? ?? 'PENDING_CONFIRMATION'),
      observations: json['observations'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => MaintenanceServiceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'maintenanceDate': maintenanceDate.toIso8601String(),
      'mileage': mileage,
      'workshopId': workshopId,
      'createdByWorkshop': createdByWorkshop,
      'status': status.value,
      'observations': observations,
      'imageUrls': imageUrls,
      'services': services.map((s) => s.toJson()).toList(),
      'totalCost': totalCost,
    };
  }

  // === Getters de formato ===

  /// Fecha formateada
  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(maintenanceDate);
  }

  /// Kilometraje formateado
  String get formattedMileage {
    return NumberFormat('#,###').format(mileage) + ' km';
  }

  /// Costo total formateado
  String get formattedTotalCost {
    return NumberFormat.currency(symbol: 'S/', decimalDigits: 2).format(totalCost);
  }

  /// Número de servicios
  int get servicesCount => services.length;

  // === Getters de estado ===

  /// ¿Está pendiente de confirmación?
  bool get isPending => status == MaintenanceStatus.pendingConfirmation;

  /// ¿Fue confirmado?
  bool get isConfirmed => status == MaintenanceStatus.confirmed;

  /// ¿Fue rechazado?
  bool get isRejected => status == MaintenanceStatus.rejected;

  /// ¿Es manual?
  bool get isManual => status == MaintenanceStatus.manual;

  /// ¿Se puede confirmar o rechazar?
  bool get canRespond => isPending;

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        maintenanceDate,
        mileage,
        workshopId,
        createdByWorkshop,
        status,
        observations,
        imageUrls,
        services,
        totalCost,
      ];
}

/// Request para crear mantenimiento manual
class CreateManualMaintenanceRequest {
  final int vehicleId;
  final DateTime maintenanceDate;
  final int mileage;
  final String? observations;
  final List<MaintenanceServiceModel> services;

  const CreateManualMaintenanceRequest({
    required this.vehicleId,
    required this.maintenanceDate,
    required this.mileage,
    this.observations,
    this.services = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'maintenanceDate': DateFormat('yyyy-MM-dd').format(maintenanceDate),
      'mileage': mileage,
      if (observations != null && observations!.isNotEmpty)
        'observations': observations,
      'services': services.map((s) => s.toJson()).toList(),
    };
  }
}




