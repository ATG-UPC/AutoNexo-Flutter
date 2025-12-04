import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// Timeline visual del progreso de una reserva
class BookingTimeline extends StatelessWidget {
  final ServiceBookingModel booking;

  const BookingTimeline({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final currentStep = booking.timelineStep;
    final isCancelled = booking.status == ServiceBookingStatus.CANCELLED;

    if (isCancelled) {
      return _buildCancelledTimeline(context);
    }

    return Column(
      children: [
        _buildTimelineStep(
          context,
          index: 0,
          currentStep: currentStep,
          icon: Icons.calendar_today,
          title: 'Agendado',
          subtitle: booking.formattedCreatedAt,
          isFirst: true,
        ),
        _buildTimelineStep(
          context,
          index: 1,
          currentStep: currentStep,
          icon: Icons.build,
          title: 'En Progreso',
          subtitle: currentStep >= 1 ? 'Servicio en curso' : 'Pendiente',
        ),
        _buildTimelineStep(
          context,
          index: 2,
          currentStep: currentStep,
          icon: Icons.check_circle,
          title: 'Completado',
          subtitle: booking.completedAt != null
              ? _formatDate(booking.completedAt!)
              : 'Pendiente',
        ),
        _buildTimelineStep(
          context,
          index: 3,
          currentStep: currentStep,
          icon: Icons.directions_car,
          title: 'Recogido',
          subtitle: booking.pickedUpAt != null
              ? _formatDate(booking.pickedUpAt!)
              : 'Pendiente',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildCancelledTimeline(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cancel_outlined,
            color: Colors.red.shade700,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reserva Cancelada',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                if (booking.cancelledAt != null)
                  Text(
                    'Cancelada el ${_formatDate(booking.cancelledAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade600,
                    ),
                  ),
                if (booking.cancellationReason != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Motivo: ${booking.cancellationReason}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
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

  Widget _buildTimelineStep(
    BuildContext context, {
    required int index,
    required int currentStep,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final isCompleted = currentStep >= index;
    final isCurrent = currentStep == index;
    
    final activeColor = theme.primaryColor;
    final inactiveColor = Colors.grey.shade300;
    final completedColor = Colors.green;

    Color getStepColor() {
      if (isCompleted && !isCurrent) return completedColor;
      if (isCurrent) return activeColor;
      return inactiveColor;
    }

    return IntrinsicHeight(
      child: Row(
        children: [
          // Línea y círculo
          SizedBox(
            width: 48,
            child: Column(
              children: [
                // Línea superior
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 16,
                    color: currentStep >= index ? completedColor : inactiveColor,
                  ),
                // Círculo con icono
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: getStepColor(),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: isCompleted || isCurrent ? Colors.white : Colors.grey.shade500,
                  ),
                ),
                // Línea inferior
                if (!isLast)
                  Container(
                    width: 2,
                    height: 16,
                    color: currentStep > index ? completedColor : inactiveColor,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Contenido
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: isFirst ? 0 : 8,
                bottom: isLast ? 0 : 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: isCompleted || isCurrent 
                          ? Colors.black87 
                          : Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isCompleted || isCurrent 
                          ? Colors.grey.shade600 
                          : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

