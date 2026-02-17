import 'package:flutter/material.dart';

class CreateCenterFormCard extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final bool saving;
  final VoidCallback onChanged;
  final VoidCallback? onSubmitted;
  final int currentLength;

  const CreateCenterFormCard({
    super.key,
    required this.controller,
    required this.errorText,
    required this.saving,
    required this.onChanged,
    required this.onSubmitted,
    required this.currentLength,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ok = errorText == null && controller.text.trim().length >= 3;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre del centro',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              enabled: !saving,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_city_rounded),
                hintText: 'Ej: ZAL BCN',
                errorText: errorText,
                helperText: errorText == null
                    ? 'Usa un nombre corto y reconocible (mín. 3 caracteres).'
                    : null,
              ),
              onChanged: (_) => onChanged(),
              onSubmitted: (_) => onSubmitted?.call(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    ok ? Icons.check_circle_rounded : Icons.info_rounded,
                    size: 20,
                    color: ok
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ok ? 'Nombre válido' : 'Mínimo 3 caracteres',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '$currentLength',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
