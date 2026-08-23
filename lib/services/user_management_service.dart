import '../main.dart';

class UserManagementService {
  /// Liste tous les profils, avec le nombre de boutiques créées par chacun.
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final profiles = await supabase
        .from('profiles')
        .select('id, email, is_banned, created_at')
        .order('created_at', ascending: false);

    final shops = await supabase.from('shops').select('owner_id');
    final shopCounts = <String, int>{};
    for (final s in (shops as List)) {
      final ownerId = s['owner_id'] as String?;
      if (ownerId != null) {
        shopCounts[ownerId] = (shopCounts[ownerId] ?? 0) + 1;
      }
    }

    return (profiles as List).map((p) {
      final map = Map<String, dynamic>.from(p as Map);
      map['shop_count'] = shopCounts[map['id']] ?? 0;
      return map;
    }).toList();
  }

  static Future<void> setBanned(String userId, bool banned) async {
    await supabase.from('profiles').update({'is_banned': banned}).eq('id', userId);
  }

  /// Vérifie si l'utilisateur actuellement connecté est banni.
  static Future<bool> isCurrentUserBanned() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;
    final response = await supabase
        .from('profiles')
        .select('is_banned')
        .eq('id', userId)
        .maybeSingle();
    return response?['is_banned'] as bool? ?? false;
  }
}
