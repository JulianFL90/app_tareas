// lib/features/tasks/data/local/centers_table.dart
//
// Tabla de centros.
// Free: 1 centro
// Premium: N centros

import 'package:drift/drift.dart';

class CentersTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
