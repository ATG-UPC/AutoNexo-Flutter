import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/enums/status.dart';
import '../../data/repositories/auth_repository.dart';
import 'forgot_password_state.dart';

/// Cubit para manejar el flujo de recuperación de contraseña
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRepository _authRepository;

  ForgotPasswordCubit(this._authRepository)
    : super(const ForgotPasswordState());

  /// Paso 1: Solicitar OTP
  Future<void> requestOtp(String phoneNumber) async {
    emit(state.copyWith(status: Status.loading));

    try {
      final response = await _authRepository.requestPasswordResetOtp(
        phoneNumber: phoneNumber,
      );

      emit(
        state.copyWith(
          status: Status.success,
          phoneNumber: phoneNumber,
          successMessage: response.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  /// Paso 2: Verificar OTP
  Future<void> verifyOtp(String otp) async {
    if (state.phoneNumber == null) {
      emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: 'Número de teléfono no encontrado',
        ),
      );
      return;
    }

    emit(state.copyWith(status: Status.loading));

    try {
      final response = await _authRepository.verifyOtp(
        phoneNumber: state.phoneNumber!,
        otp: otp,
      );

      emit(
        state.copyWith(
          status: Status.success,
          otp: otp,
          successMessage: response.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  /// Paso 3: Resetear contraseña
  Future<void> resetPassword(String newPassword) async {
    if (state.phoneNumber == null || state.otp == null) {
      emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: 'Datos de verificación no encontrados',
        ),
      );
      return;
    }

    emit(state.copyWith(status: Status.loading));

    try {
      await _authRepository.resetPassword(
        phoneNumber: state.phoneNumber!,
        otp: state.otp!,
        newPassword: newPassword,
      );

      emit(
        state.copyWith(
          status: Status.success,
          successMessage: 'Contraseña actualizada exitosamente',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  /// Reiniciar estado
  void reset() {
    emit(const ForgotPasswordState());
  }
}
