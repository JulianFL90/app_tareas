// lib/features/tasks/data/local/machines_table.dart
//
// Tabla de máquinas/lugares.
// Cada máquina pertenece a un centro.

import 'package:drift/drift.dart';

class MachinesTable extends Table {
  // Identidad
  TextColumn get id => text()();

  // Relación: centro al que pertenece esta máquina
  TextColumn get centerId => text()();

  // Nombre visible (IRV1, Cinta Norte, etc.)
  TextColumn get label => text()();

  // Fecha de creación
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
