import 'package:equatable/equatable.dart';

/// Modelo de ubicación de un taller
class LocationModel extends Equatable {
  final int id;
  final String street;
  final String city;
  final String state;
  final String zip;
  final String country;
  final double latitude;
  final double longitude;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LocationModel({
    required this.id,
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as int,
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zip: json['zip'] as String? ?? '',
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      active: json['active'] as bool? ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  /// Dirección formateada para mostrar
  String get formattedAddress {
    final parts = [street, city, state, zip, country]
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  /// Dirección corta (calle y ciudad)
  String get shortAddress {
    if (street.isEmpty && city.isEmpty) return 'Sin dirección';
    if (street.isEmpty) return city;
    if (city.isEmpty) return street;
    return '$street, $city';
  }

  @override
  List<Object?> get props => [
        id,
        street,
        city,
        state,
        zip,
        country,
        latitude,
        longitude,
        active,
        createdAt,
        updatedAt,
      ];
}






