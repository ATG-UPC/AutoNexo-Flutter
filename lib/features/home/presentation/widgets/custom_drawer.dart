import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/preferences_service.dart';
import '../../../../main.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

/// Menú lateral personalizado
class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final PreferencesService _prefs = PreferencesService();
  String _selectedLanguage = 'English';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final isDark = await _prefs.isDarkMode();
    final language = await _prefs.getLanguage();
    if (mounted) {
      setState(() {
        _isDarkMode = isDark;
        _selectedLanguage = language == 'es' ? 'Español' : 'English';
      });
    }
  }

  void _toggleLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
    final languageCode = language == 'Español' ? 'es' : 'en';
    _prefs.setLanguage(languageCode);
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
    _prefs.setDarkMode(isDark);
    
    // Actualizar el tema en la app
    final themeProvider = ThemeModeProvider.of(context);
    if (themeProvider != null) {
      themeProvider.updateThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
    }
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
                      _showPlanDialog(context, 'Plan Pro', 'Funcionalidad próximamente disponible');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.star,
                    title: 'Plan premium',
                    iconColor: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _showPlanDialog(context, 'Plan Premium', 'Funcionalidad próximamente disponible');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.support_agent_outlined,
                    title: 'Support and Assistance',
                    onTap: () {
                      Navigator.pop(context);
                      _showSupportDialog(context);
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

  void _showPlanDialog(BuildContext context, String planName, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(planName),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Soporte y Asistencia'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Necesitas ayuda?'),
            SizedBox(height: 12),
            Text('Puedes contactarnos a través de:'),
            SizedBox(height: 8),
            Text('• Email: soporte@autonexo.com'),
            SizedBox(height: 4),
            Text('• Teléfono: +51 999 888 777'),
            SizedBox(height: 4),
            Text('• Horario: Lunes a Viernes 9:00 - 18:00'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
