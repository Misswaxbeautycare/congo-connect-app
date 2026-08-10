import '../main.dart';
import '../models/advertisement.dart';

class AdvertisementService {
  static Future<List<Advertisement>> getActiveAds() async {
    final response = await supabase
        .from('advertisements')
        .select()
        .eq('status', 'active')
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => Advertisement.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> createAdRequest({
    required String businessName,
    required String contactPhone,
    required String description,
    String? imageUrl,
  }) async {
    await supabase.from('ad_requests').insert({
      'business_name': businessName,
      'contact_phone': contactPhone,
      'description': description,
      'image_url': imageUrl,
      'status': 'pending',
    });
  }
}
