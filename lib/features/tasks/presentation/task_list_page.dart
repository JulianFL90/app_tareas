// lib/features/tasks/presentation/task_list_page.dart
//
// 📋 Pantalla principal: lista de tareas pendientes.

import 'package:flutter/material.dart';

import 'task_create_page.dart';
import '../domain/task_repository.dart';
import '../domain/task.dart';
import '../domain/task_list_filters.dart';
import '../domain/tasks_filter.dart';
import '../domain/task_update_repository.dart';
import '../../machines/domain/machine.dart';
import '../../machines/domain/machine_repository.dart';
import '../../machines/presentation/machines_manager_page.dart';
import 'tasks_filter_sheet.dart';
import 'widgets/task_tile.dart';
import 'task_detail_page.dart';

class TaskListPage extends StatefulWidget {
  final TaskRepository taskRepository;
  final MachineRepository machineRepository;
  final TaskUpdateRepository taskUpdateRepository;

  final String centerId;
  final String centerName;

  final VoidCallback onBackToSelector;

  const TaskListPage({
    super.key,
    required this.taskRepository,
    required this.machineRepository,
    required this.taskUpdateRepository,
    required this.centerId,
    required this.centerName,
    required this.onBackToSelector,
  });

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  TasksFilter _filter = TasksFilter.initial;

  late Future<List<Machine?>> _machinesFuture;

  @override
  void initState() {
    super.initState();
    _loadMachines();
  }

  void _loadMachines() {
    _machinesFuture = widget.machineRepository
        .getByCenter(widget.centerId)
        .then((machines) => [null, ...machines]);
  }

  Future<void> _openMachinesManager() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MachinesManagerPage(
          machineRepository: widget.machineRepository,
          taskRepository: widget.taskRepository,
          centerId: widget.centerId,
          centerName: widget.centerName,
        ),
      ),
    );

    setState(() => _loadMachines());
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Cambiar de centro',
              onPressed: widget.onBackToSelector,
            ),
            title: Text(widget.centerName),
            actions: [
              IconButton(
                icon: const Icon(Icons.precision_manufacturing_rounded),
                tooltip: 'Gestionar máquinas',
                onPressed: _openMachinesManager,
              ),
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
                    taskUpdateRepository: widget.taskUpdateRepository, // ✅
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskDetailPage(
                            task: task,
                            taskRepository: widget.taskRepository,
                            taskUpdateRepository:
                            widget.taskUpdateRepository, // ✅
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