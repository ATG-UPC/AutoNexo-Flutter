/// Request para crear un nuevo vehículo
class CreateVehicleRequest {
  /// ID de la marca del vehículo
  final int brandId;

  /// Modelo del vehículo
  final String model;

  /// Año de fabricación
  final int year;

  /// Placa del vehículo
  final String licensePlate;

  /// Número de identificación del vehículo (VIN) - opcional
  final String? vin;

  /// Color del vehículo - opcional
  final String? color;

  /// Kilometraje inicial
  final int initialMileage;

  const CreateVehicleRequest({
    required this.brandId,
    required this.model,
    required this.year,
    required this.licensePlate,
    this.vin,
    this.color,
    this.initialMileage = 0,
  });

  /// Convierte el request a JSON
  Map<String, dynamic> toJson() {
    return {
      'brandId': brandId,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      if (vin != null && vin!.isNotEmpty) 'vin': vin,
      if (color != null && color!.isNotEmpty) 'color': color,
      'initialMileage': initialMileage,
    };
  }
}






