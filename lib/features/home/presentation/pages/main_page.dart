import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../offers/offers.dart';
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
      // MyOffersPage envuelto en su BlocProvider
      BlocProvider(
        create: (_) => OffersCubit(),
        child: const MyOffersPage(),
      ),
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

