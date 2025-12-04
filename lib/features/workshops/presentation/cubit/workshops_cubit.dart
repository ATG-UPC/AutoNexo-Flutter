import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/enums/status.dart';
import '../../../../core/services/preferences_service.dart';
import '../../data/repositories/workshops_repository.dart';
import 'workshops_state.dart';

/// Cubit para gestionar la búsqueda de talleres
class WorkshopsCubit extends Cubit<WorkshopsState> {
  final WorkshopsRepository _repository;
  final PreferencesService _preferencesService;

  WorkshopsCubit({
    WorkshopsRepository? repository,
    PreferencesService? preferencesService,
  })  : _repository = repository ?? WorkshopsRepository(),
        _preferencesService = preferencesService ?? PreferencesService(),
        super(const WorkshopsState()) {
    _loadFavorites();
  }

  /// Inicializar con ubicación actual
  Future<void> initialize() async {
    await _getCurrentLocationAndSearch();
  }

  /// Obtener ubicación actual y buscar talleres cercanos
  Future<void> _getCurrentLocationAndSearch() async {
    if (isClosed) return;

    emit(state.copyWith(status: Status.loading, clearError: true));

    try {
      // Verificar permisos de ubicación
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (isClosed) return;
          emit(state.copyWith(
            status: Status.success,
            errorMessage: 'Permiso de ubicación denegado. Mostrando todos los talleres.',
          ));
          // Buscar sin ubicación
          await searchWorkshops(const WorkshopSearchParams());
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (isClosed) return;
        emit(state.copyWith(
          status: Status.success,
          errorMessage: 'Permisos de ubicación denegados permanentemente.',
        ));
        await searchWorkshops(const WorkshopSearchParams());
        return;
      }

      // Obtener ubicación
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      if (isClosed) return;

      // Buscar con ubicación
      await searchWorkshops(WorkshopSearchParams(
        latitude: position.latitude,
        longitude: position.longitude,
        radiusKm: 50,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: 'Error al obtener ubicación: ${e.toString().replaceFirst('Exception: ', '')}',
      ));
    }
  }

  /// Buscar talleres con parámetros
  Future<void> searchWorkshops(WorkshopSearchParams params) async {
    if (isClosed) return;

    emit(state.copyWith(
      status: Status.loading, 
      searchParams: params,
      clearError: true,
    ));

    try {
      final results = await _repository.searchWorkshops(params);

      if (isClosed) return;

      emit(state.copyWith(
        status: Status.success,
        searchResults: results,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: Status.failure,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  /// Cambiar radio de búsqueda
  Future<void> updateSearchRadius(int radiusKm) async {
    final newParams = WorkshopSearchParams(
      latitude: state.searchParams.latitude,
      longitude: state.searchParams.longitude,
      radiusKm: radiusKm,
      services: state.searchParams.services,
      tags: state.searchParams.tags,
      minRating: state.searchParams.minRating,
    );
    await searchWorkshops(newParams);
  }

  /// Cambiar rating mínimo
  Future<void> updateMinRating(double? minRating) async {
    final newParams = WorkshopSearchParams(
      latitude: state.searchParams.latitude,
      longitude: state.searchParams.longitude,
      radiusKm: state.searchParams.radiusKm,
      services: state.searchParams.services,
      tags: state.searchParams.tags,
      minRating: minRating,
    );
    await searchWorkshops(newParams);
  }

  /// Filtrar por servicios
  Future<void> updateServicesFilter(List<String>? services) async {
    final newParams = WorkshopSearchParams(
      latitude: state.searchParams.latitude,
      longitude: state.searchParams.longitude,
      radiusKm: state.searchParams.radiusKm,
      services: services,
      tags: state.searchParams.tags,
      minRating: state.searchParams.minRating,
    );
    await searchWorkshops(newParams);
  }

  /// Cargar perfil de un taller
  Future<void> loadWorkshopProfile(int workshopId) async {
    if (isClosed) return;

    emit(state.copyWith(isLoadingProfile: true, clearError: true));

    try {
      final profile = await _repository.getWorkshopProfile(workshopId);

      if (isClosed) return;

      emit(state.copyWith(
        selectedWorkshop: profile,
        isLoadingProfile: false,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoadingProfile: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  /// Limpiar taller seleccionado
  void clearSelectedWorkshop() {
    if (isClosed) return;
    emit(state.copyWith(clearSelectedWorkshop: true));
  }

  /// Limpiar errores
  void clearError() {
    if (isClosed) return;
    emit(state.copyWith(clearError: true));
  }

  /// Refrescar búsqueda actual
  Future<void> refresh() async {
    await searchWorkshops(state.searchParams);
  }

  /// Buscar nuevamente con ubicación actual
  Future<void> searchWithCurrentLocation() async {
    await _getCurrentLocationAndSearch();
  }

  // === Favorites ===

  /// Cargar favoritos desde el almacenamiento local
  Future<void> _loadFavorites() async {
    try {
      final favorites = await _preferencesService.getFavoriteWorkshops();
      if (isClosed) return;
      emit(state.copyWith(favoriteWorkshopIds: favorites.toSet()));
    } catch (e) {
      // Silently fail - favoritos no son críticos
    }
  }

  /// Alternar el estado de favorito de un workshop
  Future<void> toggleFavorite(int workshopId) async {
    if (isClosed) return;

    try {
      final isFavorite = await _preferencesService.toggleFavoriteWorkshop(workshopId);
      
      // Actualizar estado local
      final newFavorites = Set<int>.from(state.favoriteWorkshopIds);
      if (isFavorite) {
        newFavorites.add(workshopId);
      } else {
        newFavorites.remove(workshopId);
      }
      
      if (isClosed) return;
      emit(state.copyWith(favoriteWorkshopIds: newFavorites));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        errorMessage: 'Error al actualizar favorito: ${e.toString()}',
      ));
    }
  }

  /// Verificar si un workshop es favorito
  bool isFavorite(int workshopId) {
    return state.isFavorite(workshopId);
  }
}

