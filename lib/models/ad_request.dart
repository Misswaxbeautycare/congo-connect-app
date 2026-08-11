class AdRequest {
  final String id;
  final String businessName;
  final String contactPhone;
  final String? description;
  final String? imageUrl;
  final String status;

  AdRequest({
    required this.id,
    required this.businessName,
    required this.contactPhone,
    this.description,
    this.imageUrl,
    this.status = 'pending',
  });

  factory AdRequest.fromMap(Map<String, dynamic> map) {
    return AdRequest(
      id: map['id'] as String,
      businessName: map['business_name'] as String? ?? '',
      contactPhone: map['contact_phone'] as String? ?? '',
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      status: map['status'] as String? ?? 'pending',
    );
  }
}
