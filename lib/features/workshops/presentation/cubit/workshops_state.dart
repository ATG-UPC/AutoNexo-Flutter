import 'package:equatable/equatable.dart';

import '../../../../core/enums/status.dart';
import '../../data/models/models.dart';
import '../../data/repositories/workshops_repository.dart';

/// Estado del Cubit de Workshops
class WorkshopsState extends Equatable {
  final Status status;
  final List<WorkshopSearchResultModel> searchResults;
  final WorkshopProfileModel? selectedWorkshop;
  final WorkshopSearchParams searchParams;
  final String? errorMessage;
  final bool isLoadingProfile;

  const WorkshopsState({
    this.status = Status.initial,
    this.searchResults = const [],
    this.selectedWorkshop,
    this.searchParams = const WorkshopSearchParams(),
    this.errorMessage,
    this.isLoadingProfile = false,
  });

  /// ¿Hay resultados?
  bool get hasResults => searchResults.isNotEmpty;

  /// ¿Está buscando?
  bool get isSearching => status == Status.loading;

  /// Número de resultados
  int get resultCount => searchResults.length;

  /// Resultados ordenados por distancia
  List<WorkshopSearchResultModel> get resultsByDistance {
    final sorted = List<WorkshopSearchResultModel>.from(searchResults);
    sorted.sort((a, b) {
      if (a.distance == null && b.distance == null) return 0;
      if (a.distance == null) return 1;
      if (b.distance == null) return -1;
      return a.distance!.compareTo(b.distance!);
    });
    return sorted;
  }

  /// Resultados ordenados por rating
  List<WorkshopSearchResultModel> get resultsByRating {
    final sorted = List<WorkshopSearchResultModel>.from(searchResults);
    sorted.sort((a, b) {
      if (a.trustScore == null && b.trustScore == null) return 0;
      if (a.trustScore == null) return 1;
      if (b.trustScore == null) return -1;
      return b.trustScore!.compareTo(a.trustScore!); // Descendente
    });
    return sorted;
  }

  WorkshopsState copyWith({
    Status? status,
    List<WorkshopSearchResultModel>? searchResults,
    WorkshopProfileModel? selectedWorkshop,
    WorkshopSearchParams? searchParams,
    String? errorMessage,
    bool? isLoadingProfile,
    bool clearSelectedWorkshop = false,
    bool clearError = false,
  }) {
    return WorkshopsState(
      status: status ?? this.status,
      searchResults: searchResults ?? this.searchResults,
      selectedWorkshop: clearSelectedWorkshop ? null : (selectedWorkshop ?? this.selectedWorkshop),
      searchParams: searchParams ?? this.searchParams,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoadingProfile: isLoadingProfile ?? this.isLoadingProfile,
    );
  }

  @override
  List<Object?> get props => [
        status,
        searchResults,
        selectedWorkshop,
        searchParams,
        errorMessage,
        isLoadingProfile,
      ];
}

