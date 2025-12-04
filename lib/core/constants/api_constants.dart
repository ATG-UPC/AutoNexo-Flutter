/// Constantes de configuración de la API
class ApiConstants {
  // Configuración de ambiente
  static const bool _isProduction =
      true; // Cambia a false para desarrollo local

  // URLs por ambiente
  static const String _devBaseUrl = 'http://localhost:8080/api/v1';
  static const String _prodBaseUrl =
      'https://autonexo-backend-akcsb5avacemdwh7.canadacentral-01.azurewebsites.net/api/v1';

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

  // Endpoints de Home / Service Bookings
  static const String getCurrentAppointmentEndpoint = '/service-bookings/current';
  static const String getScheduleEndpoint = '/service-bookings/schedule';
  static const String serviceBookingsEndpoint = '/service-bookings';
  
  // Endpoints de Bookings (reservas de servicio)
  static const String myBookingsEndpoint = '/service-bookings';
  static String bookingByIdEndpoint(int id) => '/service-bookings/$id';
  static String confirmPickupEndpoint(int id) => '/service-bookings/$id/confirm-pickup';
  static String cancelBookingEndpoint(int id) => '/service-bookings/$id';

  // Endpoints de Profile
  static const String updateProfileEndpoint = '/users/profile';
  static const String changePasswordEndpoint = '/users/change-password';

  // Endpoints de Vehicles
  // GET /vehicles retorna los vehículos del usuario autenticado
  static const String vehiclesEndpoint = '/vehicles';
  static const String myVehiclesEndpoint = '/vehicles'; // El backend usa GET /vehicles para "mis vehículos"
  static String vehicleByIdEndpoint(int id) => '/vehicles/$id';
  static String vehicleImagesEndpoint(int id) => '/vehicles/$id/images';
  static String transferVehicleEndpoint(int id) => '/vehicles/$id/transfer';
  
  // Endpoints de Usuarios Autorizados (propietarios secundarios)
  static String vehicleAuthorizedUsersEndpoint(int id) => '/vehicles/$id/authorized-users';
  static String removeAuthorizedUserEndpoint(int vehicleId, int userId) => 
      '/vehicles/$vehicleId/authorized-users/$userId';

  // Endpoints de Catalog (públicos)
  static const String brandsEndpoint = '/catalog/brands';
  static String modelsByBrandEndpoint(int brandId) =>
      '/catalog/brands/$brandId/models';
  static const String servicesEndpoint = '/catalog/services';
  static const String serviceCategoriesEndpoint = '/catalog/services/categories';

  // Endpoints de Service Requests (sin prefijo v1)
  // NOTA: Estos endpoints usan /api en lugar de /api/v1
  static String get _serviceRequestsBaseUrl {
    if (_isProduction) {
      return 'https://autonexo-backend-akcsb5avacemdwh7.canadacentral-01.azurewebsites.net/api';
    }
    return 'http://localhost:8080/api';
  }
  static String get serviceRequestsFullUrl => '$_serviceRequestsBaseUrl/service-requests';
  static String serviceRequestByIdFullUrl(int id) => '$_serviceRequestsBaseUrl/service-requests/$id';

  // Endpoints de Ofertas (sin prefijo v1)
  // NOTA: Estos endpoints usan /api en lugar de /api/v1
  static String get _offersBaseUrl {
    if (_isProduction) {
      return 'https://autonexo-backend-akcsb5avacemdwh7.canadacentral-01.azurewebsites.net/api';
    }
    return 'http://localhost:8080/api';
  }
  
  /// Obtiene todas las ofertas del usuario autenticado
  static String get myOffersFullUrl => '$_offersBaseUrl/offers/my-requests';
  
  /// Obtiene las ofertas para una solicitud específica (legacy, mantener por compatibilidad)
  static String offersForRequest(int requestId) => '/offers/for-request/$requestId';
  
  /// Acepta una oferta
  static String acceptOfferFullUrl(int offerId) => '$_offersBaseUrl/offers/$offerId/accept';
  
  /// Rechaza una oferta
  static String rejectOfferFullUrl(int offerId) => '$_offersBaseUrl/offers/$offerId/reject';

  // Endpoints de Reviews (sin prefijo v1)
  // NOTA: Estos endpoints usan /api en lugar de /api/v1
  static String get _reviewsBaseUrl {
    if (_isProduction) {
      return 'https://autonexo-backend-akcsb5avacemdwh7.canadacentral-01.azurewebsites.net/api';
    }
    return 'http://localhost:8080/api';
  }
  static String get reviewsBaseUrl => _reviewsBaseUrl;
  static String reviewsWindowStatusUrl(int bookingId) => '$_reviewsBaseUrl/reviews/window-status?serviceBookingId=$bookingId';
  static String reviewsReceivedWorkshopsUrl(int workshopId, {int page = 0, int size = 20}) => 
      '$_reviewsBaseUrl/reviews/received/workshops/$workshopId?page=$page&size=$size';
  static String get reviewsCreateUrl => '$_reviewsBaseUrl/reviews';

  // Endpoints de Workshops (públicos)
  static const String workshopSearchEndpoint = '/workshops/search';
  static String workshopPublicEndpoint(int workshopId) => '/workshops/$workshopId/public';
  static String workshopServicesEndpoint(int workshopId) => '/workshops/$workshopId/services';
  static String workshopTrustScoreEndpoint(int workshopId) => '/trust-scores/workshop/$workshopId';
  
  // Legacy (mantener por compatibilidad)
  static String workshopPublic(int workshopId) => '/workshops/$workshopId/public';
  static String workshopTrustScore(int workshopId) => '/trust-scores/workshop/$workshopId';
  static const String workshopSearch = '/workshops/search';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
