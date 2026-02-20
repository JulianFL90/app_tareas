// lib/features/tasks/presentation/widgets/task_info_chips.dart
//
// Chips reutilizables para mostrar info de una tarea:
// - Máquina
// - Prioridad
// - Turno
//
// Así evitamos estilos duplicados entre lista y detalle.

import 'package:flutter/material.dart';

import '../../domain/task.dart';

class TaskInfoChips extends StatelessWidget {
  final Task task;

  /// Si quieres, podemos permitir ocultar alguno en el futuro.
  final bool showMachine;
  final bool showPriority;
  final bool showShift;

  const TaskInfoChips({
    super.key,
    required this.task,
    this.showMachine = true,
    this.showPriority = true,
    this.showShift = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final priorityColor = task.priority.color(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (showMachine)
          _InfoChip(
            icon: Icons.precision_manufacturing_rounded,
            label: task.machine.label,
            color: theme.colorScheme.primary,
          ),
        if (showPriority)
          _InfoChip(
            icon: _priorityIcon(task.priority),
            label: task.priority.label,
            color: priorityColor,
          ),
        if (showShift)
          _InfoChip(
            icon: _shiftIcon(task.shift),
            label: task.shift.label,
            color: theme.colorScheme.secondary,
          ),
      ],
    );
  }

  IconData _priorityIcon(dynamic priority) {
    // priority es TaskPriority; lo dejamos dynamic para no importar de más.
    final name = priority.toString();
    if (name.endsWith('.low')) return Icons.arrow_downward_rounded;
    if (name.endsWith('.medium')) return Icons.drag_handle_rounded;
    return Icons.arrow_upward_rounded;
  }

  IconData _shiftIcon(dynamic shift) {
    // shift es Shift; lo dejamos dynamic para no importar de más.
    final name = shift.toString();
    if (name.endsWith('.morning')) return Icons.wb_sunny_rounded;
    if (name.endsWith('.afternoon')) return Icons.wb_twilight_rounded;
    return Icons.nightlight_round;
  }
}

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
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
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