import 'guest.dart';
import 'room.dart';
import 'service.dart';

enum BookingStatus {
  pending('Ожидает'),
  confirmed('Подтверждено'),
  checkedIn('Заселен'),
  checkedOut('Выселен'),
  cancelled('Отменено');

  final String label;
  const BookingStatus(this.label);

  static BookingStatus fromString(String? val) {
    return switch (val?.toLowerCase()) {
      'confirmed' => BookingStatus.confirmed,
      'checkedin' || 'checked_in' => BookingStatus.checkedIn,
      'checkedout' || 'checked_out' => BookingStatus.checkedOut,
      'cancelled' || 'canceled' => BookingStatus.cancelled,
      _ => BookingStatus.pending,
    };
  }
}

class Booking {
  final String id;
  final String guestId;
  final Guest? guest;
  final String roomId;
  final Room? room;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final BookingStatus status;
  final List<String> serviceIds;
  final List<Service> services;
  final double totalPrice;
  final double discountAmount;
  final String notes;
  final bool isDeleted;

  const Booking({
    required this.id,
    required this.guestId,
    this.guest,
    required this.roomId,
    this.room,
    required this.checkInDate,
    required this.checkOutDate,
    this.status = BookingStatus.pending,
    this.serviceIds = const [],
    this.services = const [],
    this.totalPrice = 0.0,
    this.discountAmount = 0.0,
    this.notes = '',
    this.isDeleted = false,
  });

  int get nights {
    final diff = checkOutDate.difference(checkInDate).inDays;
    return diff <= 0 ? 1 : diff;
  }

  static double calculateTotal({
    required double roomPricePerNight,
    required DateTime checkIn,
    required DateTime checkOut,
    double discountPercent = 0.0,
    List<Service> services = const [],
  }) {
    final days = checkOut.difference(checkIn).inDays;
    final totalDays = days <= 0 ? 1 : days;
    final rawRoomTotal = roomPricePerNight * totalDays;
    final discount = rawRoomTotal * (discountPercent.clamp(0.0, 100.0) / 100.0);
    final roomCostWithDiscount = rawRoomTotal - discount;
    final servicesCost = services.fold<double>(0.0, (sum, s) => sum + s.price);
    return roomCostWithDiscount + servicesCost;
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    Guest? parsedGuest;
    Room? parsedRoom;
    List<Service> parsedServices = [];

    if (json['expand'] is Map) {
      final exp = json['expand'] as Map;
      if (exp['guest'] is Map) {
        parsedGuest = Guest.fromJson(exp['guest'] as Map<String, dynamic>);
      }
      if (exp['room'] is Map) {
        parsedRoom = Room.fromJson(exp['room'] as Map<String, dynamic>);
      }
      if (exp['services'] is List) {
        parsedServices = (exp['services'] as List)
            .whereType<Map<String, dynamic>>()
            .map(Service.fromJson)
            .toList();
      }
    }

    if (parsedGuest == null && json['guestData'] is Map) {
      parsedGuest = Guest.fromJson(json['guestData'] as Map<String, dynamic>);
    }
    if (parsedRoom == null && json['roomData'] is Map) {
      parsedRoom = Room.fromJson(json['roomData'] as Map<String, dynamic>);
    }
    if (parsedServices.isEmpty && json['servicesData'] is List) {
      parsedServices = (json['servicesData'] as List)
          .whereType<Map<String, dynamic>>()
          .map(Service.fromJson)
          .toList();
    }

    List<String> parseIds(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      if (val is String && val.isNotEmpty) {
        return val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      return const [];
    }

    return Booking(
      id: json['id']?.toString() ?? '',
      guestId: json['guestId']?.toString() ?? json['guest']?.toString() ?? '',
      guest: parsedGuest,
      roomId: json['roomId']?.toString() ?? json['room']?.toString() ?? '',
      room: parsedRoom,
      checkInDate: json['checkInDate'] != null
          ? DateTime.tryParse(json['checkInDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      checkOutDate: json['checkOutDate'] != null
          ? DateTime.tryParse(json['checkOutDate'].toString()) ??
              DateTime.now().add(const Duration(days: 1))
          : DateTime.now().add(const Duration(days: 1)),
      status: BookingStatus.fromString(json['status']?.toString()),
      serviceIds: parseIds(json['serviceIds'] ?? json['services']),
      services: parsedServices,
      totalPrice: (json['totalPrice'] is num)
          ? (json['totalPrice'] as num).toDouble()
          : double.tryParse(json['totalPrice']?.toString() ?? '') ?? 0.0,
      discountAmount: (json['discountAmount'] is num)
          ? (json['discountAmount'] as num).toDouble()
          : double.tryParse(json['discountAmount']?.toString() ?? '') ?? 0.0,
      notes: json['notes']?.toString() ?? '',
      isDeleted: json['isDeleted'] == true || json['is_deleted'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'guestId': guestId,
        'roomId': roomId,
        'checkInDate': checkInDate.toIso8601String().substring(0, 10),
        'checkOutDate': checkOutDate.toIso8601String().substring(0, 10),
        'status': status.name,
        'serviceIds': serviceIds,
        'totalPrice': totalPrice,
        'discountAmount': discountAmount,
        'notes': notes,
        'isDeleted': isDeleted,
        if (guest != null) 'guestData': guest!.toJson(),
        if (room != null) 'roomData': room!.toJson(),
        if (services.isNotEmpty)
          'servicesData': services.map((s) => s.toJson()).toList(),
      };

  Booking copyWith({
    String? id,
    String? guestId,
    Guest? guest,
    String? roomId,
    Room? room,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    BookingStatus? status,
    List<String>? serviceIds,
    List<Service>? services,
    double? totalPrice,
    double? discountAmount,
    String? notes,
    bool? isDeleted,
  }) {
    return Booking(
      id: id ?? this.id,
      guestId: guestId ?? this.guestId,
      guest: guest ?? this.guest,
      roomId: roomId ?? this.roomId,
      room: room ?? this.room,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      status: status ?? this.status,
      serviceIds: serviceIds ?? this.serviceIds,
      services: services ?? this.services,
      totalPrice: totalPrice ?? this.totalPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      notes: notes ?? this.notes,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
