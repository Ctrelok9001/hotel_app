import 'booking.dart';

class BookingQuery {
  final int page;
  final int perPage;
  final String? search;
  final BookingStatus? status;
  final String? roomId;
  final String? guestId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? sort;
  final bool showDeleted;

  const BookingQuery({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.status,
    this.roomId,
    this.guestId,
    this.startDate,
    this.endDate,
    this.sort,
    this.showDeleted = false,
  });

  BookingQuery copyWith({
    int? page,
    int? perPage,
    String? search,
    BookingStatus? status,
    bool clearStatus = false,
    String? roomId,
    bool clearRoomId = false,
    String? guestId,
    bool clearGuestId = false,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    String? sort,
    bool? showDeleted,
  }) {
    return BookingQuery(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      search: search ?? this.search,
      status: clearStatus ? null : (status ?? this.status),
      roomId: clearRoomId ? null : (roomId ?? this.roomId),
      guestId: clearGuestId ? null : (guestId ?? this.guestId),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      sort: sort ?? this.sort,
      showDeleted: showDeleted ?? this.showDeleted,
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
    if (status != null) {
      params['status'] = status!.name;
    }
    if (roomId != null && roomId!.isNotEmpty) {
      params['roomId'] = roomId!;
    }
    if (guestId != null && guestId!.isNotEmpty) {
      params['guestId'] = guestId!;
    }
    if (startDate != null) {
      params['startDate'] = startDate!.toIso8601String().substring(0, 10);
    }
    if (endDate != null) {
      params['endDate'] = endDate!.toIso8601String().substring(0, 10);
    }
    if (sort != null && sort!.isNotEmpty) {
      params['sort'] = sort!;
    }
    if (showDeleted) {
      params['showDeleted'] = 'true';
    }
    return params;
  }

  factory BookingQuery.fromQueryParams(Map<String, String> params) {
    return BookingQuery(
      page: int.tryParse(params['page'] ?? '') ?? 1,
      perPage: int.tryParse(params['perPage'] ?? '') ?? 10,
      search: params['search'],
      status: params['status'] != null ? BookingStatus.fromString(params['status']) : null,
      roomId: params['roomId'],
      guestId: params['guestId'],
      startDate: params['startDate'] != null ? DateTime.tryParse(params['startDate']!) : null,
      endDate: params['endDate'] != null ? DateTime.tryParse(params['endDate']!) : null,
      sort: params['sort'],
      showDeleted: params['showDeleted'] == 'true',
    );
  }
}
