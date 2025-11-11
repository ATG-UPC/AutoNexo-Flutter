import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC de autenticación
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUserUpdated>(_onAuthUserUpdated);
  }

  /// Verificar si el usuario está autenticado
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final isAuthenticated = await authRepository.isAuthenticated();

      if (isAuthenticated) {
        final user = await authRepository.getUser();
        if (user != null) {
          emit(AuthState.authenticated(user.toEntity()));
        } else {
          emit(const AuthState.unauthenticated());
        }
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      emit(const AuthState.unauthenticated());
    }
  }

  /// Iniciar sesión
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final authResponse = await authRepository.signin(
        email: event.email,
        password: event.password,
      );

      emit(AuthState.authenticated(authResponse.user.toEntity()));
    } catch (e) {
      emit(AuthState.error(_extractErrorMessage(e)));
    }
  }

  /// Registrar nuevo usuario
  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      await authRepository.signup(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
      );

      // Después de registrarse exitosamente, iniciar sesión automáticamente
      final authResponse = await authRepository.signin(
        email: event.email,
        password: event.password,
      );

      emit(AuthState.authenticated(authResponse.user.toEntity()));
    } catch (e) {
      emit(AuthState.error(_extractErrorMessage(e)));
    }
  }

  /// Cerrar sesión
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      await authRepository.logout();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(_extractErrorMessage(e)));
    }
  }

  /// Actualizar datos del usuario
  void _onAuthUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) {
    emit(AuthState.authenticated(event.user.toEntity()));
  }

  /// Extraer mensaje de error legible
  String _extractErrorMessage(Object error) {
    final errorString = error.toString();

    if (errorString.contains('Exception:')) {
      return errorString.replaceAll('Exception:', '').trim();
    }

    return 'Error inesperado. Por favor, intenta de nuevo.';
  }
}
