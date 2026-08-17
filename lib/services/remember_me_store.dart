import 'package:shared_preferences/shared_preferences.dart';

/// Gère la préférence "Se souvenir de moi". Par défaut activée (l'app
/// garde le client connecté automatiquement, comme le fait déjà
/// Supabase). Si le client décoche, on le déconnecte quand il ferme
/// complètement l'application.
class RememberMeStore {
  static const _key = 'remember_me';

  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }
}
