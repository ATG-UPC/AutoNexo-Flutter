import 'package:flutter/material.dart';

/// Bottom Navigation Bar personalizado
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: _buildNavItem(
                  icon: Icons.home,
                  label: 'Inicio',
                  index: 0,
                  isSelected: currentIndex == 0,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.directions_car,
                  label: 'Vehículos',
                  index: 1,
                  isSelected: currentIndex == 1,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.handyman,
                  label: 'Servicios',
                  index: 2,
                  isSelected: currentIndex == 2,
                  isCenter: true,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.build,
                  label: 'Talleres',
                  index: 3,
                  isSelected: currentIndex == 3,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.local_offer,
                  label: 'Ofertas',
                  index: 4,
                  isSelected: currentIndex == 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    bool isCenter = false,
  }) {
    final Color selectedColor = const Color(0xFF5B7C99);
    final Color unselectedColor = Colors.grey[400]!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? selectedColor : unselectedColor,
                size: isCenter ? 24 : 20,
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: isSelected ? selectedColor : unselectedColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
