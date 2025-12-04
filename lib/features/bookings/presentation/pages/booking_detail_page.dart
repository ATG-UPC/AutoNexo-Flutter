import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/status.dart';
import '../../../../core/ui/widgets/widgets.dart';
import '../../../reviews/reviews.dart';
import '../../../workshops/workshops.dart';
import '../../data/models/models.dart';
import '../cubit/cubit.dart';
import '../widgets/widgets.dart';

/// Página de detalle de una reserva de servicio
class BookingDetailPage extends StatefulWidget {
  final ServiceBookingModel booking;

  const BookingDetailPage({
    super.key,
    required this.booking,
  });

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  @override
  void initState() {
    super.initState();
    // Cargar información del taller y vehículo al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingsCubit>().loadWorkshopInfo(widget.booking.workshopId);
      context.read<BookingsCubit>().loadVehicleInfo(widget.booking.vehicleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reserva #${widget.booking.id}'),
        elevation: 0,
      ),
      body: BlocConsumer<BookingsCubit, BookingsState>(
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
            // Si se confirmó recogida o canceló, volver a la lista
            if (state.successMessage!.contains('confirmada') || 
                state.successMessage!.contains('cancelada')) {
              Navigator.pop(context);
            }
          }
        },
        builder: (context, state) {
          // Usar el booking actualizado del estado si existe
          final currentBooking = state.selectedBooking ?? widget.booking;
          final isProcessing = state.status == Status.loading;
          final workshopInfo = state.getWorkshopInfo(currentBooking.workshopId);
          final vehicleInfo = state.getVehicleInfo(currentBooking.vehicleId);

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con estado
                    _buildHeaderCard(context, currentBooking),
                    const SizedBox(height: 16),

                    // Timeline de progreso
                    _buildTimelineCard(context, currentBooking),
                    const SizedBox(height: 16),

                    // Info del taller
                    _buildWorkshopCard(context, currentBooking, workshopInfo),
                    const SizedBox(height: 16),

                    // Info del vehículo
                    _buildVehicleCard(context, currentBooking, vehicleInfo),
                    const SizedBox(height: 16),

                    // Servicios
                    _buildServicesCard(context, currentBooking),
                    const SizedBox(height: 16),

                    // Precio
                    _buildPriceCard(context, currentBooking),
                    const SizedBox(height: 24),

                    // Botones de acción
                    _buildActionButtons(context, currentBooking, isProcessing),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              // Loading overlay
              if (isProcessing)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const LoadingPage(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, ServiceBookingModel booking) {
    final theme = Theme.of(context);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.event_note,
                color: theme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reserva #${booking.id}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Creada el ${booking.formattedCreatedAt}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            StatusBadge(
              status: booking.status.toString().split('.').last,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, ServiceBookingModel booking) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progreso del Servicio',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            BookingTimeline(booking: booking),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkshopCard(BuildContext context, ServiceBookingModel booking, WorkshopProfileModel? workshopInfo) {
    final theme = Theme.of(context);
    final workshop = workshopInfo;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => WorkshopsCubit()..loadWorkshopProfile(booking.workshopId),
                child: WorkshopDetailPage(workshopId: booking.workshopId),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.business, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Taller',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    child: workshop?.hasLogo == true
                        ? ClipOval(
                            child: Image.network(
                              workshop!.logoUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(Icons.build, color: theme.primaryColor),
                            ),
                          )
                        : Icon(Icons.build, color: theme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workshop?.name ?? 'Taller #${booking.workshopId}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          workshop != null ? 'Ver información del taller' : 'Cargando...',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, 
                      size: 16, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, ServiceBookingModel booking, vehicleInfo) {
    final theme = Theme.of(context);
    final vehicle = vehicleInfo;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Vehículo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (vehicle != null) ...[
              _buildInfoRow(context, 'Marca', vehicle.brandName ?? 'N/A'),
              _buildInfoRow(context, 'Modelo', vehicle.model),
              _buildInfoRow(context, 'Año', vehicle.year.toString()),
              _buildInfoRow(context, 'Placa', vehicle.licensePlate),
            ] else
              _buildInfoRow(context, 'ID', '#${booking.vehicleId}'),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesCard(BuildContext context, ServiceBookingModel booking) {
    final theme = Theme.of(context);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.handyman, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Servicios a Realizar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (booking.servicesToPerform.isEmpty)
              Text(
                'Sin servicios especificados',
                style: TextStyle(color: Colors.grey.shade600),
              )
            else
              ...booking.servicesToPerform.map((service) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, 
                        size: 20, color: Colors.green.shade600),
                    const SizedBox(width: 12),
                    Text(
                      _formatServiceCode(service),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              )),
            if (booking.description != null && booking.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Descripción adicional:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                booking.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(BuildContext context, ServiceBookingModel booking) {
    final theme = Theme.of(context);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monetization_on, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Precio',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(context, 'Precio Propuesto', booking.formattedProposedPrice),
            if (booking.formattedFinalPrice != null)
              _buildInfoRow(context, 'Precio Final', booking.formattedFinalPrice!,
                  highlight: true),
            _buildInfoRow(context, 'Fecha Programada', booking.formattedScheduledDateTime),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, 
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              color: highlight ? Colors.green.shade700 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ServiceBookingModel booking, 
      bool isProcessing) {
    // Si el booking ya está recogido, mostrar opción de review
    if (booking.status == ServiceBookingStatus.PICKED_UP) {
      return _buildCompletedSection(context, booking);
    }

    // Si está cancelado, no mostrar acciones
    if (booking.status == ServiceBookingStatus.CANCELLED) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Botón principal según estado
        if (booking.canConfirmPickup)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isProcessing 
                  ? null 
                  : () => _showConfirmPickupDialog(context, booking.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.check_circle),
              label: const Text('Confirmar Recogida del Vehículo'),
            ),
          ),
        
        // Botón de cancelar si aplica
        if (booking.canCancel) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isProcessing 
                  ? null 
                  : () => _showCancelDialog(context, booking.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade600,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancelar Reserva'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompletedSection(BuildContext context, ServiceBookingModel booking) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Icon(Icons.check_circle, size: 48, color: Colors.green.shade600),
          const SizedBox(height: 8),
          Text(
            '¡Servicio completado!',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gracias por usar AutoNexo',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          // Botón para dejar review
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateReview(context, booking),
            icon: const Icon(Icons.star),
            label: const Text('Dejar una Reseña'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateReview(BuildContext context, ServiceBookingModel booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ReviewsCubit(),
          child: CreateReviewPage(
            serviceBookingId: booking.id,
            workshopId: booking.workshopId,
            workshopName: 'Taller #${booking.workshopId}',
          ),
        ),
      ),
    ).then((result) {
      if (result == true) {
        // La reseña fue enviada exitosamente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Gracias por tu reseña!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _showConfirmPickupDialog(BuildContext context, int bookingId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Recogida'),
        content: const Text(
          '¿Confirmas que has recogido tu vehículo del taller?\n\n'
          'Al confirmar, el servicio se marcará como completado y podrás dejar una reseña.',
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
            child: const Text('Confirmar Recogida'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Estás seguro de que deseas cancelar esta reserva?\n\n'
              'Esta acción no se puede deshacer.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                hintText: 'Ingresa el motivo de la cancelación',
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

  String _formatServiceCode(String code) {
    return code
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1)}' 
            : '')
        .join(' ');
  }
}

