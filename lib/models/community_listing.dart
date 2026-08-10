class CommunityListing {
  final String id;
  final String type; // 'don' ou 'troc'
  final String title;
  final String? description;
  final String? imageUrl;
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
    this.imageUrl,
    this.price,
    required this.contactName,
    required this.contactPhone,
    this.pickupLocation,
    this.status = 'active',
    this.createdAt,
  });

  factory CommunityListing.fromMap(Map<String, dynamic> map) {
    return CommunityListing(
      id: map['id'] as String,
      type: map['type'] as String? ?? 'don',
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      price: (map['price'] as num?)?.toDouble(),
      contactName: map['contact_name'] as String? ?? '',
      contactPhone: map['contact_phone'] as String? ?? '',
      pickupLocation: map['pickup_location'] as String?,
      status: map['status'] as String? ?? 'active',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
    );
  }
}
