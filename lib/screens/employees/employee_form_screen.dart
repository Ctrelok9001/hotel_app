import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_exceptions.dart';
import '../../core/validators.dart';
import '../../models/employee.dart';
import '../../repositories/employee_repository.dart';
import '../../state/employee_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/states.dart';

class EmployeeFormScreen extends StatefulWidget {
  final String? employeeId;
  const EmployeeFormScreen({super.key, this.employeeId});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _shiftController = TextEditingController(text: 'Дневная');
  final _salaryController = TextEditingController();

  EmployeePosition _position = EmployeePosition.receptionist;
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
    _phoneController.dispose();
    _emailController.dispose();
    _shiftController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.employeeId == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final repo = context.read<EmployeeRepository>();
      final item = await repo.getById(widget.employeeId!);
      _nameController.text = item.fullName;
      _phoneController.text = item.phone;
      _emailController.text = item.email;
      _shiftController.text = item.shift;
      _salaryController.text = item.salary.toStringAsFixed(0);
      _position = item.position;
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
      final repo = context.read<EmployeeRepository>();
      final item = Employee(
        id: widget.employeeId ?? '',
        fullName: _nameController.text.trim(),
        position: _position,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        shift: _shiftController.text.trim(),
        salary: double.tryParse(_salaryController.text.trim()) ?? 0.0,
      );

      if (widget.employeeId != null) {
        await repo.update(widget.employeeId!, item);
      } else {
        await repo.create(item);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Сотрудник сохранен!')),
        );
        context.read<EmployeeListNotifier>().load();
        context.go('/employees');
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
      title: widget.employeeId != null ? 'Редактировать сотрудника' : 'Принять сотрудника в штат',
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
                          labelText: 'ФИО сотрудника',
                          prefixIcon: const Icon(Icons.person),
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['fullName'],
                        ),
                        validator: (v) => Validators.required(v, 'Введите ФИО'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<EmployeePosition>(
                        value: _position,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Должность',
                          prefixIcon: Icon(Icons.work),
                          border: OutlineInputBorder(),
                        ),
                        items: EmployeePosition.values.map((pos) => DropdownMenuItem(
                          value: pos,
                          child: Text(pos.label),
                        )).toList(),
                        onChanged: (val) => setState(() => _position = val ?? _position),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: 'Телефон',
                                prefixIcon: const Icon(Icons.phone),
                                border: const OutlineInputBorder(),
                                errorText: _fieldErrors['phone'],
                              ),
                              validator: (v) => Validators.phone(v),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Рабочий email',
                                prefixIcon: const Icon(Icons.email),
                                border: const OutlineInputBorder(),
                                errorText: _fieldErrors['email'],
                              ),
                              validator: (v) => Validators.email(v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _shiftController,
                              decoration: const InputDecoration(
                                labelText: 'График смены (например, 2/2)',
                                prefixIcon: Icon(Icons.schedule),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _salaryController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Оклад (₽/мес)',
                                prefixIcon: const Icon(Icons.monetization_on),
                                border: const OutlineInputBorder(),
                                errorText: _fieldErrors['salary'],
                              ),
                              validator: (v) => Validators.positiveNumber(v, 'Укажите оклад'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton(onPressed: () => context.go('/employees'), child: const Text('Отмена')),
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
