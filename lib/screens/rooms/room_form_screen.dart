import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_exceptions.dart';
import '../../core/validators.dart';
import '../../models/room.dart';
import '../../models/room_type.dart';
import '../../models/room_type_query.dart';
import '../../repositories/room_repository.dart';
import '../../repositories/room_type_repository.dart';
import '../../state/room_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/states.dart';

class RoomFormScreen extends StatefulWidget {
  final String? roomId;
  const RoomFormScreen({super.key, this.roomId});

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _floorController = TextEditingController(text: '1');
  final _notesController = TextEditingController();

  String? _selectedTypeId;
  RoomStatus _status = RoomStatus.available;
  List<RoomType> _roomTypes = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _serverError;
  Map<String, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _numberController.dispose();
    _floorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final rtRepo = context.read<RoomTypeRepository>();
      final rRepo = context.read<RoomRepository>();
      final rtRes = await rtRepo.getAll(const RoomTypeQuery(perPage: 100));
      _roomTypes = rtRes.items;

      if (widget.roomId != null && widget.roomId!.isNotEmpty) {
        final room = await rRepo.getById(widget.roomId!);
        _numberController.text = room.number;
        _floorController.text = room.floor.toString();
        _notesController.text = room.notes;
        _selectedTypeId = room.roomTypeId;
        _status = room.status;
      } else {
        if (_roomTypes.isNotEmpty) {
          _selectedTypeId = _roomTypes.first.id;
        }
      }
    } catch (e) {
      _serverError = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _serverError = null;
      _fieldErrors = {};
    });

    try {
      final repo = context.read<RoomRepository>();
      final room = Room(
        id: widget.roomId ?? '',
        number: _numberController.text.trim(),
        floor: int.tryParse(_floorController.text.trim()) ?? 1,
        roomTypeId: _selectedTypeId ?? '',
        status: _status,
        notes: _notesController.text.trim(),
      );

      if (widget.roomId != null && widget.roomId!.isNotEmpty) {
        await repo.update(widget.roomId!, room);
      } else {
        await repo.create(room);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Номер успешно сохранен!')),
        );
        context.read<RoomListNotifier>().load();
        context.go('/rooms');
      }
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

    if (_isLoading) {
      return const AppScaffold(
        title: 'Загрузка...',
        child: LoadingState(message: 'Загрузка параметров номера...'),
      );
    }

    return AppScaffold(
      title: widget.roomId != null ? 'Редактировать номер' : 'Новый номер отеля',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_serverError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_serverError!, style: TextStyle(color: theme.colorScheme.error)),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _numberController,
                        decoration: InputDecoration(
                          labelText: 'Номер комнаты',
                          hintText: '101, 204, 305...',
                          prefixIcon: const Icon(Icons.numbers),
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['number'],
                        ),
                        validator: (v) => Validators.required(v, 'Введите номер комнаты'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _floorController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Этаж',
                          prefixIcon: const Icon(Icons.stairs),
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['floor'],
                        ),
                        validator: (v) => Validators.numberRange(v, 1, 100, 'Этаж должен быть от 1 до 100'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedTypeId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Тип (категория) номера',
                          prefixIcon: const Icon(Icons.category),
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['roomTypeId'],
                        ),
                        items: _roomTypes.map((rt) => DropdownMenuItem(
                          value: rt.id,
                          child: Text('${rt.name} (${rt.basePrice.toStringAsFixed(0)} ₽/сут)', overflow: TextOverflow.ellipsis),
                        )).toList(),
                        onChanged: (val) => setState(() => _selectedTypeId = val),
                        validator: (v) => v == null ? 'Выберите тип номера' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<RoomStatus>(
                        value: _status,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Текущий статус',
                          prefixIcon: Icon(Icons.flag),
                          border: OutlineInputBorder(),
                        ),
                        items: RoomStatus.values.map((st) => DropdownMenuItem(
                          value: st,
                          child: Text(st.label),
                        )).toList(),
                        onChanged: (val) => setState(() => _status = val ?? _status),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Примечания / Особенности',
                          hintText: 'Вид на бассейн, тихая сторона и т.д.',
                          prefixIcon: Icon(Icons.note),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => context.go('/rooms'),
                            child: const Text('Отмена'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: _isSaving ? null : _save,
                            child: _isSaving
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Сохранить номер'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
