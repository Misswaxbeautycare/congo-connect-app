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

  static Future<List<CommunityListing>> searchListings(String query) async {
    if (query.trim().isEmpty) return [];
    final response = await supabase
        .from('community_listings')
        .select()
        .eq('status', 'active')
        .or('title.ilike.%$query%,description.ilike.%$query%')
        .order('created_at', ascending: false)
        .limit(30);

    return (response as List)
        .map((item) => CommunityListing.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<CommunityListing>> getListingsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final response = await supabase
        .from('community_listings')
        .select()
        .inFilter('id', ids)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => CommunityListing.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<String> createListing({
    required String type,
    required String title,
    String? description,
    List<String> imageUrls = const [],
    double? price,
    required String contactName,
    required String contactPhone,
    String? pickupLocation,
  }) async {
    final result = await supabase.from('community_listings').insert({
      'type': type,
      'title': title,
      'description': description,
      'image_urls': imageUrls,
      'image_url': imageUrls.isNotEmpty ? imageUrls.first : null,
      'price': price,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'pickup_location': pickupLocation,
      'status': 'active',
    }).select('id').single();

    return result['id'] as String;
  }

  static Future<void> deleteListing(String id) async {
    await supabase.from('community_listings').delete().eq('id', id);
  }

  static Future<List<CommunityListing>> getAllListingsForAdmin() async {
    final response = await supabase
        .from('community_listings')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => CommunityListing.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<int> countListings({String? type}) async {
    var query = supabase.from('community_listings').select('id');
    if (type != null) query = query.eq('type', type);
    final response = await query;
    return (response as List).length;
  }
}
