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

  HomeState copyWith({
    Status? status,
    String? errorMessage,
    AppointmentModel? currentAppointment,
    List<ScheduleSlotModel>? scheduleSlots,
    int? selectedNavIndex,
  }) {
    return HomeState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      currentAppointment: currentAppointment ?? this.currentAppointment,
      scheduleSlots: scheduleSlots ?? this.scheduleSlots,
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    currentAppointment,
    scheduleSlots,
    selectedNavIndex,
  ];
}
