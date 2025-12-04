import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../widgets/widgets.dart';
import 'offer_detail_page.dart';

/// Página que muestra la lista de ofertas para una solicitud
class OffersListPage extends StatefulWidget {
  final int serviceRequestId;

  const OffersListPage({
    super.key,
    required this.serviceRequestId,
  });

  @override
  State<OffersListPage> createState() => _OffersListPageState();
}

class _OffersListPageState extends State<OffersListPage> {
  String _sortBy = 'price'; // 'price' o 'date'

  @override
  void initState() {
    super.initState();
    context.read<OffersCubit>().loadOffersForRequest(widget.serviceRequestId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertas Recibidas'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'price',
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: _sortBy == 'price'
                          ? Theme.of(context).primaryColor
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ordenar por precio',
                      style: TextStyle(
                        fontWeight:
                            _sortBy == 'price' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: _sortBy == 'date'
                          ? Theme.of(context).primaryColor
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ordenar por fecha',
                      style: TextStyle(
                        fontWeight: _sortBy == 'date' ? FontWeight.bold : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<OffersCubit, OffersState>(
        listener: (context, state) {
          // Mostrar mensajes de error
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<OffersCubit>().clearMessages();
          }

          // Mostrar mensajes de éxito
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
            context.read<OffersCubit>().clearMessages();
          }

          // Si se aceptó una oferta, navegar de vuelta
          if (state.status == OffersStatus.accepted) {
            Navigator.of(context).pop(true); // true indica que hubo cambios
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!state.hasOffers) {
            return _buildEmptyState();
          }

          final sortedOffers = _sortBy == 'price'
              ? state.offersByPrice
              : state.offersByDate;

          return RefreshIndicator(
            onRefresh: () => context.read<OffersCubit>().refreshOffers(),
            child: Column(
              children: [
                // Header con contador
                _buildHeader(state),

                // Lista de ofertas
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: sortedOffers.length,
                    itemBuilder: (context, index) {
                      final offer = sortedOffers[index];
                      final workshop = state.getWorkshopInfo(offer.workshopId);

                      return OfferCard(
                        offer: offer,
                        workshop: workshop,
                        onTap: () => _navigateToDetail(context, offer),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(OffersState state) {
    final pendingCount = state.pendingOffersCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
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
              Icons.local_offer,
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
                    '$pendingCount pendiente${pendingCount == 1 ? '' : 's'} de respuesta',
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Aún no hay ofertas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Los talleres cercanos están revisando tu solicitud.\nTe notificaremos cuando recibas una oferta.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                context.read<OffersCubit>().refreshOffers();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, offer) {
    context.read<OffersCubit>().selectOffer(offer);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<OffersCubit>(),
          child: const OfferDetailPage(),
        ),
      ),
    ).then((_) {
      // Limpiar selección al volver
      if (mounted) {
        context.read<OffersCubit>().clearSelectedOffer();
      }
    });
  }
}

