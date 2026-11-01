class ReviewQuery {
  final int page;
  final int perPage;
  final String? search;
  final int? minRating;
  final String? sort;
  final bool showDeleted;

  const ReviewQuery({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.minRating,
    this.sort,
    this.showDeleted = false,
  });

  ReviewQuery copyWith({
    int? page,
    int? perPage,
    String? search,
    int? minRating,
    String? sort,
    bool? showDeleted,
  }) {
    return ReviewQuery(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      search: search ?? this.search,
      minRating: minRating ?? this.minRating,
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
    if (minRating != null) {
      params['minRating'] = '$minRating';
    }
    if (sort != null && sort!.isNotEmpty) {
      params['sort'] = sort!;
    }
    if (showDeleted) {
      params['showDeleted'] = 'true';
    }
    return params;
  }

  factory ReviewQuery.fromQueryParams(Map<String, String> params) {
    return ReviewQuery(
      page: int.tryParse(params['page'] ?? '') ?? 1,
      perPage: int.tryParse(params['perPage'] ?? '') ?? 10,
      search: params['search'],
      minRating: int.tryParse(params['minRating'] ?? ''),
      sort: params['sort'],
      showDeleted: params['showDeleted'] == 'true',
    );
  }
}
