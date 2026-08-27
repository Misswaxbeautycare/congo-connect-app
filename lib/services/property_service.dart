import '../main.dart';
import '../models/property.dart';

class PropertyService {
  static Future<List<Property>> getApprovedProperties() async {
    final response = await supabase
        .from('properties')
        .select()
        .eq('status', 'approved')
        .order('created_at', ascending: false)
        .timeout(const Duration(seconds: 15));
    return (response as List)
        .map((item) => Property.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<Property>> getMyProperties() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];
    final response = await supabase
        .from('properties')
        .select()
        .eq('owner_id', userId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((item) => Property.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> createProperty({
    required String title,
    String? description,
    String? propertyType,
    double? price,
    required String priceUnit,
    int? rooms,
    String? address,
    String? phone,
    List<String> photos = const [],
  }) async {
    final userId = supabase.auth.currentUser!.id;
    await supabase.from('properties').insert({
      'owner_id': userId,
      'title': title,
      'description': description,
      'property_type': propertyType,
      'price': price,
      'price_unit': priceUnit,
      'rooms': rooms,
      'address': address,
      'phone': phone,
      'photos': photos,
      'status': 'pending',
    });
  }

  static Future<void> deleteProperty(String id) async {
    await supabase.from('properties').delete().eq('id', id);
  }

  static Future<void> setAvailability(String id, bool isAvailable) async {
    await supabase.from('properties').update({'is_available': isAvailable}).eq('id', id);
  }

  // --- Administration ---

  static Future<List<Property>> getPendingProperties() async {
    final response = await supabase
        .from('properties')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return (response as List)
        .map((item) => Property.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> setPropertyStatus(String id, String status) async {
    await supabase.from('properties').update({'status': status}).eq('id', id);
  }

  static Future<List<Property>> getPropertiesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final response = await supabase.from('properties').select().inFilter('id', ids);
    return (response as List).map((item) => Property.fromMap(item as Map<String, dynamic>)).toList();
  }
}
