// lib/features/tasks/data/local/drift_task_repository.dart
//
// 📦 Implementación del repositorio de tareas usando Drift (SQLite local).
//
// Responsabilidad:
// - Cumple el contrato TaskRepository.
// - Traduce entre dominio (Task, Machine, Shift, TaskPriority)
//   y persistencia (TasksTable en SQLite).
// - Resuelve el label de la máquina consultando MachinesTable
//   en lugar de usar el id como fallback.

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
    // Usamos Future.wait porque _mapRowToDomain es async (consulta MachinesTable).
    return Future.wait(rows.map(_mapRowToDomain));
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

  /// Convierte una fila de TasksTable a dominio.
  /// Consulta MachinesTable para obtener el label real de la máquina.
  Future<Task> _mapRowToDomain(TasksTableData row) async {
    final machineRow = await db.getMachineById(row.machineId);

    // Si la máquina existe en bbdd usamos su label real.
    // Si no (dato huérfano), usamos el id en mayúsculas como fallback seguro.
    final machine = machineRow != null
        ? Machine(
      id: machineRow.id,
      centerId: machineRow.centerId,
      label: machineRow.label,
    )
        : Machine(
      id: row.machineId,
      centerId: '',
      label: row.machineId.toUpperCase(),
    );

    return Task(
      id: row.id,
      machine: machine,
      priority: TaskPriority.values.byName(row.priority),
      shift: Shift.values.byName(row.shift),
      description: row.description,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      completedAt: row.completedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(row.completedAt!),
    );
  }
}