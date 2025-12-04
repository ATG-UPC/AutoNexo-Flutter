import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_router.dart';
import '../../data/models/models.dart';
import '../cubit/cubit.dart';

/// Página de detalle de una oferta
class OfferDetailPage extends StatelessWidget {
  const OfferDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OffersCubit, OffersState>(
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

        // Si se aceptó, mostrar diálogo de éxito con opción de ir a reservas
        if (state.status == OffersStatus.accepted) {
          _showAcceptedDialog(context);
        }

        // Si se rechazó, navegar de vuelta
        if (state.status == OffersStatus.rejected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Oferta rechazada'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        final offer = state.selectedOffer;

        if (offer == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalle de Oferta')),
            body: const Center(
              child: Text('No se ha seleccionado ninguna oferta'),
            ),
          );
        }

        final workshop = state.getWorkshopInfo(offer.workshopId);
        final trustScore = state.getTrustScore(offer.workshopId);
        final isProcessing = state.isAccepting || state.isRejecting;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalle de Oferta'),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header del taller
                _buildWorkshopHeader(context, offer, workshop, trustScore),

                const SizedBox(height: 16),

                // Información del precio
                _buildPriceSection(context, offer),

                const SizedBox(height: 16),

                // Información de la fecha
                _buildDateSection(context, offer),

                // Mensaje del taller
                if (offer.message != null && offer.message!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildMessageSection(context, offer),
                ],

                // Información de expiración
                if (offer.isPending && !offer.isExpired) ...[
                  const SizedBox(height: 16),
                  _buildExpirySection(context, offer),
                ],

                // Información del taller
                if (workshop != null) ...[
                  const SizedBox(height: 16),
                  _buildWorkshopInfoSection(context, workshop),
                ],

                const SizedBox(height: 100), // Espacio para los botones
              ],
            ),
          ),
          bottomNavigationBar: offer.canRespond
              ? _buildActionButtons(context, offer, isProcessing)
              : _buildStatusInfo(context, offer),
        );
      },
    );
  }

  Widget _buildWorkshopHeader(
    BuildContext context,
    OfferModel offer,
    WorkshopPublicModel? workshop,
    TrustScore? trustScore,
  ) {
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
        children: [
          // Logo del taller
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: workshop?.hasLogo == true
                ? ClipOval(
                    child: Image.network(
                      workshop!.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.build_circle,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : Icon(
                    Icons.build_circle,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
          ),
          const SizedBox(height: 16),

          // Nombre del taller
          Text(
            workshop?.name ?? 'Taller #${offer.workshopId}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          // Rating
          if (trustScore != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber.shade400,
                  size: 24,
                ),
                const SizedBox(width: 4),
                Text(
                  trustScore.formattedScore,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${trustScore.totalReviews} reseñas)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context, OfferModel offer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.payments_outlined,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 12),
              const Text(
                'Precio Propuesto',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                offer.formattedPrice,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection(BuildContext context, OfferModel offer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_month,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fecha Disponible',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.formattedProposedDate,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'a las ${offer.formattedProposedTime}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageSection(BuildContext context, OfferModel offer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.message_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Mensaje del Taller',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                offer.message!,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpirySection(BuildContext context, OfferModel offer) {
    final duration = offer.timeUntilExpiry;
    final isUrgent = duration.inHours < 24;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: isUrgent ? Colors.red.shade50 : Colors.amber.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: isUrgent ? Colors.red.shade700 : Colors.amber.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiempo para responder',
                      style: TextStyle(
                        fontSize: 14,
                        color: isUrgent
                            ? Colors.red.shade700
                            : Colors.amber.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.timeUntilExpiryFormatted,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isUrgent
                            ? Colors.red.shade700
                            : Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkshopInfoSection(
      BuildContext context, WorkshopPublicModel workshop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del Taller',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Dirección
              if (workshop.location?.address != null) ...[
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'Dirección',
                  workshop.address,
                ),
                const SizedBox(height: 12),
              ],

              // Teléfono
              if (workshop.phoneNumber != null) ...[
                _buildInfoRow(
                  Icons.phone_outlined,
                  'Teléfono',
                  workshop.phoneNumber!,
                ),
                const SizedBox(height: 12),
              ],

              // Email
              if (workshop.email != null) ...[
                _buildInfoRow(
                  Icons.email_outlined,
                  'Email',
                  workshop.email!,
                ),
                const SizedBox(height: 12),
              ],

              // Servicios
              if (workshop.services.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Servicios disponibles',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: workshop.formattedServices.take(5).map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        service,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    OfferModel offer,
    bool isProcessing,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Botón Rechazar
            Expanded(
              child: OutlinedButton(
                onPressed: isProcessing
                    ? null
                    : () => _showRejectConfirmation(context, offer),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Rechazar',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Botón Aceptar
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: isProcessing
                    ? null
                    : () => _showAcceptConfirmation(context, offer),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Aceptar Oferta',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInfo(BuildContext context, OfferModel offer) {
    String message;
    Color color;
    IconData icon;

    if (offer.isExpired) {
      message = 'Esta oferta ha expirado';
      color = Colors.grey;
      icon = Icons.timer_off;
    } else if (offer.isAccepted) {
      message = '¡Oferta aceptada!';
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (offer.isRejected) {
      message = 'Oferta rechazada';
      color = Colors.red;
      icon = Icons.cancel;
    } else {
      message = 'Oferta ${offer.statusDisplay.toLowerCase()}';
      color = Colors.grey;
      icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptConfirmation(BuildContext context, OfferModel offer) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Aceptación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Estás seguro de aceptar esta oferta?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precio: ${offer.formattedPrice}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Fecha: ${offer.formattedProposedDateTime}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Se creará una reserva y el taller será notificado.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<OffersCubit>().acceptOffer(offer.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectConfirmation(BuildContext context, OfferModel offer) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Rechazo'),
          content: const Text(
            '¿Estás seguro de rechazar esta oferta?\n\nEsta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<OffersCubit>().rejectOffer(offer.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Rechazar'),
            ),
          ],
        );
      },
    );
  }

  void _showAcceptedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
              const SizedBox(width: 8),
              const Text('¡Reserva Creada!'),
            ],
          ),
          content: const Text(
            'Tu oferta ha sido aceptada exitosamente. '
            'Se ha creado una reserva de servicio.\n\n'
            '¿Deseas ver tus reservas?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Cierra el diálogo
                Navigator.pop(context); // Vuelve a la lista de ofertas
              },
              child: const Text('Cerrar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext); // Cierra el diálogo
                // Pop múltiples veces para salir del flujo de ofertas
                Navigator.popUntil(context, (route) => route.isFirst);
                // Navegar a bookings
                AppRouter.toBookings(context);
              },
              icon: const Icon(Icons.calendar_month),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
              label: const Text('Ver Mis Reservas'),
            ),
          ],
        );
      },
    );
  }
}

