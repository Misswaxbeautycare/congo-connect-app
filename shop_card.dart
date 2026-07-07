class Shop {
  final String id;
  final String name;
  final String category;
  final String? subcategory;
  final String? description;
  final String? address;
  final String? logoUrl;
  final String? coverUrl;
  final double ratingAvg;
  final int ratingCount;

  Shop({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    this.description,
    this.address,
    this.logoUrl,
    this.coverUrl,
    this.ratingAvg = 0,
    this.ratingCount = 0,
  });

  factory Shop.fromMap(Map<String, dynamic> map) {
    return Shop(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? '',
      subcategory: map['subcategory'] as String?,
      description: map['description'] as String?,
      address: map['address'] as String?,
      logoUrl: map['logo_url'] as String?,
      coverUrl: map['cover_url'] as String?,
      ratingAvg: (map['rating_avg'] as num?)?.toDouble() ?? 0,
      ratingCount: (map['rating_count'] as num?)?.toInt() ?? 0,
    );
  }
}
