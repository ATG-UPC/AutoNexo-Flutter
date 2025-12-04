import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/ui/widgets/maps/maps.dart';
import '../../data/models/models.dart';
import '../cubit/cubit.dart';
import '../../../offers/offers.dart';

/// Página de detalle de una solicitud de servicio
class ServiceRequestDetailPage extends StatelessWidget {
  final ServiceRequestModel request;

  const ServiceRequestDetailPage({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitud #${request.id}'),
        elevation: 0,
      ),
      body: BlocListener<ServiceRequestsCubit, ServiceRequestsState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green.shade700,
              ),
            );
            context.read<ServiceRequestsCubit>().clearMessages();
            Navigator.pop(context);
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
              ),
            );
            context.read<ServiceRequestsCubit>().clearMessages();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estado
              _buildStatusCard(context),

              // Botón Ver Ofertas (si hay solicitud activa)
              if (request.isPending || request.status == ServiceRequestStatus.matched)
                _buildOffersSection(context),

              const SizedBox(height: 16),

              // Información general
              _buildInfoCard(context),
              const SizedBox(height: 16),

              // Servicios solicitados
              _buildServicesCard(context),
              const SizedBox(height: 16),

              // Ubicación
              _buildLocationCard(context),
              const SizedBox(height: 16),

              // Descripción
              if (request.description != null && request.description!.isNotEmpty)
                _buildDescriptionCard(context),

              const SizedBox(height: 24),

              // Botón cancelar
              if (request.isPending)
                BlocBuilder<ServiceRequestsCubit, ServiceRequestsState>(
                  builder: (context, state) {
                    final isCancelling = state.status == ServiceRequestsStatus.cancelling;
                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: isCancelling
                            ? null
                            : () => _showCancelDialog(context),
                        icon: isCancelling
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.cancel_outlined),
                        label: Text(isCancelling ? 'Cancelando...' : 'Cancelar Solicitud'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOffersSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        child: InkWell(
          onTap: () => _navigateToOffers(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_offer,
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
                        'Ofertas de Talleres',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.status == ServiceRequestStatus.matched
                            ? '¡Tienes ofertas! Revísalas aquí'
                            : 'Esperando ofertas de talleres',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToOffers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => OffersCubit(),
          child: OffersListPage(serviceRequestId: request.id),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String statusText;
    IconData icon;

    switch (request.status) {
      case ServiceRequestStatus.pending:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        statusText = 'Pendiente - Buscando talleres';
        icon = Icons.hourglass_empty;
        break;
      case ServiceRequestStatus.matched:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        statusText = 'Emparejado - Se encontraron talleres';
        icon = Icons.check_circle_outline;
        break;
      case ServiceRequestStatus.cancelled:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        statusText = 'Cancelado';
        icon = Icons.cancel_outlined;
        break;
      case ServiceRequestStatus.expired:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade600;
        statusText = 'Expirado';
        icon = Icons.timer_off_outlined;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: textColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estado',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow(
              Icons.confirmation_number_outlined,
              'ID de Solicitud',
              '#${request.id}',
            ),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Fecha de creación',
              request.formattedDate,
            ),
            _buildInfoRow(
              Icons.directions_car_outlined,
              'ID del Vehículo',
              '#${request.vehicleId}',
            ),
            if (request.cancelledAt != null)
              _buildInfoRow(
                Icons.cancel_outlined,
                'Cancelado el',
                '${request.cancelledAt!.day}/${request.cancelledAt!.month}/${request.cancelledAt!.year}',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Servicios Solicitados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${request.requestedServices.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            ...request.requestedServices.map(
              (service) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatServiceName(service),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubicación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            // Mapa
            MapWidget(
              latitude: request.latitude,
              longitude: request.longitude,
              height: 200,
              markerTitle: 'Ubicación de la solicitud',
              markerSnippet: 'Radio: ${request.searchRadiusKm} km',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.my_location,
              'Coordenadas',
              '${request.latitude.toStringAsFixed(4)}, ${request.longitude.toStringAsFixed(4)}',
            ),
            _buildInfoRow(
              Icons.radar,
              'Radio de búsqueda',
              '${request.searchRadiusKm} km',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Text(
              request.description!,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatServiceName(String code) {
    // Convierte SNAKE_CASE a Title Case
    return code
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Solicitud'),
        content: const Text(
          '¿Estás seguro de que deseas cancelar esta solicitud? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No, mantener'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ServiceRequestsCubit>().cancelServiceRequest(request.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}

