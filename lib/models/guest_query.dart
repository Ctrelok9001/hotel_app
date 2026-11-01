class GuestQuery {
  final int page;
  final int perPage;
  final String? search;
  final double? minDiscount;
  final String? sort;
  final bool showDeleted;

  const GuestQuery({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.minDiscount,
    this.sort,
    this.showDeleted = false,
  });

  GuestQuery copyWith({
    int? page,
    int? perPage,
    String? search,
    double? minDiscount,
    String? sort,
    bool? showDeleted,
  }) {
    return GuestQuery(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      search: search ?? this.search,
      minDiscount: minDiscount ?? this.minDiscount,
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
    if (minDiscount != null) {
      params['minDiscount'] = '$minDiscount';
    }
    if (sort != null && sort!.isNotEmpty) {
      params['sort'] = sort!;
    }
    if (showDeleted) {
      params['showDeleted'] = 'true';
    }
    return params;
  }

  factory GuestQuery.fromQueryParams(Map<String, String> params) {
    return GuestQuery(
      page: int.tryParse(params['page'] ?? '') ?? 1,
      perPage: int.tryParse(params['perPage'] ?? '') ?? 10,
      search: params['search'],
      minDiscount: double.tryParse(params['minDiscount'] ?? ''),
      sort: params['sort'],
      showDeleted: params['showDeleted'] == 'true',
    );
  }
}
