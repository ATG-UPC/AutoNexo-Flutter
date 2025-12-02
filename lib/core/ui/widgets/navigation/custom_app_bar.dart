import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';

/// AppBar personalizado con estilo consistente.
/// 
/// Ejemplo de uso:
/// ```dart
/// Scaffold(
///   appBar: CustomAppBar(
///     title: 'Mis Vehículos',
///     actions: [
///       IconButton(
///         icon: Icon(Icons.add),
///         onPressed: () => _addVehicle(),
///       ),
///     ],
///   ),
///   body: ...
/// )
/// ```
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Título del AppBar
  final String title;
  
  /// Widgets de acción a la derecha
  final List<Widget>? actions;
  
  /// Widget personalizado a la izquierda
  final Widget? leading;
  
  /// Mostrar botón de retroceso automático
  final bool showBackButton;
  
  /// Color de fondo
  final Color? backgroundColor;
  
  /// Color del texto y los iconos
  final Color? foregroundColor;
  
  /// Elevación de la sombra
  final double elevation;
  
  /// Widget de título personalizado (reemplaza el texto del título)
  final Widget? titleWidget;
  
  /// Centrar el título
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.titleWidget,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    
    return AppBar(
      title: titleWidget ?? Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? AppTheme.primaryWhite,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppTheme.primaryBlue,
      foregroundColor: foregroundColor ?? AppTheme.primaryWhite,
      elevation: elevation,
      leading: leading ?? (showBackButton && canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null),
      actions: actions,
      iconTheme: IconThemeData(
        color: foregroundColor ?? AppTheme.primaryWhite,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// AppBar transparente para usar sobre contenido con imagen.
/// 
/// Ejemplo de uso:
/// ```dart
/// Scaffold(
///   extendBodyBehindAppBar: true,
///   appBar: TransparentAppBar(
///     title: 'Detalle',
///   ),
///   body: ...
/// )
/// ```
class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Título del AppBar
  final String? title;
  
  /// Widgets de acción
  final List<Widget>? actions;
  
  /// Mostrar botón de retroceso
  final bool showBackButton;
  
  /// Color de los iconos
  final Color iconColor;

  const TransparentAppBar({
    super.key,
    this.title,
    this.actions,
    this.showBackButton = true,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: showBackButton && canPop
          ? IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: iconColor,
                  size: 18,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

