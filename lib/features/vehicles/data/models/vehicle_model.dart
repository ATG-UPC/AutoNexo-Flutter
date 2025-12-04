import 'package:equatable/equatable.dart';

/// Modelo de vehículo para serialización JSON
class VehicleModel extends Equatable {
  /// ID único del vehículo
  final int id;

  /// ID de la marca del vehículo
  final int brandId;

  /// Nombre de la marca (puede venir del backend o ser asignado localmente)
  final String? brandName;

  /// Modelo del vehículo
  final String model;

  /// Año de fabricación
  final int year;

  /// Placa del vehículo
  final String licensePlate;

  /// Número de identificación del vehículo (VIN)
  final String? vin;

  /// Color del vehículo
  final String? color;

  /// Kilometraje actual
  final int currentMileage;

  /// URLs de las imágenes del vehículo
  final List<String> imageUrls;

  /// Si el vehículo está activo
  final bool active;

  /// ID del propietario principal
  final int primaryOwnerId;

  const VehicleModel({
    required this.id,
    required this.brandId,
    this.brandName,
    required this.model,
    required this.year,
    required this.licensePlate,
    this.vin,
    this.color,
    required this.currentMileage,
    required this.imageUrls,
    required this.active,
    required this.primaryOwnerId,
  });

  /// Crea un VehicleModel desde JSON
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as int,
      brandId: json['brandId'] as int,
      brandName: json['brandName'] as String?,
      model: json['model'] as String,
      year: json['year'] as int,
      licensePlate: json['licensePlate'] as String,
      vin: json['vin'] as String?,
      color: json['color'] as String?,
      currentMileage: json['currentMileage'] as int? ?? 0,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      active: json['active'] as bool? ?? true,
      primaryOwnerId: json['primaryOwnerId'] as int,
    );
  }

  /// Convierte el VehicleModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brandId': brandId,
      'brandName': brandName,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      'vin': vin,
      'color': color,
      'currentMileage': currentMileage,
      'imageUrls': imageUrls,
      'active': active,
      'primaryOwnerId': primaryOwnerId,
    };
  }

  /// Obtiene la primera imagen del vehículo o null
  String? get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  /// Crea una copia del modelo con campos actualizados
  VehicleModel copyWith({
    int? id,
    int? brandId,
    String? brandName,
    String? model,
    int? year,
    String? licensePlate,
    String? vin,
    String? color,
    int? currentMileage,
    List<String>? imageUrls,
    bool? active,
    int? primaryOwnerId,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      vin: vin ?? this.vin,
      color: color ?? this.color,
      currentMileage: currentMileage ?? this.currentMileage,
      imageUrls: imageUrls ?? this.imageUrls,
      active: active ?? this.active,
      primaryOwnerId: primaryOwnerId ?? this.primaryOwnerId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        brandId,
        brandName,
        model,
        year,
        licensePlate,
        vin,
        color,
        currentMileage,
        imageUrls,
        active,
        primaryOwnerId,
      ];
}




