import 'room_type.dart';

enum RoomStatus {
  available('Свободен'),
  occupied('Занят'),
  cleaning('Уборка'),
  maintenance('Ремонт/ТО');

  final String label;
  const RoomStatus(this.label);

  static RoomStatus fromString(String? val) {
    return switch (val?.toLowerCase()) {
      'occupied' => RoomStatus.occupied,
      'cleaning' => RoomStatus.cleaning,
      'maintenance' => RoomStatus.maintenance,
      _ => RoomStatus.available,
    };
  }
}

class Room {
  final String id;
  final String number;
  final int floor;
  final String roomTypeId;
  final RoomType? roomType;
  final RoomStatus status;
  final String notes;
  final bool isDeleted;

  const Room({
    required this.id,
    required this.number,
    required this.floor,
    required this.roomTypeId,
    this.roomType,
    this.status = RoomStatus.available,
    this.notes = '',
    this.isDeleted = false,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    RoomType? parsedType;
    if (json['expand'] is Map && json['expand']['roomType'] is Map) {
      parsedType = RoomType.fromJson(json['expand']['roomType'] as Map<String, dynamic>);
    } else if (json['roomTypeData'] is Map) {
      parsedType = RoomType.fromJson(json['roomTypeData'] as Map<String, dynamic>);
    }

    return Room(
      id: json['id']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      floor: (json['floor'] is num)
          ? (json['floor'] as num).toInt()
          : int.tryParse(json['floor']?.toString() ?? '') ?? 1,
      roomTypeId: json['roomTypeId']?.toString() ?? json['room_type']?.toString() ?? '',
      roomType: parsedType,
      status: RoomStatus.fromString(json['status']?.toString()),
      notes: json['notes']?.toString() ?? '',
      isDeleted: json['isDeleted'] == true || json['is_deleted'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'floor': floor,
        'roomTypeId': roomTypeId,
        'status': status.name,
        'notes': notes,
        'isDeleted': isDeleted,
        if (roomType != null) 'roomTypeData': roomType!.toJson(),
      };

  Room copyWith({
    String? id,
    String? number,
    int? floor,
    String? roomTypeId,
    RoomType? roomType,
    RoomStatus? status,
    String? notes,
    bool? isDeleted,
  }) {
    return Room(
      id: id ?? this.id,
      number: number ?? this.number,
      floor: floor ?? this.floor,
      roomTypeId: roomTypeId ?? this.roomTypeId,
      roomType: roomType ?? this.roomType,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
