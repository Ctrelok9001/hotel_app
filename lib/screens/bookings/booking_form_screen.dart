import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_exceptions.dart';
import '../../core/validators.dart';
import '../../models/booking.dart';
import '../../models/guest.dart';
import '../../models/guest_query.dart';
import '../../models/role.dart';
import '../../models/room.dart';
import '../../models/room_query.dart';
import '../../models/service.dart';
import '../../models/service_query.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/guest_repository.dart';
import '../../repositories/room_repository.dart';
import '../../repositories/service_repository.dart';
import '../../state/auth_notifier.dart';
import '../../state/booking_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/multi_select_field.dart';
import '../../widgets/states.dart';

class BookingFormScreen extends StatefulWidget {
  final String? bookingId;
  final String? initialRoomId;
  final DateTime? initialCheckIn;
  final DateTime? initialCheckOut;

  const BookingFormScreen({
    super.key,
    this.bookingId,
    this.initialRoomId,
    this.initialCheckIn,
    this.initialCheckOut,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _serverError;
  Map<String, String> _fieldErrors = {};

  List<Room> _rooms = [];
  List<Guest> _guests = [];
  List<Service> _allServices = [];

  String? _selectedRoomId;
  String? _selectedGuestId;
  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 2));
  BookingStatus _status = BookingStatus.pending;
  List<Service> _selectedServices = [];
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkInDate = widget.initialCheckIn ?? DateTime.now();
    _checkOutDate = widget.initialCheckOut ?? DateTime.now().add(const Duration(days: 2));
    _selectedRoomId = widget.initialRoomId;
    _loadFormData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    setState(() => _isLoading = true);
    try {
      final roomRepo = context.read<RoomRepository>();
      final guestRepo = context.read<GuestRepository>();
      final serviceRepo = context.read<ServiceRepository>();
      final bookingRepo = context.read<BookingRepository>();
      final auth = context.read<AuthNotifier>();

      final roomsRes = await roomRepo.getAll(const RoomQuery(perPage: 100));
      final guestsRes = await guestRepo.getAll(const GuestQuery(perPage: 100));
      final servicesRes = await serviceRepo.getAll(const ServiceQuery(perPage: 100));

      _rooms = roomsRes.items;
      _guests = guestsRes.items;
      _allServices = servicesRes.items;

      if (widget.bookingId != null && widget.bookingId!.isNotEmpty) {
        final b = await bookingRepo.getById(widget.bookingId!);
        _selectedRoomId = b.roomId;
        _selectedGuestId = b.guestId;
        _checkInDate = b.checkInDate;
        _checkOutDate = b.checkOutDate;
        _status = b.status;
        _notesController.text = b.notes;
        _selectedServices = _allServices.where((s) => b.serviceIds.contains(s.id)).toList();
      } else {
        if (auth.currentRole == Role.guest && auth.user?.guestId != null) {
          _selectedGuestId = auth.user!.guestId;
        } else if (_guests.isNotEmpty && _selectedGuestId == null) {
          _selectedGuestId = _guests.first.id;
        }
        if (_selectedRoomId == null && _rooms.isNotEmpty) {
          _selectedRoomId = _rooms.first.id;
        }
      }
    } catch (e) {
      _serverError = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _calculateCurrentTotal() {
    final room = _rooms.cast<Room?>().firstWhere((r) => r?.id == _selectedRoomId, orElse: () => null);
    final guest = _guests.cast<Guest?>().firstWhere((g) => g?.id == _selectedGuestId, orElse: () => null);
    final basePrice = room?.roomType?.basePrice ?? 3000.0;
    final discount = guest?.discountPercent ?? 0.0;

    return Booking.calculateTotal(
      roomPricePerNight: basePrice,
      checkIn: _checkInDate,
      checkOut: _checkOutDate,
      discountPercent: discount,
      services: _selectedServices,
    );
  }

  Future<void> _pickDates() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _checkInDate, end: _checkOutDate),
    );
    if (picked != null) {
      setState(() {
        _checkInDate = picked.start;
        _checkOutDate = picked.end;
        _fieldErrors.remove('checkOutDate');
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final dateErr = Validators.dateOrder(_checkInDate, _checkOutDate);
    if (dateErr != null) {
      setState(() => _fieldErrors['checkOutDate'] = dateErr);
      return;
    }

    setState(() {
      _isSaving = true;
      _serverError = null;
      _fieldErrors = {};
    });

    try {
      final bookingRepo = context.read<BookingRepository>();
      final item = Booking(
        id: widget.bookingId ?? '',
        guestId: _selectedGuestId ?? '',
        roomId: _selectedRoomId ?? '',
        checkInDate: _checkInDate,
        checkOutDate: _checkOutDate,
        status: _status,
        serviceIds: _selectedServices.map((s) => s.id).toList(),
        services: _selectedServices,
        notes: _notesController.text.trim(),
      );

      if (widget.bookingId != null && widget.bookingId!.isNotEmpty) {
        await bookingRepo.update(widget.bookingId!, item);
      } else {
        await bookingRepo.create(item);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Бронирование успешно сохранено!')),
        );
        context.read<BookingListNotifier>().load();
        context.go('/bookings');
      }
    } on ConflictException catch (e) {
      setState(() {
        _serverError = e.message;
      });
    } on ValidationException catch (e) {
      setState(() {
        _fieldErrors = e.errors;
        _serverError = e.message;
      });
    } catch (e) {
      setState(() => _serverError = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthNotifier>();
    final isGuestRole = auth.currentRole == Role.guest;

    if (_isLoading) {
      return const AppScaffold(
        title: 'Загрузка...',
        child: LoadingState(message: 'Загрузка параметров бронирования...'),
      );
    }

    final nights = _checkOutDate.difference(_checkInDate).inDays;
    final totalCost = _calculateCurrentTotal();
    final dIn = '${_checkInDate.day.toString().padLeft(2, '0')}.${_checkInDate.month.toString().padLeft(2, '0')}.${_checkInDate.year}';
    final dOut = '${_checkOutDate.day.toString().padLeft(2, '0')}.${_checkOutDate.month.toString().padLeft(2, '0')}.${_checkOutDate.year}';

    return AppScaffold(
      title: widget.bookingId != null ? 'Редактирование бронирования' : 'Оформление бронирования',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_serverError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.error),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Конфликт бронирования (HTTP 409 Conflict):',
                                  style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _serverError!,
                                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1. Номер и даты проживания', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedRoomId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Номер отеля',
                              prefixIcon: const Icon(Icons.meeting_room),
                              border: const OutlineInputBorder(),
                              errorText: _fieldErrors['roomId'],
                            ),
                            items: _rooms.map((r) => DropdownMenuItem(
                              value: r.id,
                              child: Text('№ ${r.number} — ${r.roomType?.name ?? "Стандарт"} (${r.roomType?.basePrice.toStringAsFixed(0)} ₽/сут) [${r.status.label}]', overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: (val) => setState(() => _selectedRoomId = val),
                            validator: (v) => v == null ? 'Выберите номер' : null,
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _pickDates,
                            borderRadius: BorderRadius.circular(8),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Интервал дат (Заезд — Выезд)',
                                prefixIcon: const Icon(Icons.date_range),
                                border: const OutlineInputBorder(),
                                errorText: _fieldErrors['checkOutDate'],
                              ),
                              child: Text(
                                '$dIn — $dOut ($nights ${nights == 1 ? "ночь" : (nights < 5 ? "ночи" : "ночей")})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('2. Гость и статус бронирования', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedGuestId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Гость (постоялец)',
                              prefixIcon: const Icon(Icons.person),
                              border: const OutlineInputBorder(),
                              errorText: _fieldErrors['guestId'],
                            ),
                            items: _guests.map((g) => DropdownMenuItem(
                              value: g.id,
                              child: Text('${g.fullName} (${g.phone}) ${g.discountPercent > 0 ? "• Скидка ${g.discountPercent.toStringAsFixed(0)}%" : ""}', overflow: TextOverflow.ellipsis),
                            )).toList(),
                            onChanged: isGuestRole ? null : (val) => setState(() => _selectedGuestId = val),
                            validator: (v) => v == null ? 'Выберите гостя' : null,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<BookingStatus>(
                            value: _status,
                            decoration: const InputDecoration(
                              labelText: 'Статус бронирования',
                              prefixIcon: Icon(Icons.flag),
                              border: OutlineInputBorder(),
                            ),
                            items: BookingStatus.values.map((st) => DropdownMenuItem(
                              value: st,
                              child: Text(st.label),
                            )).toList(),
                            onChanged: isGuestRole ? null : (val) => setState(() => _status = val ?? _status),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('3. Дополнительные услуги', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          MultiSelectField<Service>(
                            label: 'Выберите услуги, которые хотите включить в счет:',
                            items: _allServices,
                            selectedItems: _selectedServices,
                            itemLabel: (s) => '${s.name} (+${s.price.toStringAsFixed(0)} ₽)',
                            itemSubtitle: (s) => s.description,
                            onChanged: (updated) => setState(() => _selectedServices = updated),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Особые пожелания / Примечания',
                              hintText: 'Например: поздний заезд, высокий этаж, детская кроватка',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Расчет стоимости:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Проживание: $nights ноч. • Услуг: ${_selectedServices.length}',
                              style: TextStyle(color: theme.colorScheme.outline, fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          '${totalCost.toStringAsFixed(0)} ₽',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.go('/bookings'),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                        child: const Text('Отмена'),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _save,
                        icon: _isSaving
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.check),
                        label: Text(
                          widget.bookingId != null ? 'Сохранить изменения' : 'Подтвердить бронирование',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
