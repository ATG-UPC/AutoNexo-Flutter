import 'package:equatable/equatable.dart';
import '../../../../core/enums/status.dart';
import '../../data/models/models.dart';

/// Estados para el home
class HomeState extends Equatable {
  final Status status;
  final String? errorMessage;
  final AppointmentModel? currentAppointment;
  final List<ScheduleSlotModel> scheduleSlots;
  final int selectedNavIndex;

  const HomeState({
    this.status = Status.initial,
    this.errorMessage,
    this.currentAppointment,
    this.scheduleSlots = const [],
    this.selectedNavIndex = 0,
  });

  /// Copiar estado con nuevos valores
  /// 
  /// [clearError]: Si es true, limpia el errorMessage
  HomeState copyWith({
    Status? status,
    String? errorMessage,
    AppointmentModel? currentAppointment,
    List<ScheduleSlotModel>? scheduleSlots,
    int? selectedNavIndex,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentAppointment: currentAppointment ?? this.currentAppointment,
      scheduleSlots: scheduleSlots ?? this.scheduleSlots,
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
    );
  }

  /// Verificar si hay un error para mostrar
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Verificar si está cargando
  bool get isLoading => status == Status.loading;

  /// Verificar si tiene datos cargados
  bool get hasData => currentAppointment != null || scheduleSlots.isNotEmpty;

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    currentAppointment,
    scheduleSlots,
    selectedNavIndex,
  ];
}
