import '../main.dart';

class FavoriteService {
  static Future<Set<String>> getFavoriteIds(String itemType) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return {};
    final response = await supabase
        .from('favorites')
        .select('item_id')
        .eq('user_id', userId)
        .eq('item_type', itemType);
    return (response as List).map((e) => e['item_id'] as String).toSet();
  }

  static Future<bool> isFavorite(String itemType, String itemId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return false;
    final response = await supabase
        .from('favorites')
        .select('id')
        .eq('user_id', userId)
        .eq('item_type', itemType)
        .eq('item_id', itemId)
        .maybeSingle();
    return response != null;
  }

  static Future<void> toggleFavorite(String itemType, String itemId, bool isFavorite) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    if (isFavorite) {
      await supabase.from('favorites').insert({
        'user_id': userId,
        'item_type': itemType,
        'item_id': itemId,
      });
    } else {
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('item_type', itemType)
          .eq('item_id', itemId);
    }
  }

  static Future<List<String>> getFavoriteShopIds() async {
    final ids = await getFavoriteIds('shop');
    return ids.toList();
  }

  static Future<List<String>> getFavoritePropertyIds() async {
    final ids = await getFavoriteIds('property');
    return ids.toList();
  }
}
