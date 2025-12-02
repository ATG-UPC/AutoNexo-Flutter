import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';

/// Widget para mostrar imagen de vehículo con placeholder.
/// 
/// Ejemplo de uso:
/// ```dart
/// VehicleImage(
///   imageUrl: vehicle.imageUrls.firstOrNull,
///   width: 200,
///   height: 150,
/// )
/// ```
class VehicleImage extends StatelessWidget {
  /// URL de la imagen (puede ser null)
  final String? imageUrl;
  
  /// Ancho de la imagen
  final double width;
  
  /// Alto de la imagen
  final double height;
  
  /// Cómo ajustar la imagen
  final BoxFit fit;
  
  /// Radio de los bordes
  final BorderRadius? borderRadius;

  const VehicleImage({
    super.key,
    this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.gray1.withOpacity(0.5),
        borderRadius: radius,
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: radius,
              child: Image.network(
                imageUrl!,
                width: width,
                height: height,
                fit: fit,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: AppTheme.primaryBlue,
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
    return Center(
      child: Icon(
        Icons.directions_car,
        size: width * 0.4,
        color: AppTheme.gray2.withOpacity(0.5),
      ),
    );
  }
}

