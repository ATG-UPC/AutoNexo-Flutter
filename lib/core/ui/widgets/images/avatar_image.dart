import 'package:flutter/material.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';

/// Avatar circular con iniciales como fallback.
/// 
/// Ejemplo de uso:
/// ```dart
/// AvatarImage(
///   imageUrl: user.profileImageUrl,
///   initials: '${user.firstName[0]}${user.lastName[0]}',
///   size: 50,
/// )
/// ```
class AvatarImage extends StatelessWidget {
  /// URL de la imagen (puede ser null)
  final String? imageUrl;
  
  /// Iniciales para mostrar como fallback
  final String initials;
  
  /// Tamaño del avatar (diámetro)
  final double size;
  
  /// Color de fondo cuando muestra iniciales
  final Color? backgroundColor;
  
  /// Color del texto de las iniciales
  final Color? foregroundColor;

  const AvatarImage({
    super.key,
    this.imageUrl,
    required this.initials,
    required this.size,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.secondarySteelBlue;
    final fgColor = foregroundColor ?? AppTheme.primaryWhite;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: bgColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildInitials(bgColor, fgColor);
                },
                errorBuilder: (_, __, ___) => _buildInitials(bgColor, fgColor),
              ),
            )
          : _buildInitials(bgColor, fgColor),
    );
  }

  Widget _buildInitials(Color bgColor, Color fgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: fgColor,
          ),
        ),
      ),
    );
  }
}

