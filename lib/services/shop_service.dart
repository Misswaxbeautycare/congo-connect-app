import '../main.dart';
import '../models/shop.dart';

class ShopService {
  static Future<List<Shop>> getFeaturedShops({int limit = 10}) async {
    final response = await supabase
        .from('shops')
        .select()
        .eq('status', 'approved')
        .order('rating_avg', ascending: false)
        .limit(limit);

    return (response as List)
        .map((item) => Shop.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Shop>> getShopsByCategory(String category) async {
    final response = await supabase
        .from('shops')
        .select()
        .eq('status', 'approved')
        .eq('category', category)
        .order('rating_avg', ascending: false);

    return (response as List)
        .map((item) => Shop.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> createShop({
    required String name,
    required String category,
    String? subcategory,
    String? bio,
    String? phone,
    String? email,
    String? address,
    bool acceptsAppointments = false,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    await supabase.from('shops').insert({
      'owner_id': userId,
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'bio': bio,
      'phone': phone,
      'email': email,
      'address': address,
      'accepts_appointments': acceptsAppointments,
      'status': 'pending',
      'verification_status': 'pending',
    });
  }
}
