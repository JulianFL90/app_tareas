// lib/features/tasks/presentation/widgets/task_tile.dart
//
// 🎨 Widget visual para mostrar una tarea en una lista.
//
// Por qué existe este archivo:
// - Centraliza el diseño de una tarea.
// - Evita meter UI compleja en la page.
// - Permite indicar prioridad de un vistazo (color del borde izquierdo).

import 'package:flutter/material.dart';

import '../../domain/task.dart';
import '../../domain/task_priority.dart';
import '../../domain/shift.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskTile({
    super.key,
    required this.task,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = _priorityColor(task.priority);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                width: 5,
                color: borderColor,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Descripción (lo más importante)
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),

              // Información secundaria con iconos
              Row(
                children: [
                  // Máquina
                  _InfoChip(
                    icon: Icons.precision_manufacturing_rounded,
                    label: task.machine.label,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),

                  // Prioridad
                  _InfoChip(
                    icon: _priorityIcon(task.priority),
                    label: task.priority.label,
                    color: borderColor,
                  ),
                  const SizedBox(width: 8),

                  // Turno
                  _InfoChip(
                    icon: _shiftIcon(task.shift),
                    label: task.shift.label,
                    color: theme.colorScheme.secondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Color del borde según la prioridad.
  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green.shade600;
      case TaskPriority.medium:
        return Colors.orange.shade600;
      case TaskPriority.high:
        return Colors.red.shade600;
    }
  }

  /// Icono según la prioridad.
  IconData _priorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.arrow_downward_rounded;
      case TaskPriority.medium:
        return Icons.drag_handle_rounded;
      case TaskPriority.high:
        return Icons.arrow_upward_rounded;
    }
  }

  /// Icono según el turno.
  IconData _shiftIcon(Shift shift) {
    switch (shift) {
      case Shift.morning:
        return Icons.wb_sunny_rounded;
      case Shift.afternoon:
        return Icons.wb_twilight_rounded;
      case Shift.night:
        return Icons.nightlight_round;
    }
  }
}

/// Chip informativo con icono y texto.
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}