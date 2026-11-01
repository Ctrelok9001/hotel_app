import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/role.dart';
import '../../models/room.dart';
import '../../models/room_query.dart';
import '../../state/auth_notifier.dart';
import '../../state/room_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/pagination.dart';
import '../../widgets/search_field.dart';
import '../../widgets/states.dart';
import '../../widgets/status_badge.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFromUri();
    });
  }

  void _loadFromUri() {
    final uri = GoRouterState.of(context).uri;
    final query = RoomQuery.fromQueryParams(uri.queryParameters);
    context.read<RoomListNotifier>().load(query: query);
  }

  void _updateQuery(RoomQuery newQuery) {
    final params = newQuery.toQueryParams();
    context.go(Uri(path: '/rooms', queryParameters: params).toString());
    context.read<RoomListNotifier>().load(query: newQuery);
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<RoomListNotifier>();
    final auth = context.watch<AuthNotifier>();
    final canManage = auth.hasRole(Role.receptionist);
    final isManager = auth.hasRole(Role.manager);
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Управление номерным фондом',
      actions: [
        if (isManager)
          FilledButton.icon(
            onPressed: () => context.go('/rooms/new'),
            icon: const Icon(Icons.add),
            label: const Text('Добавить номер'),
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
                        hintText: 'Поиск номера комнаты или категории...',
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
                      child: DropdownButton<RoomStatus?>(
                        value: notifier.query.status,
                        hint: const Text('Все статусы'),
                        underline: const SizedBox(),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('Все статусы')),
                          ...RoomStatus.values.map((st) => DropdownMenuItem(
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
                if (notifier.selectedIds.isNotEmpty && isManager) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text('Выбрано номеров: ${notifier.selectedIds.length}'),
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
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                          icon: const Icon(Icons.delete_forever, size: 18),
                          label: const Text('Физическое удаление'),
                          onPressed: () => notifier.deleteSelected(hard: true),
                        ),
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
              _ when notifier.isLoading => const LoadingState(message: 'Загрузка номеров...'),
              _ when notifier.isError => ErrorState(
                  error: notifier.errorMessage ?? 'Ошибка загрузки номеров',
                  onRetry: () => notifier.load(),
                ),
              _ when notifier.isEmpty => EmptyState(
                  icon: Icons.meeting_room_outlined,
                  title: 'Номера не найдены',
                  subtitle: 'Попробуйте изменить параметры фильтрации или добавьте новый номер.',
                  action: isManager
                      ? FilledButton.icon(
                          onPressed: () => context.go('/rooms/new'),
                          icon: const Icon(Icons.add),
                          label: const Text('Добавить номер'),
                        )
                      : null,
                ),
              _ => Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: notifier.data.items.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final room = notifier.data.items[index];
                          final isSelected = notifier.selectedIds.contains(room.id);

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
                              leading: isManager
                                  ? Checkbox(
                                      value: isSelected,
                                      onChanged: (_) => notifier.toggleSelect(room.id),
                                    )
                                  : Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          room.number,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                              title: Row(
                                children: [
                                  Text(
                                    'Номер ${room.number}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '• Этаж ${room.floor} • ${room.roomType?.name ?? ""}',
                                    style: TextStyle(color: theme.colorScheme.outline, fontSize: 13),
                                  ),
                                  const Spacer(),
                                  StatusBadge.room(room.status),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Тариф: ${room.roomType?.basePrice.toStringAsFixed(0) ?? "0"} ₽/сут • Вместимость: ${room.roomType?.capacity ?? 1} чел.',
                                    ),
                                    if (room.notes.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Text('(${room.notes})', style: const TextStyle(fontStyle: FontStyle.italic)),
                                    ],
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (canManage && !room.isDeleted)
                                    PopupMenuButton<RoomStatus>(
                                      tooltip: 'Сменить статус номера',
                                      icon: const Icon(Icons.swap_horiz),
                                      onSelected: (newStatus) => notifier.updateRoomStatus(room.id, newStatus),
                                      itemBuilder: (ctx) => RoomStatus.values
                                          .map((st) => PopupMenuItem(
                                                value: st,
                                                child: Text(st.label),
                                              ))
                                          .toList(),
                                    ),
                                  if (isManager) ...[
                                    if (room.isDeleted)
                                      IconButton(
                                        icon: const Icon(Icons.restore, color: Colors.green),
                                        tooltip: 'Восстановить',
                                        onPressed: () => notifier.restore(room.id),
                                      )
                                    else ...[
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        tooltip: 'Редактировать',
                                        onPressed: () => context.go('/rooms/${room.id}/edit'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        tooltip: 'Удалить',
                                        onPressed: () => notifier.delete(room.id, hard: false),
                                      ),
                                    ],
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
