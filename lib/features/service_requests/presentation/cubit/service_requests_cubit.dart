import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/models.dart';
import '../../data/repositories/service_request_repository.dart';
import 'service_requests_state.dart';

/// Cubit para gestión de solicitudes de servicio
class ServiceRequestsCubit extends Cubit<ServiceRequestsState> {
  final ServiceRequestRepository _repository;
  bool _isLoading = false;

  ServiceRequestsCubit({ServiceRequestRepository? repository})
      : _repository = repository ?? ServiceRequestRepository(),
        super(ServiceRequestsState.initial());

  /// Carga el catálogo de servicios y categorías
  Future<void> loadCatalog() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final results = await Future.wait([
        _repository.getServiceCatalog(),
        _repository.getServiceCategories(),
      ]);

      if (isClosed) return;

      emit(state.copyWith(
        serviceCatalog: results[0] as List<ServiceCatalogItem>,
        serviceCategories: results[1] as List<ServiceCategoryModel>,
        clearError: true,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        errorMessage: _parseErrorMessage(e),
      ));
    } finally {
      _isLoading = false;
    }
  }

  /// Carga las solicitudes del usuario
  /// Nota: Siempre carga todas las solicitudes, el filtrado se hace del lado del cliente
  Future<void> loadServiceRequests({String? status}) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      if (!isClosed) {
        emit(state.copyWith(
          status: ServiceRequestsStatus.loading,
          clearError: true,
        ));
      }

      // Siempre cargar todas las solicitudes sin filtro del backend
      // El filtrado se hace del lado del cliente en filteredRequests
      final requests = await _repository.getMyServiceRequests();

      if (isClosed) return;

      emit(state.copyWith(
        status: ServiceRequestsStatus.loaded,
        serviceRequests: requests,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: ServiceRequestsStatus.error,
        errorMessage: _parseErrorMessage(e),
      ));
    } finally {
      _isLoading = false;
    }
  }

  /// Carga datos iniciales (catálogo + solicitudes)
  Future<void> loadInitialData() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      if (!isClosed) {
        emit(state.copyWith(
          status: ServiceRequestsStatus.loading,
          clearError: true,
        ));
      }

      // Cargar catálogo (público, no requiere auth)
      final catalogFuture = _repository.getServiceCatalog();
      final categoriesFuture = _repository.getServiceCategories();
      
      // Cargar solicitudes del usuario
      final requestsFuture = _repository.getMyServiceRequests();

      final results = await Future.wait([
        catalogFuture,
        categoriesFuture,
        requestsFuture,
      ]);

      if (isClosed) return;

      emit(state.copyWith(
        status: ServiceRequestsStatus.loaded,
        serviceCatalog: results[0] as List<ServiceCatalogItem>,
        serviceCategories: results[1] as List<ServiceCategoryModel>,
        serviceRequests: results[2] as List<ServiceRequestModel>,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: ServiceRequestsStatus.error,
        errorMessage: _parseErrorMessage(e),
      ));
    } finally {
      _isLoading = false;
    }
  }

  /// Obtiene una solicitud por ID
  Future<void> getServiceRequestById(int id) async {
    try {
      if (!isClosed) {
        emit(state.copyWith(
          status: ServiceRequestsStatus.loading,
          clearError: true,
        ));
      }

      final request = await _repository.getServiceRequestById(id);

      if (isClosed) return;

      emit(state.copyWith(
        status: ServiceRequestsStatus.loaded,
        selectedRequest: request,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: ServiceRequestsStatus.error,
        errorMessage: _parseErrorMessage(e),
      ));
    }
  }

  /// Crea una nueva solicitud de servicio
  Future<bool> createServiceRequest(CreateServiceRequest request) async {
    try {
      if (!isClosed) {
        emit(state.copyWith(
          status: ServiceRequestsStatus.creating,
          clearError: true,
        ));
      }

      final newRequest = await _repository.createServiceRequest(request);

      if (isClosed) return false;

      // Agregar la nueva solicitud a la lista
      final updatedRequests = [newRequest, ...state.serviceRequests];

      emit(state.copyWith(
        status: ServiceRequestsStatus.created,
        serviceRequests: updatedRequests,
        successMessage: 'Solicitud creada exitosamente',
      ));

      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(
        status: ServiceRequestsStatus.error,
        errorMessage: _parseErrorMessage(e),
      ));
      return false;
    }
  }

  /// Cancela una solicitud de servicio
  Future<bool> cancelServiceRequest(int id) async {
    try {
      if (!isClosed) {
        emit(state.copyWith(
          status: ServiceRequestsStatus.cancelling,
          clearError: true,
        ));
      }

      await _repository.cancelServiceRequest(id);

      if (isClosed) return false;

      // Actualizar el estado de la solicitud en la lista
      final updatedRequests = state.serviceRequests.map((r) {
        if (r.id == id) {
          // No podemos modificar el objeto directamente, así que recargamos
          return r; // Se recargará después
        }
        return r;
      }).toList();

      emit(state.copyWith(
        status: ServiceRequestsStatus.cancelled,
        serviceRequests: updatedRequests,
        successMessage: 'Solicitud cancelada exitosamente',
        clearSelectedRequest: true,
      ));

      // Recargar la lista para obtener el estado actualizado
      await loadServiceRequests();

      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(
        status: ServiceRequestsStatus.error,
        errorMessage: _parseErrorMessage(e),
      ));
      return false;
    }
  }

  /// Cambia el filtro de estado
  void setStatusFilter(String? status) {
    emit(state.copyWith(statusFilter: status));
    // No recargar desde el backend, solo actualizar el filtro
    // El filtrado se hace del lado del cliente en filteredRequests
  }

  /// Limpia la solicitud seleccionada
  void clearSelectedRequest() {
    emit(state.copyWith(clearSelectedRequest: true));
  }

  /// Limpia mensajes de error y éxito
  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  /// Parsea el mensaje de error
  String _parseErrorMessage(dynamic error) {
    final errorStr = error.toString();
    
    if (errorStr.contains('Exception:')) {
      return errorStr.replaceFirst('Exception:', '').trim();
    }
    
    if (errorStr.contains('Sin conexión')) {
      return 'Sin conexión a internet. Verifica tu conexión.';
    }
    
    if (errorStr.contains('Sesión expirada')) {
      return 'Sesión expirada. Por favor inicia sesión nuevamente.';
    }
    
    return 'Ha ocurrido un error. Intenta nuevamente.';
  }
}

