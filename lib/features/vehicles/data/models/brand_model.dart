import 'package:equatable/equatable.dart';

/// Modelo de marca de vehículo para serialización JSON
class BrandModel extends Equatable {
  /// ID único de la marca
  final int id;

  /// Nombre de la marca
  final String name;

  /// URL del logo de la marca
  final String? logoUrl;

  /// Si es una marca popular
  final bool isPopular;

  const BrandModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.isPopular = false,
  });

  /// Crea un BrandModel desde JSON
  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as int,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }

  /// Convierte el BrandModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'isPopular': isPopular,
    };
  }

  @override
  List<Object?> get props => [id, name, logoUrl, isPopular];
}






