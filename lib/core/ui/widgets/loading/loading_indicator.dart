import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';

/// Indicador de carga circular personalizado.
/// 
/// Ejemplo de uso:
/// ```dart
/// LoadingIndicator()
/// LoadingIndicator(size: 40, color: Colors.blue)
/// ```
class LoadingIndicator extends StatelessWidget {
  /// Tamaño del indicador
  final double size;
  
  /// Color del indicador (usa primaryBlue por defecto)
  final Color? color;
  
  /// Grosor de la línea del indicador
  final double strokeWidth;

  const LoadingIndicator({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppTheme.primaryBlue,
        ),
      ),
    );
  }
}

/// Widget centrado con LoadingIndicator para usar en páginas completas.
/// 
/// Ejemplo de uso:
/// ```dart
/// LoadingPage()
/// LoadingPage(message: 'Cargando datos...')
/// ```
class LoadingPage extends StatelessWidget {
  /// Mensaje opcional a mostrar debajo del indicador
  final String? message;
  
  /// Tamaño del indicador
  final double size;
  
  /// Color del indicador
  final Color? color;

  const LoadingPage({
    super.key,
    this.message,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingIndicator(size: size, color: color),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

