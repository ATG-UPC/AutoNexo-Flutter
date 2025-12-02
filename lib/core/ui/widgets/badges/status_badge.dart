import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';

/// Badge para mostrar estados con colores distintivos.
/// 
/// Ejemplo de uso:
/// ```dart
/// StatusBadge(status: 'SCHEDULED')
/// StatusBadge(status: 'COMPLETED', label: 'Completado')
/// ```
class StatusBadge extends StatelessWidget {
  /// Código del estado
  final String status;
  
  /// Etiqueta personalizada (opcional, usa traducción por defecto)
  final String? label;
  
  /// Tamaño del badge
  final StatusBadgeSize size;

  const StatusBadge({
    super.key,
    required this.status,
    this.label,
    this.size = StatusBadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    final displayLabel = label ?? config.label;
    
    final (padding, fontSize) = switch (size) {
      StatusBadgeSize.small => (
        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        10.0
      ),
      StatusBadgeSize.medium => (
        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        12.0
      ),
      StatusBadgeSize.large => (
        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        14.0
      ),
    };
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayLabel,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: config.textColor,
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    return switch (status.toUpperCase()) {
      // Service Request Status
      'OPEN' => _StatusConfig(
        label: 'Abierta',
        backgroundColor: AppTheme.secondarySteelBlue.withOpacity(0.15),
        textColor: AppTheme.secondarySteelBlue,
      ),
      'WITH_OFFERS' => _StatusConfig(
        label: 'Con ofertas',
        backgroundColor: AppTheme.warningColor.withOpacity(0.15),
        textColor: AppTheme.warningColor,
      ),
      'ACCEPTED' => _StatusConfig(
        label: 'Aceptada',
        backgroundColor: AppTheme.successColor.withOpacity(0.15),
        textColor: AppTheme.successColor,
      ),
      
      // Service Booking Status
      'SCHEDULED' => _StatusConfig(
        label: 'Agendado',
        backgroundColor: AppTheme.secondarySteelBlue.withOpacity(0.15),
        textColor: AppTheme.secondarySteelBlue,
      ),
      'IN_PROGRESS' => _StatusConfig(
        label: 'En progreso',
        backgroundColor: AppTheme.warningColor.withOpacity(0.15),
        textColor: AppTheme.warningColor,
      ),
      'COMPLETED' => _StatusConfig(
        label: 'Completado',
        backgroundColor: AppTheme.successColor.withOpacity(0.15),
        textColor: AppTheme.successColor,
      ),
      'PICKED_UP' => _StatusConfig(
        label: 'Recogido',
        backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
        textColor: AppTheme.primaryBlue,
      ),
      'CANCELLED' => _StatusConfig(
        label: 'Cancelado',
        backgroundColor: AppTheme.errorColor.withOpacity(0.15),
        textColor: AppTheme.errorColor,
      ),
      
      // Offer Status
      'PENDING' => _StatusConfig(
        label: 'Pendiente',
        backgroundColor: AppTheme.warningColor.withOpacity(0.15),
        textColor: AppTheme.warningColor,
      ),
      'REJECTED' => _StatusConfig(
        label: 'Rechazada',
        backgroundColor: AppTheme.errorColor.withOpacity(0.15),
        textColor: AppTheme.errorColor,
      ),
      'EXPIRED' => _StatusConfig(
        label: 'Expirada',
        backgroundColor: AppTheme.gray2.withOpacity(0.15),
        textColor: AppTheme.gray2,
      ),
      'WITHDRAWN' => _StatusConfig(
        label: 'Retirada',
        backgroundColor: AppTheme.gray2.withOpacity(0.15),
        textColor: AppTheme.gray2,
      ),
      
      // Maintenance Status
      'PENDING_CONFIRMATION' => _StatusConfig(
        label: 'Por confirmar',
        backgroundColor: AppTheme.warningColor.withOpacity(0.15),
        textColor: AppTheme.warningColor,
      ),
      'CONFIRMED' => _StatusConfig(
        label: 'Confirmado',
        backgroundColor: AppTheme.successColor.withOpacity(0.15),
        textColor: AppTheme.successColor,
      ),
      'MANUAL' => _StatusConfig(
        label: 'Manual',
        backgroundColor: AppTheme.secondarySteelBlue.withOpacity(0.15),
        textColor: AppTheme.secondarySteelBlue,
      ),
      
      // Default
      _ => _StatusConfig(
        label: status,
        backgroundColor: AppTheme.gray1.withOpacity(0.5),
        textColor: AppTheme.textSecondary,
      ),
    };
  }
}

class _StatusConfig {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}

/// Tamaños disponibles para StatusBadge
enum StatusBadgeSize {
  small,
  medium,
  large,
}

