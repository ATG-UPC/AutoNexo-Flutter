import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../../../core/ui/widgets/widgets.dart';
import '../cubit/cubit.dart';

/// Página para cambiar contraseña
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<ProfileCubit>().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (success && mounted) {
        await SuccessDialog.show(
          context: context,
          message: 'Your password has been changed successfully.',
          onPressed: () {
            Navigator.pop(context); // Volver a edit profile
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
                  'New Password',
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // Current Password
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Current Password',
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
            hint: 'Type your current password',
            controller: _currentPasswordController,
            obscureText: _obscureCurrentPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureCurrentPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: const Color(0xFF8D99AE),
              ),
              onPressed: () {
                setState(() {
                  _obscureCurrentPassword = !_obscureCurrentPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña actual';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Change Password
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Change Password',
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
            hint: 'Type your new password',
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF8D99AE),
              ),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu nueva contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Repeat Password
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Repeat Password',
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
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: const Color(0xFF8D99AE),
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor confirma tu contraseña';
              }
              if (value != _newPasswordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),

          const SizedBox(height: 48),

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
