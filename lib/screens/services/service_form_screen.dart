import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_exceptions.dart';
import '../../core/validators.dart';
import '../../models/service.dart';
import '../../repositories/service_repository.dart';
import '../../state/service_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/states.dart';

class ServiceFormScreen extends StatefulWidget {
  final String? serviceId;
  const ServiceFormScreen({super.key, this.serviceId});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

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
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.serviceId == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final repo = context.read<ServiceRepository>();
      final item = await repo.getById(widget.serviceId!);
      _nameController.text = item.name;
      _priceController.text = item.price.toStringAsFixed(0);
      _descController.text = item.description;
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
      final repo = context.read<ServiceRepository>();
      final item = Service(
        id: widget.serviceId ?? '',
        name: _nameController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0.0,
        description: _descController.text.trim(),
      );

      if (widget.serviceId != null) {
        await repo.update(widget.serviceId!, item);
      } else {
        await repo.create(item);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Услуга сохранена!')),
        );
        context.read<ServiceListNotifier>().load();
        context.go('/services');
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
      title: widget.serviceId != null ? 'Редактировать услугу' : 'Новая услуга отеля',
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
                          labelText: 'Название услуги',
                          hintText: 'Завтрак "Шведский стол", СПА, Трансфер...',
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['name'],
                        ),
                        validator: (v) => Validators.required(v, 'Введите название'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Стоимость (₽)',
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['price'],
                        ),
                        validator: (v) => Validators.nonNegativeNumber(v, 'Стоимость не может быть отрицательной'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Описание услуги',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(onPressed: () => context.go('/services'), child: const Text('Отмена')),
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
