class Product {
  final String id;
  final String shopId;
  final String name;
  final double? price;
  final String? photoUrl;
  final String? description;

  Product({
    required this.id,
    required this.shopId,
    required this.name,
    this.price,
    this.photoUrl,
    this.description,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      shopId: map['shop_id'] as String,
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble(),
      photoUrl: map['photo_url'] as String?,
      description: map['description'] as String?,
    );
  }
}
