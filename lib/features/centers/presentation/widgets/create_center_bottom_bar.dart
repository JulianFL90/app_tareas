import 'package:flutter/material.dart';

class CreateCenterBottomBar extends StatelessWidget {
  final bool canSubmit;
  final bool saving;
  final VoidCallback onSubmit;

  const CreateCenterBottomBar({
    super.key,
    required this.canSubmit,
    required this.saving,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canSubmit ? onSubmit : null,
                icon: saving
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.check_rounded),
                label: Text(saving ? 'Creando...' : 'Crear centro'),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Versión gratuita: 1 centro. Premium: centros ilimitados + copias de seguridad.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
