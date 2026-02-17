// lib/features/tasks/presentation/task_list_page.dart
//
// Pantalla principal: lista de tareas pendientes.
//
// Responsabilidad:
// - Cargar tareas desde el repositorio.
// - Mantener el estado del filtro actual (persistente mientras la pantalla vive).
// - Permitir crear nuevas tareas y ver detalle.
// - Abrir un bottom sheet para filtrar/ordenar y aplicar ese resultado.
//
// Nota importante (MVP):
// - El catálogo de máquinas está hardcodeado aquí para desbloquear UI/flujo.
//   Cuando exista la feature de centros/máquinas, esto debe salir de aquí
//   (repositorio o provider de estado).

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
  /// Dependencia inyectada: contrato del dominio.
  /// Esta pantalla NO debería conocer si viene de memoria, Drift o API.
  final TaskRepository taskRepository;

  const TaskListPage({
    super.key,
    required this.taskRepository,
  });

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  /// Estado UI: filtro actual aplicado en la lista.
  /// Vive en la pantalla para que persista entre aperturas del bottom sheet.
  TasksFilter _filter = TasksFilter.initial;

  /// Catálogo de máquinas del centro (temporal hardcode).
  ///
  /// Diseño elegido:
  /// - usamos `null` como opción "Todas" (útil para UI simple),
  /// - `Machine` tiene `id` (persistencia) y `label` (UI).
  ///
  /// Cuando se conecte a BBDD real:
  /// - esto debería venir de Centers/Machines repository,
  /// - y el "Todas" debería modelarse en UI sin mezclarlo con dominio (idealmente).
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
      // Acción principal: crear una tarea nueva.
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nueva tarea',
        onPressed: () async {
          // Navegamos a la pantalla de creación.
          // Al volver, hacemos setState() para recargar datos en el FutureBuilder.
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskCreatePage(
                machines: _machines.whereType<Machine>().toList(),
                taskRepository: widget.taskRepository,
              ),
            ),
          );

          // MVP: forzamos rebuild => FutureBuilder vuelve a pedir getAll().
          // Más adelante lo haremos con una función de refresh controlada.
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),

      appBar: AppBar(
        title: const Text('Tareas pendientes'),
        actions: [
          IconButton(
            tooltip: 'Filtrar y ordenar',
            // Indicador visual: si hay filtros activos, icono “relleno”.
            icon: Icon(
              _filter.hasAnyFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            onPressed: () async {
              // Abrimos el bottom sheet y esperamos un nuevo filtro.
              final result = await _openFilterSheet(
                context: context,
                current: _filter,
                machines: _machines,
              );
              if (result == null) return;

              // Persistimos el filtro en el estado de la pantalla.
              setState(() => _filter = result);
            },
          ),
        ],
      ),

      // Carga de datos:
      // - Para MVP, FutureBuilder es suficiente.
      // - Ojo: `future: getAll()` dentro de build significa que cada setState()
      //   vuelve a disparar la consulta. Lo mejoraremos luego.
      body: FutureBuilder<List<Task>>(
        future: widget.taskRepository.getAll(),
        builder: (context, snapshot) {
          // Estado: cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Estado: error
          if (snapshot.hasError) {
            return const Center(child: Text('Error cargando tareas'));
          }

          // Estado: datos (si null => lista vacía)
          final tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return const Center(child: Text('No hay tareas pendientes'));
          }

          // Transformación de datos ANTES de pintar:
          // - filtramos y ordenamos una vez,
          // - luego renderizamos únicamente lo visible.
          final visibleTasks = applyFilterAndSortTasks(tasks, _filter);

          return ListView.builder(
            itemCount: visibleTasks.length,
            itemBuilder: (context, index) {
              final task = visibleTasks[index];

              return TaskTile(
                task: task,
                onTap: () async {
                  // Abrimos detalle.
                  // Al volver, forzamos rebuild para reflejar cambios (p.ej. marcar hecha).
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
/// - Si el usuario cancela: devuelve null.
/// - Si el usuario aplica: devuelve el TasksFilter seleccionado.
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
