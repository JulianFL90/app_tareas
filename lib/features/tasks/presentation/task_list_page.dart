// lib/features/tasks/presentation/task_list_page.dart
//
// 📋 Pantalla principal: lista de tareas pendientes.
//
// Responsabilidad:
// - Cargar las máquinas del centro activo desde MachineRepository.
// - Cargar tareas desde TaskRepository.
// - Mantener el filtro activo mientras la pantalla vive.
// - Mostrar el nombre del centro activo en el AppBar.
// - Permitir volver al selector de centros.
// - Permitir crear nuevas tareas y ver su detalle.
// - Abrir un bottom sheet para filtrar/ordenar.

import 'package:flutter/material.dart';

import 'task_create_page.dart';
import '../domain/task_repository.dart';
import '../domain/task.dart';
import '../domain/task_list_filters.dart';
import '../domain/tasks_filter.dart';
import '../../machines/domain/machine.dart';
import '../../machines/domain/machine_repository.dart';
import 'tasks_filter_sheet.dart';
import 'widgets/task_tile.dart';
import 'task_detail_page.dart';

class TaskListPage extends StatefulWidget {
  final TaskRepository taskRepository;
  final MachineRepository machineRepository;

  /// Id del centro activo. Determina qué máquinas se cargan.
  final String centerId;

  /// Nombre del centro activo. Se muestra en el AppBar.
  final String centerName;

  /// Callback para volver al selector de centros.
  final VoidCallback onBackToSelector;

  const TaskListPage({
    super.key,
    required this.taskRepository,
    required this.machineRepository,
    required this.centerId,
    required this.centerName,
    required this.onBackToSelector,
  });

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  /// Filtro activo. Persiste mientras la pantalla vive.
  TasksFilter _filter = TasksFilter.initial;

  /// Máquinas del centro activo cargadas desde Drift.
  /// Incluye null como primera opción ("Todas") para la UI del filtro.
  late Future<List<Machine?>> _machinesFuture;

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  /// Carga las máquinas del centro activo y añade null al inicio ("Todas").
  void _loadMachines() {
    _machinesFuture = widget.machineRepository
        .getByCenter(widget.centerId)
        .then((machines) => [null, ...machines]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Machine?>>(
      future: _machinesFuture,
      builder: (context, machinesSnapshot) {
        if (machinesSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (machinesSnapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Error cargando máquinas')),
          );
        }

        final machines = machinesSnapshot.data ?? [null];

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            tooltip: 'Nueva tarea',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskCreatePage(
                    machines: machines.whereType<Machine>().toList(),
                    taskRepository: widget.taskRepository,
                  ),
                ),
              );

              setState(() => _loadMachines());
            },
            child: const Icon(Icons.add),
          ),

          appBar: AppBar(
            // Botón para volver al selector de centros.
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Cambiar de centro',
              onPressed: widget.onBackToSelector,
            ),

            // Mostramos el nombre del centro activo como título.
            title: Text(widget.centerName),

            actions: [
              // Botón de filtros.
              IconButton(
                tooltip: 'Filtrar y ordenar',
                icon: Icon(
                  _filter.hasAnyFilter
                      ? Icons.filter_alt
                      : Icons.filter_alt_outlined,
                ),
                onPressed: () async {
                  final result = await _openFilterSheet(
                    context: context,
                    current: _filter,
                    machines: machines,
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt_rounded,
                        size: 80,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay tareas pendientes',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final visibleTasks = applyFilterAndSortTasks(tasks, _filter);

              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
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
      },
    );
  }
}

/// Abre el BottomSheet de filtros y devuelve el filtro elegido.
/// Devuelve null si el usuario cancela.
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