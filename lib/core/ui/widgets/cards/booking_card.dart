import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';
import '../badges/status_badge.dart';

/// Tarjeta para mostrar una reserva de servicio.
/// 
/// Ejemplo de uso:
/// ```dart
/// BookingCard(
///   workshopName: 'Taller Mecánico Lima',
///   vehicleName: 'Toyota Corolla',
///   scheduledDate: DateTime(2025, 12, 5),
///   status: 'SCHEDULED',
///   services: ['Cambio de aceite', 'Inspección de frenos'],
///   price: 250.00,
///   onTap: () => _viewBookingDetails(booking),
/// )
/// ```
class BookingCard extends StatelessWidget {
  /// Nombre del taller
  final String workshopName;
  
  /// Nombre del vehículo
  final String vehicleName;
  
  /// Fecha programada
  final DateTime scheduledDate;
  
  /// Estado de la reserva
  final String status;
  
  /// Lista de servicios
  final List<String> services;
  
  /// Precio (opcional)
  final double? price;
  
  /// Moneda
  final String currency;
  
  /// Callback cuando se toca la tarjeta
  final VoidCallback? onTap;
  
  /// Callback para cancelar
  final VoidCallback? onCancel;
  
  /// Callback para confirmar recogida
  final VoidCallback? onConfirmPickup;

  const BookingCard({
    super.key,
    required this.workshopName,
    required this.vehicleName,
    required this.scheduledDate,
    required this.status,
    this.services = const [],
    this.price,
    this.currency = 'PEN',
    this.onTap,
    this.onCancel,
    this.onConfirmPickup,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con taller y status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workshopName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 12),
              
              // Vehículo
              Row(
                children: [
                  const Icon(
                    Icons.directions_car,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    vehicleName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Fecha
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(scheduledDate),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              
              // Servicios
              if (services.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: services.take(3).map((service) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.gray1.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        service,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (services.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${services.length - 3} más',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
              ],
              
              // Precio y acciones
              if (price != null || _showActions) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (price != null)
                      Text(
                        _formatPrice(price!, currency),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      )
                    else
                      const SizedBox(),
                    if (_showActions) _buildActions(),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool get _showActions => 
      (status == 'COMPLETED' && onConfirmPickup != null) ||
      (status == 'SCHEDULED' && onCancel != null);

  Widget _buildActions() {
    if (status == 'COMPLETED' && onConfirmPickup != null) {
      return TextButton.icon(
        onPressed: onConfirmPickup,
        icon: const Icon(Icons.check_circle, size: 18),
        label: const Text('Confirmar recogida'),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.successColor,
        ),
      );
    }
    if (status == 'SCHEDULED' && onCancel != null) {
      return TextButton.icon(
        onPressed: onCancel,
        icon: const Icon(Icons.cancel, size: 18),
        label: const Text('Cancelar'),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.errorColor,
        ),
      );
    }
    return const SizedBox();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPrice(double amount, String currency) {
    final symbol = currency == 'PEN' ? 'S/' : '\$';
    return '$symbol ${amount.toStringAsFixed(2)}';
  }
}

