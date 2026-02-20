import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tasks_table.dart';
import 'machines_table.dart';
import 'centers_table.dart';
import 'task_update_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [TasksTable, MachinesTable, CentersTable, TaskUpdatesTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'app_tareas'));

  @override
  int get schemaVersion => 5;

  /// Migraciones controladas.
  /// Venimos de schemaVersion 4 -> ahora 5 (añadimos TaskUpdatesTable).
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 5) {
        await m.createTable(taskUpdatesTable);
      }
    },
  );

  /// Devuelve todas las máquinas de un centro, ordenadas por fecha de creación.
  Future<List<MachinesTableData>> getMachinesByCenter(String centerId) {
    return (select(machinesTable)
      ..where((m) => m.centerId.equals(centerId))
      ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get();
  }

  /// Devuelve una máquina por su id. Null si no existe.
  Future<MachinesTableData?> getMachineById(String machineId) {
    return (select(machinesTable)..where((m) => m.id.equals(machineId)))
        .getSingleOrNull();
  }
}