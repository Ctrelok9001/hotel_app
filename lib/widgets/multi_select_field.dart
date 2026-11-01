import 'package:flutter/material.dart';

class MultiSelectField<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T item) itemLabel;
  final String Function(T item)? itemSubtitle;
  final ValueChanged<List<T>> onChanged;
  final String? errorText;

  const MultiSelectField({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItems,
    required this.itemLabel,
    this.itemSubtitle,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormField<List<T>>(
      initialValue: selectedItems,
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: errorText != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: items.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Нет доступных элементов для выбора'),
                    )
                  : Column(
                      children: items.map((item) {
                        final isSelected = selectedItems.contains(item);
                        return CheckboxListTile(
                          value: isSelected,
                          title: Text(itemLabel(item), style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: itemSubtitle != null ? Text(itemSubtitle!(item)) : null,
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (bool? checked) {
                            final updated = List<T>.from(selectedItems);
                            if (checked == true) {
                              updated.add(item);
                            } else {
                              updated.remove(item);
                            }
                            onChanged(updated);
                          },
                        );
                      }).toList(),
                    ),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 4),
              Text(
                errorText!,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
              ),
            ],
          ],
        );
      },
    );
  }
}
