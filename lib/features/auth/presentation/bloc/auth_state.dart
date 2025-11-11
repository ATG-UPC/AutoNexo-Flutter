import 'package:equatable/equatable.dart';
import '../../../../core/enums/status.dart';
import '../../domain/entities/user.dart';

/// Estados de autenticación
class AuthState extends Equatable {
  final Status status;
  final User? user;
  final String? errorMessage;

  const AuthState({this.status = Status.initial, this.user, this.errorMessage});

  /// Estado inicial
  const AuthState.initial()
    : status = Status.initial,
      user = null,
      errorMessage = null;

  /// Estado de carga
  const AuthState.loading()
    : status = Status.loading,
      user = null,
      errorMessage = null;

  /// Estado autenticado
  const AuthState.authenticated(User user)
    : status = Status.success,
      user = user,
      errorMessage = null;

  /// Estado no autenticado
  const AuthState.unauthenticated()
    : status = Status.initial,
      user = null,
      errorMessage = null;

  /// Estado de error
  const AuthState.error(String message)
    : status = Status.failure,
      user = null,
      errorMessage = message;

  /// Copiar con nuevos valores
  AuthState copyWith({Status? status, User? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Verifica si el usuario está autenticado
  bool get isAuthenticated => user != null && status == Status.success;

  @override
  List<Object?> get props => [status, user, errorMessage];
}
