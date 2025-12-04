import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/models.dart';
import '../cubit/cubit.dart';

/// Página para crear un mantenimiento manual
class CreateManualMaintenancePage extends StatefulWidget {
  final int vehicleId;

  const CreateManualMaintenancePage({
    super.key,
    required this.vehicleId,
  });

  @override
  State<CreateManualMaintenancePage> createState() => _CreateManualMaintenancePageState();
}

class _CreateManualMaintenancePageState extends State<CreateManualMaintenancePage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _mileageController = TextEditingController();
  final _observationsController = TextEditingController();
  
  DateTime? _selectedDate;
  final List<_ServiceEntry> _services = [];

  @override
  void dispose() {
    _dateController.dispose();
    _mileageController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Mantenimiento'),
        elevation: 0,
      ),
      body: BlocConsumer<MaintenancesCubit, MaintenancesState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            context.read<MaintenancesCubit>().clearMessages();
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
            context.read<MaintenancesCubit>().clearMessages();
            Navigator.pop(context, true);
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información básica
                  _buildBasicInfoSection(context),
                  const SizedBox(height: 24),

                  // Servicios
                  _buildServicesSection(context),
                  const SizedBox(height: 24),

                  // Observaciones
                  _buildObservationsSection(context),
                  const SizedBox(height: 32),

                  // Botón guardar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state.isCreating ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state.isCreating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Guardar Mantenimiento',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información del Mantenimiento',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Fecha
        TextFormField(
          controller: _dateController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Fecha del mantenimiento *',
            hintText: 'Selecciona la fecha',
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onTap: () => _selectDate(context),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Selecciona una fecha';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Kilometraje
        TextFormField(
          controller: _mileageController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Kilometraje *',
            hintText: 'Ej: 50000',
            prefixIcon: const Icon(Icons.speed),
            suffixText: 'km',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingresa el kilometraje';
            }
            final mileage = int.tryParse(value);
            if (mileage == null || mileage < 0) {
              return 'Ingresa un kilometraje válido';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Servicios Realizados',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: _addService,
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_services.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.handyman_outlined,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega los servicios realizados',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          )
        else
          ...List.generate(_services.length, (index) {
            return _buildServiceCard(index);
          }),
      ],
    );
  }

  Widget _buildServiceCard(int index) {
    final service = _services[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Servicio ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeService(index),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tipo de servicio
            TextFormField(
              initialValue: service.type,
              decoration: InputDecoration(
                labelText: 'Tipo de servicio *',
                hintText: 'Ej: Cambio de aceite',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _services[index] = service.copyWith(type: value);
                });
              },
            ),
            const SizedBox(height: 12),

            // Descripción y costo
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: service.description,
                    decoration: InputDecoration(
                      labelText: 'Descripción (opcional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _services[index] = service.copyWith(description: value);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: service.cost > 0 ? service.cost.toString() : '',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Costo *',
                      prefixText: 'S/ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _services[index] = service.copyWith(
                          cost: double.tryParse(value) ?? 0,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observaciones (opcional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _observationsController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Agrega notas adicionales sobre el mantenimiento...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _addService() {
    setState(() {
      _services.add(_ServiceEntry());
    });
  }

  void _removeService(int index) {
    setState(() {
      _services.removeAt(index);
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una fecha'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validar que haya al menos un servicio con datos completos
    final validServices = _services.where((s) => s.type.isNotEmpty && s.cost > 0).toList();

    final request = CreateManualMaintenanceRequest(
      vehicleId: widget.vehicleId,
      maintenanceDate: _selectedDate!,
      mileage: int.parse(_mileageController.text),
      observations: _observationsController.text.isEmpty 
          ? null 
          : _observationsController.text,
      services: validServices.map((s) => MaintenanceServiceModel(
        serviceType: s.type.toUpperCase().replaceAll(' ', '_'),
        description: s.description.isEmpty ? null : s.description,
        cost: s.cost,
      )).toList(),
    );

    context.read<MaintenancesCubit>().createManualMaintenance(request);
  }
}

/// Clase auxiliar para manejar entradas de servicios
class _ServiceEntry {
  final String type;
  final String description;
  final double cost;

  _ServiceEntry({
    this.type = '',
    this.description = '',
    this.cost = 0,
  });

  _ServiceEntry copyWith({
    String? type,
    String? description,
    double? cost,
  }) {
    return _ServiceEntry(
      type: type ?? this.type,
      description: description ?? this.description,
      cost: cost ?? this.cost,
    );
  }
}




