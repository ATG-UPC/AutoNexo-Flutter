import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/status.dart';
import '../../../vehicles/data/models/models.dart';
import '../../../vehicles/data/repositories/vehicle_repository.dart';
import '../../../workshops/data/models/models.dart';
import '../../../workshops/data/repositories/workshops_repository.dart';
import '../../data/models/models.dart';
import '../../data/repositories/bookings_repository.dart';
import 'bookings_state.dart';

/// Cubit para gestionar el estado de las reservas de servicio
class BookingsCubit extends Cubit<BookingsState> {
  final BookingsRepository _repository;
  final WorkshopsRepository _workshopsRepository;
  final VehicleRepository _vehicleRepository;
  bool _isLoading = false;

  BookingsCubit({
    BookingsRepository? repository,
    WorkshopsRepository? workshopsRepository,
    VehicleRepository? vehicleRepository,
  })  : _repository = repository ?? BookingsRepository(),
        _workshopsRepository = workshopsRepository ?? WorkshopsRepository(),
        _vehicleRepository = vehicleRepository ?? VehicleRepository(),
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

      // Cargar información de talleres y vehículos en background
      loadBookingsInfo(response.content);
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

  /// Cargar información de un taller
  Future<void> loadWorkshopInfo(int workshopId) async {
    // Si ya está en cache, no hacer nada
    if (state.workshopsCache.containsKey(workshopId)) {
      return;
    }

    try {
      final workshop = await _workshopsRepository.getWorkshopProfile(workshopId);
      
      if (isClosed) return;

      final updatedCache = Map<int, WorkshopProfileModel>.from(state.workshopsCache);
      updatedCache[workshopId] = workshop;

      emit(state.copyWith(workshopsCache: updatedCache));
    } catch (e) {
      // Silenciar errores, solo no se cacheará la info
      // El UI mostrará el ID como fallback
    }
  }

  /// Cargar información de un vehículo
  Future<void> loadVehicleInfo(int vehicleId) async {
    // Si ya está en cache, no hacer nada
    if (state.vehiclesCache.containsKey(vehicleId)) {
      return;
    }

    try {
      final vehicle = await _vehicleRepository.getVehicleById(vehicleId);
      
      if (isClosed) return;

      final updatedCache = Map<int, VehicleModel>.from(state.vehiclesCache);
      updatedCache[vehicleId] = vehicle;

      emit(state.copyWith(vehiclesCache: updatedCache));
    } catch (e) {
      // Silenciar errores, solo no se cacheará la info
      // El UI mostrará el ID como fallback
    }
  }

  /// Cargar información de talleres y vehículos para una lista de bookings
  Future<void> loadBookingsInfo(List<ServiceBookingModel> bookings) async {
    final workshopIds = bookings.map((b) => b.workshopId).toSet();
    final vehicleIds = bookings.map((b) => b.vehicleId).toSet();

    // Filtrar IDs que no están en cache
    final missingWorkshopIds = workshopIds.where((id) => !state.workshopsCache.containsKey(id)).toList();
    final missingVehicleIds = vehicleIds.where((id) => !state.vehiclesCache.containsKey(id)).toList();

    // Cargar en paralelo
    final futures = <Future>[];
    
    for (final workshopId in missingWorkshopIds) {
      futures.add(loadWorkshopInfo(workshopId));
    }
    
    for (final vehicleId in missingVehicleIds) {
      futures.add(loadVehicleInfo(vehicleId));
    }

    await Future.wait(futures, eagerError: false);
  }
}

