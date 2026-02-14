// lib/features/tasks/presentation/task_list_page.dart
//
// Pantalla principal: lista de tareas pendientes.
// - Muestra tareas desde el repositorio.
// - Guarda el estado del filtro actual.
// - Abre el BottomSheet para editar filtro/ordenación.
// - Aplica filtro + ordenación antes de renderizar.

import 'package:flutter/material.dart';
import 'task_create_page.dart';
import '../domain/task_repository.dart';
import '../domain/machine.dart';
import '../domain/task.dart';
import '../domain/task_list_filters.dart';
import '../domain/tasks_filter.dart';
import 'tasks_filter_sheet.dart';
import 'widgets/task_tile.dart';
import 'task_detail_page.dart';


class TaskListPage extends StatefulWidget {
  final TaskRepository taskRepository;

  const TaskListPage({
    super.key,
    required this.taskRepository,
  });

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  /// Filtro actual aplicado en la lista.
  /// Vive en la page (no en el sheet) para que persista entre aperturas.
  TasksFilter _filter = TasksFilter.initial;

  /// Catálogo de máquinas del centro (MVP hardcode).
  ///
  /// Más adelante vendrá de BBDD/repositorio, pero esta pantalla
  /// es quien debe proveer ese dato a la UI (sheet).
  final List<Machine?> _machines = const [
    null, // "Todas"
    Machine(type: MachineType.top),
    Machine(type: MachineType.cfc),
    Machine(type: MachineType.irv, number: 1),
    Machine(type: MachineType.irv, number: 2),
    Machine(type: MachineType.irv, number: 3),
    Machine(type: MachineType.irv, number: 4),
    Machine(type: MachineType.fsm, number: 1),
    Machine(type: MachineType.fsm, number: 2),
    Machine(type: MachineType.fsm, number: 3),
    Machine(type: MachineType.fsm, number: 4),
    Machine(type: MachineType.fsm, number: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nueva tarea',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskCreatePage(
                machines: _machines.whereType<Machine>().toList(),
                taskRepository: widget.taskRepository,
              ),
            ),
          );

          // Fuerza rebuild => el FutureBuilder vuelve a pedir getAll()
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Tareas pendientes'),
        actions: [
          IconButton(
            tooltip: 'Filtrar y ordenar',
            icon: Icon(
              _filter.hasAnyFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            onPressed: () async {
              final result = await _openFilterSheet(
                context: context,
                current: _filter,
                machines: _machines,
              );
              if (result == null) return;

              setState(() => _filter = result);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Task>>(
        future: widget.taskRepository.getAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error cargando tareas'));
          }

          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return const Center(child: Text('No hay tareas pendientes'));
          }

          // Aplicamos filtro + ordenación ANTES de pintar la lista.
          final visibleTasks = applyFilterAndSortTasks(tasks, _filter);

          return ListView.builder(
            itemCount: visibleTasks.length,
            itemBuilder: (context, index) {
              final task = visibleTasks[index];
              return TaskTile(
                task: task,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetailPage(
                        task: task,
                        taskRepository: widget.taskRepository,
                      ),
                    ),
                  );

                  setState(() {});
                },

              );

            },
          );
        },
      ),
    );
  }
}

/// Abre el BottomSheet y devuelve el filtro elegido por el usuario.
/// - Si el usuario cancela, devuelve null.
/// - Si pulsa "Aplicar", devuelve un TasksFilter.
Future<TasksFilter?> _openFilterSheet({
  required BuildContext context,
  required TasksFilter current,
  required List<Machine?> machines,
}) {
  return showModalBottomSheet<TasksFilter>(
    context: context,
    showDragHandle: true,
    builder: (_) => TasksFilterSheet(
      current: current,
      machines: machines,
    ),
  );
}
