import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tasks_table.dart';
import 'machines_table.dart';
import 'centers_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [TasksTable, MachinesTable, CentersTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'app_tareas'));

  @override
  int get schemaVersion => 4;
}
