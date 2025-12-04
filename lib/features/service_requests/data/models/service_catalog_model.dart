import 'package:equatable/equatable.dart';

/// Modelo de un servicio del catálogo
class ServiceCatalogItem extends Equatable {
  /// Código único del servicio (ej: OIL_CHANGE)
  final String code;

  /// Nombre para mostrar (ej: "Cambio de aceite")
  final String displayName;

  /// Descripción del servicio
  final String description;

  /// Código de la categoría
  final String category;

  /// Nombre para mostrar de la categoría
  final String categoryDisplayName;

  const ServiceCatalogItem({
    required this.code,
    required this.displayName,
    required this.description,
    required this.category,
    required this.categoryDisplayName,
  });

  /// Crea un ServiceCatalogItem desde JSON
  factory ServiceCatalogItem.fromJson(Map<String, dynamic> json) {
    return ServiceCatalogItem(
      code: json['code'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String,
      categoryDisplayName: json['categoryDisplayName'] as String? ?? '',
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'displayName': displayName,
      'description': description,
      'category': category,
      'categoryDisplayName': categoryDisplayName,
    };
  }

  @override
  List<Object?> get props => [code, displayName, description, category, categoryDisplayName];
}

/// Modelo de una categoría de servicios
class ServiceCategoryModel extends Equatable {
  /// Código único de la categoría (ej: MAINTENANCE)
  final String code;

  /// Nombre para mostrar (ej: "Mantenimiento")
  final String displayName;

  const ServiceCategoryModel({
    required this.code,
    required this.displayName,
  });

  /// Crea un ServiceCategoryModel desde JSON
  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      code: json['code'] as String,
      displayName: json['displayName'] as String,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'displayName': displayName,
    };
  }

  @override
  List<Object?> get props => [code, displayName];
}

