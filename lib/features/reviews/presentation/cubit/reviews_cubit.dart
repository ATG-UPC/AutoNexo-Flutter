import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/models.dart';
import '../../data/repositories/reviews_repository.dart';
import 'reviews_state.dart';

/// Cubit para gestionar reviews
class ReviewsCubit extends Cubit<ReviewsState> {
  final ReviewsRepository _repository;

  ReviewsCubit({ReviewsRepository? repository})
      : _repository = repository ?? ReviewsRepository(),
        super(ReviewsState.initial());

  /// Verifica si la ventana de review está abierta para un booking
  Future<void> checkReviewWindowStatus(int bookingId) async {
    if (isClosed) return;

    emit(state.copyWith(
      status: ReviewsStatus.loading,
      currentBookingId: bookingId,
      clearError: true,
    ));

    try {
      final windowStatus = await _repository.getReviewWindowStatus(bookingId);

      if (isClosed) return;

      emit(state.copyWith(
        status: ReviewsStatus.loaded,
        windowStatus: windowStatus,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: ReviewsStatus.error,
        errorMessage: _parseError(e),
      ));
    }
  }

  /// Carga las reviews de un taller
  Future<void> loadWorkshopReviews(int workshopId, {int page = 0}) async {
    if (isClosed) return;

    emit(state.copyWith(
      status: ReviewsStatus.loading,
      currentWorkshopId: workshopId,
      clearError: true,
    ));

    try {
      final response = await _repository.getWorkshopReviews(workshopId, page: page);

      if (isClosed) return;

      emit(state.copyWith(
        status: ReviewsStatus.loaded,
        reviews: page == 0 ? response.content : [...state.reviews, ...response.content],
        paginatedResponse: response,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: ReviewsStatus.error,
        errorMessage: _parseError(e),
      ));
    }
  }

  /// Carga más reviews (paginación)
  Future<void> loadMoreReviews() async {
    if (state.currentWorkshopId == null || !state.hasMorePages) return;
    
    final nextPage = (state.paginatedResponse?.currentPage ?? 0) + 1;
    await loadWorkshopReviews(state.currentWorkshopId!, page: nextPage);
  }

  /// Envía una nueva review
  Future<bool> submitReview({
    required int serviceBookingId,
    required int rating,
    String? comment,
  }) async {
    if (isClosed) return false;

    emit(state.copyWith(
      status: ReviewsStatus.submitting,
      clearError: true,
    ));

    try {
      final request = CreateReviewRequest(
        serviceBookingId: serviceBookingId,
        rating: rating,
        comment: comment,
      );

      final review = await _repository.createReview(request);

      if (isClosed) return false;

      emit(state.copyWith(
        status: ReviewsStatus.submitted,
        reviews: [review, ...state.reviews],
        successMessage: '¡Gracias por tu reseña!',
        windowStatus: const ReviewWindowStatusModel(
          canReview: false,
          daysRemaining: 0,
          hasReviewed: true,
        ),
      ));

      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(
        status: ReviewsStatus.error,
        errorMessage: _parseError(e),
      ));
      return false;
    }
  }

  /// Limpia mensajes
  void clearMessages() {
    if (isClosed) return;
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  /// Reset al estado inicial
  void reset() {
    if (isClosed) return;
    emit(ReviewsState.initial());
  }

  String _parseError(dynamic error) {
    final errorStr = error.toString();
    if (errorStr.startsWith('Exception: ')) {
      return errorStr.replaceFirst('Exception: ', '');
    }
    return errorStr;
  }
}


