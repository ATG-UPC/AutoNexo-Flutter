import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';

/// Item para la barra de navegación inferior.
class BottomNavItem {
  /// Icono del item
  final IconData icon;
  
  /// Icono cuando está seleccionado (opcional)
  final IconData? activeIcon;
  
  /// Etiqueta del item
  final String label;

  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

/// Barra de navegación inferior personalizada.
/// 
/// Ejemplo de uso:
/// ```dart
/// CustomBottomNavBar(
///   currentIndex: _currentIndex,
///   onTap: (index) => setState(() => _currentIndex = index),
///   items: [
///     BottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Inicio'),
///     BottomNavItem(icon: Icons.directions_car_outlined, activeIcon: Icons.directions_car, label: 'Vehículos'),
///     BottomNavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today, label: 'Reservas'),
///     BottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Perfil'),
///   ],
/// )
/// ```
class CustomBottomNavBar extends StatelessWidget {
  /// Índice del item seleccionado
  final int currentIndex;
  
  /// Callback cuando se toca un item
  final ValueChanged<int> onTap;
  
  /// Lista de items de navegación
  final List<BottomNavItem> items;
  
  /// Color de fondo de la barra
  final Color? backgroundColor;
  
  /// Color del item seleccionado
  final Color? selectedColor;
  
  /// Color del item no seleccionado
  final Color? unselectedColor;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;
              
              return _NavItem(
                icon: isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                label: item.label,
                isSelected: isSelected,
                selectedColor: selectedColor ?? AppTheme.primaryBlue,
                unselectedColor: unselectedColor ?? AppTheme.gray2,
                onTap: () => onTap(index),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedColor : unselectedColor;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

