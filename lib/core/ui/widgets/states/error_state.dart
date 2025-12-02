import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';
import '../buttons/secondary_button.dart';

/// Widget para mostrar estado de error con opción de reintentar.
/// 
/// Ejemplo de uso:
/// ```dart
/// ErrorState(
///   message: 'No se pudo cargar la información',
///   onRetry: () => _loadData(),
/// )
/// ```
class ErrorState extends StatelessWidget {
  /// Mensaje de error
  final String message;
  
  /// Callback para reintentar (opcional)
  final VoidCallback? onRetry;
  
  /// Título del error (opcional)
  final String? title;
  
  /// Icono a mostrar
  final IconData icon;
  
  /// Tamaño del icono
  final double iconSize;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
    this.icon = Icons.error_outline,
    this.iconSize = 64,
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 24),
            if (title != null) ...[
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              SecondaryButton(
                text: 'Reintentar',
                onPressed: onRetry,
                width: 160,
                icon: const Icon(Icons.refresh, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

