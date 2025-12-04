import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../data/models/appointment_model.dart';

/// Tarjeta para mostrar la cita actual/próxima
class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentCard({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título y estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Próxima Cita',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B2D42),
                ),
              ),
              _buildStatusBadge(),
            ],
          ),

          const SizedBox(height: 12),

          // Fecha y hora
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                appointment.formattedDate,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8D99AE),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                appointment.formattedTime,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B2D42),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Detalles de la cita
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono de calendario
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B7C99).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.build_outlined,
                  color: Color(0xFF5B7C99),
                  size: 32,
                ),
              ),

              const SizedBox(width: 16),

              // Información de la cita
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Servicios:', appointment.servicesDescription),
                    if (appointment.description != null && 
                        appointment.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow('Descripción:', appointment.description!),
                    ],
                    if (appointment.displayPrice != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Precio:', 
                        '${appointment.displayCurrency} ${appointment.displayPrice!.toStringAsFixed(2)}',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    
    switch (appointment.status) {
      case 'SCHEDULED':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      case 'IN_PROGRESS':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'COMPLETED':
      case 'PENDING_PICKUP':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'PENDING_SCHEDULE':
        backgroundColor = Colors.amber.shade100;
        textColor = Colors.amber.shade800;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        appointment.statusDisplay,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF8D99AE)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2B2D42),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget cuando no hay cita próxima
class NoAppointmentCard extends StatelessWidget {
  const NoAppointmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Sin Citas Próximas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agenda tu próximo mantenimiento',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // Navegar a la sección de Service Requests (índice 2 del BottomNavBar)
              context.read<HomeCubit>().changeNavIndex(2);
            },
            icon: const Icon(Icons.add),
            label: const Text('Nueva Solicitud'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF5B7C99),
              side: const BorderSide(color: Color(0xFF5B7C99)),
            ),
          ),
        ],
      ),
    );
  }
}
