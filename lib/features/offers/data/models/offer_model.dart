import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Estados posibles de una oferta
enum OfferStatus {
  pending('PENDING'),
  accepted('ACCEPTED'),
  rejected('REJECTED'),
  withdrawn('WITHDRAWN'),
  expired('EXPIRED');

  const OfferStatus(this.value);
  final String value;

  static OfferStatus fromString(String value) {
    return OfferStatus.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => OfferStatus.pending,
    );
  }
}

/// Modelo de oferta de un taller
class OfferModel extends Equatable {
  final int id;
  final int serviceRequestId;
  final int workshopId;
  final double proposedPriceAmount;
  final String currency;
  final DateTime proposedDate;
  final OfferStatus status;
  final String? message;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? acceptedAt;
  final DateTime? withdrawnAt;

  const OfferModel({
    required this.id,
    required this.serviceRequestId,
    required this.workshopId,
    required this.proposedPriceAmount,
    required this.currency,
    required this.proposedDate,
    required this.status,
    this.message,
    required this.createdAt,
    required this.expiresAt,
    this.acceptedAt,
    this.withdrawnAt,
  });

  /// Crea una instancia desde JSON
  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] as int,
      serviceRequestId: json['serviceRequestId'] as int,
      workshopId: json['workshopId'] as int,
      proposedPriceAmount: (json['proposedPriceAmount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'PEN',
      proposedDate: DateTime.parse(json['proposedDate'] as String),
      status: OfferStatus.fromString(json['status'] as String),
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.parse(json['acceptedAt'] as String)
          : null,
      withdrawnAt: json['withdrawnAt'] != null
          ? DateTime.parse(json['withdrawnAt'] as String)
          : null,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceRequestId': serviceRequestId,
      'workshopId': workshopId,
      'proposedPriceAmount': proposedPriceAmount,
      'currency': currency,
      'proposedDate': proposedDate.toIso8601String(),
      'status': status.value,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'withdrawnAt': withdrawnAt?.toIso8601String(),
    };
  }

  // === Getters de formato ===

  /// Precio formateado con moneda
  String get formattedPrice {
    final formatter = NumberFormat.currency(symbol: currency, decimalDigits: 2);
    return formatter.format(proposedPriceAmount);
  }

  /// Fecha propuesta formateada
  String get formattedProposedDate {
    return DateFormat('dd/MM/yyyy').format(proposedDate);
  }

  /// Hora propuesta formateada
  String get formattedProposedTime {
    return DateFormat('HH:mm').format(proposedDate);
  }

  /// Fecha y hora propuesta formateada
  String get formattedProposedDateTime {
    return DateFormat('dd/MM/yyyy HH:mm').format(proposedDate);
  }

  /// Fecha de creación formateada
  String get formattedCreatedAt {
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  }

  /// Status en español
  String get statusDisplay {
    switch (status) {
      case OfferStatus.pending:
        return 'Pendiente';
      case OfferStatus.accepted:
        return 'Aceptada';
      case OfferStatus.rejected:
        return 'Rechazada';
      case OfferStatus.withdrawn:
        return 'Retirada';
      case OfferStatus.expired:
        return 'Expirada';
    }
  }

  // === Getters de estado ===

  /// ¿La oferta está pendiente de respuesta?
  bool get isPending => status == OfferStatus.pending;

  /// ¿La oferta fue aceptada?
  bool get isAccepted => status == OfferStatus.accepted;

  /// ¿La oferta fue rechazada?
  bool get isRejected => status == OfferStatus.rejected;

  /// ¿La oferta expiró?
  bool get isExpired {
    if (status == OfferStatus.expired) return true;
    return DateTime.now().isAfter(expiresAt);
  }

  /// ¿Se puede responder a esta oferta?
  bool get canRespond => isPending && !isExpired;

  /// Tiempo restante hasta expiración
  Duration get timeUntilExpiry {
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) return Duration.zero;
    return expiresAt.difference(now);
  }

  /// Tiempo restante formateado
  String get timeUntilExpiryFormatted {
    final duration = timeUntilExpiry;
    if (duration == Duration.zero) return 'Expirada';

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '$days día${days == 1 ? '' : 's'} ${hours}h';
    } else if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '$minutes minuto${minutes == 1 ? '' : 's'}';
    }
  }

  @override
  List<Object?> get props => [
        id,
        serviceRequestId,
        workshopId,
        proposedPriceAmount,
        currency,
        proposedDate,
        status,
        message,
        createdAt,
        expiresAt,
        acceptedAt,
        withdrawnAt,
      ];
}

