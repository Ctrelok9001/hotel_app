class ServiceQuery {
  final int page;
  final int perPage;
  final String? search;
  final double? maxPrice;
  final bool? isAvailable;
  final String? sort;
  final bool showDeleted;

  const ServiceQuery({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.maxPrice,
    this.isAvailable,
    this.sort,
    this.showDeleted = false,
  });

  ServiceQuery copyWith({
    int? page,
    int? perPage,
    String? search,
    double? maxPrice,
    bool? isAvailable,
    String? sort,
    bool? showDeleted,
  }) {
    return ServiceQuery(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      search: search ?? this.search,
      maxPrice: maxPrice ?? this.maxPrice,
      isAvailable: isAvailable ?? this.isAvailable,
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
    if (maxPrice != null) {
      params['maxPrice'] = '$maxPrice';
    }
    if (isAvailable != null) {
      params['isAvailable'] = '$isAvailable';
    }
    if (sort != null && sort!.isNotEmpty) {
      params['sort'] = sort!;
    }
    if (showDeleted) {
      params['showDeleted'] = 'true';
    }
    return params;
  }

  factory ServiceQuery.fromQueryParams(Map<String, String> params) {
    return ServiceQuery(
      page: int.tryParse(params['page'] ?? '') ?? 1,
      perPage: int.tryParse(params['perPage'] ?? '') ?? 10,
      search: params['search'],
      maxPrice: double.tryParse(params['maxPrice'] ?? ''),
      isAvailable: params['isAvailable'] != null ? params['isAvailable'] == 'true' : null,
      sort: params['sort'],
      showDeleted: params['showDeleted'] == 'true',
    );
  }
}
