import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../../../core/ui/widgets/widgets.dart';
import '../../../../core/navigation/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos y condiciones'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Separar nombre y apellido
      final fullName = _fullNameController.text.trim();
      final nameParts = fullName.split(' ').where((part) => part.isNotEmpty).toList();
      
      // Asegurar que siempre haya firstName y lastName
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : firstName; // Si solo hay un nombre, usarlo también como apellido

      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: _phoneController.text.trim(),
        ),
      );
    }
  }

  void _showTermsAndConditions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TermsAndConditionsModal(
        onAccept: () {
          setState(() {
            _acceptTerms = true;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == Status.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Error al registrarse'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == Status.success) {
            // Registro exitoso, navegar al home
            AppRouter.toHome(context);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header con curva
                _buildHeader(),

                const SizedBox(height: 24),

                // Contenido del formulario
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _buildForm(),
                ),
              ],
            ),
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
                onPressed: () => AppRouter.back(context),
              ),
              const Expanded(
                child: Text(
                  'Registration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Para centrar el título
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
          // Campo Full Name
          CustomTextField(
            label: 'Full Name',
            hint: 'Sergio Iglesias',
            controller: _fullNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu nombre completo';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Campo Email
          CustomTextField(
            label: 'Email',
            hint: 'owner@gmail.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu email';
              }
              if (!value.contains('@')) {
                return 'Por favor ingresa un email válido';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Campo Phone Number
          CustomTextField(
            label: 'Phone Number',
            hint: '973372718',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 15,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu número de teléfono';
              }
              if (value.length < 9) {
                return 'El número debe tener al menos 9 dígitos';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Campo Password
          CustomTextField(
            label: 'Password',
            hint: '••••••••••••',
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF8D99AE),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Campo Repeat Password
          CustomTextField(
            label: 'Repeat Password',
            hint: '••••••••••••',
            controller: _repeatPasswordController,
            obscureText: _obscureRepeatPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor repite tu contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRepeatPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: const Color(0xFF8D99AE),
              ),
              onPressed: () {
                setState(() {
                  _obscureRepeatPassword = !_obscureRepeatPassword;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Checkbox Terms and Conditions
          Row(
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptTerms = value ?? false;
                  });
                },
                activeColor: const Color(0xFF5B7C99),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _showTermsAndConditions,
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 12, color: Color(0xFF8D99AE)),
                      children: [
                        TextSpan(text: 'Signing in you agree with our\n'),
                        TextSpan(
                          text: 'Terms and Condition',
                          style: TextStyle(
                            color: Color(0xFF5B7C99),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Botón Register
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return PrimaryButton(
                text: 'Register',
                onPressed: _onRegister,
                isLoading: state.status == Status.loading,
                backgroundColor: const Color(0xFF5B7C99),
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Modal de Términos y Condiciones
class _TermsAndConditionsModal extends StatelessWidget {
  final VoidCallback onAccept;

  const _TermsAndConditionsModal({required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: const Text(
              'Terms and conditions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B7C99),
              ),
            ),
          ),

          // Contenido
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    '1. GENERAL INFORMATION',
                    'AutoNexo is a digital platform that connects vehicle owners with repair shops through a mobile and web application. By using AutoNexo, you agree to not use the platform.',
                  ),

                  _buildSection(
                    '2. DEFINITIONS',
                    '2.1. "Platform" refers to anyone who uses AutoNexo. "Owner" refers to anyone who registers vehicles. "Shop" refers to any business offering mechanical services and licensed services on the platform.',
                  ),

                  _buildSection(
                    '3. REGISTRATION AND ACCOUNT',
                    'To register, you must be at least 18 years old, provide accurate and up-to-date information, keep your account credentials secure, and promptly report any unauthorized use. You are responsible for keeping your information current.',
                  ),

                  _buildSection(
                    '4. PLATFORM SERVICES',
                    'For vehicle owners, AutoNexo allows you to register and manage vehicles, browse and compare repair shops, schedule appointments, communicate with shops, and rate the services provided.',
                  ),

                  _buildSection(
                    '5. PAYMENTS AND BILLING',
                    'Payment methods include credit/debit cards, Yape, Plin, other digital wallets. Prices are set by each repair shop. AutoNexo does not refund any prior notice. Refunds are governed by the repair shop\'s refund policy. AutoNexo does not provide the actual repair shop services.',
                  ),

                  _buildSection(
                    '6. RESPONSIBILITIES AND LIMITATIONS',
                    'AutoNexo is NOT responsible for the quality of the services, does NOT guarantee information about shops or vehicles, but DOES facilitate the connection between user and services.',
                  ),
                ],
              ),
            ),
          ),

          // Botón aceptar
          Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              text: 'Accept',
              onPressed: onAccept,
              backgroundColor: const Color(0xFF5B7C99),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B2D42),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8D99AE),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
