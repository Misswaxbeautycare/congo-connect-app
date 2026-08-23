import '../main.dart';
import '../models/review.dart';

class ReviewService {
  static Future<List<Review>> getReviewsForShop(String shopId) async {
    final response = await supabase
        .from('reviews')
        .select()
        .eq('shop_id', shopId)
        .order('created_at', ascending: false);
    return (response as List).map((item) => Review.fromMap(item as Map<String, dynamic>)).toList();
  }

  static Future<Review?> getMyReview(String shopId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;
    final response = await supabase
        .from('reviews')
        .select()
        .eq('shop_id', shopId)
        .eq('user_id', userId)
        .maybeSingle();
    return response != null ? Review.fromMap(response) : null;
  }

  /// Crée ou met à jour l'avis de l'utilisateur pour cette boutique
  /// (un seul avis par personne et par boutique).
  static Future<void> submitReview({
    required String shopId,
    required int rating,
    String? comment,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    await supabase.from('reviews').upsert({
      'shop_id': shopId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
    }, onConflict: 'shop_id,user_id');
  }

  static Future<void> deleteReview(String reviewId) async {
    await supabase.from('reviews').delete().eq('id', reviewId);
  }
}
