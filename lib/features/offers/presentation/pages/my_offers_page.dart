import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../service_requests/data/models/models.dart';
import '../../../service_requests/presentation/cubit/cubit.dart';
import '../cubit/cubit.dart';
import 'offers_list_page.dart';

/// Página principal de ofertas para el BottomNavBar
/// Muestra las solicitudes de servicio que tienen ofertas disponibles
class MyOffersPage extends StatefulWidget {
  const MyOffersPage({super.key});

  @override
  State<MyOffersPage> createState() => _MyOffersPageState();
}

class _MyOffersPageState extends State<MyOffersPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Cargar las solicitudes de servicio
      context.read<ServiceRequestsCubit>().loadServiceRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: BlocConsumer<ServiceRequestsCubit, ServiceRequestsState>(
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
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<ServiceRequestsCubit>().loadServiceRequests(),
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: _buildHeader(context),
                  ),

                  // Contenido
                  if (state.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_getRequestsWithOffers(state).isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(context),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final request = _getRequestsWithOffers(state)[index];
                            return _ServiceRequestWithOffersCard(
                              request: request,
                              onTap: () => _navigateToOffers(context, request),
                            );
                          },
                          childCount: _getRequestsWithOffers(state).length,
                        ),
                      ),
                    ),

                  // Espacio al final
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Obtiene las solicitudes que pueden tener ofertas (PENDING o MATCHED)
  List<ServiceRequestModel> _getRequestsWithOffers(ServiceRequestsState state) {
    return state.serviceRequests.where((r) {
      return r.status == ServiceRequestStatus.pending ||
          r.status == ServiceRequestStatus.matched;
    }).toList();
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis Ofertas',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Revisa las ofertas de los talleres para tus solicitudes',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_offer_outlined,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin ofertas pendientes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B2D42),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cuando crees una solicitud de servicio,\nlos talleres cercanos te enviarán ofertas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                // Navegar a crear solicitud (índice 2 del BottomNavBar)
                // Esto se maneja en MainPage
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear Solicitud'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToOffers(BuildContext context, ServiceRequestModel request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => OffersCubit(),
          child: OffersListPage(serviceRequestId: request.id),
        ),
      ),
    );
  }
}

/// Card para mostrar una solicitud de servicio con ofertas
class _ServiceRequestWithOffersCard extends StatelessWidget {
  final ServiceRequestModel request;
  final VoidCallback onTap;

  const _ServiceRequestWithOffersCard({
    required this.request,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasOffers = request.status == ServiceRequestStatus.matched;

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
              // Header con estado
              Row(
                children: [
                  _buildStatusBadge(hasOffers),
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

              // Título
              Text(
                'Solicitud #${request.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Servicios
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

              // Descripción
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

              const SizedBox(height: 16),

              // Botón para ver ofertas
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: Icon(
                    hasOffers ? Icons.local_offer : Icons.hourglass_empty,
                    size: 18,
                  ),
                  label: Text(
                    hasOffers ? 'Ver Ofertas Recibidas' : 'Esperando Ofertas...',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasOffers 
                        ? theme.primaryColor 
                        : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool hasOffers) {
    final backgroundColor = hasOffers 
        ? Colors.green.shade50 
        : Colors.orange.shade50;
    final textColor = hasOffers 
        ? Colors.green.shade700 
        : Colors.orange.shade700;
    final icon = hasOffers 
        ? Icons.check_circle_outline 
        : Icons.hourglass_empty;
    final text = hasOffers ? 'Con ofertas' : 'Pendiente';

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

