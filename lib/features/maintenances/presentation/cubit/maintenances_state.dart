import 'package:equatable/equatable.dart';
import '../../data/models/models.dart';
import '../../data/repositories/maintenances_repository.dart';

/// Estados del cubit de mantenimientos
enum MaintenancesStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  confirming,
  confirmed,
  rejecting,
  rejected,
  error,
}

/// Estado del cubit de mantenimientos
class MaintenancesState extends Equatable {
  final MaintenancesStatus status;
  final List<MaintenanceModel> maintenances;
  final MaintenanceModel? selectedMaintenance;
  final int? currentVehicleId;
  final PaginatedMaintenancesResponse? paginatedResponse;
  final String? errorMessage;
  final String? successMessage;

  const MaintenancesState({
    this.status = MaintenancesStatus.initial,
    this.maintenances = const [],
    this.selectedMaintenance,
    this.currentVehicleId,
    this.paginatedResponse,
    this.errorMessage,
    this.successMessage,
  });

  factory MaintenancesState.initial() => const MaintenancesState();

  MaintenancesState copyWith({
    MaintenancesStatus? status,
    List<MaintenanceModel>? maintenances,
    MaintenanceModel? selectedMaintenance,
    int? currentVehicleId,
    PaginatedMaintenancesResponse? paginatedResponse,
    String? errorMessage,
    String? successMessage,
    bool clearSelectedMaintenance = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return MaintenancesState(
      status: status ?? this.status,
      maintenances: maintenances ?? this.maintenances,
      selectedMaintenance: clearSelectedMaintenance 
          ? null 
          : (selectedMaintenance ?? this.selectedMaintenance),
      currentVehicleId: currentVehicleId ?? this.currentVehicleId,
      paginatedResponse: paginatedResponse ?? this.paginatedResponse,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  /// ¿Está cargando?
  bool get isLoading => status == MaintenancesStatus.loading;

  /// ¿Está creando?
  bool get isCreating => status == MaintenancesStatus.creating;

  /// ¿Está confirmando?
  bool get isConfirming => status == MaintenancesStatus.confirming;

  /// ¿Está rechazando?
  bool get isRejecting => status == MaintenancesStatus.rejecting;

  /// ¿Está procesando?
  bool get isProcessing => isLoading || isCreating || isConfirming || isRejecting;

  /// ¿Hay mantenimientos?
  bool get hasMaintenances => maintenances.isNotEmpty;

  /// ¿Hay más páginas?
  bool get hasMorePages => !(paginatedResponse?.isLast ?? true);

  /// Mantenimientos pendientes de confirmación
  List<MaintenanceModel> get pendingMaintenances {
    return maintenances.where((m) => m.isPending).toList();
  }

  /// Total de mantenimientos
  int get totalMaintenances => paginatedResponse?.totalElements ?? maintenances.length;

  @override
  List<Object?> get props => [
        status,
        maintenances,
        selectedMaintenance,
        currentVehicleId,
        paginatedResponse,
        errorMessage,
        successMessage,
      ];
}



