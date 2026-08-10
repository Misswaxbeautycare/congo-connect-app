class Advertisement {
  final String id;
  final String title;
  final String imageUrl;
  final String? contactPhone;
  final String? linkUrl;

  Advertisement({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.contactPhone,
    this.linkUrl,
  });

  factory Advertisement.fromMap(Map<String, dynamic> map) {
    return Advertisement(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      contactPhone: map['contact_phone'] as String?,
      linkUrl: map['link_url'] as String?,
    );
  }
}
