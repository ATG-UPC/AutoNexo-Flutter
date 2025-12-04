import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/ui/theme/app_theme.dart';
import '../../../../core/ui/widgets/widgets.dart';
import '../../../maintenances/maintenances.dart';
import '../../data/models/models.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../cubit/cubit.dart';

/// Página de detalle de vehículo con opciones de editar, eliminar, 
/// subir imágenes y gestionar usuarios autorizados
class VehicleDetailPage extends StatefulWidget {
  const VehicleDetailPage({super.key});

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  bool _isEditing = false;
  bool _isLoading = false;
  final ImagePicker _imagePicker = ImagePicker();

  final _colorController = TextEditingController();
  final _mileageController = TextEditingController();

  // Lista de usuarios autorizados
  List<AuthorizedUserModel> _authorizedUsers = [];
  bool _isLoadingUsers = false;

  @override
  void initState() {
    super.initState();
    final vehicle = context.read<VehiclesCubit>().state.selectedVehicle;
    if (vehicle != null) {
      _colorController.text = vehicle.color ?? '';
      _mileageController.text = vehicle.currentMileage.toString();
      _loadAuthorizedUsers(vehicle.id);
    }
  }

  Future<void> _loadAuthorizedUsers(int vehicleId) async {
    setState(() => _isLoadingUsers = true);
    try {
      final repository = VehicleRepository();
      final users = await repository.getAuthorizedUsers(vehicleId);
      if (mounted) {
        setState(() {
          _authorizedUsers = users;
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUsers = false);
      }
    }
  }

  @override
  void dispose() {
    _colorController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    final vehicle = context.read<VehiclesCubit>().state.selectedVehicle;
    if (vehicle == null) return;

    setState(() => _isLoading = true);

    final request = UpdateVehicleRequest(
      color: _colorController.text.trim().isNotEmpty
          ? _colorController.text.trim()
          : null,
      currentMileage: int.tryParse(_mileageController.text),
    );

    final success =
        await context.read<VehiclesCubit>().updateVehicle(vehicle.id, request);

    setState(() {
      _isLoading = false;
      if (success) _isEditing = false;
    });

    if (success && mounted) {
      _showSnackBar('Vehículo actualizado', isError: false);
    } else if (mounted) {
      final errorMessage =
          context.read<VehiclesCubit>().state.errorMessage ?? 'Error al actualizar';
      _showSnackBar(errorMessage, isError: true);
    }
  }

  Future<void> _deleteVehicle() async {
    final vehicle = context.read<VehiclesCubit>().state.selectedVehicle;
    if (vehicle == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Eliminar Vehículo',
        message:
            '¿Estás seguro de que deseas eliminar ${vehicle.brandName} ${vehicle.model}? Esta acción no se puede deshacer.',
        confirmText: 'Eliminar',
        cancelText: 'Cancelar',
        isDestructive: true,
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    final success = await context.read<VehiclesCubit>().deleteVehicle(vehicle.id);

    setState(() => _isLoading = false);

    if (success && mounted) {
      _showSnackBar('Vehículo eliminado', isError: false);
      Navigator.pop(context);
    } else if (mounted) {
      final errorMessage =
          context.read<VehiclesCubit>().state.errorMessage ?? 'Error al eliminar';
      _showSnackBar(errorMessage, isError: true);
    }
  }

  // ==================== IMÁGENES ====================

  Future<void> _showImageSourceDialog() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Agregar Imagen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.secondarySteelBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppTheme.secondarySteelBlue),
                ),
                title: const Text('Tomar foto'),
                subtitle: const Text('Usar la cámara del dispositivo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.secondarySteelBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library, color: AppTheme.secondarySteelBlue),
                ),
                title: const Text('Seleccionar de galería'),
                subtitle: const Text('Elegir una imagen existente'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      await _pickAndUploadImage(source);
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    // Capturar referencias ANTES de operaciones async
    final vehiclesCubit = context.read<VehiclesCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final File imageFile = File(pickedFile.path);
      final success = await vehiclesCubit.uploadVehicleImage(imageFile);

      if (success) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Imagen subida exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMessage = vehiclesCubit.state.errorMessage ?? 'Error al subir imagen';
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Error al seleccionar imagen'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==================== USUARIOS AUTORIZADOS ====================

  Future<void> _showAddUserDialog() async {
    // Capturar referencia al Cubit ANTES de cualquier operación async
    // para evitar errores de contexto inválido
    final vehiclesCubit = context.read<VehiclesCubit>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final emailController = TextEditingController();
    
    try {
      final email = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Agregar Usuario Autorizado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ingresa el email del usuario que deseas autorizar para ver este vehículo.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'usuario@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (emailController.text.trim().isNotEmpty) {
                  Navigator.pop(dialogContext, emailController.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondarySteelBlue,
              ),
              child: const Text('Agregar'),
            ),
          ],
        ),
      );

      if (email != null && email.isNotEmpty) {
        // addAuthorizedUser retorna un record (success, error) sin emitir estado
        // Esto evita reconstrucciones del BlocBuilder que causan errores
        final result = await vehiclesCubit.addAuthorizedUser(email);
        
        // Usar scaffoldMessenger capturado para mostrar snackbar
        if (result.success) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Usuario autorizado agregado'),
              backgroundColor: Colors.green,
            ),
          );
          // Recargar lista de usuarios autorizados
          final vehicle = vehiclesCubit.state.selectedVehicle;
          if (vehicle != null) {
            _loadAuthorizedUsers(vehicle.id);
          }
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Error al agregar usuario'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      emailController.dispose();
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: BlocBuilder<VehiclesCubit, VehiclesState>(
          builder: (context, state) {
            final vehicle = state.selectedVehicle;

            if (vehicle == null) {
              return const Center(child: Text('No hay vehículo seleccionado'));
            }

            return Column(
              children: [
                // Header
                _buildHeader(vehicle),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Galería de imágenes
                        _buildImageGallery(vehicle, state.isUploadingImage),

                        const SizedBox(height: 24),

                        // Información principal
                        _buildInfoCard(vehicle),

                        const SizedBox(height: 16),

                        // Campos editables o info estática
                        if (_isEditing) ...[
                          _buildEditableFields(),
                          const SizedBox(height: 24),
                          _buildSaveButton(),
                        ] else ...[
                          _buildStaticInfo(vehicle),
                        ],

                        const SizedBox(height: 24),

                        // Sección de usuarios autorizados
                        if (!_isEditing) _buildAuthorizedUsersSection(vehicle),

                        const SizedBox(height: 24),

                        // Sección de historial de mantenimientos
                        if (!_isEditing) _buildMaintenancesSection(vehicle),

                        const SizedBox(height: 24),

                        // Botón eliminar
                        if (!_isEditing) _buildDeleteButton(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(VehicleModel vehicle) {
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
          Expanded(
            child: Text(
              '${vehicle.brandName} ${vehicle.model}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit_outlined,
              color: Colors.white,
            ),
            onPressed: _toggleEdit,
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(VehicleModel vehicle, bool isUploading) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de galería
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.photo_library, color: AppTheme.secondarySteelBlue, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Fotos del Vehículo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (isUploading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.add_a_photo, color: AppTheme.secondarySteelBlue),
                    onPressed: _showImageSourceDialog,
                    tooltip: 'Agregar foto',
                  ),
              ],
            ),
          ),
          
          // Galería horizontal
          SizedBox(
            height: 180,
            child: vehicle.imageUrls.isEmpty
                ? _buildEmptyGallery()
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vehicle.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _buildImageThumbnail(vehicle.imageUrls[index]),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyGallery() {
    return Center(
      child: GestureDetector(
        onTap: _showImageSourceDialog,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.gray1.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.gray1,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 48,
                color: AppTheme.gray2.withOpacity(0.7),
              ),
              const SizedBox(height: 8),
              Text(
                'Toca para agregar fotos',
                style: TextStyle(
                  color: AppTheme.gray2.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(String imageUrl) {
    return GestureDetector(
      onTap: () => _showFullImage(imageUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: 240,
          height: 160,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 240,
              height: 160,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            width: 240,
            height: 160,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(imageUrl),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(VehicleModel vehicle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.business, 'Marca', vehicle.brandName ?? 'N/A'),
          const Divider(height: 24),
          _buildInfoRow(Icons.directions_car, 'Modelo', vehicle.model),
          const Divider(height: 24),
          _buildInfoRow(Icons.calendar_today, 'Año', vehicle.year.toString()),
          const Divider(height: 24),
          _buildInfoRow(Icons.badge, 'Placa', vehicle.licensePlate),
          if (vehicle.vin != null && vehicle.vin!.isNotEmpty) ...[
            const Divider(height: 24),
            _buildInfoRow(Icons.qr_code, 'VIN', vehicle.vin!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF5B7C99), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8D99AE),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2B2D42),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStaticInfo(VehicleModel vehicle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.color_lens,
            'Color',
            vehicle.color ?? 'No especificado',
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.speed,
            'Kilometraje',
            '${_formatMileage(vehicle.currentMileage)} km',
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorizedUsersSection(VehicleModel vehicle) {
    // Verificar si el usuario actual es el propietario principal
    final isPrimaryOwner = _authorizedUsers.any((u) => u.isPrimaryOwner && u.userId == vehicle.primaryOwnerId);
    final authorizedOnlyUsers = _authorizedUsers.where((u) => u.isAuthorized).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.people, color: AppTheme.secondarySteelBlue, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Usuarios Autorizados',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Solo mostrar botón agregar si es propietario principal
              if (isPrimaryOwner || _authorizedUsers.isEmpty)
                IconButton(
                  icon: const Icon(Icons.person_add, color: AppTheme.secondarySteelBlue),
                  onPressed: _showAddUserDialog,
                  tooltip: 'Agregar usuario',
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Mostrar cargando
          if (_isLoadingUsers)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          // Mostrar lista de usuarios
          else if (authorizedOnlyUsers.isNotEmpty)
            Column(
              children: [
                const Text(
                  'Estos usuarios pueden ver la información de tu vehículo:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8D99AE),
                  ),
                ),
                const SizedBox(height: 12),
                ...authorizedOnlyUsers.map((user) => _buildUserTile(user, vehicle, isPrimaryOwner)),
              ],
            )
          // Sin usuarios autorizados
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.gray1.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.gray2, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Solo tú tienes acceso a este vehículo',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8D99AE),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserTile(AuthorizedUserModel user, VehicleModel vehicle, bool canRemove) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.gray1.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gray1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.secondarySteelBlue.withOpacity(0.2),
            child: Text(
              user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppTheme.secondarySteelBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8D99AE),
                  ),
                ),
              ],
            ),
          ),
          if (canRemove)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
              onPressed: () => _removeAuthorizedUser(user, vehicle),
              tooltip: 'Eliminar acceso',
            ),
        ],
      ),
    );
  }

  Future<void> _removeAuthorizedUser(AuthorizedUserModel user, VehicleModel vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text('¿Deseas quitar el acceso de ${user.fullName} a este vehículo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final repository = VehicleRepository();
      await repository.removeAuthorizedUser(vehicle.id, user.userId);
      
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Usuario eliminado'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Recargar lista
      _loadAuthorizedUsers(vehicle.id);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildMaintenancesSection(VehicleModel vehicle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.build_circle, color: AppTheme.secondarySteelBlue, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Mantenimientos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppTheme.secondarySteelBlue),
                onPressed: () => _navigateToCreateMaintenance(vehicle),
                tooltip: 'Agregar mantenimiento',
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Descripción
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.gray1.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.history, color: AppTheme.gray2, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Lleva el registro de mantenimientos de tu vehículo',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8D99AE),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToMaintenances(vehicle),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Ver Historial'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondarySteelBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMaintenances(VehicleModel vehicle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => MaintenancesCubit(),
          child: MaintenancesListPage(
            vehicleId: vehicle.id,
            vehicleName: '${vehicle.brandName} ${vehicle.model}',
          ),
        ),
      ),
    );
  }

  void _navigateToCreateMaintenance(VehicleModel vehicle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => MaintenancesCubit(),
          child: CreateManualMaintenancePage(vehicleId: vehicle.id),
        ),
      ),
    );
  }

  Widget _buildEditableFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Editar información',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B2D42),
            ),
          ),
          const SizedBox(height: 16),

          // Color
          CustomTextField(
            label: 'Color',
            controller: _colorController,
            hint: 'Ej: Blanco, Negro, Rojo',
            prefixIcon: const Icon(Icons.color_lens_outlined),
          ),
          const SizedBox(height: 16),

          // Kilometraje
          CustomTextField(
            label: 'Kilometraje actual',
            controller: _mileageController,
            hint: '0',
            prefixIcon: const Icon(Icons.speed_outlined),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        text: 'Guardar Cambios',
        onPressed: _isLoading ? null : _saveChanges,
        isLoading: _isLoading,
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _deleteVehicle,
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        label: const Text('Eliminar Vehículo'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  String _formatMileage(int mileage) {
    if (mileage >= 1000) {
      return '${(mileage / 1000).toStringAsFixed(1)}k';
    }
    return mileage.toString();
  }
}
