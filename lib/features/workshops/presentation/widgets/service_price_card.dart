import 'package:flutter/material.dart';

import '../../data/models/models.dart';

/// Card para mostrar un servicio con precio
class ServicePriceCard extends StatelessWidget {
  final ServiceTemplateModel service;
  final VoidCallback? onTap;

  const ServicePriceCard({
    super.key,
    required this.service,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      color: Colors.grey.shade50,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Ícono de categoría
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getServiceIcon(service.serviceCategory),
                  color: theme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Info del servicio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          service.formattedDuration,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            service.formattedCategory,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Precio
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    service.formattedPrice,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  if (service.basePriceAmount != null)
                    Text(
                      'desde',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(String? category) {
    if (category == null) return Icons.build;
    
    switch (category.toUpperCase()) {
      case 'MAINTENANCE':
        return Icons.settings;
      case 'REPAIR':
        return Icons.build;
      case 'INSPECTION':
        return Icons.search;
      case 'ELECTRICAL':
        return Icons.electric_bolt;
      case 'BODY_WORK':
        return Icons.car_repair;
      case 'TIRES':
        return Icons.tire_repair;
      case 'AC':
        return Icons.ac_unit;
      case 'ENGINE':
        return Icons.engineering;
      case 'TRANSMISSION':
        return Icons.miscellaneous_services;
      case 'SUSPENSION':
        return Icons.compare_arrows;
      default:
        return Icons.handyman;
    }
  }
}




