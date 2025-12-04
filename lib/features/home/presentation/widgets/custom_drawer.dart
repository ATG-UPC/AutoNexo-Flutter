import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

/// Menú lateral personalizado
class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _selectedLanguage = 'English';
  bool _isDarkMode = false;

  void _toggleLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
    // TODO: Implementar cambio de idioma real
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
    // TODO: Implementar cambio de tema real
  }

  void _logout() async {
    // Capturar referencias ANTES de cerrar el drawer para evitar "widget unmounted"
    final authBloc = context.read<AuthBloc>();
    final navigator = Navigator.of(context);

    // Cerrar drawer
    navigator.pop();

    // Ejecutar logout (esto limpia el token y datos del usuario)
    authBloc.add(const AuthLogoutRequested());

    // Pequeño delay para que el BLoC procese el evento
    await Future.delayed(const Duration(milliseconds: 100));

    // Navegar a la ruta inicial donde AuthWrapper manejará el estado
    if (mounted) {
      // Limpiar todo el stack de navegación y ir a la ruta inicial
      navigator.pushNamedAndRemoveUntil(
        AppRouter.initial,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2B3E50),
      child: SafeArea(
        child: Column(
          children: [
            // Header con logo
            _buildHeader(),

            const SizedBox(height: 32),

            // Opciones del menú
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () {
                      Navigator.pop(context);
                      AppRouter.toProfile(context);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.calendar_month_outlined,
                    title: 'Mis Reservas',
                    onTap: () {
                      Navigator.pop(context);
                      AppRouter.toBookings(context);
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.star_outline,
                    title: 'Plan pro',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navegar a plan pro
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.star,
                    title: 'Plan premium',
                    iconColor: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navegar a plan premium
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.support_agent_outlined,
                    title: 'Support and Assistance',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navegar a support
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: _logout,
                  ),
                ],
              ),
            ),

            // Configuraciones (Language y Theme)
            _buildSettings(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Image.asset(
            'assets/images/Logo_Autonexoo.png',
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Column(
                children: [
                  Icon(Icons.car_repair, size: 60, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'AutoNexo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.blue,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Language',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildLanguageToggle(),
          const SizedBox(height: 24),
          const Text(
            'Theme',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildThemeToggle(),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF374B5C),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: 'Español',
              isSelected: _selectedLanguage == 'Español',
              onTap: () => _toggleLanguage('Español'),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: 'English',
              isSelected: _selectedLanguage == 'English',
              onTap: () => _toggleLanguage('English'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF374B5C),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: '',
              icon: Icons.nightlight_round,
              isSelected: _isDarkMode,
              onTap: () => _toggleTheme(true),
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: '',
              icon: Icons.wb_sunny,
              isSelected: !_isDarkMode,
              onTap: () => _toggleTheme(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7FA8C9) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 24)
              : Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
        ),
      ),
    );
  }
}
