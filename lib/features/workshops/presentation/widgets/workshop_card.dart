import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/models.dart';
import '../cubit/cubit.dart';

/// Card para mostrar un taller en la lista de resultados
class WorkshopCard extends StatelessWidget {
  final WorkshopSearchResultModel workshop;
  final VoidCallback onTap;

  const WorkshopCard({
    super.key,
    required this.workshop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Logo
              _buildLogo(theme),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre, Premium badge y Favorito
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            workshop.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Favorito
                        BlocBuilder<WorkshopsCubit, WorkshopsState>(
                          builder: (context, state) {
                            final isFavorite = state.isFavorite(workshop.id);
                            return IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: isFavorite ? Colors.red : Colors.grey.shade400,
                              ),
                              onPressed: () {
                                context.read<WorkshopsCubit>().toggleFavorite(workshop.id);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos',
                            );
                          },
                        ),
                        if (workshop.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.amber.shade800,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'PREMIUM',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Rating y distancia
                    Row(
                      children: [
                        if (workshop.trustScore != null) ...[
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            workshop.formattedRating,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (workshop.distance != null) ...[
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            workshop.formattedDistance,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Ubicación
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            workshop.primaryLocation,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Tags
                    if (workshop.capabilityTags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: workshop.formattedTags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.primaryColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: workshop.hasLogo
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                workshop.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.build,
                  color: theme.primaryColor,
                  size: 28,
                ),
              ),
            )
          : Icon(
              Icons.build,
              color: theme.primaryColor,
              size: 28,
            ),
    );
  }
}




