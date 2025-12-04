import 'package:equatable/equatable.dart';

import 'location_model.dart';
import 'service_template_model.dart';

/// Modelo de perfil público de un taller
class WorkshopProfileModel extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? phoneNumber;
  final String? email;
  final String? logoUrl;
  final List<String> photoUrls;
  final List<LocationModel> locations;
  final List<ServiceTemplateModel> services;
  final Set<String> capabilityTags;
  final double? trustScore;
  final String subscriptionTier;
  final double? distance;

  const WorkshopProfileModel({
    required this.id,
    required this.name,
    this.description,
    this.phoneNumber,
    this.email,
    this.logoUrl,
    required this.photoUrls,
    required this.locations,
    required this.services,
    required this.capabilityTags,
    this.trustScore,
    required this.subscriptionTier,
    this.distance,
  });

  factory WorkshopProfileModel.fromJson(Map<String, dynamic> json) {
    return WorkshopProfileModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Taller',
      description: json['description'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      logoUrl: json['logoUrl'] as String?,
      photoUrls: json['photoUrls'] != null
          ? List<String>.from(json['photoUrls'] as List)
          : [],
      locations: json['locations'] != null
          ? (json['locations'] as List)
              .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      services: json['services'] != null
          ? (json['services'] as List)
              .map((e) => ServiceTemplateModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      capabilityTags: json['capabilityTags'] != null
          ? Set<String>.from(json['capabilityTags'] as List)
          : <String>{},
      trustScore: json['trustScore'] != null 
          ? (json['trustScore'] as num).toDouble() 
          : null,
      subscriptionTier: json['subscriptionTier'] as String? ?? 'BASIC',
      distance: json['distance'] != null 
          ? (json['distance'] as num).toDouble() 
          : null,
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

  /// Tiene fotos
  bool get hasPhotos => photoUrls.isNotEmpty;

  /// Tiene ubicaciones
  bool get hasLocations => locations.isNotEmpty;

  /// Ubicación principal
  LocationModel? get primaryLocation => locations.isNotEmpty ? locations.first : null;

  /// Dirección principal formateada
  String get primaryAddress => primaryLocation?.formattedAddress ?? 'Sin ubicación';

  /// Servicios activos
  List<ServiceTemplateModel> get activeServices => 
      services.where((s) => s.active).toList();

  /// Tiene contacto
  bool get hasContact => 
      (phoneNumber != null && phoneNumber!.isNotEmpty) ||
      (email != null && email!.isNotEmpty);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        phoneNumber,
        email,
        logoUrl,
        photoUrls,
        locations,
        services,
        capabilityTags,
        trustScore,
        subscriptionTier,
        distance,
      ];
}



