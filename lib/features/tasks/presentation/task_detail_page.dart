import 'package:flutter/material.dart';

import '../domain/task_repository.dart';
import '../domain/task.dart';
import '../domain/task_update.dart';
import '../domain/task_update_repository.dart';
import 'widgets/task_info_chips.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final TaskRepository taskRepository;
  final TaskUpdateRepository taskUpdateRepository;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.taskRepository,
    required this.taskUpdateRepository,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Future<List<TaskUpdate>> _updatesFuture;

  @override
  void initState() {
    super.initState();
    _loadUpdates();
  }

  void _loadUpdates() {
    _updatesFuture = widget.taskUpdateRepository.getByTask(widget.task.id);
  }

  Future<void> _addUpdate() async {
    final controller = TextEditingController();

    final text = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Añadir actualización'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Ej: Se ha tensado la banda y se deja en observación.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (text == null) return;
    final trimmed = text.trim();
    if (trimmed.length < 2) return;

    try {
      await widget.taskUpdateRepository.create(
        taskId: widget.task.id,
        message: trimmed,
      );

      if (!mounted) return;
      setState(_loadUpdates);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actualización añadida')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo añadir la actualización')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = widget.task.priority.color(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: [
          IconButton(
            tooltip: 'Añadir actualización',
            icon: const Icon(Icons.add_comment_rounded),
            onPressed: _addUpdate,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                  widget.task.description,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                TaskInfoChips(task: widget.task),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                'Creada el ${_formatDate(widget.task.createdAt)}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Text(
                'Actualizaciones',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _addUpdate,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Añadir'),
              ),
            ],
          ),

          FutureBuilder<List<TaskUpdate>>(
            future: _updatesFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final updates = snap.data ?? [];
              if (updates.isEmpty) {
                return Text(
                  'Aún no hay actualizaciones.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              }

              return Column(
                children: updates.map((u) => _UpdateCard(update: u)).toList(),
              );
            },
          ),

          const SizedBox(height: 16),

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

              await widget.taskRepository.delete(widget.task.id);

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
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $hh:$mm';
  }
}

class _UpdateCard extends StatelessWidget {
  final TaskUpdate update;

  const _UpdateCard({required this.update});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              update.message,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(update.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $hh:$mm';
  }
}