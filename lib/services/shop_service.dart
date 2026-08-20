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

  static Future<List<Shop>> searchShops(String query) async {
    if (query.trim().isEmpty) return [];
    final response = await supabase
        .from('shops')
        .select()
        .eq('status', 'approved')
        .or('name.ilike.%$query%,category.ilike.%$query%,subcategory.ilike.%$query%')
        .order('rating_avg', ascending: false)
        .limit(30);

    return (response as List)
        .map((item) => Shop.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Shop>> getMyShops() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];
    final response = await supabase
        .from('shops')
        .select()
        .eq('owner_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Shop.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> deleteShop(String shopId) async {
    await supabase.from('shops').delete().eq('id', shopId);
  }

  // --- Administration ---

  static Future<List<Shop>> getPendingShops() async {
    final response = await supabase
        .from('shops')
        .select()
        .eq('verification_status', 'pending')
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Shop.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> setShopVerification(String shopId, String status) async {
    // status: 'verified' | 'rejected' | 'pending'
    await supabase.from('shops').update({
      'verification_status': status,
      'status': status == 'verified' ? 'approved' : 'pending',
    }).eq('id', shopId);
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
    String? coverUrl,
    int? stockQuantity,
    String? paymentMethod,
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
      'cover_url': coverUrl,
      'stock_quantity': stockQuantity,
      'payment_method': paymentMethod,
      'status': 'pending',
      'verification_status': 'pending',
    });
  }

  static Future<List<Shop>> getAllShopsForAdmin() async {
    final response = await supabase
        .from('shops')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Shop.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> adminDeleteShop(String shopId) async {
    await supabase.from('shops').delete().eq('id', shopId);
  }

  static Future<int> countShops({String? status}) async {
    var query = supabase.from('shops').select('id');
    if (status != null) query = query.eq('status', status);
    final response = await query;
    return (response as List).length;
  }
}
