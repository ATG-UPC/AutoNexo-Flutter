/// Modelo para una cita de servicio (Service Booking)
/// Representa la respuesta del backend /api/v1/service-bookings/current
class AppointmentModel {
  final int id;
  final int? serviceRequestId;
  final int? offerId;
  final int userId;
  final int vehicleId;
  final int workshopId;
  final DateTime? scheduledDate;
  final double? proposedPriceAmount;
  final String? proposedPriceCurrency;
  final double? finalPriceAmount;
  final String? finalPriceCurrency;
  final String status;
  final List<String> servicesToPerform;
  final String? description;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final DateTime? pickedUpAt;
  final DateTime? cancelledAt;
  final int? cancelledBy;
  final String? cancellationReason;

  AppointmentModel({
    required this.id,
    this.serviceRequestId,
    this.offerId,
    required this.userId,
    required this.vehicleId,
    required this.workshopId,
    this.scheduledDate,
    this.proposedPriceAmount,
    this.proposedPriceCurrency,
    this.finalPriceAmount,
    this.finalPriceCurrency,
    required this.status,
    required this.servicesToPerform,
    this.description,
    this.createdAt,
    this.completedAt,
    this.pickedUpAt,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as int,
      serviceRequestId: json['serviceRequestId'] as int?,
      offerId: json['offerId'] as int?,
      userId: json['userId'] as int,
      vehicleId: json['vehicleId'] as int,
      workshopId: json['workshopId'] as int,
      scheduledDate: json['scheduledDate'] != null 
          ? DateTime.parse(json['scheduledDate'] as String)
          : null,
      proposedPriceAmount: json['proposedPriceAmount'] != null
          ? (json['proposedPriceAmount'] as num).toDouble()
          : null,
      proposedPriceCurrency: json['proposedPriceCurrency'] as String?,
      finalPriceAmount: json['finalPriceAmount'] != null
          ? (json['finalPriceAmount'] as num).toDouble()
          : null,
      finalPriceCurrency: json['finalPriceCurrency'] as String?,
      status: json['status'] as String,
      servicesToPerform: (json['servicesToPerform'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      pickedUpAt: json['pickedUpAt'] != null 
          ? DateTime.parse(json['pickedUpAt'] as String)
          : null,
      cancelledAt: json['cancelledAt'] != null 
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      cancelledBy: json['cancelledBy'] as int?,
      cancellationReason: json['cancellationReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceRequestId': serviceRequestId,
      'offerId': offerId,
      'userId': userId,
      'vehicleId': vehicleId,
      'workshopId': workshopId,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'proposedPriceAmount': proposedPriceAmount,
      'proposedPriceCurrency': proposedPriceCurrency,
      'finalPriceAmount': finalPriceAmount,
      'finalPriceCurrency': finalPriceCurrency,
      'status': status,
      'servicesToPerform': servicesToPerform,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancelledBy': cancelledBy,
      'cancellationReason': cancellationReason,
    };
  }

  /// Obtener fecha formateada para mostrar
  String get formattedDate {
    if (scheduledDate == null) return 'Sin fecha';
    return '${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}';
  }

  /// Obtener hora formateada para mostrar
  String get formattedTime {
    if (scheduledDate == null) return 'Sin hora';
    return '${scheduledDate!.hour.toString().padLeft(2, '0')}:${scheduledDate!.minute.toString().padLeft(2, '0')}';
  }

  /// Obtener precio a mostrar (final o propuesto)
  double? get displayPrice => finalPriceAmount ?? proposedPriceAmount;
  
  /// Obtener moneda a mostrar
  String get displayCurrency => finalPriceCurrency ?? proposedPriceCurrency ?? 'PEN';

  /// Obtener lista de servicios como string legible
  String get servicesDescription {
    if (servicesToPerform.isEmpty) return 'Sin servicios especificados';
    return servicesToPerform.map((s) => _formatServiceName(s)).join(', ');
  }

  /// Formatear nombre de servicio (OIL_CHANGE -> Cambio de aceite)
  String _formatServiceName(String service) {
    final names = {
      'OIL_CHANGE': 'Cambio de aceite',
      'BRAKE_INSPECTION': 'Inspección de frenos',
      'BRAKE_PAD_REPLACEMENT': 'Cambio de pastillas',
      'TIRE_ROTATION': 'Rotación de neumáticos',
      'TIRE_REPLACEMENT': 'Cambio de neumáticos',
      'BATTERY_CHECK': 'Revisión de batería',
      'BATTERY_REPLACEMENT': 'Cambio de batería',
      'AC_SERVICE': 'Servicio de A/C',
      'ENGINE_DIAGNOSTIC': 'Diagnóstico de motor',
      'TRANSMISSION_SERVICE': 'Servicio de transmisión',
      'SUSPENSION_CHECK': 'Revisión de suspensión',
      'ALIGNMENT': 'Alineación',
      'BALANCING': 'Balanceo',
      'FILTER_REPLACEMENT': 'Cambio de filtros',
      'GENERAL_INSPECTION': 'Inspección general',
    };
    return names[service] ?? service.replaceAll('_', ' ').toLowerCase();
  }

  /// Obtener estado traducido
  String get statusDisplay {
    final statuses = {
      'PENDING_SCHEDULE': 'Pendiente de agendar',
      'SCHEDULED': 'Agendada',
      'IN_PROGRESS': 'En progreso',
      'COMPLETED': 'Completada',
      'PENDING_PICKUP': 'Lista para recoger',
      'PICKED_UP': 'Recogida',
      'CANCELLED': 'Cancelada',
    };
    return statuses[status] ?? status;
  }
}
