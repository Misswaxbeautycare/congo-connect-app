import 'package:shared_preferences/shared_preferences.dart';

/// Comme les dons/troc ne nécessitent pas de compte, on retient
/// localement (sur cet appareil) les annonces que la personne a créées,
/// pour qu'elle puisse les retrouver et les supprimer dans "Mes annonces".
class MyListingsStore {
  static const _key = 'my_listing_ids';

  static Future<void> addListingId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    if (!ids.contains(id)) {
      ids.add(id);
      await prefs.setStringList(_key, ids);
    }
  }

  static Future<void> removeListingId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_key) ?? [];
    ids.remove(id);
    await prefs.setStringList(_key, ids);
  }

  static Future<List<String>> getListingIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
}
