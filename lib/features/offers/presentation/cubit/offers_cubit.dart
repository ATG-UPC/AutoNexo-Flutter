import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/models.dart';
import '../../data/repositories/offers_repository.dart';
import 'offers_state.dart';

/// Cubit para gestionar el estado de ofertas
class OffersCubit extends Cubit<OffersState> {
  final OffersRepository _repository;

  OffersCubit({OffersRepository? repository})
      : _repository = repository ?? OffersRepository(),
        super(OffersState.initial());

  /// Carga las ofertas para una solicitud de servicio
  Future<void> loadOffersForRequest(int requestId) async {
    if (isClosed) return;

    emit(state.copyWith(
      status: OffersStatus.loading,
      serviceRequestId: requestId,
      clearError: true,
    ));

    try {
      final offers = await _repository.getOffersForRequest(requestId);

      if (isClosed) return;

      emit(state.copyWith(
        status: OffersStatus.loaded,
        offers: offers,
      ));

      // Cargar info de talleres en background
      _loadWorkshopsInfo(offers);
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: OffersStatus.error,
        errorMessage: _parseError(e),
      ));
    }
  }

  /// Carga información de talleres para las ofertas (en background)
  Future<void> _loadWorkshopsInfo(List<OfferModel> offers) async {
    final workshopIds = offers.map((o) => o.workshopId).toSet();

    for (final workshopId in workshopIds) {
      if (isClosed) return;
      if (state.workshopsCache.containsKey(workshopId)) continue;

      try {
        final workshopInfo = await _repository.getWorkshopPublicInfo(workshopId);
        if (isClosed) return;

        final updatedCache = Map<int, WorkshopPublicModel>.from(state.workshopsCache);
        updatedCache[workshopId] = workshopInfo;

        emit(state.copyWith(workshopsCache: updatedCache));

        // También cargar trust score
        _loadTrustScore(workshopId);
      } catch (e) {
        // Ignorar errores de carga de info de taller
      }
    }
  }

  /// Carga el trust score de un taller
  Future<void> _loadTrustScore(int workshopId) async {
    if (isClosed) return;
    if (state.trustScoresCache.containsKey(workshopId)) return;

    try {
      final trustScore = await _repository.getWorkshopTrustScore(workshopId);
      if (isClosed) return;

      final updatedCache = Map<int, TrustScore>.from(state.trustScoresCache);
      updatedCache[workshopId] = trustScore;

      emit(state.copyWith(trustScoresCache: updatedCache));
    } catch (e) {
      // Ignorar errores de carga de trust score
    }
  }

  /// Selecciona una oferta para ver en detalle
  void selectOffer(OfferModel offer) {
    if (isClosed) return;
    emit(state.copyWith(selectedOffer: offer));
  }

  /// Limpia la oferta seleccionada
  void clearSelectedOffer() {
    if (isClosed) return;
    emit(state.copyWith(clearSelectedOffer: true));
  }

  /// Acepta una oferta
  Future<bool> acceptOffer(int offerId) async {
    if (isClosed) return false;

    emit(state.copyWith(
      status: OffersStatus.accepting,
      clearError: true,
    ));

    try {
      await _repository.acceptOffer(offerId);

      if (isClosed) return false;

      // Actualizar la lista de ofertas
      final updatedOffers = state.offers.map((offer) {
        if (offer.id == offerId) {
          return OfferModel(
            id: offer.id,
            serviceRequestId: offer.serviceRequestId,
            workshopId: offer.workshopId,
            proposedPriceAmount: offer.proposedPriceAmount,
            currency: offer.currency,
            proposedDate: offer.proposedDate,
            status: OfferStatus.accepted,
            message: offer.message,
            createdAt: offer.createdAt,
            expiresAt: offer.expiresAt,
            acceptedAt: DateTime.now(),
            withdrawnAt: offer.withdrawnAt,
          );
        }
        return offer;
      }).toList();

      emit(state.copyWith(
        status: OffersStatus.accepted,
        offers: updatedOffers,
        successMessage: '¡Oferta aceptada! Se ha creado tu reserva.',
      ));

      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(
        status: OffersStatus.error,
        errorMessage: _parseError(e),
      ));
      return false;
    }
  }

  /// Rechaza una oferta
  Future<bool> rejectOffer(int offerId) async {
    if (isClosed) return false;

    emit(state.copyWith(
      status: OffersStatus.rejecting,
      clearError: true,
    ));

    try {
      await _repository.rejectOffer(offerId);

      if (isClosed) return false;

      // Actualizar la lista de ofertas
      final updatedOffers = state.offers.map((offer) {
        if (offer.id == offerId) {
          return OfferModel(
            id: offer.id,
            serviceRequestId: offer.serviceRequestId,
            workshopId: offer.workshopId,
            proposedPriceAmount: offer.proposedPriceAmount,
            currency: offer.currency,
            proposedDate: offer.proposedDate,
            status: OfferStatus.rejected,
            message: offer.message,
            createdAt: offer.createdAt,
            expiresAt: offer.expiresAt,
            acceptedAt: offer.acceptedAt,
            withdrawnAt: offer.withdrawnAt,
          );
        }
        return offer;
      }).toList();

      emit(state.copyWith(
        status: OffersStatus.rejected,
        offers: updatedOffers,
        successMessage: 'Oferta rechazada',
        clearSelectedOffer: true,
      ));

      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(
        status: OffersStatus.error,
        errorMessage: _parseError(e),
      ));
      return false;
    }
  }

  /// Recarga las ofertas
  Future<void> refreshOffers() async {
    if (state.serviceRequestId != null) {
      await loadOffersForRequest(state.serviceRequestId!);
    }
  }

  /// Limpia los mensajes
  void clearMessages() {
    if (isClosed) return;
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  /// Parsea el mensaje de error
  String _parseError(dynamic error) {
    final errorStr = error.toString();
    if (errorStr.startsWith('Exception: ')) {
      return errorStr.replaceFirst('Exception: ', '');
    }
    return errorStr;
  }
}

