class Service {
  final String id;
  final String name;
  final double price;
  final String description;
  final bool isAvailable;
  final bool isDeleted;

  const Service({
    required this.id,
    required this.name,
    required this.price,
    this.description = '',
    this.isAvailable = true,
    this.isDeleted = false,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      description: json['description']?.toString() ?? '',
      isAvailable: json['isAvailable'] == null ? true : (json['isAvailable'] == true || json['isAvailable'] == 1),
      isDeleted: json['isDeleted'] == true || json['is_deleted'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
        'isAvailable': isAvailable,
        'isDeleted': isDeleted,
      };

  Service copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    bool? isAvailable,
    bool? isDeleted,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
