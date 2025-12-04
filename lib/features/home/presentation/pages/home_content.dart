import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../vehicles/presentation/cubit/cubit.dart';
import '../cubit/cubit.dart';
import '../widgets/widgets.dart';

/// Contenido del Home (extraído para usar con MainPage)
/// NO tiene su propio Scaffold - el Scaffold está en MainPage
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Usar addPostFrameCallback para evitar llamar durante el build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        _initialized = true;
        _loadInitialData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    // Pequeño delay para asegurar que el token esté completamente guardado
    // después del login (evita race condition con SecureStorage)
    await Future.delayed(const Duration(milliseconds: 150));
    
    // Verificar que el widget siga montado después del delay
    if (!mounted) return;
    
    // Cargar datos del home (solo si no hay datos aún)
    context.read<HomeCubit>().loadHomeData();
    // Cargar vehículos para mostrar el resumen
    context.read<VehiclesCubit>().loadVehicles();
  }

  Future<void> _onRefresh() async {
    // Forzar recarga de datos
    await context.read<HomeCubit>().refresh();
    // También recargar vehículos
    await context.read<VehiclesCubit>().loadVehicles();
  }

  void _navigateToVehicles() {
    // Navegar a la pestaña de vehículos (index 1)
    context.read<HomeCubit>().changeNavIndex(1);
  }

  @override
  Widget build(BuildContext context) {
    // NO usar Scaffold aquí - MainPage ya tiene uno con el drawer
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, homeState) {
            return Column(
              children: [
                // Header siempre visible
                _buildHeader(),

                // Contenido scrollable
                Expanded(
                  child: _buildContent(homeState),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(HomeState homeState) {
    // Mostrar error si hubo fallo
    if (homeState.status == Status.failure) {
      return _buildErrorState(homeState.errorMessage);
    }

    // Mostrar contenido con indicador de carga superpuesto si está cargando
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Logo Autonexo
                _buildLogo(),

                const SizedBox(height: 24),

                // Resumen de mis vehículos
                MyVehiclesSummary(
                  onViewAll: _navigateToVehicles,
                  onAddVehicle: _navigateToVehicles,
                ),

                const SizedBox(height: 24),

                // Tarjeta de cita actual
                homeState.currentAppointment != null
                    ? AppointmentCard(
                        appointment: homeState.currentAppointment!,
                      )
                    : const NoAppointmentCard(),

                const SizedBox(height: 24),

                // Calendario de horarios
                const ScheduleCalendar(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        
        // Indicador de carga superpuesto (no bloquea interacción)
        if (homeState.status == Status.loading)
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Actualizando...',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Ocurrió un error al cargar los datos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<HomeCubit>().loadHomeData(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B7C99),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.user;
        final firstName = user?.firstName ?? 'Usuario';

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
              // Avatar
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Color(0xFF5B7C99),
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              // Saludo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hola',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      firstName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Bienvenido de vuelta',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Notificaciones
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: Colors.white,
                onPressed: () {
                  AppRouter.toNotifications(context);
                },
              ),

              // Menu hamburguesa - usa Builder para el contexto correcto
              Builder(
                builder: (scaffoldContext) => IconButton(
                  icon: const Icon(Icons.menu),
                  color: Colors.white,
                  onPressed: () {
                    Scaffold.of(scaffoldContext).openDrawer();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Image.asset(
        'assets/images/Logo_Autonexoo.png',
        height: 120,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Column(
            children: [
              Icon(Icons.car_repair, size: 80, color: Color(0xFF5B7C99)),
              SizedBox(height: 8),
              Text(
                'AutoNexo',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B7C99),
                ),
              ),
              Text(
                'QUICK SERVICE',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFEF476F),
                  letterSpacing: 2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
