import '../main.dart';
import '../models/community_listing.dart';

class CommunityListingService {
  static Future<List<CommunityListing>> getListings(String type) async {
    final response = await supabase
        .from('community_listings')
        .select()
        .eq('type', type)
        .eq('status', 'active')
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => CommunityListing.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> createListing({
    required String type,
    required String title,
    String? description,
    String? imageUrl,
    double? price,
    required String contactName,
    required String contactPhone,
    String? pickupLocation,
  }) async {
    await supabase.from('community_listings').insert({
      'type': type,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'pickup_location': pickupLocation,
      'status': 'active',
    });
  }
}
