import 'package:equatable/equatable.dart';
import '../../../../core/enums/status.dart';

/// Estados para el flujo de recuperación de contraseña
class ForgotPasswordState extends Equatable {
  final Status status;
  final String? errorMessage;
  final String? phoneNumber;
  final String? otp;
  final String? successMessage;

  const ForgotPasswordState({
    this.status = Status.initial,
    this.errorMessage,
    this.phoneNumber,
    this.otp,
    this.successMessage,
  });

  ForgotPasswordState copyWith({
    Status? status,
    String? errorMessage,
    String? phoneNumber,
    String? otp,
    String? successMessage,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otp: otp ?? this.otp,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    phoneNumber,
    otp,
    successMessage,
  ];
}
