import 'package:equatable/equatable.dart';
import '../../../../core/enums/status.dart';

/// Estados para el perfil
class ProfileState extends Equatable {
  final Status status;
  final String? errorMessage;
  final String? successMessage;

  const ProfileState({
    this.status = Status.initial,
    this.errorMessage,
    this.successMessage,
  });

  ProfileState copyWith({
    Status? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, successMessage];
}
