import 'room.dart';

class RoomQuery {
  final int page;
  final int perPage;
  final String? search;
  final String? roomTypeId;
  final RoomStatus? status;
  final int? floor;
  final String? sort;
  final bool showDeleted;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;

  const RoomQuery({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.roomTypeId,
    this.status,
    this.floor,
    this.sort,
    this.showDeleted = false,
    this.checkInDate,
    this.checkOutDate,
  });

  RoomQuery copyWith({
    int? page,
    int? perPage,
    String? search,
    String? roomTypeId,
    bool clearRoomTypeId = false,
    RoomStatus? status,
    bool clearStatus = false,
    int? floor,
    bool clearFloor = false,
    String? sort,
    bool? showDeleted,
    DateTime? checkInDate,
    bool clearCheckInDate = false,
    DateTime? checkOutDate,
    bool clearCheckOutDate = false,
  }) {
    return RoomQuery(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      search: search ?? this.search,
      roomTypeId: clearRoomTypeId ? null : (roomTypeId ?? this.roomTypeId),
      status: clearStatus ? null : (status ?? this.status),
      floor: clearFloor ? null : (floor ?? this.floor),
      sort: sort ?? this.sort,
      showDeleted: showDeleted ?? this.showDeleted,
      checkInDate: clearCheckInDate ? null : (checkInDate ?? this.checkInDate),
      checkOutDate: clearCheckOutDate ? null : (checkOutDate ?? this.checkOutDate),
    );
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{
      'page': '$page',
      'perPage': '$perPage',
    };
    if (search != null && search!.trim().isNotEmpty) {
      params['search'] = search!.trim();
    }
    if (roomTypeId != null && roomTypeId!.isNotEmpty) {
      params['roomTypeId'] = roomTypeId!;
    }
    if (status != null) {
      params['status'] = status!.name;
    }
    if (floor != null) {
      params['floor'] = '$floor';
    }
    if (sort != null && sort!.isNotEmpty) {
      params['sort'] = sort!;
    }
    if (showDeleted) {
      params['showDeleted'] = 'true';
    }
    if (checkInDate != null) {
      params['checkInDate'] = checkInDate!.toIso8601String().substring(0, 10);
    }
    if (checkOutDate != null) {
      params['checkOutDate'] = checkOutDate!.toIso8601String().substring(0, 10);
    }
    return params;
  }

  factory RoomQuery.fromQueryParams(Map<String, String> params) {
    return RoomQuery(
      page: int.tryParse(params['page'] ?? '') ?? 1,
      perPage: int.tryParse(params['perPage'] ?? '') ?? 10,
      search: params['search'],
      roomTypeId: params['roomTypeId'],
      status: params['status'] != null ? RoomStatus.fromString(params['status']) : null,
      floor: int.tryParse(params['floor'] ?? ''),
      sort: params['sort'],
      showDeleted: params['showDeleted'] == 'true',
      checkInDate: params['checkInDate'] != null ? DateTime.tryParse(params['checkInDate']!) : null,
      checkOutDate: params['checkOutDate'] != null ? DateTime.tryParse(params['checkOutDate']!) : null,
    );
  }
}
