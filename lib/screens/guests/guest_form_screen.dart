import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_exceptions.dart';
import '../../core/validators.dart';
import '../../models/guest.dart';
import '../../models/passport.dart';
import '../../repositories/guest_repository.dart';
import '../../state/guest_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/states.dart';

class GuestFormScreen extends StatefulWidget {
  final String? guestId;
  const GuestFormScreen({super.key, this.guestId});

  @override
  State<GuestFormScreen> createState() => _GuestFormScreenState();
}

class _GuestFormScreenState extends State<GuestFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  final _passSeriesController = TextEditingController();
  final _passNumberController = TextEditingController();
  final _passIssuedByController = TextEditingController();
  final _passAddressController = TextEditingController();
  DateTime? _passIssueDate = DateTime(2018, 1, 1);

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
    _discountController.dispose();
    _notesController.dispose();
    _passSeriesController.dispose();
    _passNumberController.dispose();
    _passIssuedByController.dispose();
    _passAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.guestId == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final repo = context.read<GuestRepository>();
      final item = await repo.getById(widget.guestId!);
      _nameController.text = item.fullName;
      _phoneController.text = item.phone;
      _emailController.text = item.email;
      _discountController.text = item.discountPercent.toStringAsFixed(0);
      _notesController.text = item.notes;

      final p = item.passport;
      if (p != null) {
        _passSeriesController.text = p.series;
        _passNumberController.text = p.number;
        _passIssuedByController.text = p.issuedBy;
        _passAddressController.text = p.registrationAddress;
        _passIssueDate = p.issueDate;
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
      final repo = context.read<GuestRepository>();

      Passport? passport;
      if (_passSeriesController.text.isNotEmpty || _passNumberController.text.isNotEmpty) {
        passport = Passport(
          id: 'pass_${widget.guestId ?? DateTime.now().millisecondsSinceEpoch}',
          guestId: widget.guestId ?? '',
          series: _passSeriesController.text.trim(),
          number: _passNumberController.text.trim(),
          issuedBy: _passIssuedByController.text.trim(),
          issueDate: _passIssueDate,
          registrationAddress: _passAddressController.text.trim(),
        );
      }

      final item = Guest(
        id: widget.guestId ?? '',
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        discountPercent: double.tryParse(_discountController.text.trim()) ?? 0.0,
        notes: _notesController.text.trim(),
        passport: passport,
      );

      if (widget.guestId != null) {
        await repo.update(widget.guestId!, item);
      } else {
        await repo.create(item);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Данные гостя успешно сохранены!')),
        );
        context.read<GuestListNotifier>().load();
        context.go('/guests');
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
      title: widget.guestId != null ? 'Редактировать гостя' : 'Новый гость отеля',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Form(
              key: _formKey,
              child: Column(
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

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1. Основные контакты гостя', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'ФИО гостя',
                              prefixIcon: const Icon(Icons.person),
                              border: const OutlineInputBorder(),
                              errorText: _fieldErrors['fullName'],
                            ),
                            validator: (v) => Validators.required(v, 'Введите ФИО'),
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
                                    labelText: 'Email',
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
                          TextFormField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Персональная скидка постоянного гостя (%)',
                              prefixIcon: Icon(Icons.percent),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => Validators.numberRange(v, 0, 100),
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
                          Text('2. Паспортные данные', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  controller: _passSeriesController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Серия (4 цифры)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _passNumberController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Номер (6 цифр)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passIssuedByController,
                            decoration: const InputDecoration(
                              labelText: 'Кем выдан',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passAddressController,
                            decoration: const InputDecoration(
                              labelText: 'Адрес регистрации',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(onPressed: () => context.go('/guests'), child: const Text('Отмена')),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Сохранить гостя'),
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
