import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';
import '../buttons/primary_button.dart';

/// Diálogo de éxito.
/// 
/// Ejemplo de uso:
/// ```dart
/// SuccessDialog.show(
///   context: context,
///   message: 'Vehículo registrado correctamente',
/// );
/// ```
class SuccessDialog extends StatelessWidget {
  /// Título del diálogo
  final String title;
  
  /// Mensaje de éxito
  final String message;
  
  /// Texto del botón
  final String buttonText;

  const SuccessDialog({
    super.key,
    this.title = 'Éxito',
    required this.message,
    this.buttonText = 'Aceptar',
  });

  /// Muestra el diálogo de éxito
  static Future<void> show({
    required BuildContext context,
    String title = 'Éxito',
    required String message,
    String buttonText = 'Aceptar',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => SuccessDialog(
        title: title,
        message: message,
        buttonText: buttonText,
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 32,
                color: AppTheme.successColor,
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
              backgroundColor: AppTheme.successColor,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

