import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

/// Diálogo de confirmación con botones de confirmar y cancelar.
/// 
/// Ejemplo de uso:
/// ```dart
/// final result = await ConfirmationDialog.show(
///   context: context,
///   title: 'Cancelar reserva',
///   message: '¿Estás seguro de cancelar esta reserva?',
///   confirmText: 'Sí, cancelar',
///   cancelText: 'No',
/// );
/// 
/// if (result == true) {
///   // Usuario confirmó
/// }
/// ```
class ConfirmationDialog extends StatelessWidget {
  /// Título del diálogo
  final String title;
  
  /// Mensaje descriptivo
  final String message;
  
  /// Texto del botón de confirmar
  final String confirmText;
  
  /// Texto del botón de cancelar
  final String cancelText;
  
  /// Icono opcional a mostrar
  final IconData? icon;
  
  /// Color del icono
  final Color? iconColor;
  
  /// Si el botón de confirmar es destructivo (color rojo)
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    this.icon,
    this.iconColor,
    this.isDestructive = false,
  });

  /// Muestra el diálogo y retorna true si el usuario confirma, false si cancela
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    IconData? icon,
    Color? iconColor,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor,
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppTheme.primaryBlue).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor ?? AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
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
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: cancelText,
                    height: 48,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: confirmText,
                    height: 48,
                    backgroundColor: isDestructive 
                        ? AppTheme.errorColor 
                        : AppTheme.primaryBlue,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

