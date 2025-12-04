import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/status.dart';
import '../../data/models/models.dart';
import '../../data/repositories/bookings_repository.dart';
import 'bookings_state.dart';

/// Cubit para gestionar el estado de las reservas de servicio
class BookingsCubit extends Cubit<BookingsState> {
  final BookingsRepository _repository;
  bool _isLoading = false;

  BookingsCubit({BookingsRepository? repository})
      : _repository = repository ?? BookingsRepository(),
        super(const BookingsState());

  /// Cargar reservas inicial
  Future<void> loadBookings({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;

    if (isClosed) return;

    emit(state.copyWith(
      status: refresh ? state.status : Status.loading,
      clearError: true,
    ));

    try {
      final response = await _repository.getMyBookings(
        page: 0,
        size: 20,
        sort: 'scheduledDate,desc',
      );

      if (isClosed) return;

      emit(state.copyWith(
        status: Status.success,
        bookings: response.content,
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        totalElements: response.totalElements,
        hasMore: !response.isLast,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    } finally {
      _isLoading = false;
    }
  }

  /// Cargar más reservas (paginación infinita)
  Future<void> loadMoreBookings() async {
    if (_isLoading || !state.hasMore || state.isLoadingMore) return;

    if (isClosed) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final response = await _repository.getMyBookings(
        page: state.currentPage + 1,
        size: 20,
        sort: 'scheduledDate,desc',
      );

      if (isClosed) return;

      emit(state.copyWith(
        bookings: [...state.bookings, ...response.content],
        currentPage: response.currentPage,
        totalPages: response.totalPages,
        totalElements: response.totalElements,
        hasMore: !response.isLast,
        isLoadingMore: false,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  /// Cambiar filtro de bookings
  void setFilter(BookingFilter filter) {
    if (state.filter == filter) return;
    emit(state.copyWith(filter: filter));
  }

  /// Obtener detalle de una reserva
  Future<void> getBookingDetail(int id) async {
    if (isClosed) return;

    emit(state.copyWith(status: Status.loading, clearError: true));

    try {
      final booking = await _repository.getBookingById(id);

      if (isClosed) return;

      emit(state.copyWith(
        status: Status.success,
        selectedBooking: booking,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  /// Confirmar recogida del vehículo
  Future<bool> confirmPickup(int bookingId) async {
    if (isClosed) return false;

    emit(state.copyWith(status: Status.loading, clearError: true, clearSuccess: true));

    try {
      final updatedBooking = await _repository.confirmPickup(bookingId);

      if (isClosed) return false;

      // Actualizar el booking en la lista
      final updatedBookings = state.bookings.map((b) => 
          b.id == bookingId ? updatedBooking : b).toList();

      emit(state.copyWith(
        status: Status.success,
        bookings: updatedBookings,
        selectedBooking: updatedBooking,
        successMessage: '¡Recogida confirmada! Gracias por usar AutoNexo.',
      ));

      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  /// Cancelar una reserva
  Future<bool> cancelBooking(int bookingId, {String? reason}) async {
    if (isClosed) return false;

    emit(state.copyWith(status: Status.loading, clearError: true, clearSuccess: true));

    try {
      final updatedBooking = await _repository.cancelBooking(bookingId, reason: reason);

      if (isClosed) return false;

      // Actualizar el booking en la lista
      final updatedBookings = state.bookings.map((b) => 
          b.id == bookingId ? updatedBooking : b).toList();

      emit(state.copyWith(
        status: Status.success,
        bookings: updatedBookings,
        selectedBooking: updatedBooking,
        successMessage: 'Reserva cancelada exitosamente.',
      ));

      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  /// Seleccionar un booking
  void selectBooking(ServiceBookingModel booking) {
    if (isClosed) return;
    emit(state.copyWith(selectedBooking: booking));
  }

  /// Limpiar booking seleccionado
  void clearSelectedBooking() {
    if (isClosed) return;
    emit(state.copyWith(clearSelectedBooking: true));
  }

  /// Limpiar mensajes
  void clearMessages() {
    if (isClosed) return;
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  /// Refrescar bookings
  Future<void> refreshBookings() async {
    await loadBookings(refresh: true);
  }
}

