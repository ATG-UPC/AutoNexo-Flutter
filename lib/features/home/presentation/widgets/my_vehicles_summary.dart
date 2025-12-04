import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../../../core/ui/theme/app_theme.dart';
import '../../../vehicles/presentation/cubit/cubit.dart';

/// Widget que muestra un resumen de los vehículos del usuario en el Home
class MyVehiclesSummary extends StatelessWidget {
  /// Callback para navegar a la pestaña de vehículos
  final VoidCallback? onViewAll;

  /// Callback para agregar un nuevo vehículo
  final VoidCallback? onAddVehicle;

  const MyVehiclesSummary({
    super.key,
    this.onViewAll,
    this.onAddVehicle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehiclesCubit, VehiclesState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.secondarySteelBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.directions_car,
                            color: AppTheme.secondarySteelBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Text(
                            'Mis Vehículos',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.hasVehicles && onViewAll != null)
                    TextButton(
                      onPressed: onViewAll,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Ver todos',
                        style: TextStyle(
                          color: AppTheme.secondarySteelBlue,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Content
              _buildContent(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, VehiclesState state) {
    // Solo mostrar loading si es la primera carga y no hay datos
    if (state.status == Status.loading && !state.hasVehicles) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // No vehicles (y no está cargando)
    if (!state.hasVehicles) {
      return _buildEmptyState();
    }

    // Show primary vehicle
    final vehicle = state.primaryVehicle!;
    return _buildVehiclePreview(vehicle, state);
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.gray1.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.gray1,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 48,
                color: AppTheme.gray2.withOpacity(0.7),
              ),
              const SizedBox(height: 12),
              const Text(
                'No tienes vehículos registrados',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              if (onAddVehicle != null)
                ElevatedButton.icon(
                  onPressed: onAddVehicle,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Agregar Vehículo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehiclePreview(vehicle, VehiclesState state) {
    return Row(
      children: [
        // Imagen del vehículo
        Container(
          width: 70,
          height: 55,
          decoration: BoxDecoration(
            color: AppTheme.gray1.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: vehicle.primaryImageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    vehicle.primaryImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildCarIcon(),
                  ),
                )
              : _buildCarIcon(),
        ),

        const SizedBox(width: 12),

        // Información del vehículo
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${vehicle.brandName ?? "Marca"} ${vehicle.model}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        vehicle.licensePlate,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Año ${vehicle.year}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              if (state.vehicles.length > 1) ...[
                const SizedBox(height: 8),
                Text(
                  '+${state.vehicles.length - 1} vehículo(s) más',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondarySteelBlue.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Flecha para ver más
        if (onViewAll != null)
          IconButton(
            onPressed: onViewAll,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            icon: const Icon(
              Icons.chevron_right,
              color: AppTheme.secondarySteelBlue,
              size: 24,
            ),
          ),
      ],
    );
  }

  Widget _buildCarIcon() {
    return Center(
      child: Icon(
        Icons.directions_car,
        size: 32,
        color: AppTheme.gray2.withOpacity(0.5),
      ),
    );
  }
}


