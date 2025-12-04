import 'package:equatable/equatable.dart';

/// Modelo de resultado de búsqueda de taller
class WorkshopSearchResultModel extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? logoUrl;
  final double? trustScore;
  final String subscriptionTier;
  final Set<String> capabilityTags;
  final double? distance;
  final String primaryLocation;

  const WorkshopSearchResultModel({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.trustScore,
    required this.subscriptionTier,
    required this.capabilityTags,
    this.distance,
    required this.primaryLocation,
  });

  factory WorkshopSearchResultModel.fromJson(Map<String, dynamic> json) {
    return WorkshopSearchResultModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Taller',
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      trustScore: json['trustScore'] != null 
          ? (json['trustScore'] as num).toDouble() 
          : null,
      subscriptionTier: json['subscriptionTier'] as String? ?? 'BASIC',
      capabilityTags: json['capabilityTags'] != null
          ? Set<String>.from(json['capabilityTags'] as List)
          : <String>{},
      distance: json['distance'] != null 
          ? (json['distance'] as num).toDouble() 
          : null,
      primaryLocation: json['primaryLocation'] as String? ?? 'Sin ubicación',
    );
  }

  /// Rating formateado
  String get formattedRating => trustScore?.toStringAsFixed(1) ?? 'N/A';

  /// Distancia formateada
  String get formattedDistance {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toInt()} m';
    }
    return '${distance!.toStringAsFixed(1)} km';
  }

  /// Tags formateados para mostrar
  List<String> get formattedTags {
    return capabilityTags.map((tag) {
      return tag
          .replaceAll('_', ' ')
          .toLowerCase()
          .split(' ')
          .map((word) => word.isNotEmpty 
              ? '${word[0].toUpperCase()}${word.substring(1)}' 
              : '')
          .join(' ');
    }).toList();
  }

  /// Es premium
  bool get isPremium => subscriptionTier == 'PREMIUM' || subscriptionTier == 'ENTERPRISE';

  /// Tiene logo
  bool get hasLogo => logoUrl != null && logoUrl!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        logoUrl,
        trustScore,
        subscriptionTier,
        capabilityTags,
        distance,
        primaryLocation,
      ];
}


