import 'package:equatable/equatable.dart';

import '../../../../core/enums/status.dart';
import '../../data/models/models.dart';

/// Filtro de estado para bookings
enum BookingFilter {
  all,      // Todas las reservas
  active,   // SCHEDULED, IN_PROGRESS
  completed,// COMPLETED, PICKED_UP
  cancelled,// CANCELLED
}

/// Estado del Cubit de Bookings
class BookingsState extends Equatable {
  final Status status;
  final List<ServiceBookingModel> bookings;
  final ServiceBookingModel? selectedBooking;
  final BookingFilter filter;
  final String? errorMessage;
  final String? successMessage;
  
  // Paginación
  final int currentPage;
  final int totalPages;
  final int totalElements;
  final bool hasMore;
  final bool isLoadingMore;

  const BookingsState({
    this.status = Status.initial,
    this.bookings = const [],
    this.selectedBooking,
    this.filter = BookingFilter.all,
    this.errorMessage,
    this.successMessage,
    this.currentPage = 0,
    this.totalPages = 0,
    this.totalElements = 0,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  /// Bookings filtrados según el filtro actual
  List<ServiceBookingModel> get filteredBookings {
    switch (filter) {
      case BookingFilter.all:
        return bookings;
      case BookingFilter.active:
        return bookings.where((b) => 
            b.status == ServiceBookingStatus.SCHEDULED || 
            b.status == ServiceBookingStatus.IN_PROGRESS).toList();
      case BookingFilter.completed:
        return bookings.where((b) => 
            b.status == ServiceBookingStatus.COMPLETED || 
            b.status == ServiceBookingStatus.PICKED_UP).toList();
      case BookingFilter.cancelled:
        return bookings.where((b) => 
            b.status == ServiceBookingStatus.CANCELLED).toList();
    }
  }

  /// Cuenta de bookings por estado
  int get activeCount => bookings.where((b) => 
      b.status == ServiceBookingStatus.SCHEDULED || 
      b.status == ServiceBookingStatus.IN_PROGRESS).length;

  int get completedCount => bookings.where((b) => 
      b.status == ServiceBookingStatus.COMPLETED || 
      b.status == ServiceBookingStatus.PICKED_UP).length;

  int get cancelledCount => bookings.where((b) => 
      b.status == ServiceBookingStatus.CANCELLED).length;

  BookingsState copyWith({
    Status? status,
    List<ServiceBookingModel>? bookings,
    ServiceBookingModel? selectedBooking,
    BookingFilter? filter,
    String? errorMessage,
    String? successMessage,
    int? currentPage,
    int? totalPages,
    int? totalElements,
    bool? hasMore,
    bool? isLoadingMore,
    bool clearSelectedBooking = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return BookingsState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      selectedBooking: clearSelectedBooking ? null : (selectedBooking ?? this.selectedBooking),
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalElements: totalElements ?? this.totalElements,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        status,
        bookings,
        selectedBooking,
        filter,
        errorMessage,
        successMessage,
        currentPage,
        totalPages,
        totalElements,
        hasMore,
        isLoadingMore,
      ];
}

