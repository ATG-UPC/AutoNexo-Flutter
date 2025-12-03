import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:autonexoowner/core/enums/status.dart';
import 'package:autonexoowner/core/ui/widgets/widgets.dart';
import 'package:autonexoowner/core/ui/theme/app_theme.dart';
import 'package:autonexoowner/core/navigation/app_router.dart';
import 'package:autonexoowner/core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Página de registro de usuario.
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
      ErrorDialog.show(
        context: context,
        message: 'Debes aceptar los términos y condiciones',
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
          : firstName;

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
      backgroundColor: AppTheme.backgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == Status.failure) {
            ErrorDialog.show(
              context: context,
              message: state.errorMessage ?? 'Error al registrarse',
            );
          } else if (state.status == Status.success) {
            AppRouter.toHome(context);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
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
        color: AppTheme.secondarySteelBlue,
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
                icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryWhite),
                onPressed: () => AppRouter.back(context),
              ),
              const Expanded(
                child: Text(
                  'Registration',
                  style: TextStyle(
                    color: AppTheme.primaryWhite,
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
          // Campo Full Name
          CustomTextField(
            label: 'Full Name',
            hint: 'Sergio Iglesias',
            controller: _fullNameController,
            textInputAction: TextInputAction.next,
            validator: (value) => Validators.name(value, 'Nombre completo'),
          ),

          const SizedBox(height: 16),

          // Campo Email
          CustomTextField(
            label: 'Email',
            hint: 'owner@gmail.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.email,
          ),

          const SizedBox(height: 16),

          // Campo Phone Number
          CustomTextField(
            label: 'Phone Number',
            hint: '973372718',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 15,
            textInputAction: TextInputAction.next,
            validator: Validators.phone,
          ),

          const SizedBox(height: 16),

          // Campo Password
          PasswordField(
            label: 'Password',
            controller: _passwordController,
            textInputAction: TextInputAction.next,
            validator: Validators.password,
          ),

          const SizedBox(height: 16),

          // Campo Repeat Password
          PasswordField(
            label: 'Repeat Password',
            controller: _repeatPasswordController,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _onRegister(),
            validator: (value) => Validators.confirmPassword(
              value, 
              _passwordController.text,
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
                activeColor: AppTheme.secondarySteelBlue,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _showTermsAndConditions,
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      children: [
                        TextSpan(text: 'Signing in you agree with our\n'),
                        TextSpan(
                          text: 'Terms and Condition',
                          style: TextStyle(
                            color: AppTheme.secondarySteelBlue,
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
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Modal de Términos y Condiciones.
class _TermsAndConditionsModal extends StatelessWidget {
  final VoidCallback onAccept;

  const _TermsAndConditionsModal({required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppTheme.white,
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
              border: Border(bottom: BorderSide(color: AppTheme.gray1)),
            ),
            child: const Text(
              'Terms and conditions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondarySteelBlue,
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
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
