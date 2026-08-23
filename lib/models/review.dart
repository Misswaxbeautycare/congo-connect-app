class Review {
  final String id;
  final String shopId;
  final String userId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.shopId,
    required this.userId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as String,
      shopId: map['shop_id'] as String,
      userId: map['user_id'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String?,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'] as String) : null,
    );
  }
}
