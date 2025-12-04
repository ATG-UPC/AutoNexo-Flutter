/// Modelo para un slot de horario en el calendario
/// Representa una cita del calendario devuelta por /api/v1/service-bookings/schedule
class ScheduleSlotModel {
  final int id;
  final DateTime? scheduledDate;
  final String status;
  final List<String> servicesToPerform;
  final String? description;
  final int vehicleId;
  final int workshopId;

  ScheduleSlotModel({
    required this.id,
    this.scheduledDate,
    required this.status,
    required this.servicesToPerform,
    this.description,
    required this.vehicleId,
    required this.workshopId,
  });

  factory ScheduleSlotModel.fromJson(Map<String, dynamic> json) {
    return ScheduleSlotModel(
      id: json['id'] as int,
      scheduledDate: json['scheduledDate'] != null 
          ? DateTime.parse(json['scheduledDate'] as String)
          : null,
      status: json['status'] as String,
      servicesToPerform: (json['servicesToPerform'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      description: json['description'] as String?,
      vehicleId: json['vehicleId'] as int,
      workshopId: json['workshopId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'status': status,
      'servicesToPerform': servicesToPerform,
      'description': description,
      'vehicleId': vehicleId,
      'workshopId': workshopId,
    };
  }

  /// Obtener el día del mes
  int? get dayOfMonth => scheduledDate?.day;

  /// Obtener hora formateada
  String get formattedTime {
    if (scheduledDate == null) return '';
    return '${scheduledDate!.hour.toString().padLeft(2, '0')}:${scheduledDate!.minute.toString().padLeft(2, '0')}';
  }

  /// Verificar si la cita está activa (no cancelada)
  bool get isActive => status != 'CANCELLED' && status != 'PICKED_UP';
}
