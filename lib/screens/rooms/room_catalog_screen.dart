import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/breakpoints.dart';
import '../../models/room_query.dart';
import '../../state/room_list_notifier.dart';
import '../../state/room_type_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/search_field.dart';
import '../../widgets/states.dart';
import '../../widgets/status_badge.dart';

class RoomCatalogScreen extends StatefulWidget {
  const RoomCatalogScreen({super.key});

  @override
  State<RoomCatalogScreen> createState() => _RoomCatalogScreenState();
}

class _RoomCatalogScreenState extends State<RoomCatalogScreen> {
  DateTime _checkIn = DateTime.now();
  DateTime _checkOut = DateTime.now().add(const Duration(days: 2));
  String? _selectedTypeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomTypeListNotifier>().load();
      _applyFilter();
    });
  }

  void _applyFilter({String? search}) {
    final notifier = context.read<RoomListNotifier>();
    notifier.load(
      query: RoomQuery(
        search: search ?? notifier.query.search,
        roomTypeId: _selectedTypeId,
        checkInDate: _checkIn,
        checkOutDate: _checkOut,
        perPage: 20,
      ),
    );
  }

  Future<void> _selectDates() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _checkIn, end: _checkOut),
    );
    if (picked != null) {
      setState(() {
        _checkIn = picked.start;
        _checkOut = picked.end;
      });
      _applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomNotifier = context.watch<RoomListNotifier>();
    final typeNotifier = context.watch<RoomTypeListNotifier>();
    final theme = Theme.of(context);
    final isDesktop = Breakpoints.isExpanded(context);

    final dIn = '${_checkIn.day.toString().padLeft(2, '0')}.${_checkIn.month.toString().padLeft(2, '0')}';
    final dOut = '${_checkOut.day.toString().padLeft(2, '0')}.${_checkOut.month.toString().padLeft(2, '0')}';
    final nights = _checkOut.difference(_checkIn).inDays;

    return AppScaffold(
      title: 'Каталог свободных номеров',
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
                  width: 240,
                  child: SearchFieldWidget(
                    initialValue: roomNotifier.query.search,
                    hintText: 'Поиск номера или категории...',
                    onSearch: (s) => _applyFilter(search: s),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _selectDates,
                  icon: const Icon(Icons.date_range),
                  label: Text('Даты: $dIn — $dOut ($nights ноч.)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: DropdownButton<String?>(
                    value: _selectedTypeId,
                    hint: const Text('Все типы номеров'),
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Все типы номеров')),
                      ...typeNotifier.data.items.map((rt) => DropdownMenuItem(
                            value: rt.id,
                            child: Text('${rt.name} (${rt.basePrice.toStringAsFixed(0)} ₽/сут)'),
                          )),
                    ],
                    onChanged: (val) {
                      setState(() => _selectedTypeId = val);
                      _applyFilter();
                    },
                  ),
                ),
                if (_selectedTypeId != null || roomNotifier.query.search != null)
                  IconButton(
                    icon: const Icon(Icons.filter_alt_off),
                    tooltip: 'Сбросить фильтры',
                    onPressed: () {
                      setState(() => _selectedTypeId = null);
                      _applyFilter(search: '');
                    },
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: switch (roomNotifier.status) {
              _ when roomNotifier.isLoading => const LoadingState(message: 'Поиск доступных номеров на выбранные даты...'),
              _ when roomNotifier.isError => ErrorState(
                  error: roomNotifier.errorMessage ?? 'Ошибка загрузки номеров',
                  onRetry: () => _applyFilter(),
                ),
              _ when roomNotifier.isEmpty => EmptyState(
                  icon: Icons.hotel_class_outlined,
                  title: 'На выбранные даты нет свободных номеров',
                  subtitle: 'Попробуйте изменить даты заезда/выезда или сбросить фильтры.',
                  action: FilledButton(
                    onPressed: () {
                      setState(() {
                        _selectedTypeId = null;
                        _checkIn = DateTime.now();
                        _checkOut = DateTime.now().add(const Duration(days: 2));
                      });
                      _applyFilter(search: '');
                    },
                    child: const Text('Сбросить фильтры'),
                  ),
                ),
              _ => GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 3 : (Breakpoints.isMedium(context) ? 2 : 1),
                    childAspectRatio: 1.25,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: roomNotifier.data.items.length,
                  itemBuilder: (context, index) {
                    final room = roomNotifier.data.items[index];
                    final rt = room.roomType;
                    final pricePerNight = rt?.basePrice ?? 3000.0;
                    final totalStayPrice = pricePerNight * (nights <= 0 ? 1 : nights);

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 70,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.meeting_room, size: 28),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Номер ${room.number}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                  ],
                                ),
                                StatusBadge.room(room.status),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rt?.name ?? 'Стандарт',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Этаж: ${room.floor} • Вместимость: до ${rt?.capacity ?? 2} гостей',
                                    style: TextStyle(color: theme.colorScheme.outline, fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    rt?.description ?? 'Уютный светлый номер со всеми удобствами.',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${pricePerNight.toStringAsFixed(0)} ₽ / сутки',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo),
                                          ),
                                          Text(
                                            'За $nights ноч.: ${totalStayPrice.toStringAsFixed(0)} ₽',
                                            style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                                          ),
                                        ],
                                      ),
                                      FilledButton.icon(
                                        onPressed: () {
                                          final inStr = _checkIn.toIso8601String().substring(0, 10);
                                          final outStr = _checkOut.toIso8601String().substring(0, 10);
                                          context.go('/bookings/new?roomId=${room.id}&checkIn=$inStr&checkOut=$outStr');
                                        },
                                        icon: const Icon(Icons.bookmark_add, size: 16),
                                        label: const Text('Забронировать'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            },
          ),
        ],
      ),
    );
  }
}
