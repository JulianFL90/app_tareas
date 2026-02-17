// lib/features/tasks/data/local/drift_task_repository.dart
//
// Implementación del repositorio usando Drift (SQLite local).
//
// Importante:
// - Cumple el contrato TaskRepository.
// - Traduce entre:
//   - Dominio (Task, Machine, Shift, TaskPriority)
//   - Persistencia (TasksTable en SQLite)

import 'package:drift/drift.dart';

import '../../domain/task_repository.dart';
import '../../../machines/domain/machine.dart';
import '../../domain/shift.dart';
import '../../domain/task.dart';
import '../../domain/task_priority.dart';
import '../../../../core/data/local/app_database.dart';

class DriftTaskRepository implements TaskRepository {
  final AppDatabase db;

  DriftTaskRepository({required this.db});

  @override
  Future<List<Task>> getAll() async {
    final rows = await db.select(db.tasksTable).get();
    return rows.map(_mapRowToDomain).toList();
  }

  @override
  Future<Task> create(Task task) async {
    await db.into(db.tasksTable).insert(
      TasksTableCompanion.insert(
        id: task.id,
        machineId: task.machine.id,
        priority: task.priority.name,
        shift: task.shift.name,
        description: task.description,
        createdAt: task.createdAt.millisecondsSinceEpoch,
        completedAt: Value(task.completedAt?.millisecondsSinceEpoch),
      ),
      mode: InsertMode.insertOrReplace,
    );

    return task;
  }

  @override
  Future<Task> markDone(String taskId) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await (db.update(db.tasksTable)..where((t) => t.id.equals(taskId))).write(
      TasksTableCompanion(
        completedAt: Value(now),
      ),
    );

    final row =
    await (db.select(db.tasksTable)..where((t) => t.id.equals(taskId)))
        .getSingle();

    return _mapRowToDomain(row);
  }

  @override
  Future<void> delete(String taskId) async {
    await (db.delete(db.tasksTable)..where((t) => t.id.equals(taskId))).go();
  }

  // -----------------------------
  // Mappers (SQLite <-> Dominio)
  // -----------------------------

  Task _mapRowToDomain(TasksTableData row) {
    return Task(
      id: row.id,
      machine: Machine(
        id: row.machineId,
        centerId: '',
        label: _prettyMachineLabel(row.machineId),
      ),

      priority: TaskPriority.values.byName(row.priority),
      shift: Shift.values.byName(row.shift),
      description: row.description,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      completedAt: row.completedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.completedAt!),
    );
  }

  String _prettyMachineLabel(String machineId) {
    // Ajuste rápido para que no se vea "irv1" en UI mientras no exista MachinesTable.
    // Ejemplos:
    // - top -> TOP
    // - cfc -> CFC
    // - irv1 -> IRV1
    // - fsm3 -> FSM3
    if (machineId.isEmpty) return machineId;

    final upper = machineId.toUpperCase();
    // Por si algún día usas ids tipo "irv-1" o "IRV-1"
    return upper.replaceAll('-', '');
  }
}
