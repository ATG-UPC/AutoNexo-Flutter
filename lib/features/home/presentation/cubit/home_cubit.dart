import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../data/repositories/home_repository.dart';
import 'home_state.dart';

/// Cubit para manejar el estado del home
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;

  HomeCubit(this._homeRepository) : super(const HomeState());

  /// Cargar datos iniciales del home
  Future<void> loadHomeData() async {
    emit(state.copyWith(status: Status.loading));

    try {
      // Cargar cita actual
      final appointment = await _homeRepository.getCurrentAppointment();

      // Cargar horario del mes actual
      final now = DateTime.now();
      final schedule = await _homeRepository.getSchedule(
        month: now.month.toString(),
        year: now.year.toString(),
      );

      emit(
        state.copyWith(
          status: Status.success,
          currentAppointment: appointment,
          scheduleSlots: schedule,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  /// Cambiar tab del bottom navigation
  void changeNavIndex(int index) {
    emit(state.copyWith(selectedNavIndex: index));
  }

  /// Recargar solo la cita actual
  Future<void> refreshAppointment() async {
    try {
      final appointment = await _homeRepository.getCurrentAppointment();
      emit(
        state.copyWith(currentAppointment: appointment, status: Status.success),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  /// Recargar horario
  Future<void> refreshSchedule({String? month, String? year}) async {
    try {
      final now = DateTime.now();
      final schedule = await _homeRepository.getSchedule(
        month: month ?? now.month.toString(),
        year: year ?? now.year.toString(),
      );

      emit(state.copyWith(scheduleSlots: schedule, status: Status.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}
