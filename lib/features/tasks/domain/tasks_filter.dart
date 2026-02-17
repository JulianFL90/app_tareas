// lib/features/tasks/presentation/tasks_filter.dart
//
// Estado del filtro/ordenación para la lista de tareas.
//
// Por qué existe este archivo:
// - Representa la selección del usuario (máquina, prioridades, orden).
// - Separa la lógica de filtrado/ordenación de la UI.
// - Permite aplicar filtros sin “ensuciar” la page.

import '../../machines/domain/machine.dart';
import 'task_priority.dart';

/// Opciones de ordenación disponibles en la lista.
enum TasksSort {
  priorityThenOldest,
  priorityThenNewest,
  oldestFirst,
  newestFirst,
}

class TasksFilter {
  /// Filtrar por una máquina concreta. Si es null, no se filtra por máquina.
  final Machine? machine;

  /// Filtrar por varias prioridades. Si está vacío, no se filtra por prioridad.
  final Set<TaskPriority> priorities;

  /// Orden seleccionado.
  final TasksSort sort;

  const TasksFilter({
    this.machine,
    this.priorities = const {},
    this.sort = TasksSort.priorityThenOldest,
  });

  /// Filtro por defecto (sin filtros activos).
  static const TasksFilter initial = TasksFilter();

  bool get hasMachineFilter => machine != null;
  bool get hasPriorityFilter => priorities.isNotEmpty;

  /// Indica si hay algún filtro activo (máquina o prioridades).
  bool get hasAnyFilter => hasMachineFilter || hasPriorityFilter;

  TasksFilter copyWith({
    Machine? machine,
    bool clearMachine = false,
    Set<TaskPriority>? priorities,
    TasksSort? sort,
  }) {
    return TasksFilter(
      machine: clearMachine ? null : (machine ?? this.machine),
      priorities: priorities ?? this.priorities,
      sort: sort ?? this.sort,
    );
  }

  /// Devuelve un filtro “limpio” manteniendo solo el orden por defecto.
  TasksFilter cleared() {
    return const TasksFilter();
  }
}
