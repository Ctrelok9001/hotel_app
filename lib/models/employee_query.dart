import 'employee.dart';

class EmployeeQuery {
  final int page;
  final int perPage;
  final String? search;
  final EmployeePosition? position;
  final String? shift;
  final String? sort;
  final bool showDeleted;

  const EmployeeQuery({
    this.page = 1,
    this.perPage = 10,
    this.search,
    this.position,
    this.shift,
    this.sort,
    this.showDeleted = false,
  });

  EmployeeQuery copyWith({
    int? page,
    int? perPage,
    String? search,
    EmployeePosition? position,
    bool clearPosition = false,
    String? shift,
    bool clearShift = false,
    String? sort,
    bool? showDeleted,
  }) {
    return EmployeeQuery(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      search: search ?? this.search,
      position: clearPosition ? null : (position ?? this.position),
      shift: clearShift ? null : (shift ?? this.shift),
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
    if (position != null) {
      params['position'] = position!.name;
    }
    if (shift != null && shift!.isNotEmpty) {
      params['shift'] = shift!;
    }
    if (sort != null && sort!.isNotEmpty) {
      params['sort'] = sort!;
    }
    if (showDeleted) {
      params['showDeleted'] = 'true';
    }
    return params;
  }

  factory EmployeeQuery.fromQueryParams(Map<String, String> params) {
    return EmployeeQuery(
      page: int.tryParse(params['page'] ?? '') ?? 1,
      perPage: int.tryParse(params['perPage'] ?? '') ?? 10,
      search: params['search'],
      position: params['position'] != null ? EmployeePosition.fromString(params['position']) : null,
      shift: params['shift'],
      sort: params['sort'],
      showDeleted: params['showDeleted'] == 'true',
    );
  }
}
