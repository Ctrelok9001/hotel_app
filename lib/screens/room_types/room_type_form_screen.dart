import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_exceptions.dart';
import '../../core/validators.dart';
import '../../models/room_type.dart';
import '../../repositories/room_type_repository.dart';
import '../../state/room_type_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/states.dart';

class RoomTypeFormScreen extends StatefulWidget {
  final String? typeId;
  const RoomTypeFormScreen({super.key, this.typeId});

  @override
  State<RoomTypeFormScreen> createState() => _RoomTypeFormScreenState();
}

class _RoomTypeFormScreenState extends State<RoomTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController(text: '2');
  final _amenitiesController = TextEditingController();

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
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _amenitiesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.typeId == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final repo = context.read<RoomTypeRepository>();
      final item = await repo.getById(widget.typeId!);
      _nameController.text = item.name;
      _descController.text = item.description;
      _priceController.text = item.basePrice.toStringAsFixed(0);
      _capacityController.text = item.capacity.toString();
      _amenitiesController.text = item.amenities.join(', ');
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
      final repo = context.read<RoomTypeRepository>();
      final amenities = _amenitiesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final item = RoomType(
        id: widget.typeId ?? '',
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        basePrice: double.tryParse(_priceController.text.trim()) ?? 0.0,
        capacity: int.tryParse(_capacityController.text.trim()) ?? 2,
        amenities: amenities,
      );

      if (widget.typeId != null) {
        await repo.update(widget.typeId!, item);
      } else {
        await repo.create(item);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Категория номера сохранена!')),
        );
        context.read<RoomTypeListNotifier>().load();
        context.go('/room-types');
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
      return const AppScaffold(title: 'Загрузка...', child: LoadingState());
    }

    return AppScaffold(
      title: widget.typeId != null ? 'Редактировать категорию' : 'Новая категория номеров',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_serverError != null) ...[
                        Text(_serverError!, style: TextStyle(color: theme.colorScheme.error)),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Название категории',
                          hintText: 'Люкс, Делюкс, Стандарт...',
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['name'],
                        ),
                        validator: (v) => Validators.required(v, 'Введите название'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Описание',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Базовый тариф (₽/сут)',
                                border: const OutlineInputBorder(),
                                errorText: _fieldErrors['basePrice'],
                              ),
                              validator: (v) => Validators.positiveNumber(v, 'Укажите положительную цену'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _capacityController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Вместимость (чел)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => Validators.numberRange(v, 1, 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amenitiesController,
                        decoration: const InputDecoration(
                          labelText: 'Удобства (через запятую)',
                          hintText: 'Wi-Fi, Джакузи, Кондиционер, Сейф',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(onPressed: () => context.go('/room-types'), child: const Text('Отмена')),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: _isSaving ? null : _save,
                            child: _isSaving
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Сохранить'),
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
