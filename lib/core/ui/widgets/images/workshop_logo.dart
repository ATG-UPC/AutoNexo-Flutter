import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';

/// Widget para mostrar logo de taller con placeholder.
/// 
/// Ejemplo de uso:
/// ```dart
/// WorkshopLogo(
///   logoUrl: workshop.logoUrl,
///   size: 60,
/// )
/// ```
class WorkshopLogo extends StatelessWidget {
  /// URL del logo (puede ser null)
  final String? logoUrl;
  
  /// Tamaño del logo (cuadrado)
  final double size;
  
  /// Radio de los bordes
  final double? borderRadius;
  
  /// Nombre del taller para generar placeholder
  final String? workshopName;

  const WorkshopLogo({
    super.key,
    this.logoUrl,
    required this.size,
    this.borderRadius,
    this.workshopName,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? size * 0.2;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.gray1.withOpacity(0.5),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppTheme.gray1,
          width: 1,
        ),
      ),
      child: logoUrl != null && logoUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Image.network(
                logoUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: size * 0.4,
                      height: size * 0.4,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    if (workshopName != null && workshopName!.isNotEmpty) {
      final initials = _getInitials(workshopName!);
      return Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
      );
    }
    
    return Center(
      child: Icon(
        Icons.store,
        size: size * 0.5,
        color: AppTheme.gray2.withOpacity(0.5),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}

