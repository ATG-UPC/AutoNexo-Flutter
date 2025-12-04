import 'package:equatable/equatable.dart';
import '../../data/models/models.dart';

/// Estados posibles del flujo
enum ServiceRequestsStatus {
  initial,
  loading,
  loaded,
  creating,
  created,
  cancelling,
  cancelled,
  error,
}

/// Estado del cubit de solicitudes de servicio
class ServiceRequestsState extends Equatable {
  /// Estado actual del flujo
  final ServiceRequestsStatus status;

  /// Lista de solicitudes del usuario
  final List<ServiceRequestModel> serviceRequests;

  /// Catálogo de servicios disponibles
  final List<ServiceCatalogItem> serviceCatalog;

  /// Categorías de servicios
  final List<ServiceCategoryModel> serviceCategories;

  /// Solicitud actualmente seleccionada
  final ServiceRequestModel? selectedRequest;

  /// Filtro actual de estado
  final String? statusFilter;

  /// Mensaje de error (si hay)
  final String? errorMessage;

  /// Mensaje de éxito (si hay)
  final String? successMessage;

  const ServiceRequestsState({
    this.status = ServiceRequestsStatus.initial,
    this.serviceRequests = const [],
    this.serviceCatalog = const [],
    this.serviceCategories = const [],
    this.selectedRequest,
    this.statusFilter,
    this.errorMessage,
    this.successMessage,
  });

  /// Estado inicial
  factory ServiceRequestsState.initial() => const ServiceRequestsState();

  /// Crea una copia con campos actualizados
  ServiceRequestsState copyWith({
    ServiceRequestsStatus? status,
    List<ServiceRequestModel>? serviceRequests,
    List<ServiceCatalogItem>? serviceCatalog,
    List<ServiceCategoryModel>? serviceCategories,
    ServiceRequestModel? selectedRequest,
    String? statusFilter,
    String? errorMessage,
    String? successMessage,
    bool clearSelectedRequest = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ServiceRequestsState(
      status: status ?? this.status,
      serviceRequests: serviceRequests ?? this.serviceRequests,
      serviceCatalog: serviceCatalog ?? this.serviceCatalog,
      serviceCategories: serviceCategories ?? this.serviceCategories,
      selectedRequest: clearSelectedRequest ? null : (selectedRequest ?? this.selectedRequest),
      statusFilter: statusFilter ?? this.statusFilter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  /// Verifica si hay datos cargados
  bool get hasData => serviceRequests.isNotEmpty || serviceCatalog.isNotEmpty;

  /// Verifica si está cargando
  bool get isLoading => status == ServiceRequestsStatus.loading;

  /// Verifica si está creando
  bool get isCreating => status == ServiceRequestsStatus.creating;

  /// Obtiene las solicitudes filtradas por estado
  List<ServiceRequestModel> get filteredRequests {
    if (statusFilter == null) return serviceRequests;
    return serviceRequests
        .where((r) => r.status.value == statusFilter)
        .toList();
  }

  /// Obtiene las solicitudes pendientes
  List<ServiceRequestModel> get pendingRequests =>
      serviceRequests.where((r) => r.isPending).toList();

  /// Obtiene el catálogo agrupado por categoría
  Map<String, List<ServiceCatalogItem>> get catalogByCategory {
    final map = <String, List<ServiceCatalogItem>>{};
    for (final item in serviceCatalog) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  @override
  List<Object?> get props => [
        status,
        serviceRequests,
        serviceCatalog,
        serviceCategories,
        selectedRequest,
        statusFilter,
        errorMessage,
        successMessage,
      ];
}

