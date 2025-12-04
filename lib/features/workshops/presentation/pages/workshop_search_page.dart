import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/status.dart';
import '../../../../core/ui/widgets/widgets.dart';
import '../cubit/cubit.dart';
import '../widgets/widgets.dart';
import 'workshop_detail_page.dart';

/// Página de búsqueda de talleres
class WorkshopSearchPage extends StatefulWidget {
  const WorkshopSearchPage({super.key});

  @override
  State<WorkshopSearchPage> createState() => _WorkshopSearchPageState();
}

class _WorkshopSearchPageState extends State<WorkshopSearchPage> {
  String _sortBy = 'distance'; // 'distance' o 'rating'
  double? _selectedMinRating;
  int _selectedRadius = 50;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkshopsCubit>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Talleres'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              context.read<WorkshopsCubit>().searchWithCurrentLocation();
            },
            tooltip: 'Usar mi ubicación',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFiltersBottomSheet(context),
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de filtros rápidos
          _buildQuickFilters(context),
          // Lista de resultados
          Expanded(
            child: BlocConsumer<WorkshopsCubit, WorkshopsState>(
              listener: (context, state) {
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  context.read<WorkshopsCubit>().clearError();
                }
              },
              builder: (context, state) {
                if (state.status == Status.loading &&
                    state.searchResults.isEmpty) {
                  return const LoadingPage(
                    message: 'Buscando talleres cercanos...',
                  );
                }

                if (state.status == Status.failure &&
                    state.searchResults.isEmpty) {
                  return _buildErrorState(context, state.errorMessage);
                }

                if (!state.hasResults) {
                  return _buildEmptyState(context);
                }

                final sortedResults = _sortBy == 'rating'
                    ? state.resultsByRating
                    : state.resultsByDistance;

                return RefreshIndicator(
                  onRefresh: () => context.read<WorkshopsCubit>().refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedResults.length,
                    itemBuilder: (context, index) {
                      final workshop = sortedResults[index];
                      return WorkshopCard(
                        workshop: workshop,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<WorkshopsCubit>()
                                  ..loadWorkshopProfile(workshop.id),
                                child: WorkshopDetailPage(
                                  workshopId: workshop.id,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Resultados count
          BlocBuilder<WorkshopsCubit, WorkshopsState>(
            buildWhen: (prev, curr) => prev.resultCount != curr.resultCount,
            builder: (context, state) {
              return Text(
                '${state.resultCount} talleres',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              );
            },
          ),
          const Spacer(),
          // Ordenar por
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _sortBy == 'rating' ? Icons.star : Icons.near_me,
                    size: 16,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _sortBy == 'rating' ? 'Rating' : 'Distancia',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'distance',
                child: Row(
                  children: [
                    Icon(Icons.near_me, size: 18),
                    SizedBox(width: 8),
                    Text('Ordenar por distancia'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'rating',
                child: Row(
                  children: [
                    Icon(Icons.star, size: 18),
                    SizedBox(width: 8),
                    Text('Ordenar por rating'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFiltersBottomSheet(BuildContext context) {
    final cubit = context.read<WorkshopsCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.8,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    // Handle
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        physics: const ClampingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Título
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Filtros de Búsqueda',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setSheetState(() {
                                        _selectedRadius = 50;
                                        _selectedMinRating = null;
                                      });
                                    },
                                    child: const Text('Limpiar'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Radio de búsqueda
                              Text(
                                'Radio de búsqueda',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              Slider(
                                value: _selectedRadius.toDouble(),
                                min: 5,
                                max: 100,
                                divisions: 19,
                                label: '$_selectedRadius km',
                                onChanged: (value) {
                                  setSheetState(() {
                                    _selectedRadius = value.toInt();
                                  });
                                },
                              ),
                              Text(
                                '$_selectedRadius km',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 24),
                              // Rating mínimo
                              Text(
                                'Rating mínimo',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildRatingChip(
                                    null,
                                    'Todos',
                                    setSheetState,
                                  ),
                                  _buildRatingChip(3.0, '3+', setSheetState),
                                  _buildRatingChip(3.5, '3.5+', setSheetState),
                                  _buildRatingChip(4.0, '4+', setSheetState),
                                  _buildRatingChip(4.5, '4.5+', setSheetState),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Botón aplicar
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom +
                                      20,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      cubit.updateSearchRadius(_selectedRadius);
                                      cubit.updateMinRating(_selectedMinRating);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                    ),
                                    child: const Text('Aplicar Filtros'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRatingChip(
    double? rating,
    String label,
    StateSetter setSheetState,
  ) {
    final isSelected = _selectedMinRating == rating;
    final theme = Theme.of(context);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rating != null) ...[
            Icon(
              Icons.star,
              size: 14,
              color: isSelected ? Colors.white : Colors.amber.shade600,
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) {
        setSheetState(() {
          _selectedMinRating = rating;
        });
      },
      selectedColor: theme.primaryColor,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error al buscar talleres',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Ocurrió un error inesperado',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<WorkshopsCubit>().initialize(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No se encontraron talleres',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta ampliar el radio de búsqueda o cambiar los filtros.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _showFiltersBottomSheet(context),
              icon: const Icon(Icons.filter_list),
              label: const Text('Cambiar Filtros'),
            ),
          ],
        ),
      ),
    );
  }
}
