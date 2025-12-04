import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/ui/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../cubit/cubit.dart';
import '../widgets/widgets.dart';

/// Página de detalle de un taller
class WorkshopDetailPage extends StatelessWidget {
  final int workshopId;

  const WorkshopDetailPage({
    super.key,
    required this.workshopId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<WorkshopsCubit, WorkshopsState>(
        builder: (context, state) {
          if (state.isLoadingProfile && state.selectedWorkshop == null) {
            return const Scaffold(
              body: LoadingPage(message: 'Cargando información del taller...'),
            );
          }

          final workshop = state.selectedWorkshop;
          if (workshop == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Taller')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text('No se pudo cargar la información'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Volver'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildContent(context, workshop);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WorkshopProfileModel workshop) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        // App bar con imagen
        _buildSliverAppBar(context, workshop),
        
        // Contenido
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con info básica
                _buildHeader(context, workshop),
                const SizedBox(height: 20),

                // Rating y tags
                _buildRatingSection(context, workshop),
                const SizedBox(height: 20),

                // Descripción
                if (workshop.description != null && workshop.description!.isNotEmpty) ...[
                  _buildSection(
                    context,
                    title: 'Acerca del Taller',
                    child: Text(
                      workshop.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Galería de fotos
                if (workshop.hasPhotos) ...[
                  _buildSection(
                    context,
                    title: 'Fotos',
                    child: _buildPhotoGallery(context, workshop),
                  ),
                  const SizedBox(height: 20),
                ],

                // Ubicaciones
                if (workshop.hasLocations) ...[
                  _buildSection(
                    context,
                    title: 'Ubicaciones',
                    child: _buildLocationsSection(context, workshop),
                  ),
                  const SizedBox(height: 20),
                ],

                // Servicios
                _buildSection(
                  context,
                  title: 'Servicios (${workshop.activeServices.length})',
                  child: _buildServicesSection(context, workshop),
                ),
                const SizedBox(height: 20),

                // Contacto
                if (workshop.hasContact) ...[
                  _buildSection(
                    context,
                    title: 'Contacto',
                    child: _buildContactSection(context, workshop),
                  ),
                  const SizedBox(height: 20),
                ],

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WorkshopProfileModel workshop) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: workshop.hasPhotos
            ? Image.network(
                workshop.photoUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.build,
                    size: 60,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Center(
                  child: workshop.hasLogo
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(workshop.logoUrl!),
                          backgroundColor: Colors.white,
                        )
                      : const Icon(
                          Icons.build,
                          size: 60,
                          color: Colors.white,
                        ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WorkshopProfileModel workshop) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: workshop.hasLogo
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    workshop.logoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.build,
                      color: theme.primaryColor,
                      size: 32,
                    ),
                  ),
                )
              : Icon(
                  Icons.build,
                  color: theme.primaryColor,
                  size: 32,
                ),
        ),
        const SizedBox(width: 16),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      workshop.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (workshop.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber.shade800,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'PREMIUM',
                            style: TextStyle(
                              fontSize: 10,
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
              if (workshop.hasLocations)
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        workshop.primaryAddress,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context, WorkshopProfileModel workshop) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 32,
                  color: Colors.amber.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  workshop.formattedRating,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ' / 5',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Tags
            if (workshop.capabilityTags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: workshop.formattedTags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.primaryColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildPhotoGallery(BuildContext context, WorkshopProfileModel workshop) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: workshop.photoUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < workshop.photoUrls.length - 1 ? 8 : 0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                workshop.photoUrls[index],
                width: 160,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 160,
                  height: 120,
                  color: Colors.grey.shade200,
                  child: Icon(Icons.image, color: Colors.grey.shade400),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationsSection(BuildContext context, WorkshopProfileModel workshop) {
    return Column(
      children: workshop.locations.map((location) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.location_on,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(location.shortAddress),
            subtitle: Text(location.formattedAddress),
            trailing: IconButton(
              icon: const Icon(Icons.directions),
              onPressed: () => _openMaps(location.latitude, location.longitude),
              tooltip: 'Abrir en Maps',
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServicesSection(BuildContext context, WorkshopProfileModel workshop) {
    if (workshop.activeServices.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay servicios disponibles'),
        ),
      );
    }

    return Column(
      children: workshop.activeServices.map((service) {
        return ServicePriceCard(service: service);
      }).toList(),
    );
  }

  Widget _buildContactSection(BuildContext context, WorkshopProfileModel workshop) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          if (workshop.phoneNumber != null && workshop.phoneNumber!.isNotEmpty)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                child: const Icon(Icons.phone, color: Colors.green),
              ),
              title: Text(workshop.phoneNumber!),
              trailing: IconButton(
                icon: const Icon(Icons.call),
                onPressed: () => _makePhoneCall(workshop.phoneNumber!),
              ),
            ),
          if (workshop.email != null && workshop.email!.isNotEmpty)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                child: const Icon(Icons.email, color: Colors.blue),
              ),
              title: Text(workshop.email!),
              trailing: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _sendEmail(workshop.email!),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}



