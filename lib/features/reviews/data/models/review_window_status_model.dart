import 'package:equatable/equatable.dart';

/// Modelo para el estado de la ventana de review
class ReviewWindowStatusModel extends Equatable {
  /// ¿Puede dejar review?
  final bool canReview;

  /// Días restantes para dejar review
  final int daysRemaining;

  /// ¿Ya dejó review?
  final bool hasReviewed;

  const ReviewWindowStatusModel({
    required this.canReview,
    required this.daysRemaining,
    required this.hasReviewed,
  });

  /// Crea una instancia desde JSON
  factory ReviewWindowStatusModel.fromJson(Map<String, dynamic> json) {
    return ReviewWindowStatusModel(
      canReview: json['canReview'] as bool? ?? false,
      daysRemaining: json['daysRemaining'] as int? ?? 0,
      hasReviewed: json['hasReviewed'] as bool? ?? false,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'canReview': canReview,
      'daysRemaining': daysRemaining,
      'hasReviewed': hasReviewed,
    };
  }

  /// Mensaje descriptivo del estado
  String get statusMessage {
    if (hasReviewed) {
      return 'Ya dejaste una reseña';
    }
    if (canReview) {
      if (daysRemaining > 0) {
        return 'Tienes $daysRemaining día${daysRemaining == 1 ? '' : 's'} para dejar tu reseña';
      }
      return 'Puedes dejar tu reseña ahora';
    }
    return 'El período para dejar reseña ha expirado';
  }

  @override
  List<Object?> get props => [canReview, daysRemaining, hasReviewed];
}

