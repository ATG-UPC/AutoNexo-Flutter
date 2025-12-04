import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../../../core/ui/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../cubit/cubit.dart';

/// Página para agregar un nuevo vehículo
class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _vinController = TextEditingController();
  final _colorController = TextEditingController();
  final _mileageController = TextEditingController(text: '0');

  BrandModel? _selectedBrand;
  int? _selectedYear;
  bool _isLoading = false;

  // Lista de años disponibles (últimos 30 años)
  final List<int> _availableYears = List.generate(
    30,
    (index) => DateTime.now().year - index,
  );

  @override
  void initState() {
    super.initState();
    // Cargar marcas
    context.read<VehiclesCubit>().loadBrands();
  }

  @override
  void dispose() {
    _modelController.dispose();
    _licensePlateController.dispose();
    _vinController.dispose();
    _colorController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBrand == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una marca')),
      );
      return;
    }

    if (_selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona el año')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final request = CreateVehicleRequest(
      brandId: _selectedBrand!.id,
      model: _modelController.text.trim(),
      year: _selectedYear!,
      licensePlate: _licensePlateController.text.trim().toUpperCase(),
      vin: _vinController.text.trim().isNotEmpty
          ? _vinController.text.trim().toUpperCase()
          : null,
      color: _colorController.text.trim().isNotEmpty
          ? _colorController.text.trim()
          : null,
      initialMileage: int.tryParse(_mileageController.text) ?? 0,
    );

    final success = await context.read<VehiclesCubit>().createVehicle(request);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehículo registrado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      final errorMessage =
          context.read<VehiclesCubit>().state.errorMessage ?? 'Error desconocido';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Marca
                      _buildLabel('Marca *'),
                      _buildBrandDropdown(),
                      const SizedBox(height: 16),

                      // Modelo
                      CustomTextField(
                        label: 'Modelo *',
                        controller: _modelController,
                        hint: 'Ej: Corolla, Civic, Hilux',
                        prefixIcon: const Icon(Icons.directions_car_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El modelo es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Año
                      _buildLabel('Año *'),
                      _buildYearDropdown(),
                      const SizedBox(height: 16),

                      // Placa
                      CustomTextField(
                        label: 'Placa *',
                        controller: _licensePlateController,
                        hint: 'Ej: ABC-123',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La placa es requerida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Color (opcional)
                      CustomTextField(
                        label: 'Color',
                        controller: _colorController,
                        hint: 'Ej: Blanco, Negro, Rojo',
                        prefixIcon: const Icon(Icons.color_lens_outlined),
                      ),
                      const SizedBox(height: 16),

                      // Kilometraje inicial
                      CustomTextField(
                        label: 'Kilometraje inicial',
                        controller: _mileageController,
                        hint: '0',
                        prefixIcon: const Icon(Icons.speed_outlined),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      const SizedBox(height: 16),

                      // VIN (opcional)
                      CustomTextField(
                        label: 'VIN (opcional)',
                        controller: _vinController,
                        hint: '17 caracteres',
                        prefixIcon: const Icon(Icons.qr_code_outlined),
                        maxLength: 17,
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length != 17) {
                            return 'El VIN debe tener 17 caracteres';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // Botón de guardar
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          text: 'Registrar Vehículo',
                          onPressed: _isLoading ? null : _submitForm,
                          isLoading: _isLoading,
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF5B7C99),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Nuevo Vehículo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2B2D42),
        ),
      ),
    );
  }

  Widget _buildBrandDropdown() {
    return BlocBuilder<VehiclesCubit, VehiclesState>(
      builder: (context, state) {
        if (state.brandsStatus == Status.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonFormField<BrandModel>(
            value: _selectedBrand,
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.business_outlined,
                color: Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            hint: const Text('Selecciona una marca'),
            items: state.brands.map((brand) {
              return DropdownMenuItem<BrandModel>(
                value: brand,
                child: Text(brand.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBrand = value;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildYearDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonFormField<int>(
        value: _selectedYear,
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFF9CA3AF),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        hint: const Text('Selecciona el año'),
        items: _availableYears.map((year) {
          return DropdownMenuItem<int>(
            value: year,
            child: Text(year.toString()),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedYear = value;
          });
        },
      ),
    );
  }
}

