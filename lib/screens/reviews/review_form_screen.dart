import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api_exceptions.dart';
import '../../core/validators.dart';
import '../../models/review.dart';
import '../../repositories/review_repository.dart';
import '../../state/auth_notifier.dart';
import '../../state/review_list_notifier.dart';
import '../../widgets/app_scaffold.dart';

class ReviewFormScreen extends StatefulWidget {
  const ReviewFormScreen({super.key});

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isSaving = false;
  String? _serverError;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _serverError = null;
    });

    try {
      final auth = context.read<AuthNotifier>();
      final repo = context.read<ReviewRepository>();

      final item = Review(
        id: '',
        guestId: auth.user?.guestId ?? 'gst_guest',
        guestName: auth.user?.name ?? 'Гость отеля',
        rating: _rating,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      await repo.create(item);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Спасибо! Ваш отзыв опубликован.')),
        );
        context.read<ReviewListNotifier>().load();
        context.go('/reviews');
      }
    } on ValidationException catch (e) {
      setState(() => _serverError = e.message);
    } catch (e) {
      setState(() => _serverError = e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Оставить отзыв об отеле',
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
                      const Text('Оцените ваше пребывание:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          return IconButton(
                            iconSize: 36,
                            icon: Icon(
                              starIndex <= _rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () => setState(() => _rating = starIndex),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Ваш отзыв',
                          hintText: 'Поделитесь впечатлениями о сервисе, номере, питании...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => Validators.required(v, 'Напишите текст отзыва'),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(onPressed: () => context.go('/reviews'), child: const Text('Отмена')),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: _isSaving ? null : _save,
                            child: _isSaving
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Опубликовать отзыв'),
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
