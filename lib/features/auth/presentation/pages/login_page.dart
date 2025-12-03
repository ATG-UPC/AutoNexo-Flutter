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

/// Página de inicio de sesión.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _navigateToRegister() {
    AppRouter.toRegister(context);
  }

  void _navigateToForgotPassword() {
    AppRouter.toForgotPassword(context);
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
              message: state.errorMessage ?? 'Error al iniciar sesión',
            );
          } else if (state.status == Status.success && state.isAuthenticated) {
            // Login exitoso, navegar al home
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
        color: AppTheme.secondarySteelBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.elliptical(200, 30),
          bottomRight: Radius.elliptical(200, 30),
        ),
      ),
      child: const Column(
        children: [
          SizedBox(height: 16),
          Text(
            'Owner',
            style: TextStyle(
              color: AppTheme.primaryWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
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
          const Text(
            'Login',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondarySteelBlue,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Logo de Login
          Center(
            child: Image.asset(
              'assets/images/Logo_Login.png',
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.gray1.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car,
                        size: 80,
                        color: AppTheme.secondarySteelBlue,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'AutoNexo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondarySteelBlue,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

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

          // Campo Password usando PasswordField
          PasswordField(
            label: 'Password',
            controller: _passwordController,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _onLogin(),
            validator: Validators.password,
          ),

          const SizedBox(height: 8),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _navigateToForgotPassword,
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Botón Register
          SecondaryButton(
            text: 'Register',
            onPressed: _navigateToRegister,
          ),

          const SizedBox(height: 16),

          // Separador "Or"
          Row(
            children: [
              Expanded(child: Divider(color: AppTheme.gray1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppTheme.gray1)),
            ],
          ),

          const SizedBox(height: 16),

          // Botón Login
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return PrimaryButton(
                text: 'Login',
                onPressed: _onLogin,
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
