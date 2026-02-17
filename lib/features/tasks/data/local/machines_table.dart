// lib/features/tasks/data/local/machines_table.dart
//
// Tabla de máquinas.
// Cada máquina pertenece a un centro (de momento no tenemos centers aún,
// pero dejamos preparado el modelo para escalar).

import 'package:drift/drift.dart';

class MachinesTable extends Table {
  // -----------------------------
  // Identidad
  // -----------------------------
  TextColumn get id => text()();

  // -----------------------------
  // Nombre visible (IRV1, Cinta Norte, etc.)
  // -----------------------------
  TextColumn get label => text()();

  // -----------------------------
  // Fecha de creación
  // -----------------------------
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
