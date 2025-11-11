import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/enums/status.dart';
import '../../../../../core/ui/widgets/widgets.dart';
import '../../../../../core/navigation/app_router.dart';
import '../../cubit/forgot_password_cubit.dart';
import '../../cubit/forgot_password_state.dart';

/// Página 2: Verificación de código OTP
class ForgotPasswordOtpPage extends StatefulWidget {
  const ForgotPasswordOtpPage({super.key});

  @override
  State<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends State<ForgotPasswordOtpPage> {
  String _otp = '';

  void _onOtpCompleted(String otp) {
    setState(() {
      _otp = otp;
    });
  }

  void _onVerify() {
    if (_otp.length == 4) {
      context.read<ForgotPasswordCubit>().verifyOtp(_otp);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el código OTP completo'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _onResendOtp() {
    final cubit = context.read<ForgotPasswordCubit>();
    final phoneNumber = cubit.state.phoneNumber;

    if (phoneNumber != null) {
      cubit.requestOtp(phoneNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código OTP reenviado'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state.status == Status.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Error al verificar OTP'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == Status.success && state.otp != null) {
            // Navegar a la página de nueva contraseña
            AppRouter.toForgotPasswordNewPassword(context);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header con curva
                _buildHeader(),

                const SizedBox(height: 40),

                // Contenido del formulario
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _buildContent(),
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

  Widget _buildContent() {
    return BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'OTP Verification',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B7C99),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Text(
              'Enter the OTP sent to ${state.phoneNumber ?? "your phone"}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF8D99AE)),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // OTP Input
            OtpInput(
              length: 4,
              onCompleted: _onOtpCompleted,
              onChanged: (otp) {
                setState(() {
                  _otp = otp;
                });
              },
            ),

            const SizedBox(height: 24),

            // Resend OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't recive the OTP? ",
                  style: TextStyle(fontSize: 14, color: Color(0xFF8D99AE)),
                ),
                TextButton(
                  onPressed: _onResendOtp,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'RESEND OTP',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5B7C99),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Botón Verify & Proceed
            PrimaryButton(
              text: 'Verify & Proceed',
              onPressed: _onVerify,
              isLoading: state.status == Status.loading,
              backgroundColor: const Color(0xFF5B7C99),
            ),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
