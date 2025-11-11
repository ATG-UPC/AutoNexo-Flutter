/// Constantes de configuración de la API
class ApiConstants {
  // Base URL del backend
  // TODO: Actualizar con tu URL de Azure

  // Configuración de ambiente
  static const bool _isProduction =
      true; // Cambia a false para desarrollo local

  // URLs por ambiente
  static const String _devBaseUrl = 'http://localhost:8080/api/v1';
  static const String _prodBaseUrl =
      'https://TU-APP.azurewebsites.net/api/v1'; // REEMPLAZAR con tu URL de Azure

  // URL activa según el ambiente
  static String get baseUrl => _isProduction ? _prodBaseUrl : _devBaseUrl;

  // Endpoints de autenticación
  static const String signupEndpoint = '/users/signup';
  static const String signinEndpoint = '/users/signin';

  // Endpoints de recuperación de contraseña
  static const String forgotPasswordRequestOtpEndpoint =
      '/users/forgot-password/request';
  static const String forgotPasswordVerifyOtpEndpoint =
      '/users/forgot-password/verify-otp';
  static const String forgotPasswordResetEndpoint =
      '/users/forgot-password/reset';

  // Endpoints de Home
  static const String getCurrentAppointmentEndpoint = '/appointments/current';
  static const String getScheduleEndpoint = '/appointments/schedule';

  // Endpoints de Profile
  static const String updateProfileEndpoint = '/users/profile';
  static const String changePasswordEndpoint = '/users/change-password';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
