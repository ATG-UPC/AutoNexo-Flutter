import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../../../core/ui/widgets/widgets.dart';
import '../cubit/cubit.dart';
import 'add_vehicle_page.dart';
import 'vehicle_detail_page.dart';

/// Página de lista de vehículos del usuario
class VehiclesListPage extends StatefulWidget {
  const VehiclesListPage({super.key});

  @override
  State<VehiclesListPage> createState() => _VehiclesListPageState();
}

class _VehiclesListPageState extends State<VehiclesListPage> {
  @override
  void initState() {
    super.initState();
    // Cargar vehículos al iniciar
    context.read<VehiclesCubit>().loadVehicles();
  }

  void _navigateToAddVehicle() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddVehiclePage()),
    ).then((_) {
      // Recargar lista al volver
      context.read<VehiclesCubit>().loadVehicles();
    });
  }

  void _navigateToDetail(vehicle) {
    context.read<VehiclesCubit>().selectVehicle(vehicle);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VehicleDetailPage()),
    ).then((_) {
      // Recargar lista al volver
      context.read<VehiclesCubit>().loadVehicles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: BlocBuilder<VehiclesCubit, VehiclesState>(
                builder: (context, state) {
                  if (state.status == Status.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state.status == Status.failure) {
                    return ErrorState(
                      message: state.errorMessage ?? 'Error al cargar vehículos',
                      onRetry: () => context.read<VehiclesCubit>().loadVehicles(),
                    );
                  }

                  if (!state.hasVehicles) {
                    return EmptyState(
                      icon: Icons.directions_car_outlined,
                      title: 'No tienes vehículos',
                      message:
                          'Registra tu primer vehículo para comenzar a solicitar servicios',
                      actionLabel: 'Registrar Vehículo',
                      onAction: _navigateToAddVehicle,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<VehiclesCubit>().loadVehicles();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = state.vehicles[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: VehicleCard(
                            brandName: vehicle.brandName ?? 'Marca',
                            model: vehicle.model,
                            year: vehicle.year,
                            licensePlate: vehicle.licensePlate,
                            color: vehicle.color,
                            currentMileage: vehicle.currentMileage,
                            imageUrl: vehicle.primaryImageUrl,
                            onTap: () => _navigateToDetail(vehicle),
                            onEdit: () => _navigateToDetail(vehicle),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: BlocBuilder<VehiclesCubit, VehiclesState>(
        builder: (context, state) {
          if (state.hasVehicles) {
            return FloatingActionButton.extended(
              onPressed: _navigateToAddVehicle,
              backgroundColor: const Color(0xFF2B3E50),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Agregar',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF5B7C99),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Mis Vehículos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

