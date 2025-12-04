import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../service_requests/service_requests.dart';
import '../../../vehicles/presentation/pages/vehicles_list_page.dart';
import '../../../workshops/workshops.dart';
import '../cubit/cubit.dart';
import '../widgets/widgets.dart';
import 'home_content.dart';

/// Página principal que contiene el BottomNavBar y las diferentes secciones
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Lista de páginas para el IndexedStack
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeContent(),
      const VehiclesListPage(),
      // ServiceRequestsListPage envuelto en su BlocProvider
      BlocProvider(
        create: (_) => ServiceRequestsCubit(),
        child: const ServiceRequestsListPage(),
      ),
      // WorkshopSearchPage envuelto en su BlocProvider
      BlocProvider(
        create: (_) => WorkshopsCubit(),
        child: const WorkshopSearchPage(),
      ),
      const _PlaceholderPage(title: 'Ofertas', icon: Icons.local_offer),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Usar BlocSelector para solo escuchar cambios en selectedNavIndex
    // Esto evita reconstrucciones innecesarias cuando cambia el status de carga
    return BlocSelector<HomeCubit, HomeState, int>(
      selector: (state) => state.selectedNavIndex,
      builder: (context, selectedNavIndex) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: const CustomDrawer(),
          body: IndexedStack(
            index: selectedNavIndex,
            children: _pages,
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: selectedNavIndex,
            onTap: (index) {
              context.read<HomeCubit>().changeNavIndex(index);
            },
          ),
        );
      },
    );
  }
}

/// Página placeholder para secciones no implementadas
class _PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderPage({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
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
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B7C99).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 80,
                        color: const Color(0xFF5B7C99),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B2D42),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Próximamente',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8D99AE),
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
}


