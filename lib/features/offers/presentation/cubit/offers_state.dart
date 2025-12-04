import 'package:equatable/equatable.dart';
import '../../data/models/models.dart';

/// Estados posibles del flujo de ofertas
enum OffersStatus {
  initial,
  loading,
  loaded,
  accepting,
  accepted,
  rejecting,
  rejected,
  error,
}

/// Estado del cubit de ofertas
class OffersState extends Equatable {
  /// Estado actual del flujo
  final OffersStatus status;

  /// ID de la solicitud de servicio actual
  final int? serviceRequestId;

  /// Lista de ofertas para la solicitud actual
  final List<OfferModel> offers;

  /// Oferta actualmente seleccionada (para detalle)
  final OfferModel? selectedOffer;

  /// Información de talleres cacheada (workshopId -> WorkshopPublicModel)
  final Map<int, WorkshopPublicModel> workshopsCache;

  /// Trust scores cacheados (workshopId -> TrustScore)
  final Map<int, TrustScore> trustScoresCache;

  /// Mensaje de error (si hay)
  final String? errorMessage;

  /// Mensaje de éxito (si hay)
  final String? successMessage;

  const OffersState({
    this.status = OffersStatus.initial,
    this.serviceRequestId,
    this.offers = const [],
    this.selectedOffer,
    this.workshopsCache = const {},
    this.trustScoresCache = const {},
    this.errorMessage,
    this.successMessage,
  });

  /// Estado inicial
  factory OffersState.initial() => const OffersState();

  /// Crea una copia con campos actualizados
  OffersState copyWith({
    OffersStatus? status,
    int? serviceRequestId,
    List<OfferModel>? offers,
    OfferModel? selectedOffer,
    Map<int, WorkshopPublicModel>? workshopsCache,
    Map<int, TrustScore>? trustScoresCache,
    String? errorMessage,
    String? successMessage,
    bool clearSelectedOffer = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return OffersState(
      status: status ?? this.status,
      serviceRequestId: serviceRequestId ?? this.serviceRequestId,
      offers: offers ?? this.offers,
      selectedOffer: clearSelectedOffer ? null : (selectedOffer ?? this.selectedOffer),
      workshopsCache: workshopsCache ?? this.workshopsCache,
      trustScoresCache: trustScoresCache ?? this.trustScoresCache,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  // === Getters de estado ===

  /// ¿Está cargando?
  bool get isLoading => status == OffersStatus.loading;

  /// ¿Está aceptando una oferta?
  bool get isAccepting => status == OffersStatus.accepting;

  /// ¿Está rechazando una oferta?
  bool get isRejecting => status == OffersStatus.rejecting;

  /// ¿Hay ofertas?
  bool get hasOffers => offers.isNotEmpty;

  /// Número de ofertas pendientes
  int get pendingOffersCount => offers.where((o) => o.isPending).length;

  /// Ofertas ordenadas por precio (menor a mayor)
  List<OfferModel> get offersByPrice {
    final sorted = List<OfferModel>.from(offers);
    sorted.sort((a, b) => a.proposedPriceAmount.compareTo(b.proposedPriceAmount));
    return sorted;
  }

  /// Ofertas ordenadas por fecha propuesta (más cercana primero)
  List<OfferModel> get offersByDate {
    final sorted = List<OfferModel>.from(offers);
    sorted.sort((a, b) => a.proposedDate.compareTo(b.proposedDate));
    return sorted;
  }

  /// Ofertas pendientes únicamente
  List<OfferModel> get pendingOffers {
    return offers.where((o) => o.isPending).toList();
  }

  /// Obtiene info del taller desde cache
  WorkshopPublicModel? getWorkshopInfo(int workshopId) {
    return workshopsCache[workshopId];
  }

  /// Obtiene trust score desde cache
  TrustScore? getTrustScore(int workshopId) {
    return trustScoresCache[workshopId];
  }

  @override
  List<Object?> get props => [
        status,
        serviceRequestId,
        offers,
        selectedOffer,
        workshopsCache,
        trustScoresCache,
        errorMessage,
        successMessage,
      ];
}

