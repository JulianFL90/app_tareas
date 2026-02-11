// lib/features/tasks/data/in_memory_task_repository.dart
//
// Implementación en memoria del repositorio de tareas.
//
// Por qué existe este archivo:
// - Permite avanzar rápido en el MVP sin base de datos.
// - Ideal para validar el flujo (crear/listar/cerrar) y la UI.
// - Más adelante se reemplaza por SQLite/API sin cambiar pantallas
//   gracias al contrato TaskRepository.

import 'dart:math';

import 'task_repository.dart';
import '../domain/task.dart';
import '../domain/shift.dart';

class InMemoryTaskRepository implements TaskRepository {
  final List<Task> _tasks = [];

  final Random _rng = Random();

  @override
  Future<List<Task>> getAll() async {
    // Devolvemos una copia para evitar modificaciones externas.
    return List.unmodifiable(_tasks);
  }

  @override
  Future<Task> create(Task task) async {
    // En MVP generamos id simple. En producción usarías uuid.
    final created = Task(
      id: _newId(),
      machine: task.machine,
      priority: task.priority,
      description: task.description,
      shift: task.shift,
      createdAt: DateTime.now(),
      completedAt: null,
    );

    _tasks.add(created);
    return created;
  }

  @override
  Future<Task> markDone(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) {
      throw StateError('Task not found: $taskId');
    }

    final updated = _tasks[index].markDone();
    _tasks[index] = updated;
    return updated;
  }

  String _newId() {
    // Id legible y suficientemente único para un repo en memoria.
    final millis = DateTime.now().millisecondsSinceEpoch;
    final salt = _rng.nextInt(100000).toString().padLeft(5, '0');
    return '$millis-$salt';
  }
}
