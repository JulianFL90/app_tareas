// lib/features/tasks/domain/task_create_draft.dart
//
// Modelo simple con los datos mínimos que el usuario introduce al crear una tarea.
// No es una Task todavía (no tiene id, ni createdAt, etc.).

import '../../machines/domain/machine.dart';
import 'task_priority.dart';

class TaskCreateDraft {
  final Machine machine;
  final TaskPriority priority;
  final String description;

  const TaskCreateDraft({
    required this.machine,
    required this.priority,
    required this.description,
  });
}
