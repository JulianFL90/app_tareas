// lib/features/tasks/presentation/task_list_page.dart
//
// Pantalla principal: lista de tareas pendientes.
// - Muestra tareas desde el repositorio.
// - Guarda el estado del filtro actual.
// - Abre el BottomSheet para editar filtro/ordenación.
// - Aplica filtro + ordenación antes de renderizar.
//
// Nota (temporal):
// - El catálogo de máquinas sigue hardcodeado, pero YA usa el nuevo modelo:
//   Machine(id, label). Más adelante vendrá de BBDD.

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

  /// Catálogo de máquinas del centro (temporal hardcode).
  ///
  /// En el nuevo modelo, Machine tiene:
  /// - id (para guardar en BBDD)
  /// - label (para mostrar en UI)
  final List<Machine?> _machines = const [
    null, // "Todas"
    Machine(id: 'top', label: 'TOP'),
    Machine(id: 'cfc', label: 'CFC'),
    Machine(id: 'irv1', label: 'IRV1'),
    Machine(id: 'irv2', label: 'IRV2'),
    Machine(id: 'irv3', label: 'IRV3'),
    Machine(id: 'irv4', label: 'IRV4'),
    Machine(id: 'fsm1', label: 'FSM1'),
    Machine(id: 'fsm2', label: 'FSM2'),
    Machine(id: 'fsm3', label: 'FSM3'),
    Machine(id: 'fsm4', label: 'FSM4'),
    Machine(id: 'fsm5', label: 'FSM5'),
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
