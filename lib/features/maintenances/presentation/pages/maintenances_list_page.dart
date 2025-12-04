import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/models.dart';
import '../cubit/cubit.dart';
import 'maintenance_detail_page.dart';
import 'create_manual_maintenance_page.dart';

/// Página que muestra el historial de mantenimientos de un vehículo
class MaintenancesListPage extends StatefulWidget {
  final int vehicleId;
  final String? vehicleName;

  const MaintenancesListPage({
    super.key,
    required this.vehicleId,
    this.vehicleName,
  });

  @override
  State<MaintenancesListPage> createState() => _MaintenancesListPageState();
}

class _MaintenancesListPageState extends State<MaintenancesListPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<MaintenancesCubit>().loadVehicleMaintenances(widget.vehicleId);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MaintenancesCubit>().loadMoreMaintenances();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicleName ?? 'Historial de Mantenimientos'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToCreate(context),
            tooltip: 'Agregar mantenimiento manual',
          ),
        ],
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
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () => context.read<MaintenancesCubit>().refresh(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Header con estadísticas
                SliverToBoxAdapter(
                  child: _buildHeader(context, state),
                ),

                // Lista o estados
                if (state.isLoading && state.maintenances.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.maintenances.isEmpty)
                  SliverFillRemaining(
                    child: _buildEmptyState(context),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < state.maintenances.length) {
                            return _MaintenanceCard(
                              maintenance: state.maintenances[index],
                              onTap: () => _navigateToDetail(
                                  context, state.maintenances[index]),
                            );
                          }
                          if (state.hasMorePages) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return null;
                        },
                        childCount: state.maintenances.length + (state.hasMorePages ? 1 : 0),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(context),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MaintenancesState state) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historial de Mantenimientos',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.totalMaintenances} registro${state.totalMaintenances == 1 ? '' : 's'}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          if (state.pendingMaintenances.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.pending_actions,
                    size: 18,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${state.pendingMaintenances.length} pendiente(s) de confirmación',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build_circle_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin mantenimientos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no hay registros de mantenimiento.\nAgrega el primero para comenzar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreate(context),
              icon: const Icon(Icons.add),
              label: const Text('Agregar Mantenimiento'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, MaintenanceModel maintenance) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MaintenancesCubit>()
            ..selectMaintenance(maintenance),
          child: MaintenanceDetailPage(maintenance: maintenance),
        ),
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MaintenancesCubit>(),
          child: CreateManualMaintenancePage(vehicleId: widget.vehicleId),
        ),
      ),
    );
  }
}

/// Card para mostrar un mantenimiento
class _MaintenanceCard extends StatelessWidget {
  final MaintenanceModel maintenance;
  final VoidCallback onTap;

  const _MaintenanceCard({
    required this.maintenance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  _buildStatusBadge(context),
                  const Spacer(),
                  Text(
                    maintenance.formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Info
              Row(
                children: [
                  Icon(
                    Icons.speed,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    maintenance.formattedMileage,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.handyman,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${maintenance.servicesCount} servicio(s)',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Costo total
              Row(
                children: [
                  Icon(
                    Icons.monetization_on_outlined,
                    size: 16,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    maintenance.formattedTotalCost,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),

              // Observaciones
              if (maintenance.observations != null &&
                  maintenance.observations!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  maintenance.observations!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (maintenance.status) {
      case MaintenanceStatus.pendingConfirmation:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        text = 'Pendiente';
        icon = Icons.pending_actions;
        break;
      case MaintenanceStatus.confirmed:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        text = 'Confirmado';
        icon = Icons.check_circle;
        break;
      case MaintenanceStatus.rejected:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        text = 'Rechazado';
        icon = Icons.cancel;
        break;
      case MaintenanceStatus.manual:
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        text = 'Manual';
        icon = Icons.edit_note;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

