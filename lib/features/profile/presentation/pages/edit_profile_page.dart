import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/ui/widgets/widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../cubit/cubit.dart';

/// Página para editar el perfil
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      final fullName =
          '${_firstNameController.text} ${_lastNameController.text}';
      final names = fullName.trim().split(' ');
      final firstName = names.first;
      final lastName = names.length > 1 ? names.skip(1).join(' ') : '';

      final updatedUser = await context.read<ProfileCubit>().updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      if (updatedUser != null && mounted) {
        // Actualizar el usuario en AuthBloc
        context.read<AuthBloc>().add(AuthUserUpdated(updatedUser));

        // Mostrar diálogo de éxito
        await SuccessDialog.show(
          context: context,
          message: 'The profile was edited successfully.',
          onPressed: () {
            Navigator.pop(context); // Volver a profile
          },
        );
      }
    }
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state.status == Status.failure) {
              ErrorDialog.show(
                context: context,
                message:
                    state.errorMessage ??
                    'There was an error during the process.',
              );
            }
          },
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildForm(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF5B7C99),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.elliptical(200, 30),
          bottomRight: Radius.elliptical(200, 30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: _onCancel,
              ),
              const Expanded(
                child: Text(
                  'Edit Profile',
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Avatar con botón de editar
          Stack(
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFFD1D5DB),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 20,
                    color: Color(0xFF5B7C99),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Full Name
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Full Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5B7C99),
              ),
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            label: '',
            hint: 'Sergio Iglesias',
            controller: _firstNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu nombre';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Email
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Email',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5B7C99),
              ),
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            label: '',
            hint: 'owner@gmail.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu email';
              }
              if (!value.contains('@')) {
                return 'Email inválido';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Phone Number
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Phone Number',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5B7C99),
              ),
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            label: '',
            hint: '973372718',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu teléfono';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password (read-only)
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Password',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5B7C99),
              ),
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            label: '',
            hint: '••••••••••••',
            obscureText: true,
            enabled: false,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                AppRouter.toChangePassword(context);
              },
              child: const Text(
                'Change Password?',
                style: TextStyle(color: Color(0xFF5B7C99), fontSize: 14),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Botones
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.status == Status.loading
                          ? null
                          : _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B7C99),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: state.status == Status.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B3E50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
