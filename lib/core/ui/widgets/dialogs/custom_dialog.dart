import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';
import '../buttons/primary_button.dart';

/// Diálogo personalizado genérico.
/// 
/// Base para crear diálogos con diseño consistente.
/// Para casos específicos, usar:
/// - [SuccessDialog] para éxito
/// - [ErrorDialog] para errores
/// - [InfoDialog] para información
/// - [ConfirmationDialog] para confirmaciones
/// 
/// Ejemplo de uso:
/// ```dart
/// CustomDialog.show(
///   context: context,
///   icon: Icons.help_outline,
///   iconColor: AppTheme.secondarySteelBlue,
///   title: 'Título',
///   message: 'Mensaje del diálogo',
///   buttonText: 'Aceptar',
/// );
/// ```
class CustomDialog extends StatelessWidget {
  /// Icono a mostrar
  final IconData icon;
  
  /// Color del icono
  final Color iconColor;
  
  /// Título del diálogo
  final String title;
  
  /// Mensaje del diálogo
  final String message;
  
  /// Texto del botón
  final String buttonText;
  
  /// Callback al presionar el botón
  final VoidCallback? onPressed;

  const CustomDialog({
    super.key,
    required this.icon,
    this.iconColor = AppTheme.primaryBlue,
    required this.title,
    required this.message,
    this.buttonText = 'Aceptar',
    this.onPressed,
  });

  /// Muestra el diálogo
  static Future<void> show({
    required BuildContext context,
    required IconData icon,
    Color iconColor = AppTheme.primaryBlue,
    required String title,
    required String message,
    String buttonText = 'Aceptar',
    VoidCallback? onPressed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        icon: icon,
        iconColor: iconColor,
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
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
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: iconColor,
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
              onPressed: () {
                Navigator.of(context).pop();
                onPressed?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
