import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/models.dart';
import '../../data/repositories/maintenances_repository.dart';
import 'maintenances_state.dart';

/// Cubit para gestionar mantenimientos
class MaintenancesCubit extends Cubit<MaintenancesState> {
  final MaintenancesRepository _repository;

  MaintenancesCubit({MaintenancesRepository? repository})
      : _repository = repository ?? MaintenancesRepository(),
        super(MaintenancesState.initial());

  /// Carga el historial de mantenimientos de un vehículo
  Future<void> loadVehicleMaintenances(int vehicleId, {int page = 0}) async {
    if (isClosed) return;

    emit(state.copyWith(
      status: MaintenancesStatus.loading,
      currentVehicleId: vehicleId,
      clearError: true,
    ));

    try {
      final response = await _repository.getVehicleMaintenances(
        vehicleId,
        page: page,
        sort: 'maintenanceDate,desc',
      );

      if (isClosed) return;

      emit(state.copyWith(
        status: MaintenancesStatus.loaded,
        maintenances: page == 0 
            ? response.content 
            : [...state.maintenances, ...response.content],
        paginatedResponse: response,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: MaintenancesStatus.error,
        errorMessage: _parseError(e),
      ));
    }
  }

  /// Carga más mantenimientos (paginación)
  Future<void> loadMoreMaintenances() async {
    if (state.currentVehicleId == null || !state.hasMorePages) return;
    
    final nextPage = (state.paginatedResponse?.currentPage ?? 0) + 1;
    await loadVehicleMaintenances(state.currentVehicleId!, page: nextPage);
  }

  /// Refresca la lista de mantenimientos
  Future<void> refresh() async {
    if (state.currentVehicleId != null) {
      await loadVehicleMaintenances(state.currentVehicleId!);
    }
  }

  /// Obtiene un mantenimiento por ID
  Future<void> getMaintenanceById(int id) async {
    if (isClosed) return;

    emit(state.copyWith(
      status: MaintenancesStatus.loading,
      clearError: true,
    ));

    try {
      final maintenance = await _repository.getMaintenanceById(id);

      if (isClosed) return;

      emit(state.copyWith(
        status: MaintenancesStatus.loaded,
        selectedMaintenance: maintenance,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: MaintenancesStatus.error,
        errorMessage: _parseError(e),
      ));
    }
  }

  /// Crea un mantenimiento manual
  Future<bool> createManualMaintenance(CreateManualMaintenanceRequest request) async {
    if (isClosed) return false;

    emit(state.copyWith(
      status: MaintenancesStatus.creating,
      clearError: true,
    ));

    try {
      final maintenance = await _repository.createManualMaintenance(request);

      if (isClosed) return false;

      emit(state.copyWith(
        status: MaintenancesStatus.created,
        maintenances: [maintenance, ...state.maintenances],
        successMessage: 'Mantenimiento registrado correctamente',
      ));

      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(
        status: MaintenancesStatus.error,
        errorMessage: _parseError(e),
      ));
      return false;
    }
  }

  /// Confirma un mantenimiento
  Future<bool> confirmMaintenance(int id) async {
    if (isClosed) return false;

    emit(state.copyWith(
      status: MaintenancesStatus.confirming,
      clearError: true,
    ));

    try {
      final maintenance = await _repository.confirmMaintenance(id);

      if (isClosed) return false;

      // Actualizar en la lista
      final updatedList = state.maintenances.map((m) {
        return m.id == id ? maintenance : m;
      }).toList();

      emit(state.copyWith(
        status: MaintenancesStatus.confirmed,
        maintenances: updatedList,
        selectedMaintenance: maintenance,
        successMessage: 'Mantenimiento confirmado',
      ));

      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(
        status: MaintenancesStatus.error,
        errorMessage: _parseError(e),
      ));
      return false;
    }
  }

  /// Rechaza un mantenimiento
  Future<bool> rejectMaintenance(int id) async {
    if (isClosed) return false;

    emit(state.copyWith(
      status: MaintenancesStatus.rejecting,
      clearError: true,
    ));

    try {
      final maintenance = await _repository.rejectMaintenance(id);

      if (isClosed) return false;

      // Actualizar en la lista
      final updatedList = state.maintenances.map((m) {
        return m.id == id ? maintenance : m;
      }).toList();

      emit(state.copyWith(
        status: MaintenancesStatus.rejected,
        maintenances: updatedList,
        selectedMaintenance: maintenance,
        successMessage: 'Mantenimiento rechazado',
      ));

      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(
        status: MaintenancesStatus.error,
        errorMessage: _parseError(e),
      ));
      return false;
    }
  }

  /// Selecciona un mantenimiento
  void selectMaintenance(MaintenanceModel maintenance) {
    if (isClosed) return;
    emit(state.copyWith(selectedMaintenance: maintenance));
  }

  /// Limpia el mantenimiento seleccionado
  void clearSelectedMaintenance() {
    if (isClosed) return;
    emit(state.copyWith(clearSelectedMaintenance: true));
  }

  /// Limpia mensajes
  void clearMessages() {
    if (isClosed) return;
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  String _parseError(dynamic error) {
    final errorStr = error.toString();
    if (errorStr.startsWith('Exception: ')) {
      return errorStr.replaceFirst('Exception: ', '');
    }
    return errorStr;
  }
}

