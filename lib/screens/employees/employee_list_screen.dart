import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/employee.dart';
import '../../models/employee_query.dart';
import '../../state/employee_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/pagination.dart';
import '../../widgets/search_field.dart';
import '../../widgets/states.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFromUri();
    });
  }

  void _loadFromUri() {
    final uri = GoRouterState.of(context).uri;
    final query = EmployeeQuery.fromQueryParams(uri.queryParameters);
    context.read<EmployeeListNotifier>().load(query: query);
  }

  void _updateQuery(EmployeeQuery newQuery) {
    final params = newQuery.toQueryParams();
    context.go(Uri(path: '/employees', queryParameters: params).toString());
    context.read<EmployeeListNotifier>().load(query: newQuery);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<EmployeeListNotifier>();
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Штат сотрудников отеля',
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('/employees/new'),
          icon: const Icon(Icons.person_add),
          label: const Text('Принять сотрудника'),
        ),
      ],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 280,
                  child: SearchFieldWidget(
                    initialValue: notifier.query.search,
                    hintText: 'Поиск сотрудника по ФИО или email...',
                    onSearch: (s) => _updateQuery(notifier.query.copyWith(search: s, page: 1)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: DropdownButton<EmployeePosition?>(
                    value: notifier.query.position,
                    hint: const Text('Все должности'),
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Все должности')),
                      ...EmployeePosition.values.map((pos) => DropdownMenuItem(
                            value: pos,
                            child: Text(pos.label),
                          )),
                    ],
                    onChanged: (val) => _updateQuery(
                      notifier.query.copyWith(
                        position: val,
                        clearPosition: val == null,
                        page: 1,
                      ),
                    ),
                  ),
                ),
                FilterChip(
                  label: const Text('Удаленные'),
                  selected: notifier.query.showDeleted,
                  onSelected: (val) => _updateQuery(notifier.query.copyWith(showDeleted: val, page: 1)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: switch (notifier.status) {
              _ when notifier.isLoading => const LoadingState(message: 'Загрузка списка персонала...'),
              _ when notifier.isError => ErrorState(
                  error: notifier.errorMessage ?? 'Ошибка загрузки',
                  onRetry: () => notifier.load(),
                ),
              _ when notifier.isEmpty => EmptyState(
                  icon: Icons.badge_outlined,
                  title: 'Сотрудники не найдены',
                  action: FilledButton.icon(
                    onPressed: () => context.go('/employees/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Принять сотрудника'),
                  ),
                ),
              _ => Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: notifier.data.items.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = notifier.data.items[index];

                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primaryContainer,
                                child: const Icon(Icons.badge),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.fullName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text(item.position.label, style: const TextStyle(fontSize: 11)),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${item.salary.toStringAsFixed(0)} ₽/мес',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 15),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text('Смена: ${item.shift} • Тел: ${item.phone} • Email: ${item.email}'),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (item.isDeleted)
                                    IconButton(
                                      icon: const Icon(Icons.restore, color: Colors.green),
                                      onPressed: () => notifier.restore(item.id),
                                    )
                                  else ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () => context.go('/employees/${item.id}/edit'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => notifier.delete(item.id, hard: false),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    PaginationWidget(
                      currentPage: notifier.data.page,
                      totalPages: notifier.data.totalPages,
                      totalItems: notifier.data.totalItems,
                      onPageChanged: (p) => _updateQuery(notifier.query.copyWith(page: p)),
                    ),
                  ],
                ),
            },
          ),
        ],
      ),
    );
  }
}
