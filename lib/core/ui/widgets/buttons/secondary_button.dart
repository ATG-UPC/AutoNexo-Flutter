import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';

/// Botón secundario con estilo outlined.
/// 
/// Utiliza el color primario del tema para el borde y texto.
/// 
/// Ejemplo de uso:
/// ```dart
/// SecondaryButton(
///   text: 'Cancelar',
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
class SecondaryButton extends StatelessWidget {
  /// Texto del botón
  final String text;
  
  /// Callback cuando se presiona el botón
  final VoidCallback? onPressed;
  
  /// Muestra un indicador de carga
  final bool isLoading;
  
  /// Indica si el botón está habilitado
  final bool isEnabled;
  
  /// Color del borde y texto personalizado
  final Color? color;
  
  /// Ancho del botón (usa double.infinity por defecto)
  final double? width;
  
  /// Alto del botón
  final double height;
  
  /// Icono opcional a mostrar antes del texto
  final Widget? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.color,
    this.width,
    this.height = 56,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppTheme.primaryBlue;
    final isDisabled = !isEnabled || isLoading || onPressed == null;
    
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(
            color: isDisabled ? buttonColor.withOpacity(0.4) : buttonColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledForegroundColor: buttonColor.withOpacity(0.4),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDisabled ? buttonColor.withOpacity(0.4) : buttonColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

