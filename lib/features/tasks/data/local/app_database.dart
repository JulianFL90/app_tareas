// lib/features/tasks/data/local/app_database.dart
//
// Base de datos local usando Drift.
//
// Esta clase será el punto central de acceso a SQLite.
// De momento no tiene tablas. En el siguiente paso
// añadiremos la tabla de tareas.

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tasks_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [TasksTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'app_tareas'));

  // Versión del esquema.
  // Cada vez que cambiemos tablas habrá que subir este número.
  @override
  int get schemaVersion => 1;
}
