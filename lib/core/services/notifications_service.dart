import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para gestionar el estado de las notificaciones
class NotificationsService {
  static const String _readOffersKey = 'read_offer_ids';

  /// Marca una oferta como leída
  static Future<void> markOfferAsRead(int offerId) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = getReadOfferIds(prefs);
    readIds.add(offerId.toString());
    await prefs.setStringList(_readOffersKey, readIds.toList());
  }

  /// Marca múltiples ofertas como leídas
  static Future<void> markOffersAsRead(List<int> offerIds) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = getReadOfferIds(prefs);
    readIds.addAll(offerIds.map((id) => id.toString()));
    await prefs.setStringList(_readOffersKey, readIds.toList());
  }

  /// Verifica si una oferta está marcada como leída
  static Future<bool> isOfferRead(int offerId) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = getReadOfferIds(prefs);
    return readIds.contains(offerId.toString());
  }

  /// Obtiene los IDs de ofertas leídas
  static Set<String> getReadOfferIds(SharedPreferences prefs) {
    return prefs.getStringList(_readOffersKey)?.toSet() ?? <String>{};
  }

  /// Obtiene el conteo de ofertas no leídas
  static Future<int> getUnreadOffersCount(
    List<int> allOfferIds,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = getReadOfferIds(prefs);
    return allOfferIds
        .where((id) => !readIds.contains(id.toString()))
        .length;
  }

  /// Limpia todas las ofertas leídas (útil para logout)
  static Future<void> clearReadOffers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_readOffersKey);
  }
}

