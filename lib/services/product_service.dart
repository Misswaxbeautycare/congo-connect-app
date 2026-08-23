import '../main.dart';
import '../models/product.dart';

class ProductService {
  static const int freeLimit = 5;

  static Future<List<Product>> getProductsForShop(String shopId) async {
    final response = await supabase
        .from('products')
        .select()
        .eq('shop_id', shopId)
        .order('created_at', ascending: true);
    return (response as List)
        .map((item) => Product.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addProduct({
    required String shopId,
    required String name,
    double? price,
    String? photoUrl,
    String? description,
  }) async {
    await supabase.from('products').insert({
      'shop_id': shopId,
      'name': name,
      'price': price,
      'photo_url': photoUrl,
      'description': description,
    });
  }

  static Future<void> deleteProduct(String productId) async {
    await supabase.from('products').delete().eq('id', productId);
  }
}
