import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';
import '../buttons/primary_button.dart';

/// Diálogo informativo.
/// 
/// Ejemplo de uso:
/// ```dart
/// InfoDialog.show(
///   context: context,
///   title: 'Información',
///   message: 'Tu solicitud ha sido creada exitosamente',
/// );
/// ```
class InfoDialog extends StatelessWidget {
  /// Título del diálogo
  final String title;
  
  /// Mensaje informativo
  final String message;
  
  /// Texto del botón
  final String buttonText;
  
  /// Icono a mostrar
  final IconData icon;
  
  /// Color del icono
  final Color? iconColor;

  const InfoDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'Entendido',
    this.icon = Icons.info_outline,
    this.iconColor,
  });

  /// Muestra el diálogo informativo
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'Entendido',
    IconData icon = Icons.info_outline,
    Color? iconColor,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => InfoDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppTheme.secondarySteelBlue;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
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
            PrimaryButton(
              text: buttonText,
              height: 48,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

