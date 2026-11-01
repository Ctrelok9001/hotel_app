import 'payment.dart';

class PaymentQuery {
  final int page;
  final int perPage;
  final String? search;
  final String? bookingId;
  final PaymentMethod? method;
  final PaymentStatus? status;
  final String? sort;
  final bool showDeleted;

  const PaymentQuery({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.bookingId,
    this.method,
    this.status,
    this.sort,
    this.showDeleted = false,
  });

  PaymentQuery copyWith({
    int? page,
    int? perPage,
    String? search,
    String? bookingId,
    PaymentMethod? method,
    PaymentStatus? status,
    String? sort,
    bool? showDeleted,
  }) {
    return PaymentQuery(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      search: search ?? this.search,
      bookingId: bookingId ?? this.bookingId,
      method: method ?? this.method,
      status: status ?? this.status,
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
    if (bookingId != null && bookingId!.isNotEmpty) {
      params['bookingId'] = bookingId!;
    }
    if (method != null) {
      params['method'] = method!.name;
    }
    if (status != null) {
      params['status'] = status!.name;
    }
    if (sort != null && sort!.isNotEmpty) {
      params['sort'] = sort!;
    }
    if (showDeleted) {
      params['showDeleted'] = 'true';
    }
    return params;
  }

  factory PaymentQuery.fromQueryParams(Map<String, String> params) {
    return PaymentQuery(
      page: int.tryParse(params['page'] ?? '') ?? 1,
      perPage: int.tryParse(params['perPage'] ?? '') ?? 10,
      search: params['search'],
      bookingId: params['bookingId'],
      method: params['method'] != null ? PaymentMethod.fromString(params['method']) : null,
      status: params['status'] != null ? PaymentStatus.fromString(params['status']) : null,
      sort: params['sort'],
      showDeleted: params['showDeleted'] == 'true',
    );
  }
}
