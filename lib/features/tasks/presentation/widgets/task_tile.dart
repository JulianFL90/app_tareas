// lib/features/tasks/presentation/widgets/task_tile.dart
//
// Widget visual para mostrar una tarea en una lista.
//
// Por qué existe este archivo:
// - Centraliza el diseño de una tarea.
// - Evita meter UI compleja en la page.
// - Permite indicar prioridad de un vistazo (color del borde).

import 'package:flutter/material.dart';

import '../../domain/task.dart';
import '../../domain/task_priority.dart';

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
    final borderColor = _priorityColor(task.priority);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              offset: Offset(0, 2),
              color: Color(0x1A000000),
            ),
          ],
          border: Border(
            left: BorderSide(
              width: 6,
              color: borderColor,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Descripción (lo más importante).
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // Información secundaria.
            Row(
              children: [
                _Chip(text: task.machine.label),
                const SizedBox(width: 8),
                _Chip(text: task.priority.label),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.amber; // 🟡
      case TaskPriority.medium:
        return Colors.orange; // 🟠
      case TaskPriority.high:
        return Colors.red; // 🔴
    }
  }
}

class _Chip extends StatelessWidget {
  final String text;

  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}
