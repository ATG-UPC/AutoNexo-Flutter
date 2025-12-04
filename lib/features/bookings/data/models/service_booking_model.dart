import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Estados posibles de una reserva de servicio
enum ServiceBookingStatus {
  SCHEDULED,    // Agendado, pendiente de inicio
  IN_PROGRESS,  // Servicio en curso
  COMPLETED,    // Servicio completado, pendiente recogida
  PICKED_UP,    // Vehículo recogido por usuario
  CANCELLED,    // Cancelado
}

/// Modelo de reserva de servicio
class ServiceBookingModel extends Equatable {
  final int id;
  final int serviceRequestId;
  final int offerId;
  final int userId;
  final int vehicleId;
  final int workshopId;
  final DateTime scheduledDate;
  final double proposedPriceAmount;
  final String proposedPriceCurrency;
  final double? finalPriceAmount;
  final String? finalPriceCurrency;
  final ServiceBookingStatus status;
  final List<String> servicesToPerform;
  final String? description;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? pickedUpAt;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final String? cancellationReason;

  const ServiceBookingModel({
    required this.id,
    required this.serviceRequestId,
    required this.offerId,
    required this.userId,
    required this.vehicleId,
    required this.workshopId,
    required this.scheduledDate,
    required this.proposedPriceAmount,
    required this.proposedPriceCurrency,
    this.finalPriceAmount,
    this.finalPriceCurrency,
    required this.status,
    required this.servicesToPerform,
    this.description,
    required this.createdAt,
    this.completedAt,
    this.pickedUpAt,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
  });

  factory ServiceBookingModel.fromJson(Map<String, dynamic> json) {
    return ServiceBookingModel(
      id: json['id'] as int,
      serviceRequestId: json['serviceRequestId'] as int,
      offerId: json['offerId'] as int,
      userId: json['userId'] as int,
      vehicleId: json['vehicleId'] as int,
      workshopId: json['workshopId'] as int,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      proposedPriceAmount: (json['proposedPriceAmount'] as num).toDouble(),
      proposedPriceCurrency: json['proposedPriceCurrency'] as String,
      finalPriceAmount: json['finalPriceAmount'] != null 
          ? (json['finalPriceAmount'] as num).toDouble() 
          : null,
      finalPriceCurrency: json['finalPriceCurrency'] as String?,
      status: ServiceBookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ServiceBookingStatus.SCHEDULED,
      ),
      servicesToPerform: (json['servicesToPerform'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      pickedUpAt: json['pickedUpAt'] != null 
          ? DateTime.parse(json['pickedUpAt'] as String) 
          : null,
      cancelledAt: json['cancelledAt'] != null 
          ? DateTime.parse(json['cancelledAt'] as String) 
          : null,
      cancelledBy: json['cancelledBy'] as String?,
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
      'scheduledDate': scheduledDate.toIso8601String(),
      'proposedPriceAmount': proposedPriceAmount,
      'proposedPriceCurrency': proposedPriceCurrency,
      'finalPriceAmount': finalPriceAmount,
      'finalPriceCurrency': finalPriceCurrency,
      'status': status.toString().split('.').last,
      'servicesToPerform': servicesToPerform,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancelledBy': cancelledBy,
      'cancellationReason': cancellationReason,
    };
  }

  // === Helpers de formato ===

  /// Fecha programada formateada
  String get formattedScheduledDate => 
      DateFormat('dd/MM/yyyy').format(scheduledDate);

  /// Hora programada formateada
  String get formattedScheduledTime => 
      DateFormat('HH:mm').format(scheduledDate);

  /// Fecha y hora programada formateada
  String get formattedScheduledDateTime => 
      DateFormat('dd/MM/yyyy HH:mm').format(scheduledDate);

  /// Precio propuesto formateado
  String get formattedProposedPrice => 
      '${NumberFormat.currency(symbol: '').format(proposedPriceAmount)} $proposedPriceCurrency';

  /// Precio final formateado (si existe)
  String? get formattedFinalPrice => finalPriceAmount != null
      ? '${NumberFormat.currency(symbol: '').format(finalPriceAmount)} ${finalPriceCurrency ?? proposedPriceCurrency}'
      : null;

  /// Precio a mostrar (final si existe, sino propuesto)
  String get displayPrice => formattedFinalPrice ?? formattedProposedPrice;

  /// Servicios como texto
  String get servicesDescription => servicesToPerform.isEmpty 
      ? 'Sin servicios especificados'
      : servicesToPerform.map(_formatServiceCode).join(', ');

  /// Fecha de creación formateada
  String get formattedCreatedAt => 
      DateFormat('dd/MM/yyyy HH:mm').format(createdAt);

  // === Helpers de estado ===

  /// Estado en español
  String get statusDisplay {
    switch (status) {
      case ServiceBookingStatus.SCHEDULED:
        return 'Agendado';
      case ServiceBookingStatus.IN_PROGRESS:
        return 'En Progreso';
      case ServiceBookingStatus.COMPLETED:
        return 'Completado';
      case ServiceBookingStatus.PICKED_UP:
        return 'Recogido';
      case ServiceBookingStatus.CANCELLED:
        return 'Cancelado';
    }
  }

  /// Color asociado al estado (para badges)
  String get statusColor {
    switch (status) {
      case ServiceBookingStatus.SCHEDULED:
        return 'info';
      case ServiceBookingStatus.IN_PROGRESS:
        return 'warning';
      case ServiceBookingStatus.COMPLETED:
        return 'success';
      case ServiceBookingStatus.PICKED_UP:
        return 'success';
      case ServiceBookingStatus.CANCELLED:
        return 'error';
    }
  }

  /// ¿Se puede cancelar la reserva?
  bool get canCancel => 
      status == ServiceBookingStatus.SCHEDULED || 
      status == ServiceBookingStatus.IN_PROGRESS;

  /// ¿Se puede confirmar la recogida?
  bool get canConfirmPickup => status == ServiceBookingStatus.COMPLETED;

  /// ¿Está activo (no cancelado ni recogido)?
  bool get isActive => 
      status != ServiceBookingStatus.CANCELLED && 
      status != ServiceBookingStatus.PICKED_UP;

  /// ¿Es una reserva pasada?
  bool get isPast => scheduledDate.isBefore(DateTime.now());

  /// ¿Es una reserva futura?
  bool get isFuture => scheduledDate.isAfter(DateTime.now());

  /// Índice del paso actual en el timeline (0-3)
  int get timelineStep {
    switch (status) {
      case ServiceBookingStatus.SCHEDULED:
        return 0;
      case ServiceBookingStatus.IN_PROGRESS:
        return 1;
      case ServiceBookingStatus.COMPLETED:
        return 2;
      case ServiceBookingStatus.PICKED_UP:
        return 3;
      case ServiceBookingStatus.CANCELLED:
        return -1; // Cancelado no aplica al timeline
    }
  }

  /// Formatea código de servicio a texto legible
  String _formatServiceCode(String code) {
    return code
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1)}' 
            : '')
        .join(' ');
  }

  @override
  List<Object?> get props => [
        id,
        serviceRequestId,
        offerId,
        userId,
        vehicleId,
        workshopId,
        scheduledDate,
        proposedPriceAmount,
        proposedPriceCurrency,
        finalPriceAmount,
        finalPriceCurrency,
        status,
        servicesToPerform,
        description,
        createdAt,
        completedAt,
        pickedUpAt,
        cancelledAt,
        cancelledBy,
        cancellationReason,
      ];
}

