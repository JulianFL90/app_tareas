// lib/features/tasks/data/task_repository.dart
//
// Contrato (interfaz) para acceder y modificar tareas.
//
// Por qué existe este archivo:
// - Separa la lógica de la app de la forma de guardar datos.
// - Hoy lo implementaremos en memoria (rápido para MVP).
// - Mañana puede ser SQLite/API sin tocar la UI.

import '../domain/task.dart';

abstract class TaskRepository {
  /// Devuelve todas las tareas (pendientes y hechas).
  Future<List<Task>> getAll();

  /// Crea una nueva tarea y la devuelve (ya con id/fechas).
  Future<Task> create(Task task);

  /// Marca una tarea como hecha y devuelve la tarea actualizada.
  Future<Task> markDone(String taskId);
}
