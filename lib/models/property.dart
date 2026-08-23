class Property {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final String? propertyType;
  final double? price;
  final String priceUnit; // 'nuit' | 'mois' | 'vente'
  final int? rooms;
  final String? address;
  final String? phone;
  final List<String> photos;
  final bool isAvailable;
  final String status;

  Property({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    this.propertyType,
    this.price,
    this.priceUnit = 'nuit',
    this.rooms,
    this.address,
    this.phone,
    this.photos = const [],
    this.isAvailable = true,
    this.status = 'pending',
  });

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      propertyType: map['property_type'] as String?,
      price: (map['price'] as num?)?.toDouble(),
      priceUnit: map['price_unit'] as String? ?? 'nuit',
      rooms: map['rooms'] as int?,
      address: map['address'] as String?,
      phone: map['phone'] as String?,
      photos: (map['photos'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isAvailable: map['is_available'] as bool? ?? true,
      status: map['status'] as String? ?? 'pending',
    );
  }
}
