import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Widget reutilizable para mostrar mapas en diferentes pantallas
/// 
/// Ejemplo de uso:
/// ```dart
/// MapWidget(
///   latitude: -12.0464,
///   longitude: -77.0428,
///   height: 200,
/// )
/// ```
class MapWidget extends StatefulWidget {
  /// Latitud del punto a mostrar
  final double latitude;
  
  /// Longitud del punto a mostrar
  final double longitude;
  
  /// Altura del mapa (default: 200)
  final double height;
  
  /// Marcadores adicionales a mostrar en el mapa
  final Set<Marker>? markers;
  
  /// Callback cuando se toca el mapa
  final VoidCallback? onTap;
  
  /// Si el mapa es interactivo (default: true)
  final bool interactive;
  
  /// Zoom inicial (default: 15.0)
  final double zoom;
  
  /// Título del marcador principal
  final String? markerTitle;
  
  /// Subtítulo del marcador principal
  final String? markerSnippet;

  const MapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 200,
    this.markers,
    this.onTap,
    this.interactive = true,
    this.zoom = 15.0,
    this.markerTitle,
    this.markerSnippet,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  late CameraPosition _initialCameraPosition;
  late Set<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _initialCameraPosition = CameraPosition(
      target: LatLng(widget.latitude, widget.longitude),
      zoom: widget.zoom,
    );
    _updateMarkers();
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude ||
        oldWidget.markers != widget.markers ||
        oldWidget.markerTitle != widget.markerTitle ||
        oldWidget.markerSnippet != widget.markerSnippet) {
      _updateMarkers();
      _updateCameraPosition();
    }
  }

  void _updateMarkers() {
    _markers = <Marker>{};
    
    // Agregar marcador principal
    _markers.add(
      Marker(
        markerId: const MarkerId('main_location'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(
          title: widget.markerTitle ?? 'Ubicación',
          snippet: widget.markerSnippet,
        ),
      ),
    );
    
    // Agregar marcadores adicionales
    if (widget.markers != null) {
      _markers.addAll(widget.markers!);
    }
  }

  void _updateCameraPosition() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(widget.latitude, widget.longitude),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            markers: _markers,
            zoomControlsEnabled: widget.interactive,
            zoomGesturesEnabled: widget.interactive,
            scrollGesturesEnabled: widget.interactive,
            tiltGesturesEnabled: false,
            rotateGesturesEnabled: widget.interactive,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onTap: widget.onTap != null ? (_) => widget.onTap!() : null,
          ),
          if (!widget.interactive)
            Positioned.fill(
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


