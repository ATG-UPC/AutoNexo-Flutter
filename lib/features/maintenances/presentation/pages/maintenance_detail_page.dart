import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/models.dart';
import '../cubit/cubit.dart';

/// Página de detalle de un mantenimiento
class MaintenanceDetailPage extends StatelessWidget {
  final MaintenanceModel maintenance;

  const MaintenanceDetailPage({
    super.key,
    required this.maintenance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mantenimiento #${maintenance.id}'),
        elevation: 0,
      ),
      body: BlocConsumer<MaintenancesCubit, MaintenancesState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<MaintenancesCubit>().clearMessages();
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
            context.read<MaintenancesCubit>().clearMessages();
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final currentMaintenance = state.selectedMaintenance ?? maintenance;
          final isProcessing = state.isConfirming || state.isRejecting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con estado
                _buildHeaderCard(context, currentMaintenance),
                const SizedBox(height: 16),

                // Información general
                _buildInfoCard(context, currentMaintenance),
                const SizedBox(height: 16),

                // Servicios
                _buildServicesCard(context, currentMaintenance),
                const SizedBox(height: 16),

                // Observaciones
                if (currentMaintenance.observations != null &&
                    currentMaintenance.observations!.isNotEmpty)
                  _buildObservationsCard(context, currentMaintenance),

                const SizedBox(height: 24),

                // Botones de acción
                if (currentMaintenance.canRespond)
                  _buildActionButtons(context, currentMaintenance, isProcessing),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, MaintenanceModel maintenance) {
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
                Icons.build_circle,
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
                    'Mantenimiento',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    maintenance.formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(maintenance),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MaintenanceModel maintenance) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (maintenance.status) {
      case MaintenanceStatus.pendingConfirmation:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        text = 'Pendiente';
        break;
      case MaintenanceStatus.confirmed:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        text = 'Confirmado';
        break;
      case MaintenanceStatus.rejected:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        text = 'Rechazado';
        break;
      case MaintenanceStatus.manual:
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        text = 'Manual';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, MaintenanceModel maintenance) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow(context, 'Fecha', maintenance.formattedDate),
            _buildInfoRow(context, 'Kilometraje', maintenance.formattedMileage),
            _buildInfoRow(context, 'Costo Total', maintenance.formattedTotalCost,
                highlight: true),
            if (maintenance.workshopId != null)
              _buildInfoRow(
                  context, 'Taller', 'Taller #${maintenance.workshopId}'),
            _buildInfoRow(
              context,
              'Origen',
              maintenance.createdByWorkshop
                  ? 'Registrado por taller'
                  : 'Registro propio',
            ),
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

  Widget _buildServicesCard(BuildContext context, MaintenanceModel maintenance) {
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
                Text(
                  'Servicios',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${maintenance.servicesCount}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (maintenance.services.isEmpty)
              Text(
                'Sin servicios detallados',
                style: TextStyle(color: Colors.grey.shade600),
              )
            else
              ...maintenance.services.map((service) => _buildServiceItem(context, service)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, MaintenanceServiceModel service) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Colors.green.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.formattedServiceType,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (service.description != null &&
                    service.description!.isNotEmpty)
                  Text(
                    service.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            service.formattedCost,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationsCard(BuildContext context, MaintenanceModel maintenance) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Observaciones',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Text(
              maintenance.observations!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, MaintenanceModel maintenance,
      bool isProcessing) {
    return Column(
      children: [
        // Mensaje informativo
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Este mantenimiento fue registrado por el taller. '
                  'Confirma si los datos son correctos.',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Botón confirmar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isProcessing
                ? null
                : () => _showConfirmDialog(context, maintenance.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.check),
            label: const Text('Confirmar Mantenimiento'),
          ),
        ),
        const SizedBox(height: 12),

        // Botón rechazar
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isProcessing
                ? null
                : () => _showRejectDialog(context, maintenance.id),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade600,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.close),
            label: const Text('Rechazar'),
          ),
        ),
      ],
    );
  }

  void _showConfirmDialog(BuildContext context, int maintenanceId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Mantenimiento'),
        content: const Text(
          '¿Confirmas que este mantenimiento fue realizado correctamente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<MaintenancesCubit>().confirmMaintenance(maintenanceId);
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

  void _showRejectDialog(BuildContext context, int maintenanceId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rechazar Mantenimiento'),
        content: const Text(
          '¿Estás seguro de que deseas rechazar este registro de mantenimiento? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<MaintenancesCubit>().rejectMaintenance(maintenanceId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }
}

