import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_exceptions.dart';
import '../../core/validators.dart';
import '../../models/booking.dart';
import '../../models/booking_query.dart';
import '../../models/payment.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/payment_repository.dart';
import '../../state/payment_list_notifier.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/states.dart';

class PaymentFormScreen extends StatefulWidget {
  final String? bookingId;
  const PaymentFormScreen({super.key, this.bookingId});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _guestNameController = TextEditingController();

  PaymentMethod _method = PaymentMethod.card;
  List<Booking> _bookings = [];
  String? _selectedBookingId;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _serverError;
  Map<String, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _selectedBookingId = widget.bookingId;
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _guestNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final bRepo = context.read<BookingRepository>();
      final res = await bRepo.getAll(const BookingQuery(perPage: 100));
      _bookings = res.items;

      if (_selectedBookingId != null) {
        final b = _bookings.cast<Booking?>().firstWhere((e) => e?.id == _selectedBookingId, orElse: () => null);
        if (b != null) {
          _amountController.text = b.totalPrice.toStringAsFixed(0);
          _guestNameController.text = b.guest?.fullName ?? '';
        }
      } else if (_bookings.isNotEmpty) {
        _selectedBookingId = _bookings.first.id;
        _amountController.text = _bookings.first.totalPrice.toStringAsFixed(0);
        _guestNameController.text = _bookings.first.guest?.fullName ?? '';
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
      final repo = context.read<PaymentRepository>();
      final item = Payment(
        id: '',
        bookingId: _selectedBookingId ?? '',
        guestName: _guestNameController.text.trim(),
        amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
        method: _method,
        createdAt: DateTime.now(),
      );

      await repo.create(item);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Оплата успешно проведена!')),
        );
        context.read<PaymentListNotifier>().load();
        context.go('/payments');
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
      title: 'Прием оплаты от гостя',
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_serverError != null) ...[
                        Text(_serverError!, style: TextStyle(color: theme.colorScheme.error)),
                        const SizedBox(height: 12),
                      ],
                      DropdownButtonFormField<String>(
                        value: _selectedBookingId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Бронирование',
                          prefixIcon: Icon(Icons.bookmark),
                          border: OutlineInputBorder(),
                        ),
                        items: _bookings.map((b) => DropdownMenuItem(
                          value: b.id,
                          child: Text(
                            'Бронь #${b.id} — ${b.guest?.fullName ?? "Гость"} (${b.room?.number ?? "№"}) [${b.totalPrice.toStringAsFixed(0)} ₽]',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedBookingId = val;
                            final b = _bookings.firstWhere((e) => e.id == val);
                            _amountController.text = b.totalPrice.toStringAsFixed(0);
                            _guestNameController.text = b.guest?.fullName ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _guestNameController,
                        decoration: const InputDecoration(
                          labelText: 'Имя плательщика (гостя)',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => Validators.required(v, 'Укажите имя плательщика'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Сумма к оплате (₽)',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: const OutlineInputBorder(),
                          errorText: _fieldErrors['amount'],
                        ),
                        validator: (v) => Validators.positiveNumber(v, 'Укажите сумму оплаты'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<PaymentMethod>(
                        value: _method,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Способ проведения платежа',
                          prefixIcon: Icon(Icons.credit_card),
                          border: OutlineInputBorder(),
                        ),
                        items: PaymentMethod.values.map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.label, overflow: TextOverflow.ellipsis),
                        )).toList(),
                        onChanged: (val) => setState(() => _method = val ?? _method),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          OutlinedButton(onPressed: () => context.go('/payments'), child: const Text('Отмена')),
                          FilledButton(
                            onPressed: _isSaving ? null : _save,
                            child: _isSaving
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Провести платеж'),
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
