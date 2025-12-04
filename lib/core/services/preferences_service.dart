import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para almacenamiento de preferencias no sensibles.
/// 
/// Utiliza SharedPreferences para guardar datos no sensibles como
/// configuraciones, flags de onboarding, preferencias de usuario, etc.
/// 
/// Ejemplo de uso:
/// ```dart
/// final prefs = PreferencesService();
/// 
/// // Guardar preferencias
/// await prefs.setHasSeenOnboarding(true);
/// await prefs.setDarkMode(false);
/// 
/// // Leer preferencias
/// final hasSeenOnboarding = await prefs.hasSeenOnboarding();
/// ```
class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  
  factory PreferencesService() => _instance;
  
  PreferencesService._internal();

  // Keys
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _darkModeKey = 'dark_mode';
  static const String _languageKey = 'language';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _lastSyncKey = 'last_sync';
  static const String _favoriteWorkshopsKey = 'favorite_workshops';

  // === Onboarding ===
  
  /// Verifica si el usuario ya vio el onboarding
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  /// Marca el onboarding como visto
  Future<void> setHasSeenOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, value);
  }

  // === Theme ===
  
  /// Verifica si está activado el modo oscuro
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  /// Establece el modo oscuro
  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  // === Language ===
  
  /// Obtiene el idioma preferido
  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'es';
  }

  /// Establece el idioma preferido
  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  // === Notifications ===
  
  /// Verifica si las notificaciones están habilitadas
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  /// Establece si las notificaciones están habilitadas
  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, value);
  }

  // === Sync ===
  
  /// Obtiene la fecha de la última sincronización
  Future<DateTime?> getLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  /// Establece la fecha de la última sincronización
  Future<void> setLastSync(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, dateTime.millisecondsSinceEpoch);
  }

  // === Generic Methods ===
  
  /// Guarda un string
  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// Obtiene un string
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Guarda un int
  Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  /// Obtiene un int
  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  /// Guarda un bool
  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Obtiene un bool
  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  /// Guarda una lista de strings
  Future<void> setStringList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  /// Obtiene una lista de strings
  Future<List<String>?> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  /// Elimina una clave
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Verifica si existe una clave
  Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  /// Limpia todas las preferencias
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // === Favorites (Workshops) ===

  /// Obtiene la lista de IDs de workshops favoritos
  Future<List<int>> getFavoriteWorkshops() async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList(_favoriteWorkshopsKey);
    if (stringList == null) {
      return [];
    }
    return stringList.map((id) => int.tryParse(id) ?? 0).where((id) => id > 0).toList();
  }

  /// Agrega un workshop a favoritos
  Future<void> addFavoriteWorkshop(int workshopId) async {
    if (workshopId <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteWorkshops();
    if (!favorites.contains(workshopId)) {
      favorites.add(workshopId);
      final stringList = favorites.map((id) => id.toString()).toList();
      await prefs.setStringList(_favoriteWorkshopsKey, stringList);
    }
  }

  /// Remueve un workshop de favoritos
  Future<void> removeFavoriteWorkshop(int workshopId) async {
    if (workshopId <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteWorkshops();
    favorites.remove(workshopId);
    final stringList = favorites.map((id) => id.toString()).toList();
    await prefs.setStringList(_favoriteWorkshopsKey, stringList);
  }

  /// Verifica si un workshop es favorito
  Future<bool> isFavoriteWorkshop(int workshopId) async {
    if (workshopId <= 0) return false;
    final favorites = await getFavoriteWorkshops();
    return favorites.contains(workshopId);
  }

  /// Alterna el estado de favorito de un workshop
  Future<bool> toggleFavoriteWorkshop(int workshopId) async {
    if (workshopId <= 0) return false;
    final isFavorite = await isFavoriteWorkshop(workshopId);
    if (isFavorite) {
      await removeFavoriteWorkshop(workshopId);
      return false;
    } else {
      await addFavoriteWorkshop(workshopId);
      return true;
    }
  }
}

