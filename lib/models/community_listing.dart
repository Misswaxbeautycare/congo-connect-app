class CommunityListing {
  final String id;
  final String type; // 'don' ou 'troc'
  final String title;
  final String? description;
  final List<String> imageUrls;
  final double? price;
  final String contactName;
  final String contactPhone;
  final String? pickupLocation;
  final String status;
  final DateTime? createdAt;

  CommunityListing({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.imageUrls = const [],
    this.price,
    required this.contactName,
    required this.contactPhone,
    this.pickupLocation,
    this.status = 'active',
    this.createdAt,
  });

  factory CommunityListing.fromMap(Map<String, dynamic> map) {
    final urls = (map['image_urls'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
    final legacy = map['image_url'] as String?;
    return CommunityListing(
      id: map['id'] as String,
      type: map['type'] as String? ?? 'don',
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      imageUrls: urls.isNotEmpty ? urls : (legacy != null && legacy.isNotEmpty ? [legacy] : const []),
      price: (map['price'] as num?)?.toDouble(),
      contactName: map['contact_name'] as String? ?? '',
      contactPhone: map['contact_phone'] as String? ?? '',
      pickupLocation: map['pickup_location'] as String?,
      status: map['status'] as String? ?? 'active',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
    );
  }
}
