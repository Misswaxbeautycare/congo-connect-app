class Advertisement {
  final String id;
  final String title;
  final String imageUrl;
  final String? videoUrl;
  final String? contactPhone;
  final String? linkUrl;
  final int priority;

  Advertisement({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.videoUrl,
    this.contactPhone,
    this.linkUrl,
    this.priority = 0,
  });

  bool get isVideo => videoUrl != null && videoUrl!.isNotEmpty;

  factory Advertisement.fromMap(Map<String, dynamic> map) {
    return Advertisement(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      videoUrl: map['video_url'] as String?,
      contactPhone: map['contact_phone'] as String?,
      linkUrl: map['link_url'] as String?,
      priority: map['priority'] as int? ?? 0,
    );
  }
}
