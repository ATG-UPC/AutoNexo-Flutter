import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';
import '../buttons/primary_button.dart';

/// Widget para mostrar estado vacío con mensaje, icono y acción opcional.
/// 
/// Ejemplo de uso:
/// ```dart
/// EmptyState(
///   icon: Icons.directions_car_outlined,
///   title: 'No tienes vehículos',
///   message: 'Registra tu primer vehículo para comenzar',
///   actionLabel: 'Registrar Vehículo',
///   onAction: () => _registerVehicle(),
/// )
/// ```
class EmptyState extends StatelessWidget {
  /// Icono a mostrar
  final IconData icon;
  
  /// Título del estado vacío
  final String title;
  
  /// Mensaje descriptivo
  final String message;
  
  /// Etiqueta del botón de acción (opcional)
  final String? actionLabel;
  
  /// Callback para la acción (opcional)
  final VoidCallback? onAction;
  
  /// Tamaño del icono
  final double iconSize;
  
  /// Color del icono (opcional)
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconSize = 80,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.secondarySteelBlue).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor ?? AppTheme.secondarySteelBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              PrimaryButton(
                text: actionLabel!,
                onPressed: onAction,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

