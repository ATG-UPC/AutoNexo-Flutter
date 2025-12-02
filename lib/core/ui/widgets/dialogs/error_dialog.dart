import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';
import '../buttons/primary_button.dart';

/// Diálogo para mostrar errores.
/// 
/// Ejemplo de uso:
/// ```dart
/// ErrorDialog.show(
///   context: context,
///   message: 'No se pudo conectar al servidor',
/// );
/// ```
class ErrorDialog extends StatelessWidget {
  /// Título del diálogo
  final String title;
  
  /// Mensaje de error
  final String message;
  
  /// Texto del botón
  final String buttonText;

  const ErrorDialog({
    super.key,
    this.title = 'Error',
    required this.message,
    this.buttonText = 'Aceptar',
  });

  /// Muestra el diálogo de error
  static Future<void> show({
    required BuildContext context,
    String title = 'Error',
    required String message,
    String buttonText = 'Aceptar',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
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
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 32,
                color: AppTheme.errorColor,
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
              backgroundColor: AppTheme.errorColor,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

