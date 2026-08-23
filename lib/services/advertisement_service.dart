import '../main.dart';
import '../models/advertisement.dart';
import '../models/ad_request.dart';

class AdvertisementService {
  static Future<List<Advertisement>> getActiveAds() async {
    final response = await supabase
        .from('advertisements')
        .select()
        .eq('status', 'active')
        .order('priority', ascending: false)
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

  // --- Administration ---

  static Future<List<AdRequest>> getPendingAdRequests() async {
    final response = await supabase
        .from('ad_requests')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => AdRequest.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Publie une demande : crée la publicité active et marque la demande comme approuvée.
  static Future<void> approveAdRequest(AdRequest request) async {
    if (request.imageUrl == null || request.imageUrl!.isEmpty) {
      throw Exception('Cette demande n\'a pas de visuel, impossible de la publier.');
    }
    await supabase.from('advertisements').insert({
      'title': request.businessName,
      'image_url': request.imageUrl,
      'contact_phone': request.contactPhone,
      'status': 'active',
    });
    await supabase.from('ad_requests').update({'status': 'approved'}).eq('id', request.id);
  }

  static Future<void> rejectAdRequest(String id) async {
    await supabase.from('ad_requests').update({'status': 'rejected'}).eq('id', id);
  }
}
