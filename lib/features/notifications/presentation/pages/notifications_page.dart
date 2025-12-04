import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../offers/presentation/cubit/cubit.dart';
import '../../../offers/presentation/widgets/widgets.dart';
import '../../../offers/presentation/pages/offer_detail_page.dart';
import '../../../../core/services/notifications_service.dart';

/// Página de notificaciones que muestra las ofertas recibidas
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      // Cargar todas las ofertas del usuario
      context.read<OffersCubit>().loadMyOffers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        elevation: 0,
      ),
      body: BlocConsumer<OffersCubit, OffersState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
              ),
            );
            context.read<OffersCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => context.read<OffersCubit>().refreshOffers(),
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _buildHeader(context, state),
                ),

                // Contenido
                if (state.isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (!state.hasOffers)
                  SliverFillRemaining(
                    child: _buildEmptyState(context),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final offer = state.offers[index];
                          final workshop = state.getWorkshopInfo(
                            offer.workshopId,
                          );
                          final offersCubit = context.read<OffersCubit>();

                          return OfferCard(
                            offer: offer,
                            workshop: workshop,
                            onTap: () => _navigateToDetail(
                              context,
                              offer,
                              offersCubit,
                            ),
                            // NO permitir aceptar ni rechazar desde notificaciones
                            onAccept: null,
                            onReject: null,
                            isProcessing: false,
                          );
                        },
                        childCount: state.offers.length,
                      ),
                    ),
                  ),

                // Espacio al final
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OffersState state) {
    final pendingCount = state.pendingOffersCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.offers.length} oferta${state.offers.length == 1 ? '' : 's'} recibida${state.offers.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (pendingCount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '$pendingCount pendiente${pendingCount == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
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
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin notificaciones',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aquí verás tus ofertas cuando los talleres te las envíen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToDetail(
    BuildContext context,
    offer,
    OffersCubit offersCubit,
  ) async {
    // Marcar la oferta como leída
    await NotificationsService.markOfferAsRead(offer.id);

    if (!mounted) return;

    offersCubit.selectOffer(offer);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: offersCubit,
          child: const OfferDetailPage(),
        ),
      ),
    ).then((shouldReload) {
      // Limpiar selección al volver y recargar ofertas si hubo cambios
      if (mounted) {
        offersCubit.clearSelectedOffer();
        if (shouldReload == true) {
          offersCubit.loadMyOffers();
        }
      }
    });
  }
}

