import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';

/// Tarjeta para mostrar información de un vehículo.
/// 
/// Ejemplo de uso:
/// ```dart
/// VehicleCard(
///   brandName: 'Toyota',
///   model: 'Corolla',
///   year: 2024,
///   licensePlate: 'ABC-123',
///   imageUrl: vehicle.imageUrls.firstOrNull,
///   onTap: () => _viewVehicleDetails(vehicle),
/// )
/// ```
class VehicleCard extends StatelessWidget {
  /// Nombre de la marca del vehículo
  final String brandName;
  
  /// Modelo del vehículo
  final String model;
  
  /// Año del vehículo
  final int year;
  
  /// Placa del vehículo
  final String licensePlate;
  
  /// Color del vehículo (opcional)
  final String? color;
  
  /// Kilometraje actual (opcional)
  final int? currentMileage;
  
  /// URL de la imagen del vehículo (opcional)
  final String? imageUrl;
  
  /// Callback cuando se toca la tarjeta
  final VoidCallback? onTap;
  
  /// Callback para editar
  final VoidCallback? onEdit;
  
  /// Mostrar acciones (editar)
  final bool showActions;

  const VehicleCard({
    super.key,
    required this.brandName,
    required this.model,
    required this.year,
    required this.licensePlate,
    this.color,
    this.currentMileage,
    this.imageUrl,
    this.onTap,
    this.onEdit,
    this.showActions = true,
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
          child: Row(
            children: [
              // Imagen del vehículo
              Container(
                width: 100,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.gray1.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        ),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 16),
              // Información del vehículo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$brandName $model',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Año $year',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        licensePlate,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    if (currentMileage != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.speed,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatMileage(currentMileage!)} km',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Acciones
              if (showActions && onEdit != null)
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppTheme.secondarySteelBlue,
                  ),
                  onPressed: onEdit,
                  splashRadius: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.directions_car,
        size: 40,
        color: AppTheme.gray2.withOpacity(0.5),
      ),
    );
  }

  String _formatMileage(int mileage) {
    if (mileage >= 1000) {
      return '${(mileage / 1000).toStringAsFixed(1)}k';
    }
    return mileage.toString();
  }
}

