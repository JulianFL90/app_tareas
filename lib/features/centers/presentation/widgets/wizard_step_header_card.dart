import 'package:flutter/material.dart';

/// Header reutilizable para pantallas tipo wizard (Paso 1/2, 2/2, etc.).
/// Mantiene el estilo “pro” y evita duplicar código entre pantallas.
class WizardStepHeaderCard extends StatelessWidget {
  final IconData icon;
  final String stepLabel; // Ej: "Paso 1/2"
  final String title;     // Ej: "Crea tu centro"
  final String subtitle;  // Texto de ayuda (puede ser multilínea)

  const WizardStepHeaderCard({
    super.key,
    required this.icon,
    required this.stepLabel,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stepLabel, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
