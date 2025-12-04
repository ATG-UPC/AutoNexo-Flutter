import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/ui/widgets/maps/maps.dart';
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

        // Si se rechazó, navegar de vuelta y recargar ofertas
        if (state.status == OffersStatus.rejected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Oferta rechazada'),
              backgroundColor: Colors.orange,
            ),
          );
          // Esperar un momento antes de navegar para mostrar el snackbar
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              Navigator.of(context).pop(true); // true indica que hubo cambios
            }
          });
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
          appBar: AppBar(title: const Text('Detalle de Oferta')),
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
            child: workshop?.hasLogo == true && workshop?.logoUrl != null
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
                Icon(Icons.star, color: Colors.amber.shade400, size: 24),
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
                style: TextStyle(fontSize: 14, color: Colors.grey),
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
                      style: TextStyle(fontSize: 14, color: Colors.grey),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    BuildContext context,
    WorkshopPublicModel workshop,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: InkWell(
          onTap: () => _showWorkshopInfoDialog(context, workshop),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Información del Taller',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ],
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
                  // Mapa
                  if (workshop.location != null) ...[
                    MapWidget(
                      latitude: workshop.location!.latitude,
                      longitude: workshop.location!.longitude,
                      height: 200,
                      markerTitle: workshop.name,
                      markerSnippet: workshop.address,
                    ),
                    const SizedBox(height: 12),
                  ],
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
                  _buildInfoRow(Icons.email_outlined, 'Email', workshop.email!),
                  const SizedBox(height: 12),
                ],

                // Servicios
                if (workshop.services.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Servicios disponibles',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
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
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(value, style: const TextStyle(fontSize: 14)),
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
                child: const Text('Rechazar', style: TextStyle(fontSize: 16)),
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
      decoration: BoxDecoration(color: color.withOpacity(0.1)),
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
    // Capturar el cubit ANTES de mostrar el diálogo
    final offersCubit = context.read<OffersCubit>();

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
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final success = await offersCubit.acceptOffer(offer.id);
                if (success && context.mounted) {
                  // Recargar ofertas después de aceptar
                  await offersCubit.loadMyOffers();
                }
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
    // Capturar el cubit ANTES de mostrar el diálogo
    final offersCubit = context.read<OffersCubit>();

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
              onPressed: () async {
                Navigator.pop(dialogContext);
                final success = await offersCubit.rejectOffer(offer.id);
                if (success && context.mounted) {
                  // Recargar ofertas después de rechazar
                  await offersCubit.loadMyOffers();
                }
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

  void _showWorkshopInfoDialog(
    BuildContext context,
    WorkshopPublicModel workshop,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con logo y nombre
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Logo
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
                        child: workshop.hasLogo && workshop.logoUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  workshop.logoUrl!,
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
                      const SizedBox(height: 12),
                      Text(
                        workshop.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (workshop.trustScore != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              workshop.formattedTrustScore,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Contenido
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Descripción
                        if (workshop.description != null &&
                            workshop.description!.isNotEmpty) ...[
                          Text(
                            'Descripción',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            workshop.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Dirección
                        if (workshop.location?.address != null) ...[
                          _buildDialogInfoRow(
                            context,
                            Icons.location_on,
                            'Dirección',
                            workshop.address,
                            onTap: workshop.location != null
                                ? () => _openMaps(
                                    workshop.location!.latitude,
                                    workshop.location!.longitude,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Teléfono
                        if (workshop.phoneNumber != null) ...[
                          _buildDialogInfoRow(
                            context,
                            Icons.phone,
                            'Teléfono',
                            workshop.phoneNumber!,
                            onTap: () => _makePhoneCall(workshop.phoneNumber!),
                            showAction: true,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email
                        if (workshop.email != null) ...[
                          _buildDialogInfoRow(
                            context,
                            Icons.email,
                            'Email',
                            workshop.email!,
                            onTap: () => _sendEmail(workshop.email!),
                            showAction: true,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Sitio web
                        if (workshop.website != null &&
                            workshop.website!.isNotEmpty) ...[
                          _buildDialogInfoRow(
                            context,
                            Icons.language,
                            'Sitio Web',
                            workshop.website!,
                            onTap: () => _openWebsite(workshop.website!),
                            showAction: true,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Distancia
                        if (workshop.distance != null) ...[
                          _buildDialogInfoRow(
                            context,
                            Icons.straighten,
                            'Distancia',
                            workshop.formattedDistance,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Servicios
                        if (workshop.services.isNotEmpty) ...[
                          const Divider(),
                          const SizedBox(height: 12),
                          const Text(
                            'Servicios disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: workshop.formattedServices.map((service) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  service,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.w500,
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

                // Botón cerrar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
    bool showAction = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: onTap != null ? Colors.grey.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (showAction && onTap != null)
              Icon(
                icon == Icons.phone
                    ? Icons.call
                    : icon == Icons.email
                    ? Icons.send
                    : icon == Icons.language
                    ? Icons.open_in_new
                    : Icons.arrow_forward_ios,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWebsite(String website) async {
    String url = website;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showAcceptedDialog(BuildContext context) {
    // Capturar el cubit y el Navigator root ANTES de mostrar el diálogo
    final offersCubit = context.read<OffersCubit>();
    // Capturar el Navigator root antes de hacer cualquier pop
    final rootNavigator = Navigator.of(context, rootNavigator: true);

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
                // Recargar ofertas antes de volver
                offersCubit.loadMyOffers();
                if (context.mounted) {
                  Navigator.pop(
                    context,
                    true,
                  ); // Vuelve a la lista indicando que hubo cambios
                }
              },
              child: const Text('Cerrar'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                // Cerrar el diálogo
                Navigator.pop(dialogContext);

                // Recargar ofertas
                offersCubit.loadMyOffers();

                // Cerrar la página de detalle
                if (context.mounted) {
                  Navigator.pop(context, true);
                }

                // Esperar un momento para que la navegación se complete
                await Future.delayed(const Duration(milliseconds: 600));

                // Navegar a bookings usando el root navigator
                // Lo capturamos antes de hacer cualquier pop, así que debería ser seguro
                if (rootNavigator.mounted) {
                  rootNavigator.pushNamed(AppRouter.bookings);
                }
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
