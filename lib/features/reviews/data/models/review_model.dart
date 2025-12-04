import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Tipos de review
enum ReviewType {
  userToWorkshop('USER_TO_WORKSHOP'),
  workshopToUser('WORKSHOP_TO_USER');

  const ReviewType(this.value);
  final String value;

  static ReviewType fromString(String value) {
    return ReviewType.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => ReviewType.userToWorkshop,
    );
  }
}

/// Estados de review
enum ReviewStatus {
  active('ACTIVE'),
  hidden('HIDDEN'),
  deleted('DELETED');

  const ReviewStatus(this.value);
  final String value;

  static ReviewStatus fromString(String value) {
    return ReviewStatus.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => ReviewStatus.active,
    );
  }
}

/// Modelo de Review
class ReviewModel extends Equatable {
  final int id;
  final int serviceBookingId;
  final int reviewerId;
  final int revieweeId;
  final ReviewType reviewType;
  final int rating;
  final String? comment;
  final ReviewStatus status;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.serviceBookingId,
    required this.reviewerId,
    required this.revieweeId,
    required this.reviewType,
    required this.rating,
    this.comment,
    required this.status,
    required this.createdAt,
  });

  /// Crea una instancia desde JSON
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int,
      serviceBookingId: json['serviceBookingId'] as int,
      reviewerId: json['reviewerId'] as int,
      revieweeId: json['revieweeId'] as int,
      reviewType: ReviewType.fromString(json['reviewType'] as String? ?? 'USER_TO_WORKSHOP'),
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      status: ReviewStatus.fromString(json['status'] as String? ?? 'ACTIVE'),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceBookingId': serviceBookingId,
      'reviewerId': reviewerId,
      'revieweeId': revieweeId,
      'reviewType': reviewType.value,
      'rating': rating,
      'comment': comment,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Fecha formateada
  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(createdAt);
  }

  /// Fecha y hora formateada
  String get formattedDateTime {
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  }

  /// ¿Es una review activa?
  bool get isActive => status == ReviewStatus.active;

  @override
  List<Object?> get props => [
        id,
        serviceBookingId,
        reviewerId,
        revieweeId,
        reviewType,
        rating,
        comment,
        status,
        createdAt,
      ];
}

/// Request para crear una review
class CreateReviewRequest {
  final int serviceBookingId;
  final int rating;
  final String? comment;

  const CreateReviewRequest({
    required this.serviceBookingId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceBookingId': serviceBookingId,
      'rating': rating,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
    };
  }
}




