// lib/features/tasks/domain/task_list_filters.dart
//
// Lógica de filtrado y ordenación de tareas.
//
// Por qué existe este archivo:
// - Evita meter lógica de negocio dentro de widgets (UI).
// - Centraliza el comportamiento de filtrado/ordenación en un solo sitio.
// - Hace más fácil testear y mantener.
//
// Nota importante:
// - NO accede a Flutter.
// - Solo trabaja con modelos de dominio (Task, Machine, TaskPriority) y con TasksFilter.

import 'machine.dart';
import 'task.dart';
import 'tasks_filter.dart';

/// Devuelve una NUEVA lista con:
/// - filtro aplicado (máquina / prioridades)
/// - ordenación aplicada (según TasksSort)
///
/// Importante:
/// - No muta la lista original `tasks`.
List<Task> applyFilterAndSortTasks(List<Task> tasks, TasksFilter filter) {
  // 1) Filtrado
  final filtered = tasks.where((task) {
    // --- Máquina ---
    if (filter.machine != null) {
      // Machine no implementa == / hashCode, así que comparamos por identidad lógica.
      if (!sameMachine(task.machine, filter.machine!)) return false;
    }

    // --- Prioridades ---
    if (filter.priorities.isNotEmpty) {
      if (!filter.priorities.contains(task.priority)) return false;
    }

    return true;
  }).toList();

  // 2) Ordenación (mutamos `filtered` porque YA es copia)
  filtered.sort((a, b) => compareTasks(a, b, filter.sort));
  return filtered;
}

/// Compara dos máquinas por su identidad lógica: type + number.
///
/// Esto evita depender de igualdad por referencia (instancias distintas).
bool sameMachine(Machine a, Machine b) {
  return a.type == b.type && a.number == b.number;
}

/// Comparador central de ordenación según el enum TasksSort.
int compareTasks(Task a, Task b, TasksSort sort) {
  // Para prioridad usamos el "order" que YA definiste:
  // high=0, medium=1, low=2 => más urgente primero.
  int byPriorityAsc() => a.priority.order.compareTo(b.priority.order);

  int byCreatedAtAsc() => a.createdAt.compareTo(b.createdAt);
  int byCreatedAtDesc() => b.createdAt.compareTo(a.createdAt);

  switch (sort) {
    case TasksSort.priorityThenOldest:
    // Prioridad primero; si empatan, antiguas primero.
      final prio = byPriorityAsc();
      return prio != 0 ? prio : byCreatedAtAsc();

    case TasksSort.priorityThenNewest:
    // Prioridad primero; si empatan, recientes primero.
      final prio = byPriorityAsc();
      return prio != 0 ? prio : byCreatedAtDesc();

    case TasksSort.oldestFirst:
      return byCreatedAtAsc();

    case TasksSort.newestFirst:
      return byCreatedAtDesc();
  }
}
