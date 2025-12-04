import 'package:equatable/equatable.dart';

/// Modelo de ubicación del taller
class WorkshopLocation extends Equatable {
  final String? address;
  final double latitude;
  final double longitude;

  const WorkshopLocation({
    this.address,
    required this.latitude,
    required this.longitude,
  });

  factory WorkshopLocation.fromJson(Map<String, dynamic> json) {
    return WorkshopLocation(
      address: json['address'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  List<Object?> get props => [address, latitude, longitude];
}

/// Modelo de trust score del taller
class TrustScore extends Equatable {
  final int workshopId;
  final double score;
  final int totalReviews;
  final double averageRating;
  final double recencyScore;
  final double responseRate;

  const TrustScore({
    required this.workshopId,
    required this.score,
    required this.totalReviews,
    required this.averageRating,
    required this.recencyScore,
    required this.responseRate,
  });

  factory TrustScore.fromJson(Map<String, dynamic> json) {
    final breakdown = json['breakdown'] as Map<String, dynamic>? ?? {};
    return TrustScore(
      workshopId: json['workshopId'] as int,
      score: (json['score'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int? ?? 0,
      averageRating: (breakdown['averageRating'] as num?)?.toDouble() ?? 0.0,
      recencyScore: (breakdown['recencyScore'] as num?)?.toDouble() ?? 0.0,
      responseRate: (breakdown['responseRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workshopId': workshopId,
      'score': score,
      'totalReviews': totalReviews,
      'breakdown': {
        'averageRating': averageRating,
        'recencyScore': recencyScore,
        'responseRate': responseRate,
      },
    };
  }

  /// Score formateado (ej: "4.5")
  String get formattedScore => score.toStringAsFixed(1);

  /// Porcentaje de respuesta formateado
  String get formattedResponseRate => '${(responseRate * 100).toInt()}%';

  @override
  List<Object?> get props => [
        workshopId,
        score,
        totalReviews,
        averageRating,
        recencyScore,
        responseRate,
      ];
}

/// Modelo de información pública de un taller
class WorkshopPublicModel extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? logoUrl;
  final double? trustScore;
  final double? distance;
  final List<String> services;
  final List<String> tags;
  final WorkshopLocation? location;
  final String? phoneNumber;
  final String? email;
  final String? website;

  const WorkshopPublicModel({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.trustScore,
    this.distance,
    this.services = const [],
    this.tags = const [],
    this.location,
    this.phoneNumber,
    this.email,
    this.website,
  });

  /// Crea una instancia desde JSON
  factory WorkshopPublicModel.fromJson(Map<String, dynamic> json) {
    return WorkshopPublicModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      trustScore: (json['trustScore'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      location: json['location'] != null
          ? WorkshopLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
    );
  }

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'trustScore': trustScore,
      'distance': distance,
      'services': services,
      'tags': tags,
      'location': location?.toJson(),
      'phoneNumber': phoneNumber,
      'email': email,
      'website': website,
    };
  }

  // === Getters de formato ===

  /// Trust score formateado
  String get formattedTrustScore {
    if (trustScore == null) return 'N/A';
    return trustScore!.toStringAsFixed(1);
  }

  /// Distancia formateada
  String get formattedDistance {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toInt()} m';
    }
    return '${distance!.toStringAsFixed(1)} km';
  }

  /// Dirección del taller
  String get address => location?.address ?? 'Dirección no disponible';

  /// ¿Tiene logo?
  bool get hasLogo => logoUrl != null && logoUrl!.isNotEmpty;

  /// Lista de servicios formateados (nombres legibles)
  List<String> get formattedServices {
    return services.map((s) => _formatServiceName(s)).toList();
  }

  String _formatServiceName(String code) {
    // Convierte OIL_CHANGE a "Cambio de aceite"
    final words = code.split('_');
    return words.map((w) => w.toLowerCase()).join(' ').capitalize();
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        logoUrl,
        trustScore,
        distance,
        services,
        tags,
        location,
        phoneNumber,
        email,
        website,
      ];
}

/// Extensión para capitalizar strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

