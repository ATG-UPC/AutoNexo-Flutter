import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Modelo de servicio ofrecido por un taller
class ServiceTemplateModel extends Equatable {
  final int id;
  final String code;
  final String? catalogService;
  final String? serviceCategory;
  final String? customName;
  final String displayName;
  final String? description;
  final int? estimatedDurationMinutes;
  final double? basePriceAmount;
  final String currency;
  final bool active;
  final bool linkedToCatalog;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServiceTemplateModel({
    required this.id,
    required this.code,
    this.catalogService,
    this.serviceCategory,
    this.customName,
    required this.displayName,
    this.description,
    this.estimatedDurationMinutes,
    this.basePriceAmount,
    required this.currency,
    required this.active,
    required this.linkedToCatalog,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceTemplateModel.fromJson(Map<String, dynamic> json) {
    return ServiceTemplateModel(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      catalogService: json['catalogService'] as String?,
      serviceCategory: json['serviceCategory'] as String?,
      customName: json['customName'] as String?,
      displayName: json['displayName'] as String? ?? json['customName'] as String? ?? 'Servicio',
      description: json['description'] as String?,
      estimatedDurationMinutes: json['estimatedDurationMinutes'] as int?,
      basePriceAmount: json['basePriceAmount'] != null 
          ? (json['basePriceAmount'] as num).toDouble() 
          : null,
      currency: json['currency'] as String? ?? 'PEN',
      active: json['active'] as bool? ?? true,
      linkedToCatalog: json['linkedToCatalog'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  /// Precio formateado
  String get formattedPrice {
    if (basePriceAmount == null) return 'Consultar';
    final symbol = currency == 'PEN' ? 'S/' : '\$';
    return '$symbol ${NumberFormat.currency(symbol: '').format(basePriceAmount)}';
  }

  /// Duración formateada
  String get formattedDuration {
    if (estimatedDurationMinutes == null) return 'Variable';
    if (estimatedDurationMinutes! < 60) {
      return '$estimatedDurationMinutes min';
    }
    final hours = estimatedDurationMinutes! ~/ 60;
    final minutes = estimatedDurationMinutes! % 60;
    if (minutes == 0) {
      return '$hours h';
    }
    return '$hours h $minutes min';
  }

  /// Categoría formateada
  String get formattedCategory {
    if (serviceCategory == null) return 'General';
    return serviceCategory!
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1)}' 
            : '')
        .join(' ');
  }

  @override
  List<Object?> get props => [
        id,
        code,
        catalogService,
        serviceCategory,
        customName,
        displayName,
        description,
        estimatedDurationMinutes,
        basePriceAmount,
        currency,
        active,
        linkedToCatalog,
        createdAt,
        updatedAt,
      ];
}


