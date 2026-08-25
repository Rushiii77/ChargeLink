class ReviewModel {
  final String id;
  final String chargerId;
  final String customerId;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  ReviewModel({
    required this.id,
    required this.chargerId,
    required this.customerId,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      chargerId: map['chargerId'] ?? '',
      customerId: map['customerId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chargerId': chargerId,
      'customerId': customerId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}
