class Review {
  final String id;
  final String guestId;
  final String guestName;
  final int rating;
  final String comment;
  final String response;
  final DateTime createdAt;
  final bool isPublished;
  final bool isDeleted;

  const Review({
    required this.id,
    required this.guestId,
    this.guestName = 'Гость отеля',
    required this.rating,
    required this.comment,
    this.response = '',
    required this.createdAt,
    this.isPublished = true,
    this.isDeleted = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      guestId: json['guestId']?.toString() ?? json['guest']?.toString() ?? '',
      guestName: json['guestName']?.toString() ?? 'Гость отеля',
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toInt()
          : int.tryParse(json['rating']?.toString() ?? '') ?? 5,
      comment: json['comment']?.toString() ?? '',
      response: json['response']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isPublished: json['isPublished'] == null ? true : (json['isPublished'] == true || json['isPublished'] == 1),
      isDeleted: json['isDeleted'] == true || json['is_deleted'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'guestId': guestId,
        'guestName': guestName,
        'rating': rating,
        'comment': comment,
        'response': response,
        'createdAt': createdAt.toIso8601String(),
        'isPublished': isPublished,
        'isDeleted': isDeleted,
      };

  Review copyWith({
    String? id,
    String? guestId,
    String? guestName,
    int? rating,
    String? comment,
    String? response,
    DateTime? createdAt,
    bool? isPublished,
    bool? isDeleted,
  }) {
    return Review(
      id: id ?? this.id,
      guestId: guestId ?? this.guestId,
      guestName: guestName ?? this.guestName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      response: response ?? this.response,
      createdAt: createdAt ?? this.createdAt,
      isPublished: isPublished ?? this.isPublished,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
