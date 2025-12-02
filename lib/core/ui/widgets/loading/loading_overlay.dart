import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';
import 'loading_indicator.dart';

/// Overlay de carga que bloquea la interacción con la UI.
/// 
/// Ejemplo de uso:
/// ```dart
/// // Mostrar overlay
/// LoadingOverlay.show(context);
/// 
/// // Hacer operación async
/// await _performOperation();
/// 
/// // Ocultar overlay
/// LoadingOverlay.hide(context);
/// ```
/// 
/// También puede usarse como widget:
/// ```dart
/// Stack(
///   children: [
///     MyContent(),
///     if (isLoading) const LoadingOverlay(),
///   ],
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  /// Mensaje opcional a mostrar
  final String? message;
  
  /// Color de fondo del overlay
  final Color? backgroundColor;
  
  /// Opacidad del fondo
  final double backgroundOpacity;

  const LoadingOverlay({
    super.key,
    this.message,
    this.backgroundColor,
    this.backgroundOpacity = 0.5,
  });

  /// Muestra el overlay como un dialog modal
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => LoadingOverlay(message: message),
    );
  }

  /// Oculta el overlay
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: (backgroundColor ?? Colors.black).withOpacity(backgroundOpacity),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LoadingIndicator(size: 40),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget wrapper que muestra un overlay de carga sobre su contenido.
/// 
/// Ejemplo de uso:
/// ```dart
/// LoadingWrapper(
///   isLoading: _isLoading,
///   message: 'Guardando...',
///   child: MyContent(),
/// )
/// ```
class LoadingWrapper extends StatelessWidget {
  /// Widget hijo sobre el que se muestra el overlay
  final Widget child;
  
  /// Si se debe mostrar el overlay de carga
  final bool isLoading;
  
  /// Mensaje opcional a mostrar
  final String? message;

  const LoadingWrapper({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: LoadingOverlay(
              message: message,
              backgroundOpacity: 0.3,
            ),
          ),
      ],
    );
  }
}

