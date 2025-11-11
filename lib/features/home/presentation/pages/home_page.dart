import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/cubit.dart';
import '../widgets/widgets.dart';

/// Página principal del home
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Cargar datos del home al iniciar
    context.read<HomeCubit>().loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, homeState) {
            if (homeState.status == Status.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Header
                _buildHeader(),

                // Contenido scrollable
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await context.read<HomeCubit>().loadHomeData();
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // Logo Autonexo
                          _buildLogo(),

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
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return CustomBottomNavBar(
            currentIndex: state.selectedNavIndex,
            onTap: (index) {
              context.read<HomeCubit>().changeNavIndex(index);
              // TODO: Implementar navegación a otras secciones
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.user;
        final firstName = user?.firstName ?? 'User';

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
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: const Color(0xFF5B7C99),
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
                      'Hello',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '$firstName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Welcome back',
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
                  // TODO: Navegar a notificaciones
                },
              ),

              // Menu hamburguesa
              IconButton(
                icon: const Icon(Icons.menu),
                color: Colors.white,
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/Logo_Login.png',
      height: 100,
      errorBuilder: (context, error, stackTrace) {
        return const Column(
          children: [
            Icon(Icons.car_repair, size: 80, color: Color(0xFF5B7C99)),
            SizedBox(height: 8),
            Text(
              'Autonexo',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B7C99),
              ),
            ),
            Text(
              'AUTOCARE SERVICE',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFEF476F),
                letterSpacing: 2,
              ),
            ),
          ],
        );
      },
    );
  }
}
