class PageResult<T> {
  final int page;
  final int perPage;
  final int totalItems;
  final int totalPages;
  final List<T> items;

  const PageResult({
    required this.page,
    required this.perPage,
    required this.totalItems,
    required this.totalPages,
    required this.items,
  });

  factory PageResult.empty([int perPage = 10]) => PageResult(
        page: 1,
        perPage: perPage,
        totalItems: 0,
        totalPages: 0,
        items: const [],
      );

  factory PageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) itemFromJson,
  ) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(itemFromJson)
        .toList();
    final total = json['totalItems'] as int? ?? items.length;
    final perPage = json['perPage'] as int? ?? 10;
    final totalPages = json['totalPages'] as int? ??
        (total == 0 ? 0 : (total / perPage).ceil());

    return PageResult(
      page: json['page'] as int? ?? 1,
      perPage: perPage,
      totalItems: total,
      totalPages: totalPages,
      items: items,
    );
  }
}
