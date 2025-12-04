import 'package:flutter/material.dart';
import '../../data/models/models.dart';

/// Card compacto para mostrar una oferta en la lista
class OfferCard extends StatelessWidget {
  final OfferModel offer;
  final WorkshopPublicModel? workshop;
  final VoidCallback? onTap;
  final Future<bool> Function(int offerId)? onAccept;
  final Future<bool> Function(int offerId)? onReject;
  final bool isProcessing;

  const OfferCard({
    super.key,
    required this.offer,
    this.workshop,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpired = offer.isExpired;
    final isPending = offer.isPending && !isExpired;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPending
            ? BorderSide(color: theme.primaryColor.withOpacity(0.3), width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: Taller y status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo del taller
                  _buildWorkshopLogo(),
                  const SizedBox(width: 12),
                  // Info del taller
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workshop?.name ?? 'Taller #${offer.workshopId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (workshop?.trustScore != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                workshop!.formattedTrustScore,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Status badge
                  _buildStatusBadge(context),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Fila inferior: Precio, fecha y tiempo restante
              Row(
                children: [
                  // Precio
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Precio propuesto',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          offer.formattedPrice,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Fecha propuesta
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha disponible',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              offer.formattedProposedDate,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Tiempo restante (solo si está pendiente)
              if (isPending) ...[
                const SizedBox(height: 12),
                _buildExpiryIndicator(context),
              ],

              // Mensaje del taller (si existe)
              if (offer.message != null && offer.message!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.message_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          offer.message!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Botones de acción (solo si está pendiente y no expirada)
              if (isPending && !offer.isExpired && (onAccept != null || onReject != null)) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Botón Rechazar
        if (onReject != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isProcessing
                  ? null
                  : () => _handleReject(context),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Rechazar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        if (onReject != null && onAccept != null) const SizedBox(width: 12),
        // Botón Aceptar
        if (onAccept != null)
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: isProcessing
                  ? null
                  : () => _handleAccept(context),
              icon: isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check, size: 18),
              label: Text(isProcessing ? 'Procesando...' : 'Aceptar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleAccept(BuildContext context) async {
    if (onAccept == null) return;

    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
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
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
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

    if (confirmed == true) {
      await onAccept!(offer.id);
    }
  }

  Future<void> _handleReject(BuildContext context) async {
    if (onReject == null) return;

    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Rechazo'),
          content: const Text(
            '¿Estás seguro de rechazar esta oferta?\n\nEsta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
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

    if (confirmed == true) {
      await onReject!(offer.id);
    }
  }

  Widget _buildWorkshopLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: workshop?.hasLogo == true
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                workshop!.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultLogo(),
              ),
            )
          : _buildDefaultLogo(),
    );
  }

  Widget _buildDefaultLogo() {
    return Icon(
      Icons.build_circle_outlined,
      color: Colors.grey.shade400,
      size: 24,
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text = offer.statusDisplay;

    switch (offer.status) {
      case OfferStatus.pending:
        if (offer.isExpired) {
          backgroundColor = Colors.grey.shade200;
          textColor = Colors.grey.shade700;
          text = 'Expirada';
        } else {
          backgroundColor = Colors.blue.shade50;
          textColor = Colors.blue.shade700;
        }
        break;
      case OfferStatus.accepted:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case OfferStatus.rejected:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      case OfferStatus.withdrawn:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case OfferStatus.expired:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildExpiryIndicator(BuildContext context) {
    final duration = offer.timeUntilExpiry;
    final isUrgent = duration.inHours < 24;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUrgent ? Colors.red.shade200 : Colors.amber.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: isUrgent ? Colors.red.shade700 : Colors.amber.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            'Expira en ${offer.timeUntilExpiryFormatted}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isUrgent ? Colors.red.shade700 : Colors.amber.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

