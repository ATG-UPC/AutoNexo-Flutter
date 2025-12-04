import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/status.dart';
import '../../../../core/ui/widgets/widgets.dart';
import '../cubit/cubit.dart';
import 'booking_detail_page.dart';

/// Página que lista las reservas de servicio del usuario
class BookingsListPage extends StatefulWidget {
  const BookingsListPage({super.key});

  @override
  State<BookingsListPage> createState() => _BookingsListPageState();
}

class _BookingsListPageState extends State<BookingsListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Cargar bookings al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingsCubit>().loadBookings();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      context.read<BookingsCubit>().loadMoreBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filtros
          _buildFilterChips(),
          // Lista de bookings
          Expanded(
            child: BlocConsumer<BookingsCubit, BookingsState>(
              listener: (context, state) {
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Colors.red,
                    ),
                  );
                  context.read<BookingsCubit>().clearMessages();
                }
                if (state.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.successMessage!),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.read<BookingsCubit>().clearMessages();
                }
              },
              builder: (context, state) {
                if (state.status == Status.loading && state.bookings.isEmpty) {
                  return const LoadingPage();
                }

                if (state.status == Status.failure && state.bookings.isEmpty) {
                  return _buildErrorState(context, state.errorMessage);
                }

                final filteredBookings = state.filteredBookings;

                if (filteredBookings.isEmpty) {
                  return _buildEmptyState(context, state.filter);
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<BookingsCubit>().refreshBookings(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBookings.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= filteredBookings.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final booking = filteredBookings[index];
                      final workshopInfo = state.getWorkshopInfo(booking.workshopId);
                      final vehicleInfo = state.getVehicleInfo(booking.vehicleId);
                      
                      final workshopName = workshopInfo?.name ?? 'Taller #${booking.workshopId}';
                      final vehicleName = vehicleInfo != null 
                          ? '${vehicleInfo.brandName ?? ''} ${vehicleInfo.model}'.trim()
                          : 'Vehículo #${booking.vehicleId}';
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: BookingCard(
                          workshopName: workshopName,
                          vehicleName: vehicleName,
                          scheduledDate: booking.scheduledDate,
                          status: booking.status.toString().split('.').last,
                          services: booking.servicesToPerform,
                          price: booking.proposedPriceAmount,
                          currency: booking.proposedPriceCurrency,
                          onTap: () {
                            context.read<BookingsCubit>().selectBooking(booking);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: context.read<BookingsCubit>(),
                                  child: BookingDetailPage(booking: booking),
                                ),
                              ),
                            );
                          },
                          onConfirmPickup: booking.canConfirmPickup
                              ? () => _showConfirmPickupDialog(context, booking.id)
                              : null,
                          onCancel: booking.canCancel
                              ? () => _showCancelDialog(context, booking.id)
                              : null,
                        ),
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

  Widget _buildFilterChips() {
    return BlocBuilder<BookingsCubit, BookingsState>(
      buildWhen: (previous, current) => 
          previous.filter != current.filter ||
          previous.bookings != current.bookings,
      builder: (context, state) {
        return Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip(
                context,
                label: 'Todas (${state.bookings.length})',
                filter: BookingFilter.all,
                isSelected: state.filter == BookingFilter.all,
              ),
              _buildFilterChip(
                context,
                label: 'Activas (${state.activeCount})',
                filter: BookingFilter.active,
                isSelected: state.filter == BookingFilter.active,
              ),
              _buildFilterChip(
                context,
                label: 'Completadas (${state.completedCount})',
                filter: BookingFilter.completed,
                isSelected: state.filter == BookingFilter.completed,
              ),
              _buildFilterChip(
                context,
                label: 'Canceladas (${state.cancelledCount})',
                filter: BookingFilter.cancelled,
                isSelected: state.filter == BookingFilter.cancelled,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required BookingFilter filter,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => context.read<BookingsCubit>().setFilter(filter),
        selectedColor: theme.primaryColor.withOpacity(0.2),
        checkmarkColor: theme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? theme.primaryColor : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar reservas',
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
              onPressed: () => context.read<BookingsCubit>().loadBookings(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, BookingFilter filter) {
    String message;
    IconData icon;

    switch (filter) {
      case BookingFilter.all:
        message = 'No tienes reservas de servicio aún.\n\nCrea una solicitud y acepta una oferta para comenzar.';
        icon = Icons.calendar_today_outlined;
        break;
      case BookingFilter.active:
        message = 'No tienes reservas activas en este momento.';
        icon = Icons.event_busy_outlined;
        break;
      case BookingFilter.completed:
        message = 'No tienes reservas completadas aún.';
        icon = Icons.check_circle_outline;
        break;
      case BookingFilter.cancelled:
        message = 'No tienes reservas canceladas.';
        icon = Icons.cancel_outlined;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmPickupDialog(BuildContext context, int bookingId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Recogida'),
        content: const Text(
          '¿Confirmas que has recogido tu vehículo del taller?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BookingsCubit>().confirmPickup(bookingId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, int bookingId) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Estás seguro de cancelar esta reserva?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Volver'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BookingsCubit>().cancelBooking(
                bookingId,
                reason: reasonController.text.isNotEmpty 
                    ? reasonController.text 
                    : null,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancelar Reserva'),
          ),
        ],
      ),
    );
  }
}

