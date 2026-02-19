// lib/features/tasks/presentation/task_detail_page.dart
//
// Pantalla de detalle de una tarea (MVP).
// - Diseño tipo "card" con indicador de prioridad.
// - Muestra chips (máquina / prioridad / turno).
// - Muestra fecha de creación.
// - Acción: "Marcar como hecha" (borra de la BBDD local) con confirmación.

import 'package:flutter/material.dart';

import '../domain/task_repository.dart';
import '../domain/task.dart';

class TaskDetailPage extends StatelessWidget {
  final Task task;
  final TaskRepository taskRepository;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.taskRepository,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Fuente de verdad única
    final priorityColor = task.priority.color(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -----------------------------
          // Card principal
          // -----------------------------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border(left: BorderSide(width: 8, color: priorityColor)),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 8,
                  offset: Offset(0, 3),
                  color: Color(0x1A000000),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.description,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Chip(
                      icon: Icons.precision_manufacturing,
                      text: task.machine.label,
                    ),
                    _Chip(
                      icon: Icons.flag,
                      text: task.priority.label,
                    ),
                    _Chip(
                      icon: Icons.schedule,
                      text: task.shift.label,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Icon(Icons.access_time, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                'Creada el ${_formatDate(task.createdAt)}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // -----------------------------
          // Acción principal
          // -----------------------------
          FilledButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Marcar como hecha?'),
                  content: const Text(
                    'Se eliminará de la lista y de la base de datos local.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Sí, marcar'),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              await taskRepository.delete(task.id);

              if (!context.mounted) return;
              Navigator.pop(context, true);
            },
            icon: const Icon(Icons.check),
            label: const Text('Marcar como hecha'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    // dd/MM/yyyy HH:mm (sin intl, MVP)
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $hh:$mm';
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Chip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(text, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
