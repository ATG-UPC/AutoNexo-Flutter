import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../data/repositories/home_repository.dart';
import 'home_state.dart';

/// Cubit para manejar el estado del home
class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _homeRepository;
  
  // Bandera para evitar cargas simultáneas
  bool _isLoading = false;

  HomeCubit(this._homeRepository) : super(const HomeState());

  /// Cargar datos iniciales del home
  /// Evita cargas simultáneas y no bloquea la UI
  Future<void> loadHomeData({bool forceRefresh = false}) async {
    // Evitar cargas simultáneas
    if (_isLoading) return;
    
    // Si ya hay datos y no es refresh forzado, no recargar
    if (!forceRefresh && state.status == Status.success) return;
    
    _isLoading = true;
    
    // Solo mostrar loading si es la primera carga
    final isFirstLoad = state.status == Status.initial;
    
    if (isFirstLoad) {
      emit(state.copyWith(status: Status.loading));
    }

    try {
      // Cargar cita actual y horario en paralelo
      final results = await Future.wait([
        _homeRepository.getCurrentAppointment(),
        _loadSchedule(),
      ]);

      final appointment = results[0] as dynamic;
      final schedule = results[1] as List;

      if (!isClosed) {
        emit(
          state.copyWith(
            status: Status.success,
            currentAppointment: appointment,
            scheduleSlots: schedule.cast(),
            clearError: true,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        final errorMessage = _parseErrorMessage(e);
        
        if (isFirstLoad) {
          emit(
            state.copyWith(
              status: Status.failure,
              errorMessage: errorMessage,
            ),
          );
        } else {
          // Si ya hay datos, mantener success pero guardar el error
          emit(
            state.copyWith(
              status: Status.success,
              errorMessage: errorMessage,
            ),
          );
        }
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Cargar horario del mes actual
  Future<List> _loadSchedule() async {
    final now = DateTime.now();
    return await _homeRepository.getSchedule(
      month: now.month.toString(),
      year: now.year.toString(),
    );
  }

  /// Cambiar tab del bottom navigation
  /// NO emite status loading - solo cambia el índice
  void changeNavIndex(int index) {
    if (state.selectedNavIndex != index) {
      emit(state.copyWith(
        selectedNavIndex: index,
        // Mantener el status actual, no cambiarlo
      ));
    }
  }

  /// Forzar recarga de datos (para pull-to-refresh)
  Future<void> refresh() async {
    await loadHomeData(forceRefresh: true);
  }

  /// Recargar solo la cita actual
  Future<void> refreshAppointment() async {
    if (_isLoading) return;
    
    try {
      final appointment = await _homeRepository.getCurrentAppointment();
      if (!isClosed) {
        emit(
          state.copyWith(
            currentAppointment: appointment, 
            clearError: true,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            errorMessage: _parseErrorMessage(e),
          ),
        );
      }
    }
  }

  /// Recargar horario de un mes específico
  Future<void> refreshSchedule({String? month, String? year}) async {
    if (_isLoading) return;
    
    try {
      final now = DateTime.now();
      final schedule = await _homeRepository.getSchedule(
        month: month ?? now.month.toString(),
        year: year ?? now.year.toString(),
      );

      if (!isClosed) {
        emit(
          state.copyWith(
            scheduleSlots: schedule, 
            clearError: true,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            errorMessage: _parseErrorMessage(e),
          ),
        );
      }
    }
  }

  /// Limpiar mensaje de error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Parsear mensaje de error amigable
  String _parseErrorMessage(dynamic error) {
    String message = error.toString();
    
    message = message.replaceAll('Exception: ', '');
    message = message.replaceAll('Error: ', '');
    
    if (message.length > 150 || message.contains('SocketException') || 
        message.contains('TimeoutException')) {
      return 'Error de conexión. Verifica tu internet e intenta de nuevo.';
    }
    
    return message;
  }
}
