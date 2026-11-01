class RoomTypeQuery {
  final int page;
  final int perPage;
  final String? search;
  final int? minCapacity;
  final double? maxPrice;
  final String? sort;
  final bool showDeleted;

  const RoomTypeQuery({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.minCapacity,
    this.maxPrice,
    this.sort,
    this.showDeleted = false,
  });

  RoomTypeQuery copyWith({
    int? page,
    int? perPage,
    String? search,
    int? minCapacity,
    double? maxPrice,
    String? sort,
    bool? showDeleted,
  }) {
    return RoomTypeQuery(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      search: search ?? this.search,
      minCapacity: minCapacity ?? this.minCapacity,
      maxPrice: maxPrice ?? this.maxPrice,
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
    if (minCapacity != null) {
      params['minCapacity'] = '$minCapacity';
    }
    if (maxPrice != null) {
      params['maxPrice'] = '$maxPrice';
    }
    if (sort != null && sort!.isNotEmpty) {
      params['sort'] = sort!;
    }
    if (showDeleted) {
      params['showDeleted'] = 'true';
    }
    return params;
  }

  factory RoomTypeQuery.fromQueryParams(Map<String, String> params) {
    return RoomTypeQuery(
      page: int.tryParse(params['page'] ?? '') ?? 1,
      perPage: int.tryParse(params['perPage'] ?? '') ?? 10,
      search: params['search'],
      minCapacity: int.tryParse(params['minCapacity'] ?? ''),
      maxPrice: double.tryParse(params['maxPrice'] ?? ''),
      sort: params['sort'],
      showDeleted: params['showDeleted'] == 'true',
    );
  }
}
