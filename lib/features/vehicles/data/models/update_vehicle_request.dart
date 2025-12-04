/// Request para actualizar un vehículo existente
class UpdateVehicleRequest {
  /// Color del vehículo - opcional
  final String? color;

  /// Kilometraje actual
  final int? currentMileage;

  const UpdateVehicleRequest({
    this.color,
    this.currentMileage,
  });

  /// Convierte el request a JSON
  Map<String, dynamic> toJson() {
    return {
      if (color != null) 'color': color,
      if (currentMileage != null) 'currentMileage': currentMileage,
    };
  }
}






