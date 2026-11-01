import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../models/booking_query.dart';
import '../../models/role.dart';
import '../../state/auth_notifier.dart';
import '../../state/booking_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/pagination.dart';
import '../../widgets/search_field.dart';
import '../../widgets/states.dart';
import '../../widgets/status_badge.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFromUri();
    });
  }

  void _loadFromUri() {
    final uri = GoRouterState.of(context).uri;
    final query = BookingQuery.fromQueryParams(uri.queryParameters);
    final auth = context.read<AuthNotifier>();

    BookingQuery effectiveQuery = query;
    if (auth.currentRole == Role.guest && auth.user?.guestId != null) {
      effectiveQuery = query.copyWith(guestId: auth.user!.guestId);
    }
    context.read<BookingListNotifier>().load(query: effectiveQuery);
  }

  void _updateQuery(BookingQuery newQuery) {
    final params = newQuery.toQueryParams();
    context.go(Uri(path: '/bookings', queryParameters: params).toString());
    context.read<BookingListNotifier>().load(query: newQuery);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BookingListNotifier>();
    final auth = context.watch<AuthNotifier>();
    final canManage = auth.hasRole(Role.receptionist);
    final canHardDelete = auth.hasRole(Role.manager);
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Управление бронированиями',
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('/bookings/new'),
          icon: const Icon(Icons.add),
          label: const Text('Новая бронь'),
        ),
      ],
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Column(
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 280,
                      child: SearchFieldWidget(
                        initialValue: notifier.query.search,
                        hintText: 'Поиск по номеру комнаты или имени гостя...',
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
                      child: DropdownButton<BookingStatus?>(
                        value: notifier.query.status,
                        hint: const Text('Все статусы'),
                        underline: const SizedBox(),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Все статусы')),
                          ...BookingStatus.values.map((st) => DropdownMenuItem(
                                value: st,
                                child: Text(st.label),
                              )),
                        ],
                        onChanged: (val) => _updateQuery(
                          notifier.query.copyWith(
                            status: val,
                            clearStatus: val == null,
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
                if (notifier.selectedIds.isNotEmpty && canManage) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text('Выбрано: ${notifier.selectedIds.length}'),
                        const Spacer(),
                        TextButton(
                          onPressed: () => notifier.clearSelection(),
                          child: const Text('Снять выделение'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonalIcon(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Логическое удаление'),
                          onPressed: () => notifier.deleteSelected(hard: false),
                        ),
                        if (canHardDelete) ...[
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                            icon: const Icon(Icons.delete_forever, size: 18),
                            label: const Text('Физическое удаление'),
                            onPressed: () => notifier.deleteSelected(hard: true),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: switch (notifier.status) {
              _ when notifier.isLoading => const LoadingState(message: 'Загрузка списка бронирований...'),
              _ when notifier.isError => ErrorState(
                  error: notifier.errorMessage ?? 'Ошибка загрузки',
                  onRetry: () => notifier.load(),
                ),
              _ when notifier.isEmpty => EmptyState(
                  icon: Icons.event_busy_outlined,
                  title: 'Бронирования не найдены',
                  subtitle: 'Попробуйте изменить параметры поиска или создайте новое бронирование.',
                  action: FilledButton.icon(
                    onPressed: () => context.go('/bookings/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Забронировать номер'),
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
                          final isSelected = notifier.selectedIds.contains(item.id);
                          final cIn = '${item.checkInDate.day.toString().padLeft(2, '0')}.${item.checkInDate.month.toString().padLeft(2, '0')}.${item.checkInDate.year}';
                          final cOut = '${item.checkOutDate.day.toString().padLeft(2, '0')}.${item.checkOutDate.month.toString().padLeft(2, '0')}.${item.checkOutDate.year}';

                          return Card(
                            elevation: isSelected ? 3 : 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              leading: canManage
                                  ? Checkbox(
                                      value: isSelected,
                                      onChanged: (_) => notifier.toggleSelect(item.id),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: theme.colorScheme.primaryContainer,
                                      child: const Icon(Icons.hotel),
                                    ),
                              title: Row(
                                children: [
                                  Text(
                                    'Номер ${item.room?.number ?? "—"}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${item.room?.roomType?.name ?? ""})',
                                    style: TextStyle(color: theme.colorScheme.outline, fontSize: 13),
                                  ),
                                  const Spacer(),
                                  StatusBadge.booking(item.status),
                                  if (item.isDeleted) ...[
                                    const SizedBox(width: 6),
                                    const Chip(label: Text('УДАЛЕНО', style: TextStyle(color: Colors.red, fontSize: 10))),
                                  ],
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Гость: ${item.guest?.fullName ?? "—"} • Тел: ${item.guest?.phone ?? "—"}'),
                                    const SizedBox(height: 2),
                                    Text('Период: $cIn — $cOut (${item.nights} ноч.) • Итого: ${item.totalPrice.toStringAsFixed(0)} ₽'),
                                    if (item.services.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Wrap(
                                          spacing: 6,
                                          children: item.services.map((s) => Chip(
                                            label: Text(s.name, style: const TextStyle(fontSize: 10)),
                                            padding: EdgeInsets.zero,
                                            visualDensity: VisualDensity.compact,
                                          )).toList(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (item.isDeleted)
                                    IconButton(
                                      icon: const Icon(Icons.restore, color: Colors.green),
                                      tooltip: 'Восстановить запись',
                                      onPressed: () => notifier.restore(item.id),
                                    )
                                  else ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      tooltip: 'Редактировать',
                                      onPressed: () => context.go('/bookings/${item.id}/edit'),
                                    ),
                                    if (canManage)
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        tooltip: 'Логическое удаление',
                                        onPressed: () => notifier.delete(item.id, hard: false),
                                      ),
                                  ],
                                ],
                              ),
                              onTap: () => context.go('/bookings/${item.id}/edit'),
                            ),
                          );
                        },
                      ),
                    ),
                    PaginationWidget(
                      currentPage: notifier.data.page,
                      totalPages: notifier.data.totalPages,
                      totalItems: notifier.data.totalItems,
                      onPageChanged: (page) => _updateQuery(notifier.query.copyWith(page: page)),
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
