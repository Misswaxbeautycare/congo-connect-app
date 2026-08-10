class Shop {
  final String id;
  final String name;
  final String category;
  final String? subcategory;
  final String? description;
  final String? bio;
  final String? address;
  final String? phone;
  final String? email;
  final String? logoUrl;
  final String? coverUrl;
  final List<String> galleryPhotos;
  final List<String> specialties;
  final bool acceptsAppointments;
  final bool isPremium;
  final bool featured;
  final String verificationStatus;
  final double ratingAvg;
  final int ratingCount;

  Shop({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    this.description,
    this.bio,
    this.address,
    this.phone,
    this.email,
    this.logoUrl,
    this.coverUrl,
    this.galleryPhotos = const [],
    this.specialties = const [],
    this.acceptsAppointments = false,
    this.isPremium = false,
    this.featured = false,
    this.verificationStatus = 'pending',
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
      bio: map['bio'] as String?,
      address: map['address'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      logoUrl: map['logo_url'] as String?,
      coverUrl: map['cover_url'] as String?,
      galleryPhotos: (map['gallery_photos'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      specialties: (map['specialties'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      acceptsAppointments: map['accepts_appointments'] as bool? ?? false,
      isPremium: map['is_premium'] as bool? ?? false,
      featured: map['featured'] as bool? ?? false,
      verificationStatus: map['verification_status'] as String? ?? 'pending',
      ratingAvg: (map['rating_avg'] as num?)?.toDouble() ?? 0,
      ratingCount: (map['rating_count'] as num?)?.toInt() ?? 0,
    );
  }
}
