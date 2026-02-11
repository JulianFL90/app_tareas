// lib/features/tasks/data/local/tasks_table.dart
//
// Definición de la tabla "tasks" para SQLite (Drift).
//
// Nota:
// - Guardamos enums como TEXT (string) para que sea legible y fácil de migrar.
// - Guardamos fechas como INTEGER (millisecondsSinceEpoch).

import 'package:drift/drift.dart';

class TasksTable extends Table {
  // -----------------------------
  // Identidad
  // -----------------------------
  TextColumn get id => text()();

  // -----------------------------
  // Máquina (la guardamos como dos campos)
  // -----------------------------
  // Ej: type="irv" y number=3  => IRV-3
  TextColumn get machineType => text()();
  IntColumn get machineNumber => integer().nullable()();

  // -----------------------------
  // Datos de la tarea
  // -----------------------------
  TextColumn get priority => text()(); // low | medium | high
  TextColumn get shift => text()(); // morning | afternoon | night
  TextColumn get description => text()();

  // -----------------------------
  // Fechas
  // -----------------------------
  IntColumn get createdAt => integer()(); // millis
  IntColumn get completedAt => integer().nullable()(); // millis o null

  @override
  Set<Column> get primaryKey => {id};
}
