class RoomType {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final int capacity;
  final List<String> amenities;
  final bool isDeleted;

  const RoomType({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.capacity,
    this.amenities = const [],
    this.isDeleted = false,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) {
    List<String> parseAmenities(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      if (val is String && val.isNotEmpty) {
        return val.split(',').map((e) => e.trim()).toList();
      }
      return const [];
    }

    return RoomType(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      basePrice: (json['basePrice'] is num)
          ? (json['basePrice'] as num).toDouble()
          : double.tryParse(json['basePrice']?.toString() ?? '') ?? 0.0,
      capacity: (json['capacity'] is num)
          ? (json['capacity'] as num).toInt()
          : int.tryParse(json['capacity']?.toString() ?? '') ?? 1,
      amenities: parseAmenities(json['amenities']),
      isDeleted: json['isDeleted'] == true || json['is_deleted'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'basePrice': basePrice,
        'capacity': capacity,
        'amenities': amenities,
        'isDeleted': isDeleted,
      };

  RoomType copyWith({
    String? id,
    String? name,
    String? description,
    double? basePrice,
    int? capacity,
    List<String>? amenities,
    bool? isDeleted,
  }) {
    return RoomType(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      capacity: capacity ?? this.capacity,
      amenities: amenities ?? this.amenities,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
