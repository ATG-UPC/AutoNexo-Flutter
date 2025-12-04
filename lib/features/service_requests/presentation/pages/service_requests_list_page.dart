import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/models.dart';
import '../cubit/cubit.dart';
import 'create_service_request_page.dart';
import 'service_request_detail_page.dart';

/// Página de lista de solicitudes de servicio
class ServiceRequestsListPage extends StatefulWidget {
  const ServiceRequestsListPage({super.key});

  @override
  State<ServiceRequestsListPage> createState() => _ServiceRequestsListPageState();
}

class _ServiceRequestsListPageState extends State<ServiceRequestsListPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      context.read<ServiceRequestsCubit>().loadInitialData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ServiceRequestsCubit, ServiceRequestsState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade700,
            ),
          );
          context.read<ServiceRequestsCubit>().clearMessages();
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green.shade700,
            ),
          );
          context.read<ServiceRequestsCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
            onRefresh: () => context.read<ServiceRequestsCubit>().loadInitialData(),
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Solicitudes de Servicio',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Gestiona tus solicitudes de servicio automotriz',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Botón para crear solicitud
                            ElevatedButton.icon(
                              onPressed: () => _navigateToCreate(context),
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('Nueva'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Filtros
                SliverToBoxAdapter(
                  child: _buildFilterChips(context, state),
                ),

                // Loading indicator
                if (state.isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                // Empty state
                else if (state.filteredRequests.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildEmptyState(context, state.serviceRequests.isEmpty),
                  )
                // Lista de solicitudes
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final request = state.filteredRequests[index];
                          return _ServiceRequestCard(
                            request: request,
                            onTap: () => _navigateToDetail(context, request),
                          );
                        },
                        childCount: state.filteredRequests.length,
                      ),
                    ),
                  ),

                // Espacio al final para el FAB
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
        );
      },
    );
  }

  Widget _buildFilterChips(BuildContext context, ServiceRequestsState state) {
    final filters = [
      (null, 'Todas'),
      ('PENDING', 'Pendientes'),
      ('MATCHED', 'Emparejadas'),
      ('CANCELLED', 'Canceladas'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = state.statusFilter == filter.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter.$2),
                selected: isSelected,
                onSelected: (_) {
                  context.read<ServiceRequestsCubit>().setStatusFilter(filter.$1);
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                checkmarkColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool noRequestsAtAll) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.handyman_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            noRequestsAtAll ? 'Sin solicitudes' : 'No hay solicitudes con este filtro',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            noRequestsAtAll
                ? 'Crea tu primera solicitud de servicio\npara encontrar talleres cercanos'
                : 'No se encontraron solicitudes con el filtro seleccionado.\nIntenta con otro filtro o crea una nueva solicitud.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, ServiceRequestModel request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ServiceRequestsCubit>(),
          child: ServiceRequestDetailPage(request: request),
        ),
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ServiceRequestsCubit>(),
          child: const CreateServiceRequestPage(),
        ),
      ),
    ).then((_) {
      // Recargar solicitudes al volver de crear una nueva
      if (mounted) {
        context.read<ServiceRequestsCubit>().loadServiceRequests();
      }
    });
  }
}

/// Card para mostrar una solicitud
class _ServiceRequestCard extends StatelessWidget {
  final ServiceRequestModel request;
  final VoidCallback onTap;

  const _ServiceRequestCard({
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusBadge(),
                  const Spacer(),
                  Text(
                    request.formattedDate,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Solicitud #${request.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.build_outlined,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${request.servicesCount} servicio(s) solicitado(s)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              if (request.description != null && request.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.notes_outlined,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        request.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Radio de búsqueda: ${request.searchRadiusKm} km',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (request.status) {
      case ServiceRequestStatus.pending:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        text = 'Pendiente';
        icon = Icons.hourglass_empty;
        break;
      case ServiceRequestStatus.matched:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        text = 'Emparejado';
        icon = Icons.check_circle_outline;
        break;
      case ServiceRequestStatus.cancelled:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        text = 'Cancelado';
        icon = Icons.cancel_outlined;
        break;
      case ServiceRequestStatus.expired:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade600;
        text = 'Expirado';
        icon = Icons.timer_off_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

