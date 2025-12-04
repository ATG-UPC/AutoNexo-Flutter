import 'package:equatable/equatable.dart';
import '../../data/models/models.dart';
import '../../data/repositories/reviews_repository.dart';

/// Estados del cubit de reviews
enum ReviewsStatus {
  initial,
  loading,
  loaded,
  submitting,
  submitted,
  error,
}

/// Estado del cubit de reviews
class ReviewsState extends Equatable {
  final ReviewsStatus status;
  final List<ReviewModel> reviews;
  final ReviewWindowStatusModel? windowStatus;
  final int? currentBookingId;
  final int? currentWorkshopId;
  final PaginatedReviewsResponse? paginatedResponse;
  final String? errorMessage;
  final String? successMessage;

  const ReviewsState({
    this.status = ReviewsStatus.initial,
    this.reviews = const [],
    this.windowStatus,
    this.currentBookingId,
    this.currentWorkshopId,
    this.paginatedResponse,
    this.errorMessage,
    this.successMessage,
  });

  factory ReviewsState.initial() => const ReviewsState();

  ReviewsState copyWith({
    ReviewsStatus? status,
    List<ReviewModel>? reviews,
    ReviewWindowStatusModel? windowStatus,
    int? currentBookingId,
    int? currentWorkshopId,
    PaginatedReviewsResponse? paginatedResponse,
    String? errorMessage,
    String? successMessage,
    bool clearWindowStatus = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ReviewsState(
      status: status ?? this.status,
      reviews: reviews ?? this.reviews,
      windowStatus: clearWindowStatus ? null : (windowStatus ?? this.windowStatus),
      currentBookingId: currentBookingId ?? this.currentBookingId,
      currentWorkshopId: currentWorkshopId ?? this.currentWorkshopId,
      paginatedResponse: paginatedResponse ?? this.paginatedResponse,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  /// ¿Está cargando?
  bool get isLoading => status == ReviewsStatus.loading;

  /// ¿Está enviando una review?
  bool get isSubmitting => status == ReviewsStatus.submitting;

  /// ¿Puede dejar review?
  bool get canReview => windowStatus?.canReview ?? false;

  /// ¿Ya dejó review?
  bool get hasReviewed => windowStatus?.hasReviewed ?? false;

  /// ¿Hay reviews?
  bool get hasReviews => reviews.isNotEmpty;

  /// Promedio de rating
  double get averageRating {
    if (reviews.isEmpty) return 0;
    final sum = reviews.fold<int>(0, (sum, r) => sum + r.rating);
    return sum / reviews.length;
  }

  /// Total de reviews
  int get totalReviews => paginatedResponse?.totalElements ?? reviews.length;

  /// ¿Hay más páginas?
  bool get hasMorePages => !(paginatedResponse?.isLast ?? true);

  @override
  List<Object?> get props => [
        status,
        reviews,
        windowStatus,
        currentBookingId,
        currentWorkshopId,
        paginatedResponse,
        errorMessage,
        successMessage,
      ];
}




