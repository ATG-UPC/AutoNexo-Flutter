import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../widgets/widgets.dart';
import 'offer_detail_page.dart';

/// Página principal de ofertas para el BottomNavBar
/// Muestra todas las ofertas recibidas del usuario
class MyOffersPage extends StatefulWidget {
  const MyOffersPage({super.key});

  @override
  State<MyOffersPage> createState() => _MyOffersPageState();
}

class _MyOffersPageState extends State<MyOffersPage> {
  bool _initialized = false;
  int? _processingOfferId;

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
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: BlocConsumer<OffersCubit, OffersState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red.shade700,
                ),
              );
              context.read<OffersCubit>().clearMessages();
              // Limpiar estado de procesamiento en caso de error
              if (_processingOfferId != null) {
                setState(() {
                  _processingOfferId = null;
                });
              }
            }

            if (state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: Colors.green.shade700,
                ),
              );
              context.read<OffersCubit>().clearMessages();
            }

            // Si se aceptó o rechazó una oferta, recargar la lista
            if (state.status == OffersStatus.accepted ||
                state.status == OffersStatus.rejected) {
              // Limpiar estado de procesamiento
              if (_processingOfferId != null) {
                setState(() {
                  _processingOfferId = null;
                });
              }
              // Recargar ofertas después de un breve delay
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  context.read<OffersCubit>().loadMyOffers();
                }
              });
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () => context.read<OffersCubit>().refreshOffers(),
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(child: _buildHeader(context, state)),

                  // Contenido
                  if (state.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (!state.hasOffers)
                    SliverFillRemaining(child: _buildEmptyState(context))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final offer = state.offers[index];
                          final workshop = state.getWorkshopInfo(
                            offer.workshopId,
                          );
                          final isProcessing = _processingOfferId == offer.id;
                          // Capturar el cubit en el builder donde sí tiene acceso
                          final offersCubit = context.read<OffersCubit>();

                          return OfferCard(
                            offer: offer,
                            workshop: workshop,
                            onTap: () =>
                                _navigateToDetail(context, offer, offersCubit),
                            onAccept: offer.canRespond
                                ? (offerId) => _handleAccept(
                                    context,
                                    offerId,
                                    offersCubit,
                                  )
                                : null,
                            onReject: offer.canRespond
                                ? (offerId) => _handleReject(
                                    context,
                                    offerId,
                                    offersCubit,
                                  )
                                : null,
                            isProcessing: isProcessing,
                          );
                        }, childCount: state.offers.length),
                      ),
                    ),

                  // Espacio al final
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OffersState state) {
    final pendingCount = state.pendingOffersCount;

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
            state.hasOffers
                ? '${state.offers.length} oferta${state.offers.length == 1 ? '' : 's'} recibida${state.offers.length == 1 ? '' : 's'}' +
                      (pendingCount > 0
                          ? ' • $pendingCount pendiente${pendingCount == 1 ? '' : 's'}'
                          : '')
                : 'Revisa las ofertas de los talleres para tus solicitudes',
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
                context.read<OffersCubit>().loadMyOffers();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _handleAccept(
    BuildContext context,
    int offerId,
    OffersCubit offersCubit,
  ) async {
    if (_processingOfferId != null)
      return false; // Ya hay una operación en curso

    setState(() {
      _processingOfferId = offerId;
    });

    try {
      final success = await offersCubit.acceptOffer(offerId);

      if (mounted) {
        if (success) {
          // Recargar ofertas después de aceptar
          await offersCubit.loadMyOffers();
        }
        setState(() {
          _processingOfferId = null;
        });
        return success;
      }
      return false;
    } catch (e) {
      if (mounted) {
        setState(() {
          _processingOfferId = null;
        });
      }
      return false;
    }
  }

  Future<bool> _handleReject(
    BuildContext context,
    int offerId,
    OffersCubit offersCubit,
  ) async {
    if (_processingOfferId != null)
      return false; // Ya hay una operación en curso

    setState(() {
      _processingOfferId = offerId;
    });

    try {
      final success = await offersCubit.rejectOffer(offerId);

      if (mounted) {
        if (success) {
          // Recargar ofertas después de rechazar
          await offersCubit.loadMyOffers();
        }
        setState(() {
          _processingOfferId = null;
        });
        return success;
      }
      return false;
    } catch (e) {
      if (mounted) {
        setState(() {
          _processingOfferId = null;
        });
      }
      return false;
    }
  }

  void _navigateToDetail(BuildContext context, offer, OffersCubit offersCubit) {
    if (!mounted) return;

    offersCubit.selectOffer(offer);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (newContext) => BlocProvider.value(
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
