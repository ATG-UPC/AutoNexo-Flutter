import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/enums/status.dart';
import '../../../vehicles/data/models/models.dart';
import '../../../vehicles/presentation/cubit/cubit.dart';
import '../../data/models/models.dart';
import '../cubit/cubit.dart';

/// Página para crear nueva solicitud de servicio (Wizard de 3 pasos)
class CreateServiceRequestPage extends StatefulWidget {
  const CreateServiceRequestPage({super.key});

  @override
  State<CreateServiceRequestPage> createState() => _CreateServiceRequestPageState();
}

class _CreateServiceRequestPageState extends State<CreateServiceRequestPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Paso 1: Vehículo seleccionado
  VehicleModel? _selectedVehicle;

  // Paso 2: Servicios seleccionados
  final Set<String> _selectedServices = {};
  String? _selectedCategory; // null = todas las categorías
  String _searchQuery = '';
  bool _isCustomRequest = false; // Para solicitud personalizada sin servicios predefinidos

  // Paso 3: Ubicación
  double? _latitude;
  double? _longitude;
  int _searchRadius = 10;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoadingLocation = false;
  String? _locationError;

  @override
  void dispose() {
    _pageController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getStepTitle()),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Indicador de progreso
          _buildStepIndicator(),
          
          // Contenido del paso actual
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildVehicleStep(),
                _buildServicesStep(),
                _buildLocationStep(),
              ],
            ),
          ),
          
          // Botones de navegación
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Seleccionar Vehículo';
      case 1:
        return 'Seleccionar Servicios';
      case 2:
        return 'Ubicación y Detalles';
      default:
        return 'Nueva Solicitud';
    }
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < 2)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: index < _currentStep
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ==================== PASO 1: SELECCIONAR VEHÍCULO ====================

  Widget _buildVehicleStep() {
    return BlocBuilder<VehiclesCubit, VehiclesState>(
      builder: (context, state) {
        if (state.status == Status.loading && state.vehicles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.vehicles.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes vehículos registrados',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega un vehículo primero para crear una solicitud',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = state.vehicles[index];
            final isSelected = _selectedVehicle?.id == vehicle.id;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isSelected
                    ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                    : BorderSide.none,
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedVehicle = vehicle;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: vehicle.primaryImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  vehicle.primaryImageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.directions_car,
                                color: Colors.grey.shade400,
                                size: 32,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${vehicle.brandName ?? ''} ${vehicle.model}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${vehicle.year} · ${vehicle.licensePlate}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==================== PASO 2: SELECCIONAR SERVICIOS ====================

  Widget _buildServicesStep() {
    return BlocBuilder<ServiceRequestsCubit, ServiceRequestsState>(
      builder: (context, state) {
        if (state.serviceCatalog.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final catalogByCategory = state.catalogByCategory;
        final categories = catalogByCategory.keys.toList();

        // Filtrar servicios por categoría seleccionada y búsqueda
        List<ServiceCatalogItem> filteredServices = [];
        if (_selectedCategory == null) {
          filteredServices = state.serviceCatalog;
        } else {
          filteredServices = catalogByCategory[_selectedCategory] ?? [];
        }

        // Aplicar filtro de búsqueda
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          filteredServices = filteredServices.where((service) {
            return service.displayName.toLowerCase().contains(query) ||
                service.description.toLowerCase().contains(query) ||
                service.categoryDisplayName.toLowerCase().contains(query);
          }).toList();
        }

        return Column(
          children: [
            // Opción de solicitud personalizada
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 3),
              child: Card(
                color: _isCustomRequest 
                    ? Theme.of(context).primaryColor.withOpacity(0.1) 
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: _isCustomRequest
                      ? BorderSide(color: Theme.of(context).primaryColor, width: 1.5)
                      : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isCustomRequest = !_isCustomRequest;
                      if (_isCustomRequest) {
                        _selectedServices.clear();
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          _isCustomRequest 
                              ? Icons.check_circle 
                              : Icons.edit_note,
                          color: _isCustomRequest 
                              ? Theme.of(context).primaryColor 
                              : Colors.grey.shade600,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Solicitud Personalizada',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'No encuentro el servicio que necesito',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (!_isCustomRequest) ...[
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 3),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar servicio...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 3),

              // Chips de categorías para navegación rápida
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: const Text('Todas'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = null;
                          });
                        },
                        backgroundColor: Colors.grey.shade200,
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _selectedCategory == null
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade700,
                          fontWeight: _selectedCategory == null 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    ...categories.map((category) {
                      final categoryDisplayName = catalogByCategory[category]!.first.categoryDisplayName;
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(categoryDisplayName.isNotEmpty 
                              ? categoryDisplayName 
                              : category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                          },
                          backgroundColor: Colors.grey.shade200,
                          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 3),

              // Contador de servicios seleccionados
              if (_selectedServices.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 3),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${_selectedServices.length} servicio(s) seleccionado(s)',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedServices.clear();
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Limpiar',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // Lista de servicios filtrados
              Expanded(
                child: filteredServices.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off, size: 40, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'No se encontraron servicios',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              if (_searchQuery.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Intenta con otros términos o usa "Solicitud Personalizada"',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredServices.length,
                        itemBuilder: (context, index) {
                          final service = filteredServices[index];
                          final isSelected = _selectedServices.contains(service.code);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: isSelected
                                  ? BorderSide(color: Theme.of(context).primaryColor, width: 1.5)
                                  : BorderSide.none,
                            ),
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedServices.add(service.code);
                                  } else {
                                    _selectedServices.remove(service.code);
                                  }
                                });
                              },
                              title: Text(
                                service.displayName,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.description,
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                  ),
                                  if (_selectedCategory == null) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        service.categoryDisplayName,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              activeColor: Theme.of(context).primaryColor,
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          );
                        },
                      ),
              ),
            ] else ...[
              // Mensaje para solicitud personalizada
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.thumb_up_outlined,
                        size: 50,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '¡Perfecto!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Podrás describir detalladamente tu problema en el siguiente paso. Los talleres revisarán tu solicitud y te contactarán con presupuestos personalizados.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber.shade700, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Asegúrate de proporcionar una descripción detallada en el siguiente paso para obtener mejores cotizaciones.',
                                style: TextStyle(
                                  color: Colors.amber.shade900,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // ==================== PASO 3: UBICACIÓN Y DETALLES ====================

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Obtener ubicación
          const Text(
            'Ubicación',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Usaremos tu ubicación para buscar talleres cercanos',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          if (_locationError != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _locationError!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),

          ElevatedButton.icon(
            onPressed: _isLoadingLocation ? null : _getCurrentLocation,
            icon: _isLoadingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(_latitude != null ? 'Ubicación obtenida ✓' : 'Obtener mi ubicación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _latitude != null ? Colors.green : null,
              minimumSize: const Size.fromHeight(48),
            ),
          ),

          if (_latitude != null && _longitude != null) ...[
            const SizedBox(height: 8),
            Text(
              'Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],

          const SizedBox(height: 24),

          // Radio de búsqueda
          const Text(
            'Radio de búsqueda',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _searchRadius.toDouble(),
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: '$_searchRadius km',
                  onChanged: (value) {
                    setState(() {
                      _searchRadius = value.round();
                    });
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_searchRadius km',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Descripción
          Row(
            children: [
              Text(
                _isCustomRequest ? 'Descripción (obligatoria)' : 'Descripción (opcional)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_isCustomRequest) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Requerido',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (_isCustomRequest)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Describe detalladamente el problema que presenta tu vehículo para que los talleres puedan darte una cotización precisa.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
          TextField(
            controller: _descriptionController,
            maxLines: _isCustomRequest ? 6 : 4,
            maxLength: 1000,
            decoration: InputDecoration(
              hintText: _isCustomRequest
                  ? 'Ej: Mi vehículo hace un ruido extraño al frenar, especialmente cuando freno en bajada. También noto que el pedal vibra ligeramente...'
                  : 'Describe el problema o proporciona detalles adicionales...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (_) => setState(() {}), // Para actualizar el botón
          ),

          const SizedBox(height: 24),

          // Resumen
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen de la solicitud',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                if (_selectedVehicle != null)
                  _buildSummaryRow(
                    'Vehículo',
                    '${_selectedVehicle!.brandName ?? ''} ${_selectedVehicle!.model}',
                  ),
                _buildSummaryRow(
                  'Tipo',
                  _isCustomRequest ? 'Solicitud Personalizada' : 'Servicios predefinidos',
                ),
                if (!_isCustomRequest)
                  _buildSummaryRow(
                    'Servicios',
                    '${_selectedServices.length} seleccionado(s)',
                  ),
                _buildSummaryRow('Radio', '$_searchRadius km'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Los permisos de ubicación están permanentemente denegados. '
          'Por favor, habilítalos en la configuración del dispositivo.',
        );
      }

      // Verificar si el servicio está habilitado
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('El servicio de ubicación está deshabilitado');
      }

      // Obtener posición
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      setState(() {
        _locationError = e.toString().replaceFirst('Exception:', '').trim();
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  // ==================== NAVEGACIÓN ====================

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Anterior'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep > 0 ? 2 : 1,
            child: BlocBuilder<ServiceRequestsCubit, ServiceRequestsState>(
              builder: (context, state) {
                final isCreating = state.isCreating;
                return ElevatedButton(
                  onPressed: isCreating || !_canProceed() ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: isCreating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_currentStep == 2 ? 'Crear Solicitud' : 'Siguiente'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedVehicle != null;
      case 1:
        // Puede continuar si tiene servicios seleccionados O si es solicitud personalizada
        return _selectedServices.isNotEmpty || _isCustomRequest;
      case 2:
        // Para solicitud personalizada, la descripción es obligatoria
        final hasLocation = _latitude != null && _longitude != null;
        if (_isCustomRequest) {
          return hasLocation && _descriptionController.text.trim().isNotEmpty;
        }
        return hasLocation;
      default:
        return false;
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitRequest();
    }
  }

  Future<void> _submitRequest() async {
    if (_selectedVehicle == null || _latitude == null || _longitude == null) {
      return;
    }

    final request = CreateServiceRequest(
      vehicleId: _selectedVehicle!.id,
      requestedServices: _selectedServices.toList(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      latitude: _latitude!,
      longitude: _longitude!,
      searchRadiusKm: _searchRadius,
    );

    final cubit = context.read<ServiceRequestsCubit>();
    final success = await cubit.createServiceRequest(request);

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}

